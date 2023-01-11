// flutter test --no-sound-null-safety test/widget_test/chat_message_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima/models/chat_message.dart';
import 'package:dima/shared/formatter.dart';
import 'package:dima/models/group.dart';
import 'package:dima/models/user.dart';

List<MyUser> users = [
  (){final u=MyUser(); u.setUserId('Aa'); u.setName('Aa'); return u;}(),
  (){final u=MyUser(); u.setUserId('Bb'); u.setName('Bb'); return u;}(),
  (){final u=MyUser(); u.setUserId('Cc'); u.setName('Cc'); return u;}(),
];
Group g = (){final g=Group(); g.setGroupCode('GroupCode'); g.setMembers(users); return g;}();
String message = 'Ciao';
DateTime timestamp = DateTime(10,10,10,10,10);


void main() {

  group('WIDGET_TEST => ChatMessage Class => ', () {

    testWidgets('Sender message', (WidgetTester tester) async {

      await tester.pumpWidget(MaterialApp(home: ChatMessage(
        senderId: users[0].getUid(), 
        timestamp: timestamp, 
        hasMedia: false, 
        messageContent: message,
        group: g,
        user: users[0],
      )));

      expect(find.textContaining(message), findsOneWidget);
      expect(find.textContaining( Formatter().formatTime(TimeOfDay.fromDateTime(timestamp))) , findsOneWidget);
      
    });

    testWidgets('Receiver message', (WidgetTester tester) async {

      await tester.pumpWidget(MaterialApp(home: ChatMessage(
        senderId: users[1].getUid(), 
        timestamp: timestamp, 
        hasMedia: false, 
        messageContent: message,
        group: g,
        user: users[0],
      )));

      expect(find.textContaining(message), findsOneWidget);
      expect(find.textContaining( Formatter().formatTime(TimeOfDay.fromDateTime(timestamp))) , findsOneWidget);
      expect(find.textContaining(users[1].getName()), findsOneWidget);
      
    });

  });

}

