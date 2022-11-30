// flutter test --no-sound-null-safety test/unit_test/formatter_shared_test.dart

import 'package:dima/shared/formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dima/models/chart_series.dart';
import 'package:flutter/material.dart';

List<List> dt = [
  [DateTime(2022,10,10,10,10), '10/10/2022', '10:10', '10/10/2022 10:10'],
  [DateTime(2022,1,1,1,1), '01/01/2022', '01:01', '01/01/2022 01:01'],
  [DateTime(2022,70,70,70,70), '11/12/2027', '23:10', '11/12/2027 23:10'],
  [DateTime(2022,1,10,9,8), '10/01/2022', '09:08', '10/01/2022 09:08'],
];


void main() {

  group('Formatter Class test', () {

    final f = Formatter();

    test('formatDate() function', () {
      for (int i=0; i<dt.length; i++) {
        expect(f.formatDate(dt[i][0]), dt[i][1]);
      } 
    });

    test('formatTime() function', () {
      for (int i=0; i<dt.length; i++) {
        expect(f.formatTime(TimeOfDay.fromDateTime(dt[i][0])), dt[i][2]);
      }
    });

    test('formatDateAndTime() function', () {
      for (int i=0; i<dt.length; i++) {
        expect(f.formatDateAndTime(dt[i][0]), dt[i][3]);
      }
    });

  });

}
