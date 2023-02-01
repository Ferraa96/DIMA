import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/constants.dart';
import 'package:dima/shared/loading.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({Key? key, required this.toggleView}) : super(key: key);

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  final DatabaseService db = DatabaseService();

  //text field state
  String email = '';
  String password = '';
  String confirmPass = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    AuthService auth = AuthService();
    return loading
        ? const Loading()
        : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 1.0),
                colors: [Color(0xffeef2f3), Colors.white],
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: <Widget>[
                  TextButton.icon(
                      onPressed: () {
                        widget.toggleView();
                      },
                      icon: const Icon(
                        Icons.person,
                        color: Colors.blueGrey,
                      ),
                      label: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.blueGrey,
                        ),
                      ))
                ],
              ),
              body: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Form(
                  key: _formKey, //track the state of the form and validates it
                  child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 60.0,
                      ),
                      SizedBox(
                        width: width > height ? width / 2 : width,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.orangeAccent,
                          decoration:
                              textInputDecoration.copyWith(hintText: 'Email'),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Enter an email';
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      SizedBox(
                        width: width > height ? width / 2 : width,
                        child: TextFormField(
                          cursorColor: Colors.orangeAccent,
                          decoration:
                              textInputDecoration.copyWith(hintText: 'Password'),
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return 'Enter a password of at least 6 characters';
                            } else {
                              return null;
                            }
                          },
                          obscureText: true,
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      SizedBox(
                        width: width > height ? width / 2 : width,
                        child: TextFormField(
                          cursorColor: Colors.orangeAccent,
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Repeat password'),
                          validator: (val) {
                            if (password.length < 6) {
                              return 'Enter a password of at least 6 characters';
                            } else if (val == null || val != password) {
                              return 'The password does not match';
                            } else {
                              return null;
                            }
                          },
                          obscureText: true,
                          onChanged: (val) {
                            setState(() {
                              confirmPass = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            if (await auth.registerWithEmailAndPass(
                                    email, password) ==
                                false) {
                              setState(() {
                                error = 'The email is not valid';
                                loading = false;
                              });
                            } else {
                              db.registerUser(auth.getUser()!.getUid(), email);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          shadowColor: Colors.black54,
                          minimumSize: const Size(120, 40),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                      const Text(
                        'Sign up with social account',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              String email = await auth.signInWithGoogle();
                              if (email == '') {
                                setState(() {
                                  error = 'Could not sign in';
                                  loading = false;
                                });
                              } else {
                                db.registerUser(
                                    auth.getUser()!.getUid(), email);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              fixedSize: const Size(30, 30),
                              shape: const CircleBorder(),
                            ),
                            child: Image.asset(
                              'assets/logos/google.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              if (await auth.signInWithTwitter() == false) {
                                setState(() {
                                  error = 'Could not sign in';
                                  loading = false;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              fixedSize: const Size(30, 30),
                              shape: const CircleBorder(),
                            ),
                            child: Image.asset('assets/logos/twitter.png'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        error,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ),
          );
  }
}
