import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dima/models/user.dart';
import 'package:dima/screens/home/chatPage.dart';
import 'package:dima/screens/home/home.dart';
import 'package:dima/screens/home/settings.dart';
import 'package:dima/screens/home/paymentsPage.dart';
import 'package:dima/services/appData.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/loading.dart';
import 'package:dima/shared/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  late String groupId;
  int index = 0;
  late Widget _groupStream;

  final screens = [
    Home(),
    const ChatPage(),
    const PaymentsPage(),
    const AppSettings(),
  ];

  @override
  void initState() {
    super.initState();
    DatabaseService db = DatabaseService();
    _groupStream = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(MyUser.groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> members =
              List<String>.from(snapshot.data!.data()!['members']);
          return FutureBuilder<List<MyUser>>(
            future: db.retrieveUsers(members),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Loading();
                default:
                  AppData().group.setMembers(snapshot.data!);
                  List<String> names = [];
                  List<String> pictures = [];
                  for (MyUser user in AppData().group.getList()) {
                    names.add(user.getName());
                    pictures.add(user.getPicUrl());
                  }
                  return ClipRRect(
                    child: SizedBox(
                      child: ListView.separated(
                        itemCount: members.length + 1,
                        itemBuilder: (_, index) {
                          if (index < members.length) {
                            return SizedBox(
                              child:
                                  _getUsersIcon(names[index], pictures[index]),
                            );
                          } else {
                            return Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                child: Center(
                                  child: IconButton(
                                    onPressed: () {
                                      showGeneralDialog(
                                        barrierLabel: 'addUser',
                                        barrierDismissible: true,
                                        context: context,
                                        pageBuilder: (ctx, a1, a2) {
                                          return Container();
                                        },
                                        transitionBuilder:
                                            (ctx, a1, a2, child) {
                                          var curve = Curves.easeInOut
                                              .transform(a1.value);
                                          return Transform.scale(
                                            scale: curve,
                                            child: _buildAddUserPopupDialog(ctx,
                                                AppData().group.getGroupCode()),
                                          );
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    color: Colors.black,
                                  ),
                                ),
                                height: kToolbarHeight * 0.9,
                                width: kToolbarHeight * 0.9,
                              ),
                            );
                          }
                        },
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            width: kToolbarHeight * 0.1,
                          );
                        },
                      ),
                      height: kToolbarHeight * 0.9,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  );
              }
            },
          );
        } else {
          return const Loading();
        }
      },
    );
  }

  Widget _buildExpandUserDialog(BuildContext context, String name, Image pic) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double size = height > width ? width : height;
    return Container(
      height: size / 3,
      width: size / 3,
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: pic.image,
            ),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddUserPopupDialog(BuildContext context, String groupCode) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: width / 3,
          maxHeight: height / 3,
        ),
        child: Column(
          children: [
            SizedBox(
              height: height / 26,
            ),
            const Text(
              'Invite a roommate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: height / 50,
            ),
            const Text('Give this code to your friend'),
            SizedBox(
              height: height / 50,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 2, color: Colors.black),
                color: Colors.orangeAccent,
              ),
              child: Row(
                children: [
                  Text(
                    groupCode,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: groupCode));
                        Fluttertoast.showToast(
                            msg: 'Copied to clipboard',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey);
                      },
                      icon: const Icon(Icons.copy)),
                  IconButton(
                    onPressed: () {
                      Share.share(
                          'Join my group on Dima\nInvitation code:\n' +
                              groupCode +
                              '\n',
                          subject: 'Dima');
                    },
                    icon: const Icon(Icons.share),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            SizedBox(
              height: height / 40,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getUsersIcon(String name, String url) {
    Image img;
    if (url != '') {
      img = Image.network(url);
      AppData().user.setPicture(img);
    } else {
      img = Image.asset('assets/defaultProfile.png');
      AppData().user.setPicture(img);
    }
    if (name.length > 3) {
      name = name.substring(0, 4);
    }
    return Container(
      height: kToolbarHeight,
      width: kToolbarHeight * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(width: 1, color: Colors.orangeAccent),
        image: DecorationImage(
          image: img.image,
          fit: BoxFit.fill,
        ),
        color: Colors.transparent,
      ),
      child: ElevatedButton(
        onPressed: () {
          showGeneralDialog(
            barrierLabel: 'expandUser',
            barrierDismissible: true,
            context: context,
            pageBuilder: (ctx, a1, a2) {
              return Container();
            },
            transitionBuilder: (ctx, a1, a2, child) {
              var curve = Curves.easeInOut.transform(a1.value);
              return Transform.scale(
                scale: curve,
                child: _buildExpandUserDialog(context, name, img),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const CircleBorder(),
        ),
        child: Container(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          Icons.money,
          size: 20,
        ),
        activeIcon: Icon(
          Icons.money,
          size: 30,
        )
      ),
      const BottomNavigationBarItem(
        label: 'Settings',
        icon: Icon(
          Icons.settings,
          size: 20,
        ),
        activeIcon: Icon(
          Icons.settings,
          size: 30,
        ),
      ),
    ];
    final PageController controller = PageController(
      initialPage: index,
    );
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          themeMode: themeProvider.themeMode,
          theme: MyThemes.lightTheme,
          darkTheme: MyThemes.darkTheme,
          home: Scaffold(
            body: screens[index],
            
            /*PageView(
              controller: controller,
              children: screens,
              onPageChanged: (viewIndex) {
                setState(() {
                  index = viewIndex;
                });
              },
            ),
            */
            extendBody: false,
            bottomNavigationBar: BottomNavigationBar(
              key: navigationKey,
              backgroundColor: Colors.transparent,
              items: items,
              currentIndex: index,
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.orangeAccent,
              unselectedFontSize: 10,
              selectedFontSize: 15,
              onTap: (index) {
                if (this.index != index) {
                  /*
                  controller.animateToPage(index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
                  */
                  setState(() {
                    this.index = index;
                  });
                }
              },
            ),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: _groupStream,
            ),
          ),
        );
      },
    );
  }
}
