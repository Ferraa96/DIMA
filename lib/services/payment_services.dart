import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dima/models/chart_series.dart';
import 'package:dima/services/app_data.dart';

//
class PaymentServices {
  List<String> uids = [];

  void setUids(List<String> uids) {
    this.uids = uids;
  }

  List<charts.Series<ChartSeries, String>> createSeriesList(
      List<double> balances) {
    final List<ChartSeries> data = [];
    for (int i = 0; i < balances.length; i++) {
      data.add(ChartSeries(name: uids[i], balance: balances[i]));
    }
    return [
      charts.Series<ChartSeries, String>(
        id: 'balances',
        domainFn: (ChartSeries s, _) =>
            AppData().group.getUserFromId(s.name)!.getName(),
        measureFn: (ChartSeries s, _) => s.balance,
        colorFn: (ChartSeries s, _) {
          if (s.balance > 0) {
            return charts.MaterialPalette.green.makeShades(2)[0];
          } else {
            return charts.MaterialPalette.red.makeShades(1)[0];
          }
        },
        data: data,
      )
    ];
  }

  bool atLeastOneTarget(List<bool> checkList) {
    for (bool check in checkList) {
      if (check == true) {
        return true;
      }
    }
    return false;
  }

  List<double> computeBalances(List list) {
    List<double> balances = [];
    late double balance;

    for (String name in uids) {
      balance = 0;
      for (var el in list) {
        List<String> payedTo = List<String>.from(el['payedTo']);
        if (el['payedBy'] == name) {
          balance += el['amount'];
        }
        if (payedTo.contains(name)) {
          balance -= el['amount'] / payedTo.length;
        }
      }
      balance = (balance * pow(10, 2)).truncate() / pow(10, 2);
      balances.add(balance);
    }
    return balances;
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().length == 1 ? '0${date.day}' : date.day.toString()}/${date.day.toString().length == 1 ? '0${date.month}' : date.month.toString()}/${date.year}';
  }
}
