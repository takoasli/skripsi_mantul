import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../komponen/style.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({Key? key,
    required this.textInputType,
    required this.hint,
    required this.textInputAction,
    required this.controller,
    this.isObscure = false,
    this.hasSuffix = false,
    this.onPress,
    this.inputFormatters,
    this.validator});


  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final TextEditingController controller;
  final String hint;
  final bool isObscure;
  final bool hasSuffix;
  final VoidCallback ? onPress;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: TextFormField(
        textAlign: TextAlign.left,
        controller: controller,
        keyboardType: textInputType,
        obscureText: isObscure,
        style: TextStyles.body,
        decoration: InputDecoration(
          suffixIcon: hasSuffix ? IconButton(
            onPressed: onPress, icon: Icon(
            isObscure ? Icons.visibility : Icons.visibility_off,
            color: Warna.grey,
          ),
          )
              :null,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.0,
              color: Warna.grey,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1.0,
              color: Warna.grey,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          hintText: hint,
          hintStyle: TextStyles.body.copyWith(color: Warna.grey),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
