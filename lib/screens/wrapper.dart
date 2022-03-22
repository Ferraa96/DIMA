import 'package:dima/models/user.dart';
import 'package:dima/screens/authenticate/authenticate.dart';
import 'package:dima/screens/getUserInfo.dart';
import 'package:dima/screens/home/home.dart';
import 'package:dima/screens/home/home.dart';
import 'package:dima/screens/home/mainPage.dart';
import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(
        context); //we access user data every time we have a new value

    // if we are logged in we go to home, else we go to the authenticate screen
    if (user == null) {
      return WillPopScope(
        child: Authenticate(),
        onWillPop: () async => false,
      );
    } else {
      // wait for the user's info to be loaded, then return home
      AuthService auth = AuthService();
      DatabaseService db = DatabaseService();
      return FutureBuilder<MyUser>(
        future: db.retrieveUser(auth.getUserId()),
        builder: (context, snapshot) {
          MyUser? myUser = snapshot.data;
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Loading();
            default:
              if (myUser!.getGroupId() == null) {
                return GetUserInfo();
              } else {
                return MainPage();
              }
          }
        },
      );
    }
  }
}
