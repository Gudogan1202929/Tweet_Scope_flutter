import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _userName = '';
  String _password = '';
  final _formKey = GlobalKey<FormState>();
  var _response2 = http.Response('', 200);
  String ipAddress = 'IP address not found';

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // Method to save user email and password
  Future<void> saveUserPreferences(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  // Method to retrieve user email and password
  Future<void> loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    print(email);
    print(password);
    if (email != null) {
      setState(() {
        _emailController.text = email;
      });
    }

    if (password != null) {
      setState(() {
        _passwordController.text = password;
      });
    }
  }

  Future _Login() async {
    ipAddress = await getIpAddress();
    print('Device IP Address: $ipAddress');

    final userData = {
      "username": _userName,
      "password": encryptPassword(_password),
    };

    final jsonData = jsonEncode(userData);
    print("object + $jsonData");
    print(ipAddress);

    var url;

    if (kIsWeb) {
      // Code specific to web or Chrome
      print("Chrome or web");
      url = Uri.parse('http://127.0.0.1:9096/account/login');
    } else if (Platform.isAndroid) {
      // Android-specific code
      print("Android");
      url = Uri.parse('http://10.0.2.2:9096/account/login');
    } else if (Platform.isIOS) {
      // iOS-specific code
      print("iOS");
      url = Uri.parse('http://localhost:9096/account/login');
    } else {
      // Fallback for other platforms
      print("Other");
      url = Uri.parse('http://127.0.0.1:9096/account/login');
    }

    _response2 = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json; charset=UTF-8",
        "X-Forwarded-For": ipAddress,
      },
      body: jsonData,
    );

    print("--------------------------------------------------------------");

    if (_response2.statusCode == null) {
      Center(child: CircularProgressIndicator());
    } else if (_response2.statusCode == 200) {
      saveUserPreferences(_userName, _password);
      final token = _response2.body;
      Navigator.of(context).pushReplacementNamed("ListUser", arguments: token);
    } else {
      return AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error while login',
        desc: 'Username or Password wrong',
        btnOkOnPress: () {},
        btnOkColor: Colors.red,
      )..show();
    }
  }

  Future<String> getIpAddress() async {
    if (kIsWeb) {
      try {
        final response =
            await http.get(Uri.parse('https://api.ipify.org?format=json'));
        if (response.statusCode == 200) {
          final ipAddress = jsonDecode(response.body)['ip'];
          return ipAddress;
        }
      } catch (e) {
        print('Error getting IP address: $e');
      }
      return 'IP address not found';
    } else {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type.name.toLowerCase() == 'ipv4') {
            return addr.address;
          }
        }
      }
      return 'IP address not found';
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

  @override
  void initState() {
    super.initState();
    loadUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 900 ||
        MediaQuery.of(context).size.height < 660;

    if (isPhone) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            padding: EdgeInsets.symmetric(vertical: 50),
            margin: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      "Tweet Scoup",
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: "Anton",
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Image(image: AssetImage("images/twitter.png"), height: 200),
                  ],
                ),
                Text(
                  "TweetScope is an application that shows you insights into the analysis of tweets published on Twitter and gives those who want to browse an idea of the most talked about topics and a visualization of some classifications.",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: "NotoSerif",
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _userName = value ?? '';
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value ?? '';
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(fontFamily: "NotoSerif"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed("SignUp");
                            },
                            child: Text("Register Now"),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _Login();
                          }
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "NotoSerif",
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(150, 50),
                          backgroundColor: Color.fromARGB(255, 57, 134, 197),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 1300,
              minHeight: 1300,
            ),
            child: Scaffold(
              body: Row(children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.blue,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Text(
                                'Tweet Scope',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 20),
                              Image(
                                image: AssetImage("images/twitter.png"),
                                height: 200,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        Container(
                          child: Column(
                            children: [
                              Text(
                                "Supervisor:",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage("images/mos.png"),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Dr. Mostafa jarar",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                            child: Column(
                          children: [
                            Text(
                              "Created by :",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 40),
                                    Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundImage:
                                                AssetImage("images/buir.png"),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Mohammad Buirat",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundImage:
                                                AssetImage("images/mosleh.png"),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Mohammad Mosleh",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundImage:
                                                AssetImage("images/anan.png"),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "Mohammad anan",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            )
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to Tweet Scope!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'TweetScope is an application that shows you insights into the analysis of tweets published on Twitter and gives those who want to browse an idea of the most talked-about topics and a visualization of some classifications.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.name,
                                        decoration: InputDecoration(
                                          hintText: "Email",
                                          prefixIcon: Icon(Icons.email),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter an email';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _userName = value ?? '';
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      TextFormField(
                                        controller: _passwordController,
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          hintText: "Password",
                                          prefixIcon: Icon(Icons.lock),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a password';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          _password = value ?? '';
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Don't have an account?",
                                            style: TextStyle(
                                                fontFamily: "NotoSerif"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pushNamed("SignUp");
                                            },
                                            child: Text("Register Now"),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();
                                            _Login();
                                          }
                                        },
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "NotoSerif",
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(150, 50),
                                          backgroundColor:
                                              Color.fromARGB(255, 57, 134, 197),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ),
              ]),
            ),
          );
        },
      );
    }
  }
}
