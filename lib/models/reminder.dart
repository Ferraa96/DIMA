import 'package:dima/shared/formatter.dart';
import 'package:flutter/material.dart';

class Reminder extends StatelessWidget {
  String title;
  DateTime dateTime;
  String creatorUid;

  Reminder(
      {Key? key,
      required this.title,
      required this.dateTime,
      required this.creatorUid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Formatter formatter = Formatter();
    return Container(
      margin: const EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(formatter.formatDateAndTime(dateTime)),
            ],
          ),
          //Text(AppData().group.getUserFromId(creatorUid)!.getName()),
        ],
      ),
    );
  }
}
