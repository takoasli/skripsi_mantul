import 'package:flutter/material.dart';
import 'Aset/AC/DetailAC.dart';
import 'Aset/Laptop/DetailLaptop.dart';
import 'Aset/Mobil/DetailMobil.dart';
import 'Aset/Motor/DetailMotor.dart';
import 'Aset/PC/DetailPC.dart';
import 'komponen/box.dart';
import 'komponen/style.dart';

class PilihInfoAset extends StatefulWidget {
  const PilihInfoAset({Key? key}) : super(key: key);

  @override
  State<PilihInfoAset> createState() => _PilihInfoAset();
}

class _PilihInfoAset extends State<PilihInfoAset> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Warna.green,
          title: const Text(
            'Aset Info',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Warna.white
            ),
          ),
          elevation: 0,
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(17.0),
              child: Text(
                'Silahkan Pilih Aset',
                style: TextStyles.title.copyWith(
                  color: Warna.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Box(
                  text: 'AC',
                  warna: Warna.green,
                  gambar: 'gambar/ac.png',
                  halaman: () {
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DetailAC()),
                      );
                  },
                ),
                Box(
                  text: 'PC',
                  warna: Warna.green,
                  gambar: 'gambar/pc.png',
                  halaman: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DetailPC()),
                    );
                  },
                ),
                Box(
                  text: 'Motor',
                  warna: Warna.green,
                  gambar: 'gambar/motor.png',
                  halaman: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DetailMotor()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Box(
                      text: 'Mobil',
                      warna: Warna.green,
                      gambar: 'gambar/mobil.png',
                      halaman: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DetailMobil()),
                        );
                      },
                    ),

                    Box(
                        text: 'Laptop',
                        gambar: 'gambar/lepi2.png',
                        halaman: (){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DetailLaptop()),
                          );
                        },
                        warna: Warna.green)
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
