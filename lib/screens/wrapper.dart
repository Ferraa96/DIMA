import 'dart:math';

import 'package:dima/models/user.dart';
import 'package:dima/screens/authenticate/authenticate.dart';
import 'package:dima/screens/get_user_info.dart';
import 'package:dima/screens/home/main_page.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  Future<void> _getUserAndGroup() async {
    DatabaseService db = DatabaseService();
    AppData().user = await db.retrieveUser(AuthService().getUserId());
    AppData().group = await db.retrieveGroup(AppData().user.getUid());
    return;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(
        context); //we access user data every time we have a new value

    // if we are logged in we go to home, else we go to the authenticate screen
    if (user == null) {
      return WillPopScope(
        child: const Authenticate(),
        onWillPop: () async => false,
      );
    } else {
      // wait for the user's info to be loaded, then return home
      return FutureBuilder<void>(
        // future: db.retrieveUser(auth.getUserId()),
        future: _getUserAndGroup(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Loading();
            default:
              if (AppData().user.getGroupId() == null) {
                return const GetUserInfo();
              } else {
                return const MainPage();
              }
          }
        },
      );
    }
  }
}
