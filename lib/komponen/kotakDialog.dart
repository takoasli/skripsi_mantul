import 'package:aplikasi_revamp/komponen/style.dart';
import 'package:aplikasi_revamp/komponen/tombol.dart';
import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final controller;
  final TextJudul;
  final JangkaKebutuhan;
  VoidCallback onAdd;
  VoidCallback onCancel;

  DialogBox({super. key,
    required this.controller,
    required this.onAdd,
    required this.onCancel,
    required this.TextJudul,
    this.JangkaKebutuhan});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Warna.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      content: SingleChildScrollView(
        child: Container(
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(TextJudul,
              style: TextStyles.body.copyWith(fontSize: 17, color: Warna.white),
              textAlign: TextAlign.left,),
              const SizedBox(height: 7),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text('Masa Kebutuhan (perbulan)',
                style: TextStyles.body.copyWith(fontSize: 17, color: Warna.white),
                textAlign: TextAlign.left,),
              const SizedBox(height: 10),
              TextField(
                controller: JangkaKebutuhan,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tombol(
                      text: 'Add',
                      onPressed: onAdd,
                      backgroundColor: Colors.green.shade500,
                      textColor: Warna.white,),
                  const SizedBox(width: 15),
                  Tombol(
                      text: 'Cancel',
                      onPressed: onCancel,
                    backgroundColor: Warna.white,
                    textColor: Warna.darkgrey)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
