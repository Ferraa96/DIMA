import 'package:dima/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 255),
      appBar: AppBar(
        title: const Text('DIMA'),
        backgroundColor: const Color.fromARGB(255, 245, 245, 255),
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: const Icon(Icons.person),
            label: const Text('Logout'),
          )
        ],
      ),
    );
  }
}
