import 'package:aplikasi_revamp/komponen/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../Aset/AC/moreDetailAC.dart';
import '../Aset/Laptop/moreDetailLaptop.dart';
import '../Aset/Mobil/MoreDetailMobil.dart';
import '../Aset/Motor/MoreDetailMotor.dart';
import '../Aset/PC/MoreDetailPC.dart';
import '../dashboard/Dashboards.dart';

class ScanQR extends StatelessWidget {

  Future<Map<String, dynamic>?> fetchDataFromFirestore(String assetCollection, String assetId) async {
    CollectionReference collection = FirebaseFirestore.instance.collection(assetCollection);
    QuerySnapshot querySnapshot;

    switch (assetCollection) {
      case 'Aset':
        querySnapshot = await collection.where('ID AC', isEqualTo: assetId).get();
        break;
      case 'PC':
        querySnapshot = await collection.where('ID PC', isEqualTo: assetId).get();
        break;
      case 'Laptop':
        querySnapshot = await collection.where('ID Laptop', isEqualTo: assetId).get();
        break;
      case 'Motor':
        querySnapshot = await collection.where('ID Motor', isEqualTo: assetId).get();
        break;
      case 'Mobil':
        querySnapshot = await collection.where('ID Mobil', isEqualTo: assetId).get();
        break;
      default:
        return null;
    }

    if (querySnapshot.docs.isNotEmpty) {
      // Jika data ditemukan, mengembalikan data pertama yang cocok
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  String determineAssetType(String barcode) {
    if (barcode.toLowerCase().contains('ac')) {
      return 'Aset';
    } else if (barcode.toLowerCase().contains('pc')) {
      return 'PC';
    } else if (barcode.toLowerCase().contains('laptop')) {
      return 'Laptop';
    } else if (barcode.toLowerCase().contains('motor')) {
      return 'Motor';
    } else if (barcode.toLowerCase().contains('mobil')) {
      return 'Mobil';
    } else {
      return '';
    }
  }

  String extractAssetId(String barcode) {
    List<String> parts = barcode.split(',');
    if (parts.length == 2) {
      return parts[1]; // Mengembalikan bagian kedua sebagai ID
    } else {
      return ''; // Mengembalikan string kosong jika format tidak sesuai
    }
  }


  void navigateToSpecificAsset(BuildContext context, String assetCollection, Map<String, dynamic> data) {
    switch (assetCollection) {
      case 'Aset':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MoreDetailAC(data: data)),
        );
        break;
      case 'PC':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MoreDetail(data: data)),
        );
        break;
      case 'Laptop':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MoreDetailLaptop(data: data)),
        );
        break;
      case 'Motor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MoreDetailMotor(data: data)),
        );
        break;
      case 'Mobil':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MoreDetailmobil(data: data)),
        );
        break;
      default:
        showNotFoundDialog(context, 'QR Tidak Ditemukan!');
        break;
    }
  }



  void showNotFoundDialog(BuildContext context, String barcode) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Gagal!',
      desc: 'Aset Tidak Ditemukan!',
      btnOkOnPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Dashboards()),
        );
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () async {
            String barcode = await FlutterBarcodeScanner.scanBarcode(
              "#FF0000",
              "Cancel",
              true,
              ScanMode.QR,
            );
            if (barcode != '-1') {
              String assetType = determineAssetType(barcode);
              String assetId = extractAssetId(barcode);
              if (assetType.isNotEmpty && assetId.isNotEmpty) {
                Map<String, dynamic>? assetData = await fetchDataFromFirestore(assetType, assetId);
                if (assetData != null) {
                  navigateToSpecificAsset(context, assetType, assetData);
                } else {
                  showNotFoundDialog(context, barcode);
                }
              } else {
                showNotFoundDialog(context, barcode);
              }
            }
            print(barcode);
          },
          backgroundColor: Warna.green,
          child: const Icon(Icons.qr_code_scanner, color: Warna.white)
        ),
      ),
    );
  }
}
