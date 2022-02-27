import 'package:dima/screens/home/home.dart';
import 'package:flutter/material.dart';

class FakeHome extends StatelessWidget {
  const FakeHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxHeight / constraints.maxWidth < 0.7) {
        print("if\tRatio: " +
            (constraints.maxHeight / constraints.maxWidth).toString());
        return Home();
      } else {
        print("else\tRatio: " +
            (constraints.maxHeight / constraints.maxWidth).toString());
        return Home();
      }
    });
  }
}
