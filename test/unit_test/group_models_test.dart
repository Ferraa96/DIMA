// flutter test --no-sound-null-safety test/unit_test/group_models_test.dart

import 'package:dima/models/group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima/models/user.dart';

List<MyUser> users = [
  (){final u=MyUser(); u.setUserId('Aa'); return u;}(),
  (){final u=MyUser(); u.setUserId('Bb'); return u;}(),
  (){final u=MyUser(); u.setUserId('Cc'); return u;}(),
];
String groupCode = 'abcdef';

void main() {

  group('UNIT_TEST => Group Class => ', () {

    final g = Group();

    test('addUser() function', () {
      g.addUser(users[0]);
      g.addUser(users[1]);
      expect(g.users, [users[0], users[1]]);
    });

    test('setGroupCode() function', () {
      g.setGroupCode(groupCode);
      expect(g.groupCode, groupCode);
    });

    test('getList() function', () {
      expect(g.getList(), [users[0], users[1]]);
    });

    test('getGroupCode() function', () {
      expect(g.getGroupCode(), groupCode);
    });

    test('setMembers() function', () {
      g.setMembers(users);
      expect(g.users, users);
    });

    test('getUserFromId() function', () {
      expect(g.getUserFromId(users[users.length-1].getUid()), users[users.length-1]);
      expect(g.getUserFromId('xyz'), null);
    });

    test('getUserIndexFromId() function', () {
      expect(g.getUserIndexFromId(users[users.length-1].getUid()), users.length-1);
      expect(g.getUserIndexFromId('xyz'), -1);
    });

  });

}
