import 'package:dima/services/app_data.dart';
import 'package:flutter/material.dart';

class Product extends StatelessWidget {
  String item;
  double quantity;
  String unit;
  String user;
  String category;

  Product({
    Key? key,
    required this.item,
    required this.quantity,
    required this.unit,
    required this.user,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item),
              Text(quantity.toString() + ' ' + unit),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(category),
              Text('Added by ' + AppData().group.getUserFromId(user)!.getName()),
            ],
          ),
        ],
      ),
    );
  }
}
