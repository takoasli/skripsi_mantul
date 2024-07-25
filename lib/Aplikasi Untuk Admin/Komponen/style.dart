import 'package:flutter/material.dart';

class Warna {
  static const Blue = Color(0XFF60C1CB);
  static const green = Color(0XFF61BF9D);
  static const grey = Color(0XFFC6C6C6);
  static const lightgreen = Color(0XFF73E17E);
  static const yellow = Color(0XFFF9CF3B);
  static const red = Color(0XFFEF5C5C);
  static const white = Color(0XFFFFFFFF);
  static const black = Color(0XFF1A1A1A);
  static const darkgrey = Color(0XFF2F2F2F);
}

class TextStyles {
  static TextStyle title = const TextStyle(
    fontFamily: 'Righteus',
    fontWeight: FontWeight.bold,
    fontSize: 40.0,
  );

  static TextStyle body = const TextStyle(
      fontFamily: 'Righteus',
      fontWeight: FontWeight.normal,
      fontSize: 16.0
  );
}