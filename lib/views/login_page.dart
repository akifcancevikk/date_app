// ignore_for_file: prefer_const_constructors, sort_child_properties_last, library_private_types_in_public_api
import 'package:date_app/api/service.dart';
import 'package:date_app/core/app_strings.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/views/register_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

    @override
  void initState() {
    super.initState();
    _getStoredCredentials();
  }

  void _getStoredCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Login.email = prefs.getString('email');
    if (Login.email != null) {
      setState(() {
        _emailController.text = Login.email!;
        LoginVariables.email = Login.email!;
      });
    }
  }

  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: Align(alignment: Alignment.bottomLeft, child: Text(AppStrings.loginTitle, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),))),
              Expanded(
                flex: 10,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.email, style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Colors.black,
                            onChanged: (value) => LoginVariables.email = value.trim(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.blankEmail;
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return AppStrings.invalidEmail;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                              hintText: AppStrings.email,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.password,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !isPasswordVisible,
                            cursorColor: Colors.black,
                            onChanged: (value) => LoginVariables.password = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.blankPassword;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: AppStrings.password,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          await login(context);
                        },
                        child: Text(AppStrings.loginButton, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(200, 50),
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.register),
                    SizedBox(width: 5,),
                    GestureDetector(
                      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => RegisterPage(),)),
                      child: Text(AppStrings.registerButton, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}