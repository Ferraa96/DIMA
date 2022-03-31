import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/services/appData.dart';
import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/loading.dart';
import 'package:dima/shared/themes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  late Widget _profilePicture;

  @override
  void initState() {
    super.initState();
    _profilePicture = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(AppData().user.getUid())
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Loading();
          default:
            String url = snapshot.data!.data()!['picture'];
            Image img;
            if (url != null) {
              img = Image.network(url);
              AppData().user.setPicture(img);
            } else {
              img = Image.asset('assets/defaultProfile.png');
              AppData().user.setPicture(img);
            }
            return img;
        }
      },
    );
  }

  Widget _userImageDialog(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double size = height > width ? width : height;
    AppData().user.setUserId(AuthService().getUserId());
    return Dialog(
      child: Container(
        height: size / 2,
        width: size / 2,
        child: Stack(
          children: [
            AppData().user.getPicture(),
            Positioned(
              right: 5,
              bottom: 5,
              child: PopupMenuButton(
                icon: const Icon(Icons.edit),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'camera',
                      child: const Icon(Icons.camera),
                      onTap: () {
                        DatabaseService().updateImage(
                            AppData().user.getUid(), ImageSource.camera);
                        Navigator.of(context).pop();
                      },
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: const Icon(Icons.archive),
                      onTap: () {
                        DatabaseService().updateImage(
                            AppData().user.getUid(), ImageSource.gallery);
                        Navigator.of(context).pop();
                      },
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _modifyName = false;
  @override
  Widget build(BuildContext context) {
    if (AppData().user.getPicUrl() == '') {
      AppData().user.setPicture(Image.asset('assets/defaultProfile.png'));
    }
    DatabaseService db = DatabaseService();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
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
              border: Border.all(width: 2, color: Colors.orangeAccent),
            ),
            child: IconButton(
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
              icon: _profilePicture,
              color: Colors.grey,
              iconSize: height / 10,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IntrinsicWidth(
                child: TextFormField(
                  initialValue: AppData().user.getName(),
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
                  });
                },
                icon: const Icon(Icons.edit),
                iconSize: 18,
              ),
            ],
          ),
          SizedBox(
            height: height / 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Enable dark mode'),
              Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  final provider =
                      Provider.of<ThemeProvider>(context, listen: false);
                  provider.toggleTheme(value);
                },
              ),
            ],
          ),
          SizedBox(
            height: height / 40,
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService().signOut();
              Navigator.of(context).pushNamed('/');
            },
            child: const Text(
              'Logout',
            ),
          ),
        ],
      ),
    );
  }
}
