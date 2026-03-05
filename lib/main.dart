// ignore_for_file: prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:io';
import 'package:date_app/api/service.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/pages/login_page.dart';
import 'package:date_app/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() async {
  // Ensure Flutter bindings are initialized before async setup.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize date formatting used across the app.
  await initializeDateFormatting('en_EN', null);
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _token;
  bool _loading = true;
  bool _canOpenMain = false;

  @override
  void initState() {
    super.initState();
    // Check persisted auth state on first load.
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Load token from local storage and validate it with the backend.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    Login.userToken = token;

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _token = null;
        _canOpenMain = false;
        _loading = false;
      });
      return;
    }

    final hasInternet = await _hasInternetConnection();

    if (hasInternet) {
      await checkUser(context);
      _canOpenMain = Login.isTokenValid == true;
    } else {
      // Offline mode: if token exists locally, allow entering app.
      _canOpenMain = true;
    }

    if (!mounted) return;

    setState(() {
      _token = token;
      _loading = false;
    });
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return  Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Image.asset("assets/images/el.png")),
      );
    }

    // Route to main app when token is valid, otherwise show login.
    if (_token != null && _token!.isNotEmpty && _canOpenMain) {
      return const MainPage();
    }

    return const LoginPage();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: child,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade800),
      ),
      home: const AuthGate(),
    );
  }
}
