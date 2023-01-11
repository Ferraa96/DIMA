// flutter test --no-sound-null-safety test/unit_test/return_payment_models_test.dart

import 'package:dima/models/return_payment.dart';
import 'package:flutter_test/flutter_test.dart';

List<List> values = [
  [ [-95.0,285.0,-45.0,-145.0], {3: [1], 0: [1], 2: [1]}, {3: [145.0], 0: [95.0], 2: [45.0]}, 3 ],
  [ [100.0,100.0,-150.0,-50.0],  {2: [0, 1], 3: [1]}, {2: [100.0, 50.0], 3: [50.0]}, 3],
];

void main() {

  group('UNIT_TEST => ReturnPayment Class => ', () {

    final rp = ReturnPayment();

    test('compute() function', () {
      for (int i=0; i< values.length; i++) {
        rp.compute(values[i][0]);
        expect(rp.toUser, values[i][1]);
        expect(rp.amountToUser, values[i][2]);
        expect(rp.debtNum, values[i][3]);
      }     
    });

    test('getToUser() function', () {
      expect(rp.getToUser(), values[values.length-1][1]);
    });

    test('getAmountToUser() function', () {
      expect(rp.getAmountToUser(), values[values.length-1][2]);
    });

    test('getDebtNum() function', () {
      expect(rp.getDebtNum(), values[values.length-1][3]);
    });


  });

}
