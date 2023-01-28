import 'package:flutter/material.dart';
import 'package:dima/models/group.dart';

class Product extends StatelessWidget {
  String item;
  double quantity;
  String unit;
  String user;
  String category;
  Group group;
  Product({
    Key? key,
    required this.item,
    required this.quantity,
    required this.unit,
    required this.user,
    required this.category,
    required this.group,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item),
                Text('$quantity $unit'),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(category),
                Text('Added by ${group.getUserFromId(user)!.getName()}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
