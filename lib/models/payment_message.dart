import 'package:flutter/material.dart';

class Payment extends StatelessWidget {
  String title;
  double amount;
  String date;
  String payedBy;
  List<String> payedTo;

  Payment(
      {Key? key, required this.title,
      required this.amount,
      required this.date,
      required this.payedBy,
      required this.payedTo}) : super(key: key);

  String getPayedBy() {
    return payedBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                Text(date),
              ],
            ),
            const Divider(),
            Wrap(
              children: [
                Text(payedBy),
                const Text(' payed '),
                Text(amount.toString() + ' € to '),
                ...() {
                  List<Widget> list = [];
                  for (int i = 0; i < payedTo.length; i++) {
                    if (i == 0) {
                      list.add(Text(payedTo[0]));
                    } else if (i == payedTo.length - 1) {
                      list.add(Text(' and ' + payedTo[i]));
                    } else {
                      list.add(Text(', ' + payedTo[i]));
                    }
                  }
                  return list;
                }(),
              ],
            ),
          ],
        ),
    );
  }
}
