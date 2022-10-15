
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

      expect(find.widgetWithText(Center, 'Welcome back, '+USERNAME), findsOneWidget);
      expect(find.widgetWithText(BottomNavigationBar, 'Home'), findsOneWidget);
      expect(find.widgetWithText(BottomNavigationBar, 'Chat'), findsOneWidget);
      expect(find.widgetWithText(BottomNavigationBar, 'Payments'), findsOneWidget);
      expect(find.widgetWithText(BottomNavigationBar, 'Dates'), findsOneWidget);
      expect(find.widgetWithText(BottomNavigationBar, 'Shopping'), findsOneWidget);
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
      expect(find.widgetWithIcon(IconButton, Icons.copy), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.share), findsOneWidget);
      final Finder close = find.widgetWithText(ElevatedButton, 'Close');
      expect(close, findsOneWidget);
      await tester.tap(close);
      await Future.delayed(const Duration(milliseconds: 500), (){});
    });
    
    testWidgets('SETTINGS GENERAL CHECK', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      final Finder settings = find.widgetWithIcon(IconButton, Icons.settings);
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

      await tester.tap(find.widgetWithIcon(IconButton, Icons.settings));
      await Future.delayed(const Duration(seconds: 3), (){});
      final Finder logout = find.widgetWithText(ElevatedButton, 'Logout');
      expect(logout, findsOneWidget);
      await tester.tap(logout, warnIfMissed: false);
      await Future.delayed(const Duration(seconds: 2), (){});
      final Finder yes = find.widgetWithText(ElevatedButton, 'Yes');
      expect(yes, findsOneWidget);
      await tester.tap(yes, warnIfMissed: false);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), EMAIL);
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), PASSWORD);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
      await tester.pumpAndSettle();
    });
        
  });



  group ('CHAT => ', (){

    testWidgets('ELEMENTS', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.chat_rounded);

      expect(find.widgetWithIcon(IconButton, Icons.add), findsOneWidget);
      expect(find.widgetWithText(TextField, "Write message..."), findsOneWidget);
      expect(find.widgetWithIcon(FloatingActionButton, Icons.send), findsOneWidget);
    });

    testWidgets('SEND MESSAGE', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      await enterPage (tester, Icons.chat_rounded);

      String message = getRandom(40);
      expect (find.text(message), findsNothing);
      await tester.enterText(find.widgetWithText(TextField, "Write message..."), message);
      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.send));
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
    
    testWidgets('ADD/REMOVE PAYMENTS', (tester) async {
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

    testWidgets('ADD/REMOVE REMINDER', (tester) async {
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

    testWidgets('ADD/REMOVE PRODUCTS', (tester) async {
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


