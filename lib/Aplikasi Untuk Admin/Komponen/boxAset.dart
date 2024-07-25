import 'package:flutter/material.dart';

import '../../komponen/style.dart';

class BoxAset extends StatelessWidget {
  const BoxAset({
    Key? key,
    required this.text,
    required this.gambar,
    required this.halaman,
  }) : super(key: key);

  final String text;
  final ImageProvider<Object> gambar;
  final VoidCallback halaman;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: halaman,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Warna.Blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: gambar,
                  width: 60,
                  height: 40,
                ),
                SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyles.title.copyWith(fontSize: 16, color: Warna.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
