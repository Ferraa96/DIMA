import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/chart_series.dart';
import 'package:dima/models/user.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/services/auth.dart';
import 'package:dima/services/database.dart';
import 'package:dima/services/image_editor.dart';
import 'package:dima/services/image_getter.dart';
import 'package:dima/services/listeners.dart';
import 'package:dima/shared/constants.dart';
import 'package:dima/shared/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Home extends StatelessWidget {
  final Function callback;
  final Listeners listener;
  final Function moveToPage;
  Home({
    Key? key,
    required this.callback,
    required this.listener,
    required this.moveToPage,
  }) : super(key: key);

  Image _myImg = AppData().user.picture;
  bool _modifyName = false;
  FocusNode focusNode = FocusNode();
  String name = '';
  final PageController controller = PageController(
    initialPage: 100,
  );
  late BuildContext context;

  Widget _getUsersIcon(String name, int index) {
    double height = window.physicalSize.height / window.devicePixelRatio;
    double width = window.physicalSize.width / window.devicePixelRatio;
    double size = height < width ? height : width;
    Image img = AppData().group.getList()[index].picture;
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
                        fit: BoxFit.fill,
                      ),
                      Container(
                        width: size * 0.8,
                        decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            )),
                        child: Center(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color:
            ThemeProvider().isDarkMode ? const Color(0xff1e314d) : Colors.white,
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

  Widget _buildGroupTitle() {
    List<String> names = [];
    for (MyUser user in AppData().group.getList()) {
      names.add(user.name);
    }
    return SizedBox(
      child: ListView.separated(
        itemCount: names.length + 1,
        itemBuilder: (_, index) {
          if (index < names.length) {
            return SizedBox(
              child: _getUsersIcon(names[index], index),
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
                        transitionBuilder: (ctx, a1, a2, child) {
                          var curve = Curves.easeInOut.transform(a1.value);
                          return Transform.scale(
                            scale: curve,
                            child: _buildAddUserPopupDialog(
                                ctx, AppData().group.getGroupCode()),
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
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
    );
  }

  Future<void> _setNewImage(ImageSource source) async {
    String? path = await ImageGetter().selectFile(source);
    if (path == null) {
      return;
    }
    File? file = await ImageEditor().cropSquareImage(
      File(path),
    );
    if (file == null) {
      return;
    }
    _myImg = Image.file(file);
    DatabaseService().updateImage(AppData().user.getUid(), file);
  }

  Widget _userImageDialog(BuildContext context, double size) {
    AppData().user.setUserId(AuthService().getUserId());
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: size * 0.7, child: _myImg),
          PopupMenuButton(
            color: ThemeProvider().isDarkMode
                ? const Color(0xff1e314d)
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
                    _setNewImage(ImageSource.camera);
                    //setState(() {});
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
                    _setNewImage(ImageSource.gallery);
                    //setState(() {});
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
    double size = window.physicalSize.height > window.physicalSize.width
        ? window.physicalSize.width
        : window.physicalSize.height;
    size = size / window.devicePixelRatio;
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(ctx);
    TextEditingController _nameController = TextEditingController(
      text: name,
    );
    return StatefulBuilder(builder: (context, setState) {
      List<bool> isSelected = [
        !themeProvider.isDarkMode,
        themeProvider.isDarkMode
      ];
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: ThemeProvider().isDarkMode
              ? const Color(0xff1e314d)
              : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: size / 40,
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
                        scale: curve,
                        child: _userImageDialog(context, size),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  );
                },
                icon: _myImg,
                color: Colors.grey,
                iconSize: size / 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IntrinsicWidth(
                    child: TextFormField(
                      focusNode: focusNode,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      controller: _nameController,
                      onFieldSubmitted: (newName) {
                        if (newName.isNotEmpty && newName != name) {
                          db.updateUserName(AppData().user.getUid(), newName);
                        }
                        _modifyName = false;
                        name = newName;
                      },
                      enabled: _modifyName,
                      decoration: const InputDecoration(
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (!_modifyName) {
                        setState(() {
                          _modifyName = true;
                          focusNode.requestFocus();
                          _nameController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _nameController.text.length);
                        });
                      } else {
                        if (_nameController.text.isNotEmpty &&
                            _nameController.text != name) {
                          db.updateUserName(
                              AppData().user.getUid(), _nameController.text);
                        }
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _modifyName = false;
                        });
                      }
                    },
                    icon: Icon(
                      _modifyName ? Icons.check : Icons.edit,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    iconSize: 18,
                  ),
                ],
              ),
              SizedBox(
                height: size / 60,
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
                    callback(index == 1);
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
                height: size / 60,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: themeProvider.isDarkMode
                              ? const Color(0xff1e314d)
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
                height: size / 60,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _constructPie(double size, bool isCredit) {
    List<double> balances = [];
    double balance = 0;

    for (MyUser user in AppData().group.users) {
      balance = 0;
      for (var el in listener.getPaymentsList()) {
        List<String> payedTo = List<String>.from(el['payedTo']);
        if (el['payedBy'] == user.uid) {
          balance += el['amount'];
        }
        if (payedTo.contains(user.uid)) {
          balance -= el['amount'] / payedTo.length;
        }
      }
      balance = (balance * 100).roundToDouble() / 100;
      balances.add(balance);
    }

    List<ChartSeries> seriesList = [];
    for (int i = 0; i < AppData().group.users.length; i++) {
      if ((isCredit && balances[i] > 0) || (!isCredit && balances[i] < 0)) {
        seriesList.add(
          ChartSeries(
            name: i.toString(),
            balance: balances[i],
          ),
        );
      }
    }
    List<charts.Series<ChartSeries, String>> series = [
      charts.Series<ChartSeries, String>(
        id: 'balances',
        domainFn: (ChartSeries s, _) => s.name,
        measureFn: (ChartSeries s, _) => s.balance,
        labelAccessorFn: (ChartSeries s, _) => s.balance.abs().toString() + '€',
        colorFn: (ChartSeries s, _) => charts.ColorUtil.fromDartColor(
          colors[int.parse(s.name) % colors.length],
        ),
        insideLabelStyleAccessorFn: (ChartSeries s, _) => charts.TextStyleSpec(
          color: charts.ColorUtil.fromDartColor(Colors.black),
        ),
        outsideLabelStyleAccessorFn: (ChartSeries s, _) => charts.TextStyleSpec(
          color: charts.ColorUtil.fromDartColor(Colors.black),
        ),
        data: seriesList,
      )
    ];

    return charts.PieChart(
      series,
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: (size / 8).round(),
        /*arcRendererDecorators: [
          charts.ArcLabelDecorator(
            labelPosition: charts.ArcLabelPosition.auto,
          ),
        ],*/
      ),
    );
  }

  Widget _paymentWidgetWideScreen(double width, double height) {
    double size = width > height ? height : width;
    return Container(
      width: width * 0.5,
      height: height * 0.8,
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 4,
            child: Column(
              children: [
                Column(
                  children: [
                    const Text(
                      'Credits',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: size / 3,
                      child: _constructPie(size, true),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Debits',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: size / 3,
                      child: _constructPie(size, false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: ListView(
              shrinkWrap: true,
              children: [
                ...() {
                  List<Widget> list = [];
                  for (int i = 0; i < AppData().group.users.length; i++) {
                    list.add(
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: colors[i % colors.length],
                            ),
                            height: 10,
                            width: 10,
                          ),
                          const VerticalDivider(),
                          Text(
                            AppData().group.users[i].getName(),
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return list;
                }(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentWidgetNarrowScreen(double size) {
    return Container(
      height: size * 0.45,
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: controller,
        itemBuilder: (context, index) {
          return Wrap(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  index % 2 == 0 ? 'Credits' : 'Debts',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: SizedBox(
                      height: size * 0.4,
                      child: _constructPie(size, index % 2 == 0),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ...() {
                          List<Widget> list = [];
                          for (int i = 0;
                              i < AppData().group.users.length;
                              i++) {
                            list.add(
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 0.8,
                                      ),
                                      color: colors[i % colors.length],
                                    ),
                                    height: 10,
                                    width: 10,
                                  ),
                                  const VerticalDivider(),
                                  Text(
                                    AppData().group.users[i].getName(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return list;
                        }(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShoppingWidget(double size) {
    List<String> categoriesInList = [];
    List<int> numPerCategory = [];
    int numProducts = listener.getShoppingList().length;
    int counter = 0;
    categoriesInList.add(listener.getShoppingList()[0]['category']);
    numPerCategory.add(1);
    for (int i = 1; i < numProducts; i++) {
      String cat = listener.getShoppingList()[i]['category'];
      if (cat != categoriesInList[counter]) {
        categoriesInList.add(cat);
        numPerCategory.add(1);
        counter++;
      } else {
        numPerCategory[counter]++;
      }
    }
    return GestureDetector(
      onTap: () => moveToPage(4),
      child: Container(
        height: size * 0.45,
        width: size * 0.47,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          child: numProducts == 1
              ? Text(
                  'There is 1 product in the shopping list, in the category ${categories[0]}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Column(
                  children: [
                    Text(
                      'There are $numProducts products in the shopping list',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Divider(
                      color: Colors.black45,
                    ),
                    Expanded(
                      child: ListView(
                          shrinkWrap: true,
                          children: () {
                            List<Widget> list = [];
                            for (int i = 0; i < categoriesInList.length; i++) {
                              list.add(
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        () {
                                          switch (categoriesInList[i]) {
                                            case 'Fruit':
                                              return Image.asset(
                                                'assets/icons/fruit.png',
                                                width: 25,
                                              );
                                            case 'Meat':
                                              return Image.asset(
                                                'assets/icons/meat.png',
                                                width: 25,
                                              );
                                            case 'Vegetables':
                                              return Image.asset(
                                                'assets/icons/vegetables.png',
                                                width: 25,
                                              );
                                            default:
                                              return Image.asset(
                                                'assets/icons/other.png',
                                                width: 25,
                                              );
                                          }
                                        }(),
                                        const VerticalDivider(),
                                        Text(
                                          categoriesInList[i],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      numPerCategory[i].toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              list.add(const SizedBox(
                                height: 5,
                              ));
                            }
                            return list;
                          }()),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRemindersWidget(double size, List reminders) {
    Map<int, String> days = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    Map<int, String> months = {
      1: 'Genuary',
      2: 'February',
      3: 'March',
      4: 'April',
      5: 'May',
      6: 'June',
      7: 'July',
      8: 'August',
      9: 'September',
      10: 'October',
      11: 'November',
      12: 'December',
    };
    int futureRemindersNum = 0;
    for (var el in reminders) {
      if ((el['dateTime'] as Timestamp).toDate().isAfter(DateTime.now())) {
        futureRemindersNum++;
      }
    }
    return GestureDetector(
      onTap: () => moveToPage(3),
      child: Container(
        height: size * 0.45,
        width: size * 0.47,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 78, 128, 214),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                days[DateTime.now().weekday]!.toUpperCase().substring(0, 3) +
                    ', ' +
                    DateTime.now().day.toString() +
                    ' ' +
                    months[DateTime.now().month]!.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(
                color: Colors.black45,
              ),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: futureRemindersNum,
                  itemBuilder: (context, index) {
                    String time;
                    DateTime dateTime =
                        (reminders[futureRemindersNum - index - 1]['dateTime']
                                as Timestamp)
                            .toDate();
                    if (dateTime.difference(DateTime.now()).inDays == 0) {
                      if (dateTime.difference(DateTime.now()).inHours == 0) {
                        time =
                            'in ${dateTime.difference(DateTime.now()).inMinutes} minutes';
                      } else {
                        time =
                            'in ${dateTime.difference(DateTime.now()).inHours} hours';
                      }
                    } else if (dateTime.difference(DateTime.now()).inDays ==
                        1) {
                      time = 'tomorrow';
                    } else {
                      time =
                          'in ${dateTime.difference(DateTime.now()).inDays} days';
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 20,
                          decoration: BoxDecoration(
                            color: colors[AppData().group.getUserIndexFromId(
                                    reminders[futureRemindersNum - index - 1]
                                        ['creator']) %
                                colors.length],
                            border: Border.all(
                              color: Colors.black38,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                reminders[futureRemindersNum - index - 1]
                                    ['title'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black45,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 4,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    name = AppData().user.getName();
    double width = window.physicalSize.width / window.devicePixelRatio;
    double height = window.physicalSize.height / window.devicePixelRatio;
    double size = width > height ? height : width;
    return MaterialApp(
      themeMode: ThemeProvider.themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: _buildGroupTitle(),
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
          margin: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Center(
                      child: Text(
                    'Welcome back, $name',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  )),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        child: constraints.maxWidth < constraints.maxHeight
                            ? Wrap(
                                runSpacing: 10,
                                spacing: 10,
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  ...() {
                                    List<Widget> list = [];
                                    if (listener.getPaymentsList().isNotEmpty) {
                                      list.add(
                                        GestureDetector(
                                          onTap: () => moveToPage(2),
                                          child:
                                              _paymentWidgetNarrowScreen(size),
                                        ),
                                      );
                                    }
                                    if (listener.getShoppingList().isNotEmpty) {
                                      list.add(_buildShoppingWidget(size));
                                    }
                                    List reminders =
                                        listener.getRemindersList();
                                    if (reminders.isNotEmpty &&
                                        (reminders[0]['dateTime'] as Timestamp)
                                            .toDate()
                                            .isAfter(DateTime.now())) {
                                      list.add(_buildRemindersWidget(
                                          size, reminders));
                                    }
                                    return list;
                                  }()
                                ],
                              )
                            : Wrap(
                                runSpacing: 10,
                                spacing: 10,
                                direction: Axis.horizontal,
                                children: [
                                  ...() {
                                    List<Widget> list = [];
                                    if (listener.getPaymentsList().isNotEmpty) {
                                      list.add(
                                        GestureDetector(
                                          onTap: () => moveToPage(2),
                                          child: _paymentWidgetWideScreen(
                                              width, height),
                                        ),
                                      );
                                    }
                                    if (listener.getShoppingList().isNotEmpty) {
                                      list.add(
                                        _buildShoppingWidget(size * 0.7),
                                      );
                                    }
                                    List reminders =
                                        listener.getRemindersList();
                                    if (reminders.isNotEmpty &&
                                        (reminders[0]['dateTime'] as Timestamp)
                                            .toDate()
                                            .isAfter(DateTime.now())) {
                                      list.add(
                                        _buildRemindersWidget(
                                            size * 0.7, reminders),
                                      );
                                    }

                                    return list;
                                  }()
                                ],
                              ),
                      ),
                      /*
                      child: Wrap(
                        runSpacing: 10,
                        spacing: 10,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          ...() {
                            List<Widget> list = [];
                            if (listener.getPaymentsList().isNotEmpty) {
                              list.add(
                                GestureDetector(
                                  onTap: () => moveToPage(2),
                                  child: (constraints.maxWidth >
                                          constraints.maxHeight
                                      ? _paymentWidgetWideScreen(width, height)
                                      : _paymentWidgetNarrowScreen(size)),
                                ),
                              );
                            }
                            if (listener.getShoppingList().isNotEmpty) {
                              list.add(_buildShoppingWidget(size));
                            }
                            List reminders = listener.getRemindersList();
                            if (reminders.isNotEmpty &&
                                (reminders[0]['dateTime'] as Timestamp)
                                    .toDate()
                                    .isAfter(DateTime.now())) {
                              list.add(_buildRemindersWidget(size, reminders));
                            }
                            return list;
                          }(),
                        ],
                      ),
                      */
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
