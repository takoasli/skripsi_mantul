import 'package:aplikasi_revamp/komponen/style.dart';
import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  const Box({
    Key? key,
    required this.text,
    required this.gambar,
    required this.halaman,
    required this.warna,
  }) : super(key: key);

  final String text;
  final String gambar;
  final Color warna;
  final VoidCallback halaman;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: halaman,
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: warna,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(
              gambar,
              width: 40,
              height: 40,
            ),
          ),
          SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyles.title.copyWith(fontSize: 14, color: Warna.black),
          ),
        ],
      ),
    );
  }
}
