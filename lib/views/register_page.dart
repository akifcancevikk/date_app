// ignore_for_file: prefer_const_constructors
import 'package:date_app/api/service.dart';
import 'package:date_app/core/app_strings.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/views/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController = TextEditingController();
  bool isPasswordVisible = false;
  bool isPasswordConfirmationVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16,50,16,16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex: 2, child: Align(alignment: Alignment.bottomLeft, child: Text(AppStrings.registerTitle, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),))),
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
                            cursorColor: Colors.black,
                            onChanged: (value) {
                              RegisterVariables.email = value;
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.blankEmail;
                              }
                              if (!value.contains('@')) {
                                return AppStrings.invalidEmail;
                              }
                              return null;
                            },
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: AppStrings.email,
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.username, style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          TextFormField(
                            cursorColor: Colors.black,
                            onChanged: (value) {
                              RegisterVariables.name = value;
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.blankUsername;
                              }
                              return null;
                            },
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: AppStrings.username,
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.password, style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          TextFormField(
                            cursorColor: Colors.black,
                            onChanged: (value) {
                              RegisterVariables.password = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.blankPassword;
                              }
                              return null;
                            },
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: AppStrings.password,
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
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
                            obscureText: !isPasswordVisible,
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.passwordAgain, style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          TextFormField(
                            cursorColor: Colors.black,
                            controller: _passwordAgainController,
                            onChanged: (value) {
                              RegisterVariables.passwordConfirmation = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.blankPassword;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: AppStrings.passwordAgain,
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordConfirmationVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordConfirmationVisible = !isPasswordConfirmationVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !isPasswordConfirmationVisible,
                          ),
                        ],
                      ),
                      SizedBox(height: 40.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await register(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(200, 50),
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(AppStrings.registerButton, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
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
                    Text(AppStrings.haveAccount),
                    SizedBox(width: 5,),
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => LoginPage(),), (route) => false,),
                      child: Text(AppStrings.loginButton, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
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