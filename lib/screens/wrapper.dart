import 'package:dima/models/user.dart';
import 'package:dima/screens/authenticate/authenticate.dart';
import 'package:dima/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(
        context); //we access user data every time we have a new value

    //if we are logged in we go to home, else we go to the authenticate screen
    if (user == null) {
      return const Authenticate();
    } else {
      return Home();
    }
  }
}
