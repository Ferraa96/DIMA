import 'dart:math';

class ReturnPayment {
  late Map<int, List<int>> toUser;
  late Map<int, List<double>> amountToUser;
  late int debtNum;

  void compute(List<double> netAmountList) {
    toUser = {};
    amountToUser = {};
    debtNum = 0;
    int maxCred = 0, maxDebt = 0;
    double balance;
    while (true) {
      for (int i = 0; i < netAmountList.length; i++) {
        if (netAmountList[i] > netAmountList[maxCred]) {
          maxCred = i;
        }
        if (netAmountList[i] < netAmountList[maxDebt]) {
          maxDebt = i;
        }
      }
      if (netAmountList[maxCred] == 0 && netAmountList[maxDebt] == 0) {
        break;
      }
      balance = min(netAmountList[maxCred], -netAmountList[maxDebt]);
      netAmountList[maxCred] -= balance;
      netAmountList[maxDebt] += balance;
      if (!toUser.containsKey(maxDebt)) {
        toUser[maxDebt] = [];
        amountToUser[maxDebt] = [];
      }
      toUser[maxDebt]!.add(maxCred);
      amountToUser[maxDebt]!.add(balance);
      debtNum++;
    }
  }

  Map<int, List<int>> getToUser() {
    return toUser;
  }

  Map<int, List<double>> getAmountToUser() {
    return amountToUser;
  }

  int getDebtNum() {
    return debtNum;
  }
}
