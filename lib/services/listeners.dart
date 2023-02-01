import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/services/app_data.dart';
import 'package:dima/shared/constants.dart';
import 'package:flutter/material.dart';

class Listeners extends ChangeNotifier {
  Function notifyChange;
  Listeners({required this.notifyChange});
  List<Stream<DocumentSnapshot<Map<String, dynamic>>>> streamList = [];
  List<String> groupList = [];
  List chatList = [];
  List paymentsList = [];
  List remindersList = [];
  List shoppingList = [];

  void startListening() {
    print("START LISTENING");
    String groupId = AppData().user.getGroupId();
    Stream<DocumentSnapshot<Map<String, dynamic>>> groupReference =
        FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .snapshots();
    groupReference.listen((event) {
      groupList =
          event.data() == null ? [] : List.from(event.data()!['members']);
      notifyChange(0);
    });

    bool listenChat = false;
    Stream<DocumentSnapshot<Map<String, dynamic>>> chatReference =
        FirebaseFirestore.instance.collection('chats').doc(groupId).snapshots();
    chatReference.listen((event) {
      if (event.data() != null) {
        chatList = event.data()!['messages'];
      }
      if (listenChat) {
        notifyChange(1);
      } else {
        listenChat = true;
      }
    });
    streamList.add(chatReference);

    bool listenPayment = false;
    Stream<DocumentSnapshot<Map<String, dynamic>>> paymentsReference =
        FirebaseFirestore.instance
            .collection('payments')
            .doc(groupId)
            .snapshots();
    paymentsReference.listen((event) {
      if (event.data() != null) {
        paymentsList = event.data()!['payments'];
      }
      if (listenPayment) {
        notifyChange(2);
      } else {
        listenPayment = true;
      }
    });
    streamList.add(paymentsReference);

    bool listenReminder = false;
    Stream<DocumentSnapshot<Map<String, dynamic>>> remindersReference =
        FirebaseFirestore.instance
            .collection('reminders')
            .doc(groupId)
            .snapshots();
    remindersReference.listen((event) {
      if (event.data() != null) {
        remindersList = event.data()!['reminders'];
        remindersList.sort((a, b) => (b['dateTime'] as Timestamp)
            .toDate()
            .compareTo((a['dateTime'] as Timestamp).toDate()));
      }
      if (listenReminder) {
        notifyChange(3);
      } else {
        listenReminder = true;
      }
    });
    streamList.add(remindersReference);

    bool listenShopping = false;
    Stream<DocumentSnapshot<Map<String, dynamic>>> shoppingListReference =
        FirebaseFirestore.instance
            .collection('shoppingList')
            .doc(groupId)
            .snapshots();
    shoppingListReference.listen((event) {
      if (event.data() != null) {
        shoppingList = event.data()!['shoppingList'];
        sortListPerCategory();
      }
      if (listenShopping) {
        notifyChange(4);
      } else {
        listenShopping = true;
      }
    });
    streamList.add(shoppingListReference);
  }

  void sortListPerCategory() {
    List newList = [];
    for (String cat in categories) {
      for (int i = 0; i < shoppingList.length; i++) {
        if (newList.length == shoppingList.length) {
          break;
        }
        if (shoppingList[i]['category'] == cat) {
          newList.add(shoppingList[i]);
        }
      }
    }
    shoppingList = newList;
  }

  List<String> getGroupList() {
    return groupList;
  }

  List getChatsList() {
    return chatList;
  }

  List getPaymentsList() {
    return paymentsList;
  }

  List getRemindersList() {
    return remindersList;
  }

  List getShoppingList() {
    return shoppingList;
  }
}
