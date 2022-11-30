// flutter test --no-sound-null-safety test/unit_test/chart_series_models_test.dart

import 'package:dima/models/chart_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

String NAME = 'abcd';
double BALANCE = 23.57;

void main() {

  group('Formatter Class test', () {

    ChartSeries cs = ChartSeries(name: NAME, balance: BALANCE);

    test('class creation', () {
      expect(cs.name, NAME);
      expect(cs.balance, BALANCE);
    });


  });

}
