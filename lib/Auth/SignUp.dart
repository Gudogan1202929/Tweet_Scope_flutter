import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

void main() => runApp(MaterialApp(home: SignUp()));

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 900;

    if (isPhone) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
        ),
        body: SignUpForm(),
      );
    } else {
      return Scaffold(
        body: Row(children: [
          Expanded(
            flex: 1,
            child: Container(
                color: Colors.blue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Center(
                          child: Text(
                            'TweetScope',
                            style: TextStyle(
                              fontSize: 32,
                              fontFamily: "NotoSerif",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Text(
                          "TweetScope is an application that shows you insights into the analysis of tweets published on Twitter and gives those who want to browse an idea of the most talked about topics and a visualization of some classifications.",
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "NotoSerif",
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 3,
                        child: Container(
                          child: Image(image: AssetImage("images/pic1.png")),
                        ))
                  ],
                )),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: SignUpForm(),
            ),
          ),
        ]),
      );
    }
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'User';
  var _response2 = http.Response('', 200);

  Future _signUp() async {
    final userData = {
      "username": _emailController.text,
      "password": encryptPassword(_passwordController.text),
      "role": _selectedRole
    };

    final jsonData = jsonEncode(userData);

    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/account/signup');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/account/signup');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/account/signup');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/account/signup');
    }

    _response2 = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json; charset=UTF-8",
        "X-Forwarded-For": "192.168.1.100",
      },
      body: jsonData,
    );

    if (_response2.statusCode == 200) {
      showSuccessDialog();
    } else if (_response2.statusCode == 409) {
      showErrorDialog('Username is already taken');
    } else {
      showErrorDialog('An error occurred during registration');
    }
  }

  String encryptPassword(String password) {
    final keyText = 'GXBD91tMbO47qkExaDLuOVU6K4fEu0V8';
    final ivText = 'MyIV012345678910';

    final keyBytes = utf8.encode(keyText);
    final ivBytes = utf8.encode(ivText);

    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV(Uint8List.fromList(ivBytes));

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(password, iv: iv);
    final encryptedText = encrypted.base64;

    return encryptedText;
  }

  void showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.SCALE,
      title: 'Success',
      desc: 'Registration successful!',
      dismissOnTouchOutside: false,
      btnOkOnPress: () {
        Navigator.of(context).pushReplacementNamed("Login");
      },
    )..show();
  }

  void showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.SCALE,
      title: 'Error',
      desc: message,
      dismissOnTouchOutside: false,
      btnOkOnPress: () {},
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image(
                          image: AssetImage("images/twitter.png"), height: 200),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!EmailValidator.validate(value)) {
                            return 'Invalid email format';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          hintText: 'At least 8 characters',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                          });
                        },
                        items: <String>['User', 'Admin'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signUp();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Color.fromARGB(255, 57, 134, 197),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "NotoSerif",
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
