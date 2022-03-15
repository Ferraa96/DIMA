import 'package:dima/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _buildPopupDialog(BuildContext context) {
    return Dialog(
      child: Container(
        child: Column(
          children: [
            const Text('Ciao'),
            const Text('Ciaone'),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                Navigator.of(context).pop();
              },
              child: const Text('Logout'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Chiudi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 245, 255),
        appBar: AppBar(
          title: const Text(
            'DIMA',
            style: TextStyle(color: Colors.greenAccent),
          ),
          backgroundColor: const Color.fromARGB(255, 245, 245, 255),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                showGeneralDialog(
                  barrierLabel: 'account',
                  barrierDismissible: true,
                  context: context,
                  pageBuilder: (ctx, a1, a2) {
                    return Container();
                  },
                  transitionBuilder: (ctx, a1, a2, child) {
                    var curve = Curves.easeInOut.transform(a1.value);
                    return Transform.scale(
                      scale: curve,
                      child: _buildPopupDialog(ctx),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                );
              },
              icon: const Icon(Icons.person),
              color: Colors.greenAccent,
            ),
          ],
        ),
        body: Container(),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                ),
                child: Text('Boh'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
