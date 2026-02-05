// ignore_for_file: prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:date_app/api/service.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/views/login_page.dart';
import 'package:date_app/views/main_page.dart';
import 'package:date_app/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_EN', null);
  runApp(
    MultiProvider(
      providers: [
      ChangeNotifierProvider(create: (_) => MemoryProvider()),
      ],
      child: const MyApp(),
    )
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

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    Login.userToken = token;

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _token = null;
        _loading = false;
      });
      return;
    }
    await checkUser(context);

    if (!mounted) return;

    setState(() {
      _token = token;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return  Scaffold(
        body: Center(child: Image.asset("assets/images/el.png")),
      );
    }

    if (_token != null &&
        _token!.isNotEmpty &&
        Login.isTokenValid == true) {
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade800),
      ),
      home: const AuthGate(),
    );
  }
}