
// flutter test --no-sound-null-safety integration_test/app_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:dima/shared/constants.dart';

import 'package:dima/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized ();

  group('PAGES TESTS', () {

    testWidgets('SIGN IN WITH EMAIL', (tester) async {

      await app.main();
      await tester.pumpAndSettle();
      
      //trova TextFormField "email" e "password" e inserisce i dati
      final Finder fields = find.byType(TextFormField);
      expect(fields, findsWidgets);
      Finder fields_email = fields.at(0);
      Finder fields_password = fields.at(1);
      await tester.enterText(fields_email, 'prova12@gmail.com');
      await tester.enterText(fields_password, 'prova12');

      //trova il Sign In button e lo clicka
      final Finder buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
      Finder buttons_signin = buttons.at(0);
      await tester.tap(buttons_signin);

      //carica pagina Home
      await tester.pumpAndSettle();

    });

  });

}

