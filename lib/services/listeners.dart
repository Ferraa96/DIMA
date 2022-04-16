import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/reminder.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/shared/loading.dart';
import 'package:flutter/material.dart';

class Listeners {
  late Widget _reminders;
  late List messages;

  void startListening() {
    _reminders = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reminders')
          .doc(AppData().user.getGroupId())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.data() == null) {
            return const Center(
              child: Text('You have no reminders'),
            );
          }
          List list = List.from(snapshot.data!.data()!['reminders']);
          return Container(
            margin: const EdgeInsets.only(bottom: 80),
            child: Scrollbar(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  Reminder reminder = Reminder(
                    title: list[index]['title'],
                    dateTime: (list[index]['dateTime'] as Timestamp).toDate(),
                    creatorUid: list[index]['creator'],
                  );
                  return reminder;
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 5,
                  );
                },
                itemCount: list.length,
              ),
            ),
          );
        }
        return const Loading();
      },
    );
  }

  Widget getReminders() {
    return _reminders;
  }
}
