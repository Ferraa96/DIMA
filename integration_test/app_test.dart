
// flutter test --no-sound-null-safety integration_test/app_test.dart

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:dima/shared/constants.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/src/material/date_picker.dart';
import 'package:dima/main.dart' as app;

const String EMAIL = 'prova12@gmail.com';
const String PASSWORD = 'prova12';
const String USERNAME = 'Zeno';
const List <String> USERS = ['Franco', 'Anna', 'Zeno'];
const String GROUP_CODE = 'DXfJSt';

Future enterPage (WidgetTester tester, IconData icon) async {
  final Finder finder_icon = find.byIcon(icon);
  expect(finder_icon, findsOneWidget);
  await tester.tap(finder_icon);
  await tester.pumpAndSettle();
}

String getRandom(int length){
        const ch = '''AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890!"£%&/()=?^'ìè+òàù,.-é*ç°§;:_{}''';
        Random r = Random();
        return String.fromCharCodes(Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
      }



void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized ();
 


  group ('SIGN IN => ', (){

    testWidgets ('EMAIL AND PASSWORD', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      final Finder email = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(email, EMAIL);
      final Finder password = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(password, PASSWORD);

      // trova il Sign In button e lo clicka
      final Finder button = find.widgetWithText(ElevatedButton, 'Sign in');
      expect(button, findsWidgets);
      await tester.tap(button);

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
      expect(find.text(USERS.first), findsWidgets);
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

    testWidgets('ELEMENTS', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.chat_rounded);

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text("Write message..."), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('SEND MESSAGE', (tester) async {  // PRODUCES A WARNING
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.chat_rounded);

      String message = getRandom(40);
      expect (find.text(message), findsNothing);
      await tester.enterText(find.byType(TextField), message);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
    });

  });



  group ('PAYMENTS => ', (){
  
    testWidgets('ELEMENTS', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.attach_money);

      expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Add payment'));
      await tester.pumpAndSettle();
      expect(find.text('Add payment'), findsNWidgets(2));
      expect(find.widgetWithIcon(ElevatedButton, Icons.check), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Title'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Amount'), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.calendar_today_outlined), findsOneWidget);
      expect(find.text('Payed by'), findsOneWidget);
      expect(find.text('To whom'), findsOneWidget);
      expect(find.text('Select all'), findsOneWidget);
    });
    
    testWidgets('ADD/REMOVE PAYMENTS', (tester) async { // PRODUCES A WARNING
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.attach_money);

      String title = getRandom(15);
      expect(find.widgetWithText(Container, title), findsNothing);
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Title'), title);
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '300');
      await tester.tap(find.byType(Checkbox).first);
      await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.check));
      await tester.pumpAndSettle();
      final Finder payment = find.widgetWithText(Container, title).first;
      expect(payment, findsOneWidget);

      final Finder list = find.byIcon(Icons.list);
      expect(list, findsOneWidget);
      final Finder graph = find.byIcon(Icons.auto_graph);
      expect(graph, findsOneWidget);
      await tester.tap(graph);
      expect(find.byType(ListView), findsOneWidget);
      await tester.tap(list);

      await tester.longPress(payment, warnIfMissed: false);
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(Container, title), findsNothing);
    });
    
  });



  group ('DATES => ', (){

    testWidgets('ELEMENTS', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.calendar_today_rounded);

      await tester.tap(find.widgetWithText(FloatingActionButton, 'Add reminder'));
      await tester.pumpAndSettle();
      expect(find.text('Add reminder'), findsNWidgets(2));
      expect(find.widgetWithIcon(ElevatedButton, Icons.check), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Title'), findsOneWidget);
    });

    testWidgets('ADD/REMOVE REMINDER', (tester) async { // PRODUCES A WARNING
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.calendar_today_rounded);

      String title = getRandom(15);
      expect(find.widgetWithText(Container, title), findsNothing);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Add reminder'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Title'), title);
      await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.check));
      await tester.pumpAndSettle();
      final Finder reminder= find.widgetWithText(Container, title).first;
      expect(reminder, findsOneWidget);

      await tester.longPress(reminder, warnIfMissed: false);
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(Container, title), findsNothing);
    });

  });



  group ('PAYMENTS => ', (){

    testWidgets('ELEMENTS', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.shopping_cart_outlined);

      expect(find.widgetWithIcon(FloatingActionButton, Icons.add), findsOneWidget);
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Add product'));
      await tester.pumpAndSettle();
      expect(find.text('Add product'), findsNWidgets(2));
      expect(find.widgetWithIcon(ElevatedButton, Icons.check), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Product'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Quantity'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Unit'), findsOneWidget);
    });

    testWidgets('ADD/REMOVE PRODUCTS', (tester) async { // PRODUCES A WARNING
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.shopping_cart_outlined);

      String product = getRandom(15);
      expect(find.widgetWithText(Container, product), findsNothing);
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Product'), product);
      await tester.enterText(find.widgetWithText(TextField, 'Quantity'), '10');
      await tester.enterText(find.widgetWithText(TextField, 'Unit'), '#');
      await tester.tap(find.widgetWithIcon(ElevatedButton, Icons.check));
      await tester.pumpAndSettle();
      final Finder item = find.widgetWithText(Container, product).first;
      expect(item, findsOneWidget);

      await tester.longPress(item, warnIfMissed: false);
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(Container, product), findsNothing);
    });

  });



}


