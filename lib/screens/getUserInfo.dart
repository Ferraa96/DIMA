import 'package:dima/screens/home/home.dart';
import 'package:dima/screens/qr_scan.dart';
import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GetUserInfo extends StatelessWidget {
  Widget _joinGroupPopup(BuildContext context) {
    String groupId = '';
    return Dialog(
      child: Container(
        child: Column(
          children: [
            Row(
              children: <Widget>[
                const Text('Group code: '),
                Flexible(
                  child: TextField(
                    onChanged: (value) => groupId = value,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Join'),
            ),
            const SizedBox(
              height: 40.0,
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Use QR code'),
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
      appBar: AppBar(
        title: const Text(
          'DIMA',
          style: TextStyle(color: Colors.greenAccent),
        ),
        backgroundColor: const Color.fromARGB(255, 245, 245, 255),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          const Text(
            'Welcome',
            style: TextStyle(color: Colors.greenAccent),
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
                );
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
            onPressed: () {
              if (activate) {
                AuthService auth = AuthService();
                db.addUserName(auth.getUserId(), name);
                db.createGroup(auth.getUserId());
                Navigator.of(context).pushNamed('/home');
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
