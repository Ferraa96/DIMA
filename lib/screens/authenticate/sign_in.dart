import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/constants.dart';
import 'package:dima/shared/loading.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  const SignIn({Key? key, required this.toggleView}) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
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
                        'Register',
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
                          'Sign in',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        TextFormField(
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
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          cursorColor: Colors.orangeAccent,
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Password'),
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
                        const SizedBox(
                          height: 20.0,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              dynamic result = await auth
                                  .signInWithEmailAndPass(email, password);
                              if (result == null) {
                                setState(() {
                                  error = 'Could not sign in';
                                  loading = false;
                                });
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
                            'Sign in',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        const Text(
                          'Sign in with social account',
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
                                  DatabaseService db = DatabaseService();
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
                                String email = await auth.signInWithTwitter();
                                setState(() {
                                  error = email;
                                  loading = false;
                                });
                                /*
                                if (email == '') {
                                  setState(() {
                                    error = 'Could not sign in';
                                    loading = false;
                                  });
                                } else {
                                  DatabaseService db = DatabaseService();
                                  db.registerUser(
                                      auth.getUser()!.getUid(), email);
                                }
                                */
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                fixedSize: const Size(30, 30),
                                shape: const CircleBorder(),
                              ),
                              child: Image.asset('assets/logos/facebook.png'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          error,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 14.0),
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
