import 'package:dima/models/user.dart';

class Group {
  List<MyUser> users = [];
  late String groupCode;

  void addUser(MyUser user) {
    users.add(user);
  }

  void setGroupCode(String groupCode) {
    this.groupCode = groupCode;
  }

  List<MyUser> getList() {
    return users;
  }

  String getGroupCode() {
    return groupCode;
  }

  void setMembers(List<MyUser> members) {
    users = members;
  }
}
