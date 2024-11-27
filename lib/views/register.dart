// ignore_for_file: prefer_const_constructors

import 'package:date_app/api/service.dart';
import 'package:date_app/global/variables.dart';
import 'package:date_app/views/login.dart';
import 'package:date_app/widgets/show_dialogs/show_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context),),
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(flex: 2, child: Align(alignment: Alignment.bottomLeft, child: Text("Kayıt Olmak İçin Bilgilerinizi Giriniz!", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),))),
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
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            RegisterUser.userName = value;
                          },
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Kullanıcı adınızı girin...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black, // Tıklama durumunda kenar rengi
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey, // Normal durumda kenar rengi
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
                        Text("Şifre", style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),
                        TextField(
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            RegisterUser.password = value;
                          },
                          controller: _passwordController,
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
                    SizedBox(height: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Şifre Tekrar", style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),
                        TextField(
                          cursorColor: Colors.black,
                          controller: _passwordAgainController,
                          decoration: InputDecoration(
                            hintText: 'Şifrenizi tekrar girin...',
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
                    SizedBox(height: 40.0),
                    ElevatedButton(
                      onPressed: () async {
                        if(_usernameController.text.isEmpty){
                          errorMessage(context, "Kullanıcı adı boş olamaz");
                        }
                        else if(_passwordAgainController.text.isEmpty || _passwordController.text.isEmpty){
                          errorMessage(context, "Şifreler boş olamaz");
                        }
                        else if (_passwordController.text != _passwordAgainController.text){
                          errorMessage(context, "Şifreler uyuşmuyor!");
                        }  else if (_passwordController.text == _passwordAgainController.text){
                          await register(context);
                        } else{
                          errorMessage(context, "Beklenmedik hata");
                        }
                      },
                      child: Text('Kayıt Ol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), // Burada köşe yarıçapını belirliyoruz
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
                    Text("Hesabınız var mı?"),
                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (context) => LoginPage(),), (route) => false,),
                      child: Text(" Giriş Yapın", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)),
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