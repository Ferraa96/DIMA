import 'package:dima/models/group.dart';

import '../models/user.dart';

class AppData {
  static final AppData _appData = AppData._internal();

  MyUser user = MyUser();
  Group group = Group();

  factory AppData() {
    return _appData;
  }
  AppData._internal();
}

final appData = AppData();
