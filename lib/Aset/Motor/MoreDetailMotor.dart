import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Catatan/catatanAset.dart';
import '../../komponen/style.dart';
import '../../qrView.dart';
import '../ControllerLogic.dart';

class MoreDetailMotor extends StatefulWidget {
  const MoreDetailMotor({super.key,
    required this.data});
  final Map<String, dynamic> data;

  @override
  State<MoreDetailMotor> createState() => _MoreDetailMotorState();
}

class _MoreDetailMotorState extends State<MoreDetailMotor> {
  late DateTime targetDate = DateTime(2024, 2, 1);
  late Timer timer;
  double progressValue = 1.0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (DateTime.now().isBefore(targetDate)) {
        setState(() {
          progressValue = targetDate.difference(DateTime.now()).inSeconds /
              targetDate.difference(DateTime(targetDate.year, targetDate.month, 0)).inSeconds;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEEE, dd MMMM y', 'id_ID').format(dateTime);
  }

  Widget buildPriorityLabel(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'low':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.yellow.shade600;
        break;
      case 'high':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        priority,
        style: TextStyle(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.data['Gambar Motor'] ?? '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: Text(
            '${widget.data['ID Motor']}',
            style: TextStyles.title.copyWith(
                fontSize: 20,
                color: Warna.white
            )
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 370,
                  height: 570,
                  decoration: BoxDecoration(
                    color: Warna.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      content: Stack(
                                        children: [
                                          Image.network(imageUrl),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                              )
                                  : Image.asset(
                                'gambar/laptop.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          top: 30,
                          right: 30,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Warna.white,
                            ),
                            child: IconButton(
                              onPressed: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QRView(
                                        assetCollection: "Motor",
                                        assetId: widget.data['ID Motor'],
                                        assetName: widget.data['Merek Motor'],
                                      ),
                                    ));
                              },
                              icon: const Icon(Icons.qr_code_2,
                                  size: 33),
                            ),
                          )
                      ),
                      Positioned(
                          top: 100,
                          right: 30,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Warna.white,
                            ),
                            child: IconButton(
                              onPressed: (){
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.infoReverse,
                                  headerAnimationLoop: false,
                                  animType: AnimType.topSlide,
                                  showCloseIcon: true,
                                  closeIcon: const Icon(Icons.close),
                                  title: 'Peringatan',
                                  desc:
                                  'Silahkan Periksa Aset! Apa Perlu Diservis?',
                                  btnOkOnPress: () {
                                    List<Map<String, dynamic>> kebutuhanMotor = widget.data['Kebutuhan Motor'] ?? [];

                                    // Debugging: Cek hasil
                                    print('Kebutuhan Motor: $kebutuhanMotor');

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Catatan(
                                          List_Kebutuhan: kebutuhanMotor,
                                          ID_Aset: widget.data['ID Motor'],
                                          Nama_Aset: widget.data['Merek Motor'],
                                          Jenis_Aset: widget.data['Jenis Motor'],
                                          lokasiAset: widget.data['Lokasi'],
                                        ),
                                      ),
                                    );
                                  },
                                  btnCancelOnPress: () {},
                                  onDismissCallback: (type) {
                                    debugPrint('button yang ditekan $type');
                                  },
                                ).show();
                              },
                              icon: const Icon(Icons.border_color_outlined,
                                  size: 33),
                            ),
                          )
                      ),
                      Positioned(
                        top: 170,
                        child: Container(
                          width: 300,
                          height: 440,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Kebutuhan Servis',
                                        style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      buildPriorityLabel(widget.data['Prioritas']),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: widget.data['Kebutuhan Motor'].length,
                                        itemBuilder: (context, index) {
                                          final kebutuhanMotor = widget.data['Kebutuhan Motor']
                                          [index]['Nama Kebutuhan Motor'];
                                          final hariKebutuhanMotor =
                                          widget.data['Kebutuhan Motor'][index]
                                          ['Hari Kebutuhan Motor'];
                                          final waktuKebutuhanMotor =
                                          widget.data['Kebutuhan Motor'][index]
                                          ['Waktu Kebutuhan Motor'];

                                          final part = kebutuhanMotor.split(': ');
                                          final hasSplit =
                                          part.length > 1 ? part[1] : kebutuhanMotor;

                                          return SizedBox(
                                            height: 80,
                                            child: ListTile(
                                              dense: true,
                                              contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 8),
                                              title: Padding(
                                                padding: const EdgeInsets.only(bottom: 8.0),
                                                child: Text(
                                                  '- $hasSplit',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  showIndicator(
                                                    getValueIndicator(
                                                        hariKebutuhanMotor,
                                                        epochTimeToData(
                                                            waktuKebutuhanMotor)),
                                                    getProgressColor(
                                                        waktuKebutuhanMotor),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        overflow:
                                                        TextOverflow.ellipsis,
                                                        getRemainingTime(
                                                            waktuKebutuhanMotor),
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                      'Ditambahkan oleh',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                    '${widget.data['Teknisi Yang Menambahkan']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Tanggal dibuat',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500)),
                                  Text(
                                    formatDate(widget.data['Tanggal Dibuat']),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Merek Motor',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Merek Motor']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Status',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Status']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'ID Motor',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['ID Motor']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Kapasitas Mesin',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Kapasitas Mesin']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Sistem Pendingin',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Sistem Pendingin']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Tipe Transmisi',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Tipe Transmisi']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Kapasitas Bahan Bakar',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Kapasitas Bahan Bakar']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Kapasitas Minyak Rem',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Kapasitas Minyak']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Tipe Aki',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Tipe Aki']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Ukuran Ban Depan',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Ban Depan']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 15),

                                  Text(
                                      'Ukuran Ban Belakang',
                                      style: TextStyles.title.copyWith(
                                          fontSize: 18,
                                          color: Warna.darkgrey,
                                          fontWeight: FontWeight.w500
                                      )
                                  ),
                                  Text(
                                    '${widget.data['Ban Belakang']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
