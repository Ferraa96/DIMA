import 'package:dima/shared/formatter.dart';
import 'package:flutter/material.dart';
import 'package:dima/models/group.dart';

class Reminder extends StatelessWidget {
  String title;
  DateTime dateTime;
  String creatorUid;
  Group group;
  Reminder({
    Key? key,
    required this.title,
    required this.dateTime,
    required this.creatorUid,
    required this.group,
  }) : super(key: key);

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
              Expanded(child: Text(title)),
              Expanded(child: Text(formatter.formatDateAndTime(dateTime))),
            ],
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Created by ${group.getUserFromId(creatorUid)!.getName()}',
            ),
          ),
        ],
      ),
    );
  }
}
