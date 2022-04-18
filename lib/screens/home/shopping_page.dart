import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/product.dart';
import 'package:dima/models/return_payment.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/services/database.dart';
import 'package:dima/shared/loading.dart';
import 'package:dima/shared/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({Key? key}) : super(key: key);

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  bool addProduct = true;
  List<int> selectedItems = [];
  List<Product> allProducts = []; 


  FloatingActionButton _buildRemoveProductFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () async {
        showGeneralDialog(
          barrierLabel: 'deleteProducts',
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
                            ? 'Do you really want to remove this product?'
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
                            List<Product> toBeRemoved = [];
                            for (int index in selectedItems) {
                              toBeRemoved.add(allProducts[index]);
                            }
                            DatabaseService().removeProducts(
                                toBeRemoved, AppData().user.getGroupId());
                            setState(() {
                                addProduct = true;
                                selectedItems.clear();
                              });
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


  FloatingActionButton _buildAddProductFloatingActionButton() {
    final TextEditingController itemController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    return FloatingActionButton.extended(
      label: const Text('Add product'),
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
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
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
                                        'Add product',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                        ),
                                        onPressed: () {
                                          if (itemController.text.isNotEmpty &&
                                              quantityController.text.isNotEmpty &&
                                              double.parse(quantityController.text) > 0 &&
                                              unitController.text.isNotEmpty) { //&&
                                            Product product = Product(
                                                item: itemController.text,
                                                quantity: double.parse(
                                                    quantityController.text),
                                                unit: unitController.text,
                                            );
                                            DatabaseService().addProduct(
                                                product,
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
                                    controller: itemController,
                                    cursorColor: Colors.orangeAccent,
                                    decoration: const InputDecoration(
                                      label: Text(
                                        'Product',
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
                                          controller: quantityController,
                                          inputFormatters: [
                                            DecimalTextInputFormatter(),
                                            LengthLimitingTextInputFormatter(
                                                10),
                                          ],
                                          cursorColor: Colors.orangeAccent,
                                          decoration: const InputDecoration(
                                            label: Text(
                                              'Quantity',
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
                                      Flexible(
                                        child: TextField(
                                          textCapitalization:
                                            TextCapitalization.sentences,
                                          controller: unitController,
                                          cursorColor: Colors.orangeAccent,
                                          decoration: const InputDecoration(
                                            label: Text(
                                              'Unit',
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
                                    ],
                                  ),
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


  Widget createPage() {
    allProducts.clear();
    ReturnPayment rp = ReturnPayment();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('shoppinglist')
          .doc(AppData().user.getGroupId())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.data() == null) {
            return Scaffold(
              body: const Center(
              child: Text('Empty cart'),
              ),
              floatingActionButton: _buildAddProductFloatingActionButton(),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          }
          List list = List.from(snapshot.data!.data()!['shoppinglist']);
          return Scaffold(
            floatingActionButton: addProduct
                ? _buildAddProductFloatingActionButton()
                : _buildRemoveProductFloatingActionButton(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: Scrollbar(
              child: ListView.separated(
                reverse: true,
                shrinkWrap: true,
                itemCount: list.length,
                itemBuilder: (_, index) {
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('Empty cart'),
                    );
                  }
                  Product p = Product(
                    item: list[index]['item'],
                    quantity: list[index]['quantity'].toDouble(),
                    unit: list[index]['unit'],
                  );
                  allProducts.add(p);
                  return GestureDetector(
                    onLongPress: () {
                      if (selectedItems.isEmpty) {
                        setState(() {
                          selectedItems.add(index);
                          addProduct = false;
                        });
                      }
                    },
                    onTap: () {
                      if (!addProduct) {
                        setState(() {
                          if (!selectedItems.contains(index)) {
                            selectedItems.add(index);
                          } else {
                            selectedItems.remove(index);
                            if (selectedItems.isEmpty) {
                              addProduct = true;
                            }
                          }
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: selectedItems.contains(index)
                            ? Colors.blue
                            : Colors.transparent,
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
          );
        } else {
          return const Loading();
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: createPage(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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

