import 'dart:ui';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dima/models/chart_series.dart';
import 'package:dima/models/payment_message.dart';
import 'package:dima/models/return_payment.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/constants.dart';
import 'package:dima/shared/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentsPage extends StatelessWidget {
  final List paymentsList;
  PaymentsPage({Key? key, required this.paymentsList}) : super(key: key);

  List<String> uids = [];
  String payedBy = '0';
  List<bool> checkList = [];
  bool allChecked = false;
  late String pickedDate;
  List<double> balances = [];
  int currPage = 0;
  List<DropdownMenuItem<String>> menuItems = [];
  bool addPayment = true;
  List<int> selectedItems = [];
  List<Payment> allPayments = [];
  late BuildContext context;

  bool _atLeastOneTarget() {
    for (bool check in checkList) {
      if (check == true) {
        return true;
      }
    }
    return false;
  }

  List<charts.Series<ChartSeries, String>> _createSeriesList(
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

  Widget _buildSummary(List list) {
    // NAMES HAVE TO BE ALL DIFFERENT IN THE SAME GROUP!!!
    late double balance;
    balances.clear();
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
      balance = (balance * 100).round().toDouble() / 100;
      balances.add(balance);
    }
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: charts.BarChart(
        _createSeriesList(balances),
        primaryMeasureAxis: const charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              color: charts.MaterialPalette.white,
            ),
          ),
        ),
        domainAxis: const charts.OrdinalAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              color: charts.MaterialPalette.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSummaryElements(ReturnPayment rp, List list) {
    return Scrollbar(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: () {
          rp.compute(balances);
          return rp.getDebtNum();
        }(),
        itemBuilder: (_, index) {
          Map<int, List<int>> toUser = rp.getToUser();
          Map<int, List<double>> amountToUser = rp.getAmountToUser();
          return Column(
            children: [
              ...() {
                List<Container> list = [];
                int i = 0;
                int j = 0;
                int totalLen = 0;
                int listLen;
                for (;; i++) {
                  listLen = toUser.values.elementAt(i).length;
                  totalLen += listLen;
                  if (totalLen > index) {
                    for (j = 0; j < listLen; j++) {
                      if ((totalLen - listLen + j) == index) {
                        break;
                      }
                    }
                    break;
                  }
                }
                int debtor = AppData()
                    .group
                    .getUserIndexFromId(uids[toUser.keys.elementAt(i)]);
                int creditor = AppData()
                    .group
                    .getUserIndexFromId(uids[toUser.values.elementAt(i)[j]]);
                list.add(
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          colors[debtor % colors.length],
                          colors[creditor % colors.length],
                        ],
                      ),
                    ),
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 8, right: 8, top: 2, bottom: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppData().group.getList()[debtor].getName(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              const Text('ows',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              ),
                              Text(
                                'to ' +
                                    AppData()
                                        .group
                                        .getList()[creditor]
                                        .getName(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            amountToUser.values.elementAt(i)[j].toString() +
                                ' €',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                return list;
              }(),
            ],
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 5,
          );
        },
      ),
    );
  }

  FloatingActionButton _buildRemovePaymentFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        showGeneralDialog(
          barrierLabel: 'deletePayments',
          barrierDismissible: true,
          context: context,
          pageBuilder: (ctx, a1, a2) {
            return Container();
          },
          transitionBuilder: (ctx, a1, a2, child) {
            var curve = Curves.easeInOut.transform(a1.value);
            return Transform.scale(
              scale: curve,
              child: Dialog(
                backgroundColor: ThemeProvider().isDarkMode
                    ? Colors.grey[900]
                    : Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        selectedItems.length == 1
                            ? 'Do you really want to remove this payment?'
                            : 'Do you really want to remove these ${selectedItems.length} payments?',
                        style: TextStyle(
                          color: ThemeProvider().isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            List<Payment> toBeRemoved = [];
                            for (int index in selectedItems) {
                              toBeRemoved.add(allPayments[index]);
                            }
                            DatabaseService().removePayments(
                                toBeRemoved, AppData().user.getGroupId());
                            Navigator.of(ctx).pop();
                          },
                          child: const Text(
                            'Remove',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text(
                            'No',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      icon: const Icon(Icons.delete),
      label: const Text('Remove'),
    );
  }

  FloatingActionButton _buildAddPaymentFloatingActionButton() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    return FloatingActionButton.extended(
      label: const Text(
        'Add payment',
      ),
      icon: const Icon(
        Icons.add,
      ),
      onPressed: () {
        showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          context: context,
          builder: (
            BuildContext context,
          ) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: GestureDetector(
                    onTap: () {},
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.6,
                      minChildSize: 0.1,
                      maxChildSize: 0.9,
                      builder: (_, controller) {
                        return Container(
                          decoration: BoxDecoration(
                            color: ThemeProvider().isDarkMode
                                ? const Color(0xff000624)
                                : Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(
                              right: 10,
                              left: 10,
                            ),
                            child: Scrollbar(
                              child: ListView(
                                controller: controller,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Add payment',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                        ),
                                        onPressed: () {
                                          if (titleController.text.isNotEmpty &&
                                              amountController
                                                  .text.isNotEmpty &&
                                              double.parse(
                                                      amountController.text) >
                                                  0 &&
                                              _atLeastOneTarget()) {
                                            List<String> payedTo = [];
                                            for (int i = 0;
                                                i < checkList.length;
                                                i++) {
                                              if (checkList[i]) {
                                                payedTo.add(AppData()
                                                    .group
                                                    .getList()[i]
                                                    .getUid());
                                              }
                                            }
                                            Payment payment = Payment(
                                                title: titleController.text,
                                                amount: double.parse(
                                                    amountController.text),
                                                date: pickedDate,
                                                payedBy:
                                                    uids[int.parse(payedBy)],
                                                payedTo: payedTo);
                                            DatabaseService().addPayment(
                                                payment,
                                                AppData().user.getGroupId());
                                            Navigator.of(context).pop();
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Set a value for all the fields');
                                          }
                                        },
                                        child: const Icon(Icons.check),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  TextField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: titleController,
                                    cursorColor: Colors.orangeAccent,
                                    decoration: const InputDecoration(
                                      label: Text(
                                        'Title',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: amountController,
                                          inputFormatters: [
                                            DecimalTextInputFormatter(),
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                          cursorColor: Colors.orangeAccent,
                                          decoration: const InputDecoration(
                                            label: Text(
                                              'Amount',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Text('€'),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      Text(pickedDate),
                                      IconButton(
                                        onPressed: () {
                                          showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2030),
                                          ).then((value) {
                                            if (value != null) {
                                              setState(() {
                                                pickedDate = _formatDate(value);
                                              });
                                            }
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.calendar_today_outlined,
                                          color: Colors.orangeAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      const Text('Payed by'),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      DropdownButton<String>(
                                        hint: Text(AppData().user.getName()),
                                        value: payedBy,
                                        items: menuItems,
                                        onChanged: (newValue) {
                                          setState(() {
                                            payedBy = newValue!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('To whom'),
                                      Row(
                                        children: [
                                          const Text('Select all'),
                                          Checkbox(
                                            activeColor: Colors.orangeAccent,
                                            checkColor: Colors.black,
                                            value: allChecked,
                                            onChanged: (isChecked) {
                                              setState(
                                                () {
                                                  allChecked = isChecked!;
                                                  for (int i = 0;
                                                      i < checkList.length;
                                                      i++) {
                                                    checkList[i] = isChecked;
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ..._constructCheckBoxes(setState),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget createPage(Function setState) {
    ReturnPayment rp = ReturnPayment();
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Colors.orangeAccent,
            tabs: [
              Tab(
                icon: Icon(Icons.list),
                text: 'Payments',
              ),
              Tab(
                icon: Icon(Icons.auto_graph),
                text: 'Summary',
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: TabBarView(
              children: [
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Scrollbar(
                    child: ListView.separated(
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: paymentsList.length,
                      itemBuilder: (_, index) {
                        if (paymentsList.isEmpty) {
                          return const Center(
                            child: Text('No payments so far'),
                          );
                        }
                        Payment p = Payment(
                          title: paymentsList[index]['title'],
                          amount: paymentsList[index]['amount'],
                          date: paymentsList[index]['date'],
                          payedBy: paymentsList[index]['payedBy'],
                          payedTo:
                              List<String>.from(paymentsList[index]['payedTo']),
                        );
                        allPayments.add(p);
                        return GestureDetector(
                          onLongPress: () {
                            if (selectedItems.isEmpty) {
                              selectedItems.add(index);
                              setState(() {
                                addPayment = false;
                              });
                            }
                          },
                          onTap: () {
                            if (!addPayment) {
                              if (!selectedItems.contains(index)) {
                                setState(() {
                                  selectedItems.add(index);
                                });
                              } else {
                                setState(() {
                                  selectedItems.remove(index);
                                  if (selectedItems.isEmpty) {
                                    addPayment = true;
                                  }
                                });
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colors[AppData()
                            .group
                            .getUserIndexFromId(p.payedBy) %
                        colors.length],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: selectedItems.contains(index)
                                  ? Colors.blue
                                  : colors[AppData()
                            .group
                            .getUserIndexFromId(p.payedBy) %
                        colors.length].withOpacity(0.6),
                            ),
                            margin: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: p,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: ((context, constraints) {
                    double height =
                        window.physicalSize.height / window.devicePixelRatio;
                    double width =
                        window.physicalSize.width / window.devicePixelRatio;
                    if (constraints.maxWidth < constraints.maxHeight) {
                      return Column(
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: height / 5,
                            ),
                            child: _buildSummary(paymentsList),
                          ),
                          const Divider(),
                          _getSummaryElements(rp, paymentsList),
                        ],
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: width / 2,
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            child: _buildSummary(paymentsList),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: width / 2,
                            ),
                            child: _getSummaryElements(rp, paymentsList),
                          ),
                        ],
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _constructCheckBoxes(Function setState) {
    List<Widget> list = [];
    for (int i = 0; i < AppData().group.getList().length; i++) {
      list.add(
        Row(
          children: [
            Checkbox(
              activeColor: Colors.orangeAccent,
              checkColor: Colors.black,
              value: checkList[i],
              onChanged: (isChecked) {
                setState(() {
                  checkList[i] = isChecked!;
                });
              },
            ),
            Text(AppData().group.getList()[i].getName()),
          ],
        ),
      );
    }
    return list;
  }

  String _formatDate(DateTime date) {
    return (date.day.toString().length == 1
            ? '0' + date.day.toString()
            : date.day.toString()) +
        '/' +
        (date.day.toString().length == 1
            ? '0' + date.month.toString()
            : date.month.toString()) +
        '/' +
        date.year.toString();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    menuItems.clear();
    uids.clear();
    for (int i = 0; i < AppData().group.getList().length; i++) {
      checkList.add(false);
      menuItems.add(DropdownMenuItem(
        child: Text(AppData().group.getList()[i].getName()),
        value: i.toString(),
      ));
      uids.add(AppData().group.getList()[i].getUid());
    }
    DateTime date = DateTime.now();
    pickedDate = _formatDate(date);
    return StatefulBuilder(builder: (context, setState) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          margin: const EdgeInsets.only(top: 10),
          child: paymentsList.isNotEmpty
              ? createPage(setState)
              : const Center(
                  child: Text('Add a payment'),
                ),
        ),
        floatingActionButton: addPayment
            ? _buildAddPaymentFloatingActionButton()
            : _buildRemovePaymentFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    });
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final RegExp regEx = RegExp(r'^\d*\.?\d*');
    if (newValue.text == '.') {
      return oldValue;
    }
    final String newString = regEx.stringMatch(newValue.text) ?? '';
    return newString == newValue.text ? newValue : oldValue;
  }
}
