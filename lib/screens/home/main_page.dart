import 'package:dima/screens/home/chat_page.dart';
import 'package:dima/screens/home/dates.dart';
import 'package:dima/screens/home/home.dart';
import 'package:dima/screens/home/payments_page.dart';
import 'package:dima/services/notification_services.dart';
import 'package:dima/shared/themes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late String groupId;
  int index = 0;
  late Image myImg;
  late String myName;
  late FirebaseNotificationListener _messagingWidget;

  void callback(bool isDark) {
    setState(() {
      ThemeProvider().toggleTheme(isDark);
    });
  }

  List<Widget> screens() => [
        Home(
          callback: callback,
        ),
        const ChatPage(),
        const PaymentsPage(),
        const Dates(),
      ];

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage();

    _messagingWidget = FirebaseNotificationListener();
    _messagingWidget.initiateListening();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = screens();

    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        label: 'Home',
        icon: Icon(
          Icons.home,
          size: 20,
        ),
        activeIcon: Icon(
          Icons.home,
          size: 30,
        ),
      ),
      const BottomNavigationBarItem(
        label: 'Chat',
        icon: Icon(
          Icons.chat_rounded,
          size: 20,
        ),
        activeIcon: Icon(
          Icons.chat_rounded,
          size: 30,
        ),
      ),
      const BottomNavigationBarItem(
        label: 'Payments',
        icon: Icon(
          Icons.attach_money,
          size: 20,
        ),
        activeIcon: Icon(
          Icons.attach_money,
          size: 30,
        ),
      ),
      const BottomNavigationBarItem(
        label: 'Dates',
        icon: Icon(
          Icons.calendar_today_rounded,
          size: 20,
        ),
        activeIcon: Icon(
          Icons.calendar_today_outlined,
          size: 30,
        ),
      ),
    ];
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        return MaterialApp(
          themeMode: ThemeProvider.themeMode,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          home: Scaffold(
            body: pages[index],
            extendBody: false,
            bottomNavigationBar: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.black54,
              items: items,
              currentIndex: index,
              unselectedFontSize: 10,
              selectedFontSize: 15,
              showUnselectedLabels: true,
              onTap: (index) {
                if (this.index != index) {
                  setState(() {
                    this.index = index;
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }
}
