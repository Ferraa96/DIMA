import 'package:flutter/material.dart';

class Formatter {
  String formatDate(DateTime date) {
    return (date.day.toString().length == 1
            ? '0' + date.day.toString()
            : date.day.toString()) +
        '/' +
        (date.day.toString().length == 1
            ? '0' + date.month.toString()
            : date.month.toString()) +
        '/' +
        date.year.toString();
  }

  String formatTime(TimeOfDay time) {
    return (time.hour.toString().length == 1
            ? '0' + time.hour.toString()
            : time.hour.toString()) +
        ':' +
        (time.minute.toString().length == 1
            ? '0' + time.minute.toString()
            : time.minute.toString());
  }

  String formatDateAndTime(DateTime dateTime) {
    return (dateTime.day.toString().length == 1
            ? '0' + dateTime.day.toString()
            : dateTime.day.toString()) +
        '/' +
        (dateTime.day.toString().length == 1
            ? '0' + dateTime.month.toString()
            : dateTime.month.toString()) +
        '/' +
        dateTime.year.toString() + ' ' +
        (dateTime.hour.toString().length == 1
            ? '0' + dateTime.hour.toString()
            : dateTime.hour.toString()) +
        ':' +
        (dateTime.minute.toString().length == 1
            ? '0' + dateTime.minute.toString()
            : dateTime.minute.toString());
  }
}
