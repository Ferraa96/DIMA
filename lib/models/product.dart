import 'package:flutter/material.dart';

class Product extends StatelessWidget {
  String item;
  double quantity;
  String unit;

  Product(
      {Key? key, required this.item,
      required this.quantity,
      required this.unit}) : super(key: key);


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
                Text(item),
                Text(quantity.toString()+" "+unit),
              ],
            ),
          ],
        ),
    );
  }
}
