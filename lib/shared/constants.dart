import 'package:flutter/material.dart';

var textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  hintStyle: const TextStyle(
    color: Colors.grey,
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(width: 1, color: Colors.white),
    borderRadius: BorderRadius.circular(30),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: const BorderSide(width: 2, color: Colors.red),
    borderRadius: BorderRadius.circular(30),
  ),
  contentPadding: const EdgeInsets.symmetric(
    vertical: 10.0,
    horizontal: 15.0,
  ),
);

final List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.lime];
