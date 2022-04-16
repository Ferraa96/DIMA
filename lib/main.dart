import 'package:dima/models/user.dart';
import 'package:dima/screens/wrapper.dart';
import 'package:dima/services/auth.dart';
import 'package:dima/shared/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //LocalNotificationService.initialize();
  await Firebase.initializeApp();
  /*
  FirebaseMessaging.onBackgroundMessage((message) async {
    print(message.data.toString());
  });
  */
  SharedPreferences prefs = await SharedPreferences.getInstance();
  switch (prefs.get('night_mode')) {
    case null:
      ThemeProvider.themeMode = ThemeMode.system;
      break;
    case true:
      ThemeProvider.themeMode = ThemeMode.dark;
      break;
    default:
      ThemeProvider.themeMode = ThemeMode.light;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const Wrapper(),
        },
      ),
    );
  }
}
