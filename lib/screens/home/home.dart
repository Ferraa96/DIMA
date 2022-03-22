import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/group.dart';
import 'package:dima/models/user.dart';
import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

class Home extends StatefulWidget {
  MyUser user = MyUser(uid: AuthService().getUserId());
  // String groupId;
  // Home({required this.groupId});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget _buildAccountPopupDialog(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 3,
          maxHeight: height / 3,
        ),
        child: Column(
          children: [
            SizedBox(
              height: height / 40,
            ),
            Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(width: 2, color: Colors.green),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 50,
              ),
            ),
            SizedBox(
              height: height / 100,
            ),
            Text(
              widget.user.getName(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: height / 50,
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                Navigator.of(context).pushNamed('/');
              },
              child: const Text('Logout'),
            ),
            SizedBox(
              height: height / 100,
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

  Widget _buildAddUserPopupDialog(BuildContext context, String groupCode) {
    double height = MediaQuery.of(context).size.height;
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 3,
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
                color: Colors.green,
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

  List<Widget> _getUsersIcons(List<MyUser> users) {
    List<Widget> list = [];
    for (MyUser user in users) {
      list.add(
        Container(
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: Center(
                child: Text(
                  user.getName(),
                  style: const TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              height: kToolbarHeight * 0.8,
              width: kToolbarHeight * 0.8,
            ),
          ),
          width: kToolbarHeight * 0.9,
        ),
      );
    }
    return list;
  }

  Widget _getUsersIcon(String name) {
    return Container(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: Center(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ),
            height: kToolbarHeight * 0.8,
            width: kToolbarHeight * 0.8,
          ),
        ),
        width: kToolbarHeight * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService();
    List<MyUser>? users = [];
    Group group = Group();
    // widget.user.setGroupId(widget.groupId);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          //.doc(widget.groupId)
          .doc(MyUser.groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> members =
              List<String>.from(snapshot.data!.data()!['members']);
          group.setGroupCode(snapshot.data!.data()!['invitationCode']);
          return FutureBuilder<List<MyUser>>(
              future: db.retrieveUsers(members),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Loading();
                  default:
                    users = snapshot.data;
                    // widget.user.setGroupId(widget.groupId);
                    for (MyUser user in users!) {
                      if (user.getUid() == widget.user.getUid()) {
                        widget.user.setName(user.getName());
                        break;
                      }
                    }
                    List<String> names = [];
                    for (MyUser user in users!) {
                      names.add(user.getName());
                    }
                    group.setMembers(users!);
                    return Scaffold(
                      backgroundColor: const Color.fromARGB(255, 245, 245, 255),
                      appBar: AppBar(
                        titleSpacing: 0,
                        backgroundColor:
                            const Color.fromARGB(255, 245, 245, 255),
                        elevation: 0.0,
                        title: ClipRRect(
                          child: SizedBox(
                            child: ListView.builder(
                              itemCount: names.length + 1,
                              itemBuilder: (_, index) {
                                if (index < names.length) {
                                  return SizedBox(
                                    child: _getUsersIcon(names[index]),
                                  );
                                } else {
                                  return Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius:
                                            BorderRadius.circular(40.0),
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
                                                  child:
                                                      _buildAddUserPopupDialog(
                                                          ctx,
                                                          group.getGroupCode()),
                                                );
                                              },
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 300),
                                            );
                                          },
                                          icon: const Icon(Icons.add),
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      height: kToolbarHeight * 0.8,
                                      width: kToolbarHeight * 0.8,
                                    ),
                                  );
                                }
                              },
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                            ),
                            height: kToolbarHeight * 0.9,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        actions: <Widget>[
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.settings),
                            color: Colors.grey,
                          ),
                          IconButton(
                            onPressed: () {
                              showGeneralDialog(
                                barrierLabel: 'account',
                                barrierDismissible: true,
                                context: context,
                                pageBuilder: (ctx, a1, a2) {
                                  return Container();
                                },
                                transitionBuilder: (ctx, a1, a2, child) {
                                  var curve =
                                      Curves.easeInOut.transform(a1.value);
                                  return Transform.scale(
                                    scale: curve,
                                    child: _buildAccountPopupDialog(ctx),
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              );
                            },
                            icon: const Icon(Icons.person),
                            color: Colors.greenAccent,
                          ),
                        ],
                      ),
                      body: Container(),
                      /*
                      drawer: Drawer(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: const [
                            DrawerHeader(
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                              ),
                              child: Text('Boh'),
                            )
                          ],
                        ),
                      ),
                      */
                    );
                }
              });
        } else {
          return const Loading();
        }
      },
    );
  }
}
