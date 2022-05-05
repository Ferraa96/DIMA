import 'package:dima/services/app_data.dart';
import 'package:flutter/material.dart';

class Product extends StatelessWidget {
  String item;
  double quantity;
  String unit;
  String user;

  Product({
    Key? key,
    required this.item,
    required this.quantity,
    required this.unit,
    required this.user,
  }) : super(key: key);

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
              Text(
                item,
              ),
              Text(
                quantity.toString() + " " + unit,
              ),
            ],
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Added by ' + AppData().group.getUserFromId(user)!.getName(),
            ),
          ),
        ],
      ),
    );
  }
}
