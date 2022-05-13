import 'package:badges/badges.dart';
import 'package:dima/main.dart';
import 'package:dima/screens/home/chat_page.dart';
import 'package:dima/screens/home/dates.dart';
import 'package:dima/screens/home/home.dart';
import 'package:dima/screens/home/paymentsPage.dart';
import 'package:dima/screens/home/shopping_page.dart';
import 'package:dima/services/listeners.dart';
import 'package:dima/shared/themes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  List<int> badges = [0, 0, 0, 0, 0];
  late Listeners listeners;

  void callback(bool isDark) {
    setState(() {
      ThemeProvider().toggleTheme(isDark);
    });
  }

  void moveToPage(int index) {
    setState(() {
      this.index = index;
    });
  }

  void notifyChange(int num) {
    if (num != index) {
      setState(() {
        badges[num]++;
      });
    } else {
      setState(() {});
    }
  }

  List<Widget> screens() => [
        Home(
          callback: callback,
          listener: listeners,
          moveToPage: moveToPage,
        ),
        ChatPage(
          chatList: listeners.getChatsList(),
        ),
        PaymentsPage(
          paymentsList: listeners.getPaymentsList(),
        ),
        Dates(
          remindersList: listeners.getRemindersList(),
        ),
        ShoppingPage(
          shoppingList: listeners.getShoppingList(),
        ),
      ];

  @override
  void initState() {
    super.initState();
    listeners = Listeners(notifyChange: notifyChange);
    listeners.startListening();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      if (notification != null) {
        AndroidNotification android = message.notification!.android!;
        if (android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  channelDescription: channel.description,
                  color: Colors.blue,
                  playSound: true,
                  icon: '@mipmap/ic_launcher'),
            ),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('New notification');
      RemoteNotification notification = message.notification!;
      if (notification != null) {
        AndroidNotification android = message.notification!.android!;
        if (android != null) {
          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body!),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = screens();

    final List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        backgroundColor:
            ThemeProvider().isDarkMode ? const Color(0xff1e314d) : Colors.white,
        label: 'Home',
        icon: Badge(
          showBadge: badges[0] != 0,
          badgeContent: Text(badges[0].toString()),
          child: const Icon(
            Icons.home,
            size: 20,
          ),
        ),
        activeIcon: const Icon(
          Icons.home,
          size: 30,
        ),
      ),
      BottomNavigationBarItem(
        backgroundColor:
            ThemeProvider().isDarkMode ? const Color(0xff1e314d) : Colors.white,
        label: 'Chat',
        icon: Badge(
          showBadge: badges[1] != 0,
          badgeContent: Text(badges[1].toString()),
          child: const Icon(
            Icons.chat_rounded,
            size: 20,
          ),
        ),
        activeIcon: const Icon(
          Icons.chat_rounded,
          size: 30,
        ),
      ),
      BottomNavigationBarItem(
        backgroundColor:
            ThemeProvider().isDarkMode ? const Color(0xff1e314d) : Colors.white,
        label: 'Payments',
        icon: Badge(
          showBadge: badges[2] != 0,
          badgeContent: Text(badges[2].toString()),
          child: const Icon(
            Icons.attach_money,
            size: 20,
          ),
        ),
        activeIcon: const Icon(
          Icons.attach_money,
          size: 30,
        ),
      ),
      BottomNavigationBarItem(
        backgroundColor:
            ThemeProvider().isDarkMode ? const Color(0xff1e314d) : Colors.white,
        label: 'Dates',
        icon: Badge(
          showBadge: badges[3] != 0,
          badgeContent: Text(badges[3].toString()),
          child: const Icon(
            Icons.calendar_today_rounded,
            size: 20,
          ),
        ),
        activeIcon: const Icon(
          Icons.calendar_today_outlined,
          size: 30,
        ),
      ),
      BottomNavigationBarItem(
        backgroundColor:
            ThemeProvider().isDarkMode ? const Color(0xff1e314d) : Colors.white,
        label: 'Shopping',
        icon: Badge(
          showBadge: badges[4] != 0,
          badgeContent: Text(badges[4].toString()),
          child: const Icon(
            Icons.shopping_cart_outlined,
            size: 20,
          ),
        ),
        activeIcon: const Icon(
          Icons.shopping_cart_outlined,
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
              elevation: 1,
              items: items,
              currentIndex: index,
              unselectedFontSize: 10,
              selectedFontSize: 15,
              showUnselectedLabels: true,
              onTap: (index) {
                if (this.index != index) {
                  setState(() {
                    this.index = index;
                    badges[index] = 0;
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
