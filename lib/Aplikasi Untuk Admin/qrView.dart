import 'dart:typed_data';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'komponen/style.dart';
import 'package:device_info_plus/device_info_plus.dart';

class QRView extends StatefulWidget {
  const QRView({
    Key? key,
    required this.assetCollection,
    required this.assetId,
    required this.assetName,
  }) : super(key: key);

  final String assetCollection;
  final String assetId;
  final String assetName;

  @override
  State<QRView> createState() => _QRViewState();
}

class _QRViewState extends State<QRView> {
  late String idAset;
  late String namaAset;
  final GlobalKey _qrImageGlobalKey = GlobalKey();
  Uint8List? _imageData;

  Future<bool> _request_per(Permission permission) async {
    AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
    if (build.version.sdkInt >= 30) {
      var re = await Permission.manageExternalStorage.request();
      return re.isGranted;
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        return result.isGranted;
      }
    }
  }

  Future<void> PermissionAja() async {
    if (_imageData != null) {
      if (await _request_per(Permission.storage)) {
        final result = await ImageGallerySaver.saveImage(_imageData!);
        if (result['isSuccess']) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Berhasil!',
            desc: 'QR Code berhasil Diunduh',
            btnOkOnPress: () {
              Navigator.of(context).pop();
            },
            autoHide: const Duration(seconds: 5),
          ).show();
          print('QR Code berhasil Diunduh');
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Gagal!',
            desc: 'QR Code Gagal Diunduh',
            btnOkOnPress: () {
              Navigator.of(context).pop();
            },
            autoHide: const Duration(seconds: 5),
          ).show();
          print('QR Code Gagal Diunduh: ${result['error']}');
        }
      } else {
        // Izin tidak diberikan
        print('Permission denied');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Izin Ditolak!',
          desc: 'Izin penyimpanan diperlukan untuk mengunduh QR Code',
          btnOkOnPress: () {
            Navigator.of(context).pop();
          },
          autoHide: const Duration(seconds: 5),
        ).show();
      }
    }
  }

  Future<void> AmbilGambar() async {
    try {
      if (_qrImageGlobalKey.currentContext != null) {
        RenderRepaintBoundary boundary = _qrImageGlobalKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        if (boundary != null) {
          var image = await boundary.toImage(pixelRatio: 3.0);
          ByteData? byteData =
          await image.toByteData(format: ImageByteFormat.png);
          if (byteData != null) {
            setState(() {
              _imageData = byteData.buffer.asUint8List();
            });
          } else {
            print('ByteData is null');
          }
        } else {
          print('RenderRepaintBoundary is null');
        }
      } else {
        print('RepaintBoundary context is null');
      }
    } catch (e) {
      print('Error while capturing QR Code image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    idAset = '${widget.assetId}';
    namaAset = '${widget.assetName}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.Blue,
      appBar: AppBar(
        backgroundColor: Warna.Blue,
        title: const Text(
          'QR Code',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 370,
            height: 585,
            decoration: BoxDecoration(
              color: Warna.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                RepaintBoundary(
                  key: _qrImageGlobalKey,
                  child: Column(
                    children: [
                      Container(
                        height: 170,
                        width: 170,
                        child: QrImageView(
                          data: '${widget.assetCollection},${widget.assetId}',
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Warna.white,
                        ),
                      ),
                      const SizedBox(height: 10), // Spasi antara gambar QR dan teks baru
                      Container(
                        color: Warna.white,
                        child: Text(
                          'Nama : $namaAset',
                          style: TextStyles.title.copyWith(fontSize: 25, color: Warna.darkgrey
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        color: Warna.white,
                        child: Text(
                            'ID : $idAset',
                            style: TextStyles.body.copyWith(fontSize: 20, color: Warna.darkgrey)
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await AmbilGambar();
                    await PermissionAja();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Warna.Blue,
                    minimumSize: const Size(170, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Download',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: Warna.white
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cara Mengaplikasikan\n QR Code ke Aset",
                      style: TextStyles.title
                          .copyWith(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "1. Download Gambar QR Code",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    const Text("2. Print Gambar QR Code",
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 5),
                    const Text("3. Tempelkan Gambar QR Code ke \n     Unit Aset",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
