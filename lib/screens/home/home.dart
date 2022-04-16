import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/user.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/constants.dart';
import 'package:dima/shared/loading.dart';
import 'package:dima/shared/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class Home extends StatefulWidget {
  Function callback;
  Home({Key? key, required this.callback}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Widget _groupStream;
  late Image _myImg;
  late String _myName;
  bool _modifyName = false;

  Widget _getUsersIcon(String name, int index, String url) {
    double height = window.physicalSize.height / window.devicePixelRatio;
    double width = window.physicalSize.width / window.devicePixelRatio;
    double size = height < width ? height : width;
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
    if (index == AppData().group.getUserIndexFromId(AppData().user.getUid())) {
      _myImg = img;
      _myName = name;
    }
    return Container(
      height: kToolbarHeight,
      width: kToolbarHeight * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(width: 1, color: colors[index % colors.length]),
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
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: img.image,
                        width: size * 0.8,
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          color: colors[index % colors.length],
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildAddUserPopupDialog(BuildContext context, String groupCode) {
    double height = window.physicalSize.height / window.devicePixelRatio;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Card(
        color: ThemeProvider().isDarkMode ? Colors.grey[900] : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height / 40,
            ),
            Text(
              'Invite a roommate',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: ThemeProvider().isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(
              height: height / 50,
            ),
            Text(
              'Give this code to your friend',
              style: TextStyle(
                color: ThemeProvider().isDarkMode ? Colors.white : Colors.black,
              ),
            ),
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
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.orangeAccent,
              ),
            ),
            SizedBox(
              height: height / 40,
            ),
          ],
        ),
      ),
    );
  }

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
                              child: _getUsersIcon(
                                  names[index], index, pictures[index]),
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

  Widget _userImageDialog(BuildContext context) {
    AppData().user.setUserId(AuthService().getUserId());
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppData().user.getPicture(),
          PopupMenuButton(
            color: ThemeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 'camera',
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera,
                        color: ThemeProvider().isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Camera',
                        style: TextStyle(
                          color: ThemeProvider().isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    DatabaseService().updateImage(
                        AppData().user.getUid(), ImageSource.camera);
                    setState(() {});
                  },
                ),
                PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(
                        Icons.archive,
                        color: ThemeProvider().isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Gallery',
                        style: TextStyle(
                          color: ThemeProvider().isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    DatabaseService().updateImage(
                        AppData().user.getUid(), ImageSource.gallery);
                    setState(() {});
                  },
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsDialog(BuildContext ctx) {
    DatabaseService db = DatabaseService();
    double height = window.physicalSize.height / window.devicePixelRatio;
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(ctx);
    TextEditingController _nameController = TextEditingController(
      text: AppData().user.getName(),
    );
    return StatefulBuilder(builder: (context, setState) {
      List<bool> isSelected = [
        !themeProvider.isDarkMode,
        themeProvider.isDarkMode
      ];
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          ),
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: height / 40,
              ),
              IconButton(
                onPressed: () {
                  showGeneralDialog(
                    barrierLabel: 'imageProfile',
                    barrierDismissible: true,
                    context: context,
                    pageBuilder: (ctx, a1, a2) {
                      return Container();
                    },
                    transitionBuilder: (ctx, a1, a2, child) {
                      var curve = Curves.easeInOut.transform(a1.value);
                      return Transform.scale(
                          scale: curve, child: _userImageDialog(context));
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  );
                },
                icon: _myImg,
                color: Colors.grey,
                iconSize: height / 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IntrinsicWidth(
                    child: TextFormField(
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      controller: _nameController,
                      onFieldSubmitted: (newName) {
                        db.updateUserName(AppData().user.getUid(), newName);
                        setState(() {
                          _modifyName = false;
                        });
                        if (newName.isNotEmpty &&
                            newName != AppData().user.getName()) {}
                      },
                      enabled: _modifyName,
                      decoration: const InputDecoration(
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _modifyName = true;
                        _nameController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _nameController.text.length);
                      });
                    },
                    icon: Icon(
                      Icons.edit,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    iconSize: 18,
                  ),
                ],
              ),
              SizedBox(
                height: height / 60,
              ),
              ToggleButtons(
                selectedBorderColor: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(10),
                borderWidth: 5,
                onPressed: (index) {
                  if (!isSelected[index]) {
                    setState(() {
                      isSelected[index] = true;
                      isSelected[1 - index] = false;
                    });
                    widget.callback(index == 1);
                  }
                },
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      children: const [
                        SizedBox(
                          height: 3,
                        ),
                        Icon(
                          Icons.light_mode,
                          color: Colors.orange,
                        ),
                        Text(
                          ' Light mode ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                    ),
                    child: Column(
                      children: const [
                        SizedBox(
                          height: 3,
                        ),
                        Icon(
                          Icons.dark_mode,
                          color: Colors.yellowAccent,
                        ),
                        Text(
                          ' Dark mode ',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                isSelected: isSelected,
              ),
              SizedBox(
                height: height / 60,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orangeAccent,
                ),
                onPressed: () async {
                  showGeneralDialog(
                    barrierLabel: 'logout',
                    barrierDismissible: true,
                    context: context,
                    pageBuilder: (ctx, a1, a2) {
                      return Container();
                    },
                    transitionBuilder: (ctx, a1, a2, child) {
                      var curve = Curves.easeInOut.transform(a1.value);
                      return Transform.scale(
                        scale: curve,
                        child: Dialog(
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.grey[900]
                              : Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Do you really want to log out?',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.orangeAccent,
                                    ),
                                    onPressed: () {
                                      AuthService().signOut();
                                      Navigator.of(ctx).pop();
                                      Navigator.of(context).pushNamed('/');
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.orangeAccent,
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                height: height / 60,
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = window.physicalSize.width / window.devicePixelRatio;
    double height = window.physicalSize.height / window.devicePixelRatio;
    double size = width > height ? height : width;
    return MaterialApp(
      themeMode: ThemeProvider.themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: _groupStream,
          actions: [
            IconButton(
              onPressed: () {
                showGeneralDialog(
                  barrierLabel: 'showSettings',
                  barrierDismissible: true,
                  context: context,
                  pageBuilder: (ctx, a1, a2) {
                    return Container();
                  },
                  transitionBuilder: (ctx, a1, a2, child) {
                    var curve = Curves.easeInOut.transform(a1.value);
                    return Transform.scale(
                      scale: curve,
                      child: _buildSettingsDialog(context),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 10),
          child: Stack(
            children: [
              Container(),
              Positioned(
                child: SizedBox(
                  height: size / 2,
                  width: size / 2,
                  child: const Card(
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
              Positioned(
                top: size / 4,
                left: size / 2,
                height: size / 2,
                width: size / 2,
                child: const Card(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
