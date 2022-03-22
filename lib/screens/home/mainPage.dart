import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dima/screens/home/home.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  late String groupId;
  int index = 0;

  final screens = [
    Home(),
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(
        Icons.home,
        size: 30,
      ),
      const Icon(
        Icons.chat,
        size: 30,
      ),
      const Icon(
        Icons.shopping_bag,
        size: 30,
      ),
      const Icon(
        Icons.settings,
        size: 30,
      )
    ];
    return Scaffold(
      body: screens[0],
      extendBody: true,
      bottomNavigationBar: CurvedNavigationBar(
        key: navigationKey,
        animationDuration: const Duration(milliseconds: 300),
        color: Colors.orangeAccent,
        backgroundColor: Colors.transparent,
        height: MediaQuery.of(context).size.height / 14,
        index: index,
        items: items,
        onTap: (index) => setState(() {
          this.index = index;
        }),
      ),
    );
  }
}
