import 'package:flutter_web/material.dart';
import 'dart:async';
import 'dart:html';
import 'firebase_helper.dart';
import 'home.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool timeout = false;

  GlobalKey<FormState> _frmKey = GlobalKey();
  String username;
  String password;

  String namaLengkap;
  String rePassword;
  bool modeRegister = false;
  String emailValidator = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$';
  bool loading = false;

  String errorMessage;

  bool isEmailValid(String value) {
    RegExp regExp = RegExp(emailValidator);
    return !regExp.hasMatch(value);
  }

  @override
  void initState() {
    checkSession();

    super.initState();
  }

  checkSession() {
    if (window.sessionStorage["username"] != null && window.sessionStorage["username"].isNotEmpty) {
      checkUserIDExist(window.sessionStorage["username"], (exist) {
        if(exist) {
          navigateToHome(window.sessionStorage["username"]);
        } else {
          timeout = true;
          setState(() {});
        }
      });
    } else {
      Timer(Duration(seconds: 5), () {
        timeout = true;
        setState(() {});
      });
    }
  }

  processLogin() {
    _frmKey.currentState.save();
    if (_frmKey.currentState.validate()) {
      print("VALID");
      loading = true;
      errorMessage = null;
      if (modeRegister) {
        registerUser(username, password, namaLengkap, (stat, msg) {
          print(stat);
          print(msg);
          loading = false;
          errorMessage = null;
          if(!stat) {
            errorMessage = msg;
          } else {
            navigateToHome(username);
          }
          setState(() {});
        });
      } else {
        login(username, password, (stat, msg) {
          print(stat);
          print(msg);
          loading = false;
          errorMessage = null;
          if(!stat) {
            errorMessage = msg;
          } else {
            navigateToHome(username);
          }
          setState(() {});
        });
      }
    } else {
      print("IN VALID");
      loading = true;
    }
    setState(() {});
  }

  Widget createLoginForm() {
    return Form(
      key: _frmKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 400,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: loading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      errorMessage != null && errorMessage.isNotEmpty
                          ? Text(errorMessage, style: TextStyle(color: Colors.red[400]),)
                          : Container(),
                      TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Email",
                          hintText: "Email",
                        ),
                        onSaved: (value) {
                          this.username = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Email tidak boleh kosong.";
                          }
                          if (isEmailValid(value)) {
                            return "Email masih salah.";
                          }
                          return null;
                        },
                      ),
                      modeRegister
                          ? TextFormField(
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: "Nama Lengkap",
                                hintText: "Nama Lengkap",
                              ),
                              validator: (value) {
                                return modeRegister && value.isEmpty
                                    ? "Nama lengkap tidak boleh kosong"
                                    : null;
                              },
                              onSaved: (value) {
                                this.namaLengkap = value;
                              },
                            )
                          : Container(),
                      TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Password",
                          hintText: "Password",
                        ),
                        obscureText: true,
                        validator: (value) {
                          return value.length < 8
                              ? "Password tidak boleh kurang dari 8"
                              : null;
                        },
                        onSaved: (value) {
                          this.password = value;
                        },
                      ),
                      modeRegister
                          ? TextFormField(
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: "Password lagi",
                                hintText: "Password lagi",
                              ),
                              obscureText: true,
                              validator: (value) {
                                return value == this.password
                                    ? null
                                    : "Password tidak sama";
                              },
                              onSaved: (value) {
                                this.rePassword = value;
                              },
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          modeRegister
                              ? Expanded(
                                  child: Container(
                                    alignment: Alignment.bottomLeft,
                                    child: InkWell(
                                      onTap: () {
                                        modeRegister = false;
                                        setState(() {});
                                      },
                                      child: Text(
                                        "< Kembali",
                                        style: TextStyle(
                                            color: Colors.lightBlueAccent),
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: MaterialButton(
                                    onPressed: () {
                                      modeRegister = true;
                                      setState(() {});
                                    },
                                    color: Colors.lightBlueAccent,
                                    child: Text(
                                      "REGISTER",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                          Container(
                            width: 30,
                          ),
                          Expanded(
                            child: MaterialButton(
                              onPressed: processLogin,
                              color: Colors.lightBlueAccent,
                              child: Text(
                                modeRegister ? "DAFTAR" : "LOGIN",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "BOOTH.y",
                  style: TextStyle(fontSize: 60),
                ),
                Text(
                  "Sebuah Aplikasi komunitas untuk fast buku tamu",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: timeout ? createLoginForm() : Container(),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Text("© 2019 - hayi.nkm@gmail.com"),
          ),
        ],
      ),
    );
  }

  void navigateToHome(String username) {
    window.sessionStorage["username"] = username;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(username,)));
  }
}
