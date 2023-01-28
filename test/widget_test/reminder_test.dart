// flutter test --no-sound-null-safety test/widget_test/reminder_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima/models/reminder.dart';
import 'package:dima/models/group.dart';
import 'package:dima/models/user.dart';
import 'package:dima/shared/formatter.dart';

List<MyUser> users = [
  (){final u=MyUser(); u.setUserId('Aa'); u.setName('Aa'); return u;}(),
  (){final u=MyUser(); u.setUserId('Bb'); u.setName('Bb'); return u;}(),
  (){final u=MyUser(); u.setUserId('Cc'); u.setName('Cc'); return u;}(),
];
Group group = (){final g=Group(); g.setGroupCode('GroupCode'); g.setMembers(users); return g;}();
String title = 'Reminder';
DateTime dateTime = DateTime(10, 10, 10, 10, 10);


void main() {

  testWidgets('WIDGET_TEST => Reminder Class', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(home: Reminder(
      title: title,
      dateTime: dateTime,
      creatorUid: users[0].getUid(),
      group: group, 
    )));

    expect(find.textContaining(title), findsOneWidget);
    expect(find.textContaining(Formatter().formatDateAndTime(dateTime)), findsOneWidget);
    expect(find.textContaining('Created by ${users[0].getUid()}'), findsOneWidget);
    
  });

}

