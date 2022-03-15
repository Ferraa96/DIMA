class MyUser {
  final String uid;
  late String name = '';
  late String groupId = '';

  MyUser({required this.uid});

  String getUid() {
    return uid;
  }

  void setName(String name) {
    this.name = name;
  }

  String getName() {
    return name;
  }

  void setGroupId(String groupId) {
    this.groupId = groupId;
  }

  String getGroupId() {
    return groupId;
  }
}
