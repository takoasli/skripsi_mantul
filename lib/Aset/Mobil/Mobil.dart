import 'package:aplikasi_revamp/Aset/Mobil/manajemenMobil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../../komponen/bottomNavigation.dart';
import '../../komponen/box.dart';
import '../../komponen/style.dart';
import 'DetailMobil.dart';

class Mobil extends StatefulWidget {
  const Mobil({super.key});

  @override
  State<Mobil> createState() => _MobilState();
}

class _MobilState extends State<Mobil> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF61BF9D),
          title: const Text(
            'Mobil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
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
                'Silahkan Pilih',
                style: TextStyles.title.copyWith(
                  color: Warna.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Box(
                      text: 'Detail Mobil',
                      warna: Warna.green,
                      gambar: 'gambar/mobil.png',
                      halaman: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetailMobil()),
                        );
                      },
                    ),
                    SizedBox(width: 40),
                    Box(
                      text: 'Manajemen Mobil',
                      warna: Warna.green,
                      gambar: 'gambar/manajement aset.png',
                      halaman: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ManajemenMobil()),
                        );
                      },
                    ),
                  ]
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            onPressed: () async {
              String barcode = await FlutterBarcodeScanner.scanBarcode(
                "#FF0000",
                "Cancel",
                true,
                ScanMode.QR,
              );

              print(barcode);
            },
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(
                color: Colors.green,
                width: 6.0,
                style: BorderStyle.solid,
              ),
            ),
            child: Image.asset(
              "gambar/qr_code.png",
              height: 50,
              width: 50,
            ),
          ),
        ),
        bottomNavigationBar: BottomNav(),
      ),
    );
  }
}
