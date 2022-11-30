// flutter test --no-sound-null-safety test/unit_test/user_models_test.dart

import 'package:dima/models/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dima/models/chart_series.dart';
import 'package:flutter/material.dart';

String UID = "AXdvsAFdfsv678GJ";
String NAME = "AuhCDIOI887Jvd";
String GROUPID = "VDOIyhiug78uhHd";
String PICURL = "FDOnobSOb6776FGbhb443s";


void main() {

  group('MyUser Class test', () {

    final mu = MyUser();

    test('setUserId(), getUid() functions', () {
      mu.setUserId(UID);
      expect(mu.getUid(), UID);
    });

    test('setName(), getName() functions', () {
      mu.setName(NAME);
      expect(mu.getName(), NAME);
    });

    test('setGroupId(), getGroupId() functions', () {
      mu.setGroupId(GROUPID);
      expect(mu.getGroupId(), GROUPID);
    });

    test('setPicUrl(), getPicUrl() functions', () {
      mu.setPicUrl(PICURL);
      expect(mu.getPicUrl(), PICURL);
    });

  });

}
