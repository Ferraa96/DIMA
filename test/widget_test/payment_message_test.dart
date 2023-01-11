// flutter test --no-sound-null-safety test/widget_test/payment_message_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima/models/payment_message.dart';
import 'package:dima/models/group.dart';
import 'package:dima/models/user.dart';

List<MyUser> users = [
  (){final u=MyUser(); u.setUserId('Aa'); u.setName('Aa'); return u;}(),
  (){final u=MyUser(); u.setUserId('Bb'); u.setName('Bb'); return u;}(),
  (){final u=MyUser(); u.setUserId('Cc'); u.setName('Cc'); return u;}(),
];
Group group = (){final g=Group(); g.setGroupCode('GroupCode'); g.setMembers(users); return g;}();
String title = 'Spesa';
String timestamp = '01/01/1001';
double amount = 150;


void main() {

  testWidgets('WIDGET_TEST => PaymentMessage Class', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(home: Payment(
      title: title,
      amount: amount,
      date: timestamp,
      payedBy: users[0].getUid(),
      payedTo: [users[1].getUid()],
      group: group
    )));

    expect(find.textContaining(title), findsOneWidget);
    expect(find.textContaining(timestamp), findsOneWidget);
    expect(find.textContaining(users[0].getName()), findsOneWidget);
    expect(find.textContaining(' payed '), findsOneWidget);
    expect(find.textContaining(amount.toString() + ' € to '), findsOneWidget);
    expect(find.textContaining(users[1].getName()), findsOneWidget);

  });


}

