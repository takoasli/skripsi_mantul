import 'package:aplikasi_revamp/komponen/style.dart';
import 'package:aplikasi_revamp/komponen/tombol.dart';
import 'package:flutter/material.dart';

import 'InputKonversi.dart';

class DialogBiaya extends StatelessWidget {
  final NamaBiayacontroller;
  final HargaBiayacontroller;
  final TextJudul;
  VoidCallback onAdd;
  VoidCallback onCancel;

  DialogBiaya({super. key,
    required this.NamaBiayacontroller,
    required this.onAdd,
    required this.onCancel,
    required this.TextJudul,
    required this.HargaBiayacontroller});

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
              const SizedBox(height: 10),
              TextField(
                controller: NamaBiayacontroller,
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
              Text('Biaya Kebutuhan',
                style: TextStyles.body.copyWith(fontSize: 17, color: Warna.white),
                textAlign: TextAlign.left,),
              const SizedBox(height: 10),
              TextField(
                controller: HargaBiayacontroller,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              //tombol
              const SizedBox(height: 10),
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
