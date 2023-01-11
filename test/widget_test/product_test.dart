// flutter test --no-sound-null-safety test/widget_test/product_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima/models/product.dart';
import 'package:dima/models/group.dart';
import 'package:dima/models/user.dart';

List<MyUser> users = [
  (){final u=MyUser(); u.setUserId('Aa'); u.setName('Aa'); return u;}(),
  (){final u=MyUser(); u.setUserId('Bb'); u.setName('Bb'); return u;}(),
  (){final u=MyUser(); u.setUserId('Cc'); u.setName('Cc'); return u;}(),
];
Group group = (){final g=Group(); g.setGroupCode('GroupCode'); g.setMembers(users); return g;}();
String item = 'Item';
double quantity = 10;
String unit = 'kg';
String category = 'Other';


void main() {

  testWidgets('WIDGET_TEST => Product Class', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(home: Product(
      item:item,
      quantity: quantity,
      unit: unit,
      user: users[0].getUid(),
      category: category,
      group: group
    )));

    expect(find.textContaining(item), findsOneWidget);
    expect(find.textContaining(category), findsOneWidget);
    expect(find.textContaining(quantity.toString()+' '+unit), findsOneWidget);
    expect(find.textContaining('Added by '+users[0].getName()), findsOneWidget);
    
  });

}

