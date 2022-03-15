import 'package:dima/services/auth.dart';
import 'package:flutter/material.dart';

class EnterGroup extends StatelessWidget {
  final AuthService auth;
  EnterGroup({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Welcome ' + auth.getUser()!.getName() + 'enter in a group to start'),
        ],
      ),
    );
  }
}
