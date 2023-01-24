import 'package:dima/services/app_data.dart';
import 'package:flutter/material.dart';
import 'package:dima/models/group.dart';

class Payment extends StatelessWidget {
  String title;
  double amount;
  String date;
  String payedBy;
  List<String> payedTo;
  Group group;
  Payment(
      {Key? key,
      required this.title,
      required this.amount,
      required this.date,
      required this.payedBy,
      required this.payedTo,
      required this.group,
      })
      : super(key: key);

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
              Text(group.getUserFromId(payedBy)!.getName()),
              const Text(' payed '),
              Text(amount.toString() + ' € to '),
              ...() {
                List<Widget> list = [];
                for (int i = 0; i < payedTo.length; i++) {
                  if (i == 0) {
                    list.add(Text(
                        group.getUserFromId(payedTo[0])!.getName()));
                  } else if (i == payedTo.length - 1) {
                    list.add(Text(' and ' +
                        group.getUserFromId(payedTo[i])!.getName()));
                  } else {
                    list.add(Text(', ' +
                        group.getUserFromId(payedTo[i])!.getName()));
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
