import 'package:dima/services/auth.dart';
import 'package:dima/shared/constants.dart';
import 'package:dima/shared/loading.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({required this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String email = '';
  String password = '';
  String confirm_pass = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: const Color.fromARGB(255, 245, 245, 255),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 245, 245, 255),
              elevation: 0.0,
              actions: <Widget>[
                TextButton.icon(
                    onPressed: () {
                      widget.toggleView();
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('Sign in'))
              ],
            ),
            body: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Form(
                    key:
                        _formKey, //track the state of the form and validates it
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(hintText: 'Email'),
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
                          decoration: textInputDecoration.copyWith(hintText: 'Password'),
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
                        TextFormField(
                          decoration:
                              textInputDecoration.copyWith(hintText: 'Repeat password'),
                          validator: (val) {
                            if(password.length < 6) {
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
                              confirm_pass = val;
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
                              dynamic result = await _auth
                                  .registerWithEmailAndPass(email, password);
                              if (result == null) {
                                setState(() {
                                  error = 'The email is not valid';
                                  loading = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            shadowColor: Colors.black,
                            minimumSize: const Size(120, 40),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        const Text(
                          'Sign up with social account',
                          style: TextStyle(color: Colors.teal),
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
                                dynamic result = await _auth.signInWithGoogle();
                                if (result == null) {
                                  setState(() {
                                    error = 'Could not sign in';
                                    loading = false;
                                  });
                                }
                              },
                              child: Image.asset('assets/logos/google.png', width: 30, height: 30,),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                fixedSize: const Size(30, 30),
                                shape: const CircleBorder(),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                dynamic result = await _auth.signInWithFacebook();
                                if (result == null) {
                                  setState(() {
                                    error = 'Could not sign in';
                                    loading = false;
                                  });
                                }
                              },
                              child: Image.asset('assets/logos/facebook.png'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                fixedSize: const Size(30, 30),
                                shape: const CircleBorder(),
                              ),
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
                    ))),
          );
  }
}
