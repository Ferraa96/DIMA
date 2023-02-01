// flutter test --no-sound-null-safety test/unit_test/payment_services_test.dart

import 'package:dima/services/payment_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dima/models/chart_series.dart';

List<String> users = ['AAA', 'BBB', 'CCC', 'DDD'];
List<double> balances = [-5.0, 5.0, -5.0, 30];
List<double> amount = [20, 400, 20, -80];
List<List<double>> expected = [
  [15.0, -5.0, -5.0, -5.0],
  [-85.0, 295.0, -105.0, -105.0],
  [-95.0, 285.0, -85.0, -105.0],
  [-95.0, 285.0, -45.0, -145.0]
];
List payedTo = [users, users, users.getRange(0, 2), users.getRange(2, 4)];

void main() {
  group('UNIT_TEST => PaymentServices Class => ', () {
    final ps = PaymentServices();

    test('uids starts empty', () {
      expect(ps.uids, []);
    });

    test('setUids() test', () {
      ps.setUids(users);
      expect(ps.uids, users);
      expect(ps.uids.length, users.length);
    });

    test('createSeriesList() test', () {
      List<charts.Series<ChartSeries, String>> l =
          ps.createSeriesList(balances);
      expect(l.runtimeType, List<charts.Series<ChartSeries, String>>);
      expect(l[0].id, 'balances');
      for (int i = 0; i < ps.uids.length; i++) {
        expect(l[0].measureFn(i), balances[i]);
        expect(l[0].data[i].name, users[i]);
        expect(l[0].data[i].balance, balances[i]);
      }
    });

    test('atLeastOneTarget() test', () {
      expect(ps.atLeastOneTarget([true]), true);
      expect(ps.atLeastOneTarget([false]), false);
      expect(ps.atLeastOneTarget([false, false, false]), false);
      expect(ps.atLeastOneTarget([false, false, true]), true);
    });

    test('computeBalances()', () {
      List l = [];
      for (int i = 0; i < amount.length; i++) {
        l.add(
            {'payedBy': users[i], 'amount': amount[i], 'payedTo': payedTo[i]});
        expect(ps.computeBalances(l), expected[i]);
      }
    });

    test('formatDate()', () {
      DateTime date = DateTime.now();
      String s = ps.formatDate(date);
      expect(
          s,
          '0${date.day}/0${date.month}/${date.year}');
    });
  });
}
