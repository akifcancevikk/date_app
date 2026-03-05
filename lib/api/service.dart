// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:date_app/api/api.dart';
import 'package:date_app/core/app_strings.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/models/memory_model.dart';
import 'package:date_app/pages/login_page.dart';
import 'package:date_app/pages/main_page.dart';
import 'package:date_app/providers/memory_provider.dart';
import 'package:date_app/widgets/show_dialogs/show_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class _ApiCallResult {
  final int statusCode;
  final Map<String, dynamic> body;
  final bool fromCache;

  _ApiCallResult({
    required this.statusCode,
    required this.body,
    required this.fromCache,
  });
}

String _cacheScope() {
  return Login.email ?? LoginVariables.email ?? "guest";
}

String _cacheKey(String endpoint) {
  return "${_cacheScope()}::$endpoint";
}

Map<String, dynamic> _decodeBodyMap(String raw) {
  if (raw.trim().isEmpty) return {"ok": true};
  final decoded = jsonDecode(raw);
  if (decoded is Map<String, dynamic>) return decoded;
  return {"data": decoded};
}

String _extractMessage(Map<String, dynamic> body, {String fallback = "Error"}) {
  final msg = body['message'];
  if (msg is String && msg.isNotEmpty) return msg;
  return fallback;
}

Future<_ApiCallResult?> _callJsonWithCache({
  required String endpoint,
  required Future<http.Response> Function() call,
}) async {
  try {
    final response = await call();
    final body = _decodeBodyMap(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await CacheService.save(_cacheKey(endpoint), body);
    }

    return _ApiCallResult(
      statusCode: response.statusCode,
      body: body,
      fromCache: false,
    );
  } catch (_) {
    final cached = await CacheService.load(_cacheKey(endpoint));
    if (cached is Map<String, dynamic>) {
      return _ApiCallResult(statusCode: 200, body: cached, fromCache: true);
    }
    return null;
  }
}

Future<_ApiCallResult?> _callStreamWithCache({
  required String endpoint,
  required Future<http.StreamedResponse> Function() call,
}) async {
  try {
    final streamedResponse = await call();
    final rawBody = await streamedResponse.stream.bytesToString();
    final body = _decodeBodyMap(rawBody);

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      await CacheService.save(_cacheKey(endpoint), body);
    }

    return _ApiCallResult(
      statusCode: streamedResponse.statusCode,
      body: body,
      fromCache: false,
    );
  } catch (_) {
    final cached = await CacheService.load(_cacheKey(endpoint));
    if (cached is Map<String, dynamic>) {
      return _ApiCallResult(statusCode: 200, body: cached, fromCache: true);
    }
    return null;
  }
}

// Handle login flow and persist token on success.
Future<void> login(BuildContext context) async {
  final result = await _callJsonWithCache(
    endpoint: "auth/login/${LoginVariables.email}",
    call: () => Api.login(LoginVariables.email!, LoginVariables.password!),
  );

  if (result == null) {
    errorMessage(context, AppStrings.loginError);
    return;
  }

  if (result.statusCode == 200) {
    final userData = result.body;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', userData['token'] ?? '');
    await prefs.setString(
        'email', userData['email'] ?? LoginVariables.email ?? '');
    Login.userToken = userData['token'];
    Login.email = userData['email'] ?? LoginVariables.email;
    if (!context.mounted) return;
    Login.isTokenValid = true;
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (context) => const MainPage()),
      (route) => false,
    );
  } else {
    errorMessage(context, _extractMessage(result.body));
  }
}

// Handle user registration flow.
Future<void> register(BuildContext context) async {
  final result = await _callJsonWithCache(
    endpoint: "auth/register/${RegisterVariables.email}",
    call: () => Api.register(
      RegisterVariables.email!,
      RegisterVariables.password!,
      RegisterVariables.passwordConfirmation!,
      RegisterVariables.name!,
    ),
  );

  if (result == null) {
    errorMessage(context, AppStrings.loginError);
    return;
  }

  if (result.statusCode == 200) {
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  } else {
    errorMessage(context, _extractMessage(result.body));
  }
}

// Validate stored token and mark auth state.
Future<void> checkUser(BuildContext context) async {
  final result = await _callJsonWithCache(
    endpoint: "user/check",
    call: Api.checkUser,
  );

  if (result == null) {
    Login.isTokenValid = false;
    return;
  }

  if (result.statusCode == 200) {
    Login.isTokenValid = true;
  } else {
    Login.isTokenValid = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}

// Clear local session and return to login screen.
Future<void> logout(BuildContext context, WidgetRef ref) async {
  final result = await _callJsonWithCache(
    endpoint: "auth/logout",
    call: Api.logout,
  );

  if (!context.mounted) return;
  if (result != null && result.statusCode == 200) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');
    Login.userName = null;
    Login.email = null;
    Login.userToken = null;
    ref.read(memoriesProvider.notifier).reset();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  } else {
    if (!context.mounted) return;
    errorMessage(
        context,
        result == null
            ? AppStrings.logoutFailed
            : _extractMessage(result.body));
  }
}

Future<void> fetchMemories(WidgetRef ref, {bool isRefresh = false}) async {
  final notifier = ref.read(memoriesProvider.notifier);
  final s = ref.read(memoriesProvider);

  if (isRefresh) {
    notifier.reset();
  } else {
    if (!s.hasNextPage || s.isLoadingMore) return;
    notifier.setLoadingMore(true);
  }

  final page = isRefresh ? 1 : ref.read(memoriesProvider).currentPage;
  final response = await Api.getMemories(page: page);

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (body['data']['data'] as List)
        .map((e) => MemoryModel.fromJson(e))
        .toList();

    final hasNext = body['data']['next_page_url'] != null;

    if (isRefresh) {
      notifier.setFirstPage(list, hasNext);
    } else {
      notifier.appendPage(list, hasNext);
    }
  } else {
    notifier.setLoadingMore(false);
  }
}

Future<void> createMemory(BuildContext context, WidgetRef ref) async {
  final title = Memory.memoryName?.trim();
  final rating = Memory.memoryRating;

  if (title == null || title.isEmpty || rating == null) {
    errorMessage(context, AppStrings.createFailed);
    return;
  }

  final result = await _callJsonWithCache(
    endpoint: "memories/create",
    call: () => Api.create(title, rating),
  );

  if (result != null && result.statusCode >= 200 && result.statusCode < 300) {
    final body = result.body;
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final newMemory = MemoryModel.fromJson(data);
      ref.read(memoriesProvider.notifier).addMemory(newMemory);
      if (!result.fromCache) {
        successMessage(context, AppStrings.placeAdded);
      }
      return;
    }
  }

  errorMessage(
    context,
    result == null ? AppStrings.createFailed : _extractMessage(result.body),
  );
}

Future<void> updateMemory(BuildContext context, WidgetRef ref) async {
  final id = MemoryUpdate.memoryId;
  final title = MemoryUpdate.memoryName?.trim();
  final rating = MemoryUpdate.memoryRating;

  if (id == null || title == null || title.isEmpty || rating == null) {
    errorMessage(context, AppStrings.updateFailed);
    return;
  }

  final result = await _callJsonWithCache(
    endpoint: "memories/update/$id",
    call: () => Api.updateMemory(title, rating, id),
  );

  if (result != null && result.statusCode >= 200 && result.statusCode < 300) {
    final body = result.body;
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final updatedMemory = MemoryModel.fromJson(data);
      ref.read(memoriesProvider.notifier).updateMemory(updatedMemory);
      return;
    }
  }

  errorMessage(
    context,
    result == null ? AppStrings.updateFailed : _extractMessage(result.body),
  );
}

Future<void> deleteMemory( BuildContext context, WidgetRef ref, int id) async {
  final result = await _callJsonWithCache(
    endpoint: "memories/delete/$id",
    call: () => Api.deleteMemory(id),
  );

  if (result != null && result.statusCode >= 200 && result.statusCode < 300) {
    final body = result.body;
    final data = body['data'];
    final deletedId = data is Map<String, dynamic> ? data['id'] as int? : null;
    ref.read(memoriesProvider.notifier).removeMemoryById(deletedId ?? id);
    return;
  }

  errorMessage(
    context,
    result == null ? AppStrings.deleteFailed : _extractMessage(result.body),
  );
}

Future<MemoryModel?> updateNote(BuildContext context, WidgetRef ref, int id, List<String> notes,) async {
  final result = await _callJsonWithCache(
    endpoint: "memories/$id/notes/update",
    call: () => Api.updateNote(id, notes),
  );

  if (result != null && result.statusCode >= 200 && result.statusCode < 300) {
    final updatedMemory = MemoryModel.fromJson(result.body['data']);
    ref.read(memoriesProvider.notifier).updateMemory(updatedMemory);
    return updatedMemory;
  } else {
    if (result != null) {
      errorMessage(context, _extractMessage(result.body));
    }
    return null;
  }
}

Future<MemoryModel?> updateDetail(BuildContext context, WidgetRef ref, int id, List<String> notes,) async {
  final result = await _callJsonWithCache(
    endpoint: "memories/$id/notes/detail",
    call: () => Api.updateNote(id, notes),
  );

  if (result != null && result.statusCode >= 200 && result.statusCode < 300) {
    final updatedMemory = MemoryModel.fromJson(result.body['data']);
    ref.read(memoriesProvider.notifier).updateMemory(updatedMemory);
    return updatedMemory;
  } else {
    return null;
  }
}

Future<MemoryModel?> updateImage(BuildContext context, WidgetRef ref, int id, List<File> images,) async {
  final result = await _callStreamWithCache(
    endpoint: "memories/$id/image/upload",
    call: () => Api.updateImage(id, images),
  );

  if (result != null && result.statusCode >= 200 && result.statusCode < 300) {
    final updatedMemory = MemoryModel.fromJson(result.body['data']);
    ref.read(memoriesProvider.notifier).updateMemory(updatedMemory);
    return updatedMemory;
  } else {
    if (result != null) {
      errorMessage(context, _extractMessage(result.body));
    }
    return null;
  }
}

Future<MemoryModel?> deleteImage(BuildContext context, WidgetRef ref, int id, String imageName,  List<String> notes,) async {
  final result = await _callJsonWithCache(
    endpoint: "memories/$id/image/$imageName/delete",
    call: () => Api.deleteImage(id, imageName, notes),
  );

  if (result != null && result.statusCode >= 200 && result.statusCode < 300) {
    final updatedMemory = MemoryModel.fromJson(result.body['data']);
    ref.read(memoriesProvider.notifier).updateMemory(updatedMemory);
    return updatedMemory;
  } else {
    if (result != null) {
      errorMessage(context, _extractMessage(result.body));
    }
    return null;
  }
}

class CacheService {
  static Future<void> save(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<dynamic> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<void> clearScope(String scope) async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith("$scope::")).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
