import 'package:dima/screens/home/main_page.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GetUserInfo extends StatelessWidget {
  const GetUserInfo({Key? key}) : super(key: key);

  Widget _joinGroupPopup(BuildContext context) {
    String groupId = '';
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 3,
          maxHeight: height / 3,
        ),
        child: Column(
          children: [
            SizedBox(
              height: height / 50,
            ),
            const Text('Enter the code your friends gave you'),
            SizedBox(
              height: height / 50,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: width / 30,
                ),
                const Text('Group code: '),
                SizedBox(
                  width: width / 30,
                ),
                Flexible(
                  child: TextField(
                    onChanged: (value) => groupId = value,
                  ),
                ),
                SizedBox(
                  width: width / 30,
                ),
              ],
            ),
            SizedBox(
              height: height / 10,
            ),
            ElevatedButton(
              onPressed: () async {
                if (groupId.length == 6) {
                  DatabaseService db = DatabaseService();
                  bool joined =
                      await db.joinGroup(AuthService().getUserId(), groupId);
                  if (joined) {
                    Navigator.of(context).pop(true);
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Please provide a valid group code',
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  }
                }
              },
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String name = '';
    bool activate = false;
    DatabaseService db = DatabaseService();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 255),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 60,
          ),
          const Text(
            'Welcome to Housie',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 40.0,
          ),
          const Text('Enter your name'),
          const SizedBox(
            height: 20.0,
          ),
          TextFormField(
            decoration: textInputDecoration.copyWith(hintText: 'Name'),
            onChanged: (val) {
              name = val;
              activate = val.isNotEmpty;
            },
          ),
          const SizedBox(
            height: 40.0,
          ),
          const Text('Your friends have created a group?'),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            onPressed: () {
              if (activate) {
                showGeneralDialog(
                  barrierLabel: 'join',
                  barrierDismissible: true,
                  context: context,
                  pageBuilder: (ctx, a1, a2) {
                    return Container();
                  },
                  transitionBuilder: (ctx, a1, a2, child) {
                    var curve = Curves.easeInOut.transform(a1.value);
                    return Transform.scale(
                      scale: curve,
                      child: _joinGroupPopup(ctx),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ).then((value) {
                  if (value == true) {
                    AuthService auth = AuthService();
                    db.updateUserName(auth.getUserId(), name);
                    AppData().user.setName(name);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainPage(
                                  user: AppData().user,
                                  group: AppData().group,
                                )));
                  }
                });
              } else {
                Fluttertoast.showToast(
                  msg: 'Please insert your name',
                  toastLength: Toast.LENGTH_SHORT,
                );
              }
            },
            child: const Text('Join group'),
          ),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            onPressed: () async {
              if (activate) {
                AuthService auth = AuthService();
                db.updateUserName(auth.getUserId(), name);
                await db.createGroup(auth.getUserId());
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainPage(
                              user: AppData().user,
                              group: AppData().group,
                            )));
              } else {
                Fluttertoast.showToast(
                  msg: 'Please insert your name',
                  toastLength: Toast.LENGTH_SHORT,
                );
              }
            },
            child: const Text('Create a new group'),
          ),
        ],
      ),
    );
  }
}
