// ignore_for_file: prefer_const_constructors, sort_child_properties_last, library_private_types_in_public_api

import 'package:date_app/api/service.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/views/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

    @override
  void initState() {
    super.initState();
    _getStoredCredentials();
  }

    void _getStoredCredentials() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  User.userName = prefs.getString('userName');
  User.password = prefs.getString('password');
  if (!mounted) return;
  if (User.userName != null && User.password != null) {
      await checkUser(context);     
  } 
  else if (User.userName != null) {
    setState(() {
      _usernameController.text = User.userName!;
    });
  }
   
}

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
              Expanded(flex: 3, child: Align(alignment: Alignment.bottomLeft, child: Text("Giriş Yapmanız\nGerekmekte!", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),))),
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kullanıcı Adı", style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),
                        TextField(
                          onChanged: (value) {
                            User.userName = value;
                          },
                          cursorColor: Colors.black,
                          controller: _usernameController,
                          decoration: InputDecoration(
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
                            hintText: 'Kullanıcı adınızı girin...',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Şifre", style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),
                        TextField(
                          onChanged: (value) {
                            User.password = value;
                          },
                          controller: _passwordController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: 'Şifrenizi girin...',
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
                          ),
                          obscureText: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        await checkUser(context);
                      },
                      child: Text('Giriş Yap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
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
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Hesabınız mı yok?"),
                    GestureDetector(
                      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => Register(),)),
                      child: Text(" Kayıt olun", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
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