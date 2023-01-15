import 'dart:async';

import 'package:badges/badges.dart';
import 'package:dima/screens/home/chat_page.dart';
import 'package:dima/screens/home/dates.dart';
import 'package:dima/screens/home/home.dart';
import 'package:dima/screens/home/paymentsPage.dart';
import 'package:dima/screens/home/shopping_page.dart';
import 'package:dima/services/listeners.dart';
import 'package:dima/shared/themes.dart';
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
    if (num != index && mounted) {
      setState(() {
        badges[num]++;
      });
    } else {
      if (mounted) {
        setState(() {});
      }
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
  }

  List<BottomNavigationBarItem> _getBottomNavBarItems() {
    return [
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
  }

  List<NavigationRailDestination> _getNavRailItems() {
    return [
      NavigationRailDestination(
        icon: Badge(
          showBadge: badges[0] != 0,
          badgeContent: Text(badges[0].toString()),
          child: const Icon(
            Icons.home,
            size: 20,
          ),
        ),
        selectedIcon: const Icon(
          Icons.home,
          size: 30,
        ),
        label: const Text('Home'),
      ),
      NavigationRailDestination(
        icon: Badge(
          showBadge: badges[1] != 0,
          badgeContent: Text(badges[1].toString()),
          child: const Icon(
            Icons.chat_rounded,
            size: 20,
          ),
        ),
        selectedIcon: const Icon(
          Icons.chat_rounded,
          size: 30,
        ),
        label: const Text('Chat'),
      ),
      NavigationRailDestination(
        icon: Badge(
          showBadge: badges[2] != 0,
          badgeContent: Text(badges[2].toString()),
          child: const Icon(
            Icons.attach_money,
            size: 20,
          ),
        ),
        selectedIcon: const Icon(
          Icons.attach_money,
          size: 30,
        ),
        label: const Text('Payments'),
      ),
      NavigationRailDestination(
        icon: Badge(
          showBadge: badges[3] != 0,
          badgeContent: Text(badges[3].toString()),
          child: const Icon(
            Icons.calendar_today_rounded,
            size: 20,
          ),
        ),
        selectedIcon: const Icon(
          Icons.calendar_today_outlined,
          size: 30,
        ),
        label: const Text('Dates'),
      ),
      NavigationRailDestination(
        icon: Badge(
          showBadge: badges[4] != 0,
          badgeContent: Text(badges[4].toString()),
          child: const Icon(
            Icons.shopping_cart_outlined,
            size: 20,
          ),
        ),
        selectedIcon: const Icon(
          Icons.shopping_cart_outlined,
          size: 30,
        ),
        label: const Text('Shopping'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = screens();
    bool isWideScreen =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        return MaterialApp(
          themeMode: ThemeProvider.themeMode,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          home: DefaultTabController(
            length: 5,
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: !isWideScreen
                    ? pages[index]
                    : Row(
                        children: [
                          NavigationRail(
                            destinations: _getNavRailItems(),
                            onDestinationSelected: (newIndex) {
                              if (newIndex != index) {
                                setState(() {
                                  index = newIndex;
                                });
                              }
                            },
                            labelType: NavigationRailLabelType.all,
                            backgroundColor: ThemeProvider().isDarkMode
                                ? const Color(0xff1e314d)
                                : Colors.white,
                            selectedIndex: index,
                          ),
                          Flexible(
                            child: pages[index],
                          ),
                        ],
                      ),
                extendBody: false,
                bottomNavigationBar: !isWideScreen
                    ? BottomNavigationBar(
                        elevation: 1,
                        items: _getBottomNavBarItems(),
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
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
