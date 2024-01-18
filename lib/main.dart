import 'package:flutter/material.dart';
import 'package:tweet_scope/Auth/Login.dart';
import 'package:tweet_scope/Auth/SignUp.dart';
import 'package:tweet_scope/Dash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (MaterialApp(home: HomePage()));
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Login(),
        routes: {
          "Login": (context) => Login(),
          "SignUp": (context) => SignUp(),
          "Dash": (context) => Dashboard(),
          "ListUser": (context) => ListUser(),
        });
  }
}
