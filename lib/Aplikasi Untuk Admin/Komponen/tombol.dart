import 'package:flutter/material.dart';

import '../../komponen/style.dart';

class Tombol extends StatelessWidget {
  final String text;
  VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  Tombol({super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        onPressed: onPressed,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(text,
      style: TextStyles.body.copyWith(
          color: textColor,
      fontSize: 15),
      ),
    );
  }
}
