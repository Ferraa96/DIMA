// flutter test --no-sound-null-safety test/unit_test/user_models_test.dart

import 'package:dima/models/user.dart';
import 'package:flutter_test/flutter_test.dart';

String uid = "AXdvsAFdfsv678GJ";
String name = "AuhCDIOI887Jvd";
String groupId = "VDOIyhiug78uhHd";
String picUrl = "FDOnobSOb6776FGbhb443s";


void main() {

  group('UNIT_TEST => MyUser Class => ', () {

    final mu = MyUser();

    test('setUserId(), getUid() functions', () {
      mu.setUserId(uid);
      expect(mu.getUid(), uid);
    });

    test('setName(), getName() functions', () {
      mu.setName(name);
      expect(mu.getName(), name);
    });

    test('setGroupId(), getGroupId() functions', () {
      mu.setGroupId(groupId);
      expect(mu.getGroupId(), groupId);
    });

    test('setPicUrl(), getPicUrl() functions', () {
      mu.setPicUrl(picUrl);
      expect(mu.getPicUrl(), picUrl);
    });

  });

}
