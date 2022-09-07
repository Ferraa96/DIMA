
// flutter test --no-sound-null-safety integration_test/app_test.dart

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:dima/shared/constants.dart';
import 'package:dima/main.dart' as app;

const String EMAIL = 'prova12@gmail.com';
const String PASSWORD = 'prova12';
const String USERNAME = 'prova';
const String FIRSTUSER = 'Fra';
const String GROUP_CODE = 'DXfJSt';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized ();



  group ('SIGN IN => ', (){

    testWidgets ('EMAIL AND PASSWORD', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      // trova TextFormField "email" e "password" e inserisce i dati
      final Finder fields = find.byType(TextFormField);
      expect(fields, findsWidgets);
      Finder fields_email = fields.at(0);
      Finder fields_password = fields.at(1);
      await tester.enterText(fields_email, EMAIL);
      await tester.enterText(fields_password, PASSWORD);

      // trova il Sign In button e lo clicka
      final Finder buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
      Finder buttons_signin = buttons.at(0);
      await tester.tap(buttons_signin);

      //carica pagina Home
      await tester.pumpAndSettle();
    });

  });



  group('HOME => ', (){
  
    testWidgets('ELEMENTS', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      expect(find.text('Welcome back, '+USERNAME), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Dates'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
    });

    testWidgets('USER', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      final Finder users = find.byType(ElevatedButton);
      Finder first_user = users.at(0);
      await tester.tap(first_user);
      await Future.delayed(const Duration(milliseconds: 500), (){});
      expect(find.byType(Image), findsWidgets);
      expect(find.text(FIRSTUSER), findsWidgets);
      await tester.tapAt(Offset(0, 0));
      await Future.delayed(const Duration(milliseconds: 500), (){});
    });
    
    testWidgets('ADD USER', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      final Finder add = find.byIcon(Icons.add);
      expect(add, findsOneWidget);
      await tester.tap(add);
      await Future.delayed(const Duration(milliseconds: 500), (){});
      expect(find.text(GROUP_CODE), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
      final Finder close = find.text('Close');
      expect(close, findsOneWidget);
      await tester.tap(close);
      await Future.delayed(const Duration(milliseconds: 500), (){});
    });
    
    testWidgets('SETTINGS GENERAL CHECK', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      final Finder settings = find.byIcon(Icons.settings);
      expect(settings, findsOneWidget);
      await tester.tap(settings);
      await Future.delayed(const Duration(milliseconds: 500), (){});
      expect(find.byType(Image), findsWidgets);
      expect(find.text(USERNAME), findsWidgets);
      await tester.tapAt(Offset(0, 0));
      await Future.delayed(const Duration(milliseconds: 500), (){});
    });
    /*
    testWidgets('SETTINGS CHANGE USERNAME', (tester) async {  // NOT WORKING !!!!!!!!!!!!!!!!
      await app.main();
      await tester.pumpAndSettle();
      
      final Finder settings = find.byIcon(Icons.settings);
      expect(settings, findsOneWidget);
      await tester.tap(settings);
      await Future.delayed(const Duration(milliseconds: 500), (){});
      await tester.tap(find.byIcon(Icons.edit), warnIfMissed: false);
      await Future.delayed(const Duration(milliseconds: 500), (){});
      print(find.byType(TextFormField));
      await tester.enterText(find.byType(TextFormField), 'ABCD'); // DOESN'T FIND "TEXTFORMFIELD" => PIXEL OVERFLOW PROBLEM => COLUMN
      await Future.delayed(const Duration(milliseconds: 500), (){});
      await tester.tap(find.byIcon(Icons.check));
      await tester.tapAt(Offset(0, 0));
      await Future.delayed(const Duration(milliseconds: 500), (){});
      expect(find.text('Welcome back, ABCD'), findsOneWidget);

      await tester.tap(settings);
      await Future.delayed(const Duration(milliseconds: 500), (){});
      await tester.tap(find.byIcon(Icons.edit), warnIfMissed: false);
      await tester.enterText(find.byType(TextFormField), USERNAME); // DOESN'T FIND "TEXTFORMFIELD"
      await tester.tap(find.byIcon(Icons.check));
      await tester.tapAt(Offset(0, 0));
      await Future.delayed(const Duration(milliseconds: 500), (){});
      expect(find.text('Welcome back, '+USERNAME), findsOneWidget);
    });
    */
    testWidgets('LOG OUT & LOG IN', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await Future.delayed(const Duration(seconds: 3), (){});
      final Finder logout = find.text('Logout');
      expect(logout, findsOneWidget);
      await tester.tap(logout, warnIfMissed: false);
      await Future.delayed(const Duration(seconds: 2), (){});
      final Finder yes = find.text('Yes');
      expect(yes, findsOneWidget);
      await tester.tap(yes, warnIfMissed: false);
      await tester.pumpAndSettle();

      final Finder fields = find.byType(TextFormField);
      expect(fields, findsWidgets);
      Finder fields_email = fields.at(0);
      Finder fields_password = fields.at(1);
      await tester.enterText(fields_email, EMAIL);
      await tester.enterText(fields_password, PASSWORD);
      final Finder buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
      Finder buttons_signin = buttons.at(0);
      await tester.tap(buttons_signin);
      await tester.pumpAndSettle();
    });
    
  });



  group ('CHAT => ', (){

    testWidgets('ENTER THE PAGE', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      final Finder chat_icon = find.byIcon(Icons.chat_rounded);
      expect(chat_icon, findsOneWidget);
      await tester.tap(chat_icon);
      await tester.pumpAndSettle();
    });

  });



}


