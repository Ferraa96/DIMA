// flutter test --no-sound-null-safety test/unit_test/chart_series_models_test.dart

import 'package:dima/models/chart_series.dart';
import 'package:flutter_test/flutter_test.dart';

String name = "abcd";
double balance = 23.57;

void main() {

  group('UNIT_TEST => ChartSeries Class => ', () {

    ChartSeries cs = ChartSeries(name: name, balance: balance);

    test('class creation', () {
      expect(cs.name, name);
      expect(cs.balance, balance);
    });


  });

}
