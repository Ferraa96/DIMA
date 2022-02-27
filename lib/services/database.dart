import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/models/shoppingList.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  final CollectionReference shoppingList =
      FirebaseFirestore.instance.collection('shoppingList');

  Future updateUserData(ShoppingList list) async {
    return await shoppingList.doc(uid).set({
      'list': list,
    });
  }
}
