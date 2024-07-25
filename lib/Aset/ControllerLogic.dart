import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../komponen/style.dart';

// Hitung perbandingan tanggal berupa hari
int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

// Hitung waktu service
DateTime contTimeService(int month) {
  var timeNow = DateTime.now();
  return DateTime(timeNow.year, timeNow.month + month, timeNow.day);
}

// Convert epoch to time
DateTime epochTimeToData(int epochTime) {
  return DateTime.fromMillisecondsSinceEpoch(epochTime, isUtc: true);
}

Color getProgressColor(int waktu) {
  var timeProgress = epochTimeToData(waktu);
  Duration difference = timeProgress.difference(DateTime.now());
  var sisaHari = difference.inDays;

  if (sisaHari < 0){
    return Colors.red;
  }

  if (sisaHari >= 20) {
    return Colors.green;
  } else if (sisaHari >= 15) {
    return Colors.yellow;
  } else {
    return Colors.red;
  }
}

String getRemainingTime(int epochTime) {
  var timeProgress = epochTimeToData(epochTime);
  Duration difference = timeProgress.difference(DateTime.now());
  int days = difference.inDays;

  if (days < 0){
    return 'Waktu Habis';
  }

  int months = days ~/ 30;
  int remainingDays = days % 30;
  int hours = difference.inHours % 24;
  int minutes = difference.inMinutes % 60;
  int seconds = difference.inSeconds % 60;

  String timeRemaining = '';
  if (months > 0) {
    timeRemaining += '$months bulan ';
  }
  if (remainingDays > 0) {
    timeRemaining += '$remainingDays hari ';
  }
  if (hours > 0) {
    timeRemaining += '$hours jam ';
  }
  if (minutes > 0) {
    timeRemaining += '$minutes menit ';
  }
  if (seconds > 0) {
    timeRemaining += '$seconds detik';
  }
  if (timeRemaining.isEmpty) {
    timeRemaining = 'Waktu habis';
  }

  return timeRemaining;
}

double getValueIndicator(int totalHari, DateTime service) {
  int sisaHari = daysBetween(DateTime.now(), service);
  var sisa = sisaHari / totalHari * 100;
  var value = sisa / 100;
  return value.toDouble();
}

LinearProgressIndicator showIndicator(double value, Color color) {
  return LinearProgressIndicator(
      borderRadius: BorderRadius.circular(20.0),
      backgroundColor: Colors.grey[300],
      minHeight: 15,
      color: color,
      value: value);
}

String convertToRupiah(dynamic number) {
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return currencyFormatter.format(number);
}

class CatatanBiaya {
  CatatanBiaya(this.nama, this.biaya);
  late String nama;
  late double biaya;
}

class Notif{
  static Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async{
    var androidInitialize = new AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationsSettings = new InitializationSettings(android: androidInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  static Future showTextNotif({required int id, required String judul, required String body, var payload, required FlutterLocalNotificationsPlugin fln}) async{
    AndroidNotificationDetails androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'Channel ID',
        'Nama Channel',
        playSound: true,
        importance: Importance.high
    );

    var noti = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(
        0, judul, body, noti);
  }
}

Future<void> exportExcel(
    {required dokumenCatatan,
      required String namafile,
      required BuildContext context}) async {
  excel.Excel eksel = excel.Excel.createExcel();
  print('Tombol Export Ditekan!');
  eksel.rename(eksel.getDefaultSheet()!, 'Catatan Servis');
  excel.Sheet sheet = eksel['Catatan Servis'];
  sheet.setColumnAutoFit(1); // No
  sheet.setColumnWidth(1, 5);

  sheet.setColumnAutoFit(2); // Tanggal Dibuat

  sheet.setColumnAutoFit(3); // keterangan
  sheet.setColumnWidth(3, 40);

  sheet.setColumnWidth(4, 20); // total biaya
  sheet.setColumnAutoFit(4);


  //isi tiap judul excell

  //judulnya
  var cellD1 = sheet.cell(excel.CellIndex.indexByString("D1"));
  cellD1.value = const excel.TextCellValue('Catatan Servis');
  sheet.merge(excel.CellIndex.indexByString("B1"), excel.CellIndex.indexByString("H2"));
  cellD1.cellStyle = excel.CellStyle(
      backgroundColorHex: excel.ExcelColor.blue,
      fontSize: 12,
      verticalAlign: excel.VerticalAlign.Center,
      horizontalAlign: excel.HorizontalAlign.Center);

  //nomor
  var cellA4 = sheet.cell(excel.CellIndex.indexByString("B5"));
  cellA4.value = const excel.TextCellValue('NO');
  cellA4.cellStyle = excel.CellStyle(
      backgroundColorHex: excel.ExcelColor.brown100,
      leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      fontSize: 12,
      verticalAlign: excel.VerticalAlign.Center,
      horizontalAlign: excel.HorizontalAlign.Center);

  //tanggal
  var cellB4 = sheet.cell(excel.CellIndex.indexByString("C5"));
  cellB4.value = const excel.TextCellValue('TANGGAL');
  cellB4.cellStyle = excel.CellStyle(
      backgroundColorHex: excel.ExcelColor.brown100,
      leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      fontSize: 12,
      verticalAlign: excel.VerticalAlign.Center,
      horizontalAlign: excel.HorizontalAlign.Center);

  //nama aset
  var cellC4 = sheet.cell(excel.CellIndex.indexByString("D5"));
  cellC4.value = const excel.TextCellValue('KETERANGAN');
  cellC4.cellStyle = excel.CellStyle(
      backgroundColorHex: excel.ExcelColor.brown100,
      leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      fontSize: 12,
      verticalAlign: excel.VerticalAlign.Center,
      horizontalAlign: excel.HorizontalAlign.Center);

  //ID Aset
  var cellD4 = sheet.cell(excel.CellIndex.indexByString("E5"));
  cellD4.value = const excel.TextCellValue('TOTAL BIAYA');
  cellD4.cellStyle = excel.CellStyle(
      backgroundColorHex: excel.ExcelColor.brown100,
      leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      fontSize: 12,
      verticalAlign: excel.VerticalAlign.Center,
      horizontalAlign: excel.HorizontalAlign.Center);


  int rowIndex = 6;
  int nomor = 1;
  for (int i = 0; i < dokumenCatatan.length; i++) {
    var docId = dokumenCatatan[i];
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Catatan Servis')
        .doc(docId)
        .get();


    double total = snapshot['Total Biaya'];
    String kebutuhanDikerjakan = snapshot['Kebutuhan yg dikerjakan'];
    //convert data timestamp
    Timestamp timestamp = snapshot['Tanggal Dilakukan Servis'];
    DateTime dateTime = timestamp.toDate();
    String TanggalServis =
    DateFormat('EEEE, dd MMMM y', 'id_ID').format(dateTime);

    //

    var cellB = sheet.cell(excel.CellIndex.indexByString("B$rowIndex"));
    cellB.value = excel.TextCellValue((nomor).toString());
    cellB.cellStyle = excel.CellStyle(
      leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
    );

    var cellC = sheet.cell(excel.CellIndex.indexByString("C$rowIndex"));
    cellC.value = excel.TextCellValue(TanggalServis);
    cellC.cellStyle = excel.CellStyle(
      leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
    );

    var cellD = sheet.cell(excel.CellIndex.indexByString("D$rowIndex"));
    cellD.value = excel.TextCellValue(kebutuhanDikerjakan);
    cellD.cellStyle = excel.CellStyle(
      leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
    );

    var cellE = sheet.cell(excel.CellIndex.indexByString("E$rowIndex"));
    cellE.value = excel.TextCellValue(convertToRupiah(total));
    cellE.cellStyle = excel.CellStyle(
      leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
      rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
    );

    nomor++;
    rowIndex++;
  }

  Directory? appDocDir = await getExternalStorageDirectory();

  if (Platform.isAndroid) {
    final permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted) {
      if (appDocDir != null) {
        String filePath = '${appDocDir.path}/${namafile}.xlsx';

        final File file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }

        await file.writeAsBytes(eksel.encode()!);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export berhasil. File disimpan di folder Download'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error mengakses direktori unduhan.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied for storage access.'),
        ),
      );
    }
  }
}


Future<List<Aset>> getAllDatabaseItems() async {
  List<Aset> asets = [];

  final QuerySnapshot<Map<String, dynamic>> acGet =
  await FirebaseFirestore.instance.collection('Aset').get();
  asets.addAll(acGet.docs.map((doc) => Aset(
    doc['Merek AC'],
    'AC',
    (doc['Kebutuhan AC'] as List<dynamic>).map((kebutuhan) => Kebutuhan(
      kebutuhan['Nama Kebutuhan AC'],
      kebutuhan['Hari Kebutuhan AC'] as int,
      kebutuhan['Masa Kebutuhan AC'] as int,
      kebutuhan['Waktu Kebutuhan AC'] as int,
    )).toList(),
  )));

  final QuerySnapshot<Map<String, dynamic>> LaptopGet =
  await FirebaseFirestore.instance.collection('Laptop').get();
  asets.addAll(LaptopGet.docs.map((doc) => Aset(
    doc['Merek Laptop'],
    'Laptop',
    (doc['Kebutuhan Laptop'] as List<dynamic>).map((kebutuhan) => Kebutuhan(
      kebutuhan['Nama Kebutuhan Laptop'],
      kebutuhan['Hari Kebutuhan Laptop'] as int,
      kebutuhan['Masa Kebutuhan Laptop'] as int,
      kebutuhan['Waktu Kebutuhan Laptop'] as int,
    )).toList(),
  )));

  final QuerySnapshot<Map<String, dynamic>> PCget =
  await FirebaseFirestore.instance.collection('PC').get();
  asets.addAll(PCget.docs.map((doc) => Aset(
    doc['Merek PC'],
    'PC',
    (doc['kebutuhan'] as List<dynamic>).map((kebutuhan) => Kebutuhan(
      kebutuhan['Kebutuhan PC'],
      kebutuhan['Hari Kebutuhan PC'] as int,
      kebutuhan['Masa Kebutuhan'] as int,
      kebutuhan['Waktu Kebutuhan PC'] as int,
    )).toList(),
  )));

  final QuerySnapshot<Map<String, dynamic>> Motorget =
  await FirebaseFirestore.instance.collection('Motor').get();
  asets.addAll(Motorget.docs.map((doc) => Aset(
    doc['Merek Motor'],
    'Motor',
    (doc['Kebutuhan Motor'] as List<dynamic>).map((kebutuhan) => Kebutuhan(
      kebutuhan['Nama Kebutuhan Motor'],
      kebutuhan['Hari Kebutuhan Motor'] as int,
      kebutuhan['Masa Kebutuhan Motor'] as int,
      kebutuhan['Waktu Kebutuhan Motor'] as int,
    )).toList(),
  )));

  final QuerySnapshot<Map<String, dynamic>> Mobilget =
  await FirebaseFirestore.instance.collection('Mobil').get();
  asets.addAll(Mobilget.docs.map((doc) => Aset(
    doc['Merek Mobil'],
    'Mobil',
    (doc['Kebutuhan Mobil'] as List<dynamic>).map((kebutuhan) => Kebutuhan(
      kebutuhan['Nama Kebutuhan Mobil'],
      kebutuhan['Hari Kebutuhan Mobil'] as int,
      kebutuhan['Masa Kebutuhan Mobil'] as int,
      kebutuhan['Waktu Kebutuhan Mobil'] as int,
    )).toList(),
  )));

  return asets;
}



class Kebutuhan {
  String namaKebutuhan;
  int hariKebutuhan;
  int masaKebutuhan;
  int waktuKebutuhan;

  Kebutuhan(this.namaKebutuhan, this.hariKebutuhan, this.masaKebutuhan, this.waktuKebutuhan);
}

class Aset {
  String namaAset;
  String jenisAset;
  List<Kebutuhan> kebutuhan;

  Aset(this.namaAset, this.jenisAset, this.kebutuhan);
}


Future<List<Widget>> filterLogic(List<String> selectedKategori) async {
  List<Widget> filteredItems = [];
  List<Aset> asets = await getAllDatabaseItems();
  var jenisAsetFilter = selectedKategori;

  var filteredAsets = asets.where((aset) => jenisAsetFilter.contains(aset.jenisAset));
  if (filteredAsets.isNotEmpty) {
    for (var aset in filteredAsets) {
      List<Widget> kebutuhanWidgets = aset.kebutuhan.map((kebutuhan) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '- ${kebutuhan.namaKebutuhan}',
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              showIndicator(
                getValueIndicator(kebutuhan.hariKebutuhan, epochTimeToData(kebutuhan.waktuKebutuhan)),
                getProgressColor(kebutuhan.waktuKebutuhan),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    getRemainingTime(kebutuhan.waktuKebutuhan),
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList();

      filteredItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: Container(
            width: 311,
            decoration: BoxDecoration(
              color: Warna.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${aset.namaAset}',
                    style: TextStyles.title.copyWith(fontSize: 20, color: Warna.darkgrey),
                  ),
                  const SizedBox(height: 10),
                  Text('${aset.jenisAset}',
                    style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                  const SizedBox(height: 10),
                  Text('Kebutuhan :',
                    style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: kebutuhanWidgets,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  } else {
    filteredItems.add(
      const Text(
        "Tidak ada aset yang sesuai dengan kriteria filter.",
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  return filteredItems;
}


//untuk admin
Future<List<Pesan>> getAllDatabaseItems_Admin() async {
  List<Pesan> asets_admin = [];

  final QuerySnapshot<Map<String, dynamic>> acGet =
  await FirebaseFirestore.instance.collection('Aset').get();
  asets_admin.addAll(acGet.docs.map((doc) => Pesan(
    PesanAset: doc.data().containsKey('Pesan') ? doc['Pesan'] : 'Pesan tidak ditemukan',
    jenisAset: doc['Jenis Aset'],
    idAset: doc['ID AC'],
    tanggalDibuat : doc ['Tanggal Dibuat'],
    Teknisi : doc['Teknisi Yang Menambahkan']
  )));

  final QuerySnapshot<Map<String, dynamic>> laptopGet =
  await FirebaseFirestore.instance.collection('Laptop').get();
  asets_admin.addAll(laptopGet.docs.map((doc) => Pesan(
    PesanAset: doc.data().containsKey('Pesan') ? doc['Pesan'] : 'Pesan tidak ditemukan',
    jenisAset: doc['Jenis Aset'],
    idAset: doc['ID Laptop'],
    tanggalDibuat : doc ['Tanggal Dibuat'],
    Teknisi : doc['Teknisi Yang Menambahkan']
  )));

  final QuerySnapshot<Map<String, dynamic>> pcGet =
  await FirebaseFirestore.instance.collection('PC').get();
  asets_admin.addAll(pcGet.docs.map((doc) => Pesan(
    PesanAset: doc.data().containsKey('Pesan') ? doc['Pesan'] : 'Pesan tidak ditemukan',
    jenisAset: doc['Jenis Aset'],
    idAset: doc['ID PC'],
    tanggalDibuat : doc ['Tanggal Dibuat'],
    Teknisi : doc['Teknisi Yang Menambahkan']

  )));

  final QuerySnapshot<Map<String, dynamic>> motorGet =
  await FirebaseFirestore.instance.collection('Motor').get();
  asets_admin.addAll(motorGet.docs.map((doc) => Pesan(
    PesanAset: doc.data().containsKey('Pesan') ? doc['Pesan'] : 'Pesan tidak ditemukan',
    jenisAset: doc['Jenis Aset'],
    idAset: doc['ID Motor'],
    tanggalDibuat : doc ['Tanggal Dibuat'],
    Teknisi : doc['Teknisi Yang Menambahkan']
  )));

  final QuerySnapshot<Map<String, dynamic>> mobilGet =
  await FirebaseFirestore.instance.collection('Mobil').get();
  asets_admin.addAll(mobilGet.docs.map((doc) => Pesan(
    PesanAset: doc.data().containsKey('Pesan') ? doc['Pesan'] : 'Pesan tidak ditemukan',
    jenisAset: doc['Jenis Aset'],
    idAset: doc['ID Mobil'],
    tanggalDibuat : doc ['Tanggal Dibuat'],
    Teknisi : doc['Teknisi Yang Menambahkan']
  )));

  return asets_admin;
}

class Pesan {
  String PesanAset;
  String jenisAset;
  String idAset;
  final Timestamp tanggalDibuat;
  String Teknisi;

  Pesan({
    required this.PesanAset,
    required this.jenisAset,
    required this.idAset,
    required this.tanggalDibuat,
    required this.Teknisi
  });
}

DateTime getDateBeforeDays(int days) {
  return DateTime.now().subtract(Duration(days: days));
}

Future<List<Widget>> filterLogic_Admin(List<String> selectedKategori) async {
  List<Pesan> aset_Admin = await getAllDatabaseItems_Admin(); // Menggunakan kelas Aset_Admin
  List<Widget> PesanDitampilkan = [];

  List<Pesan> filteredAset = [];

  // Filter berdasarkan pilihan waktu dari dropdown
  for (String waktu in selectedKategori) {
    switch (waktu) {
      case '2 Hari':
        filteredAset.addAll(aset_Admin.where((aset) {
          DateTime now = DateTime.now();
          DateTime tanggalDibuat = aset.tanggalDibuat.toDate();
          return tanggalDibuat.isAfter(getDateBeforeDays(2)) && tanggalDibuat.isBefore(now);
        }));
        break;
      case 'Minggu':
        filteredAset.addAll(aset_Admin.where((aset) {
          DateTime now = DateTime.now();
          DateTime tanggalDibuat = aset.tanggalDibuat.toDate();
          return tanggalDibuat.isAfter(getDateBeforeDays(7)) && tanggalDibuat.isBefore(now);
        }));
        break;
      case 'Bulan':
        filteredAset.addAll(aset_Admin.where((aset) {
          DateTime now = DateTime.now();
          DateTime awalBulan = DateTime(now.year, now.month, 1);
          DateTime tanggalDibuat = aset.tanggalDibuat.toDate();
          return tanggalDibuat.isAfter(awalBulan) && tanggalDibuat.isBefore(now);
        }));
        break;
      case 'Semua':
        filteredAset.addAll(aset_Admin.where((aset) {
          DateTime now = DateTime.now();
          DateTime awalBulan = DateTime(now.year, now.month, 1);
          DateTime tanggalDibuat = aset.tanggalDibuat.toDate();
          return tanggalDibuat.isAfter(awalBulan) && tanggalDibuat.isBefore(now);
        }));
        break;
      default:
        break;
    }
  }

  // Sortir daftar berdasarkan tanggal dalam urutan menurun
  filteredAset.sort((a, b) => b.tanggalDibuat.compareTo(a.tanggalDibuat));

  // Tambahkan ke daftar tampilan
  _addToDisplayList(filteredAset, PesanDitampilkan);

  if (PesanDitampilkan.isEmpty) {
    PesanDitampilkan.add(
      const Text(
        "Silahkan pilih kriteria diatas...",
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  return PesanDitampilkan;
}

void _addToDisplayList(Iterable<Pesan> filteredAset, List<Widget> PesanDitampilkan) {
  for (var aset in filteredAset) {
    // Konversi Timestamp ke DateTime
    DateTime dateTime = aset.tanggalDibuat.toDate();

    // Format DateTime ke dalam format yang diinginkan
    String formattedDate = DateFormat('EEEE, dd MMMM y', 'id_ID').format(dateTime);

    PesanDitampilkan.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Container(
          width: 311,
          decoration: BoxDecoration(
            color: Warna.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${aset.PesanAset}', // Menggunakan properti PesanAset
                        style: TextStyles.title.copyWith(fontSize: 17, color: Warna.darkgrey),
                      ),
                    ),
                    Text(
                      '${aset.idAset}', // Menggunakan properti idAset
                      style: TextStyles.body.copyWith(fontSize: 14, color: Warna.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formattedDate, // Menggunakan tanggal yang sudah diformat
                        style: TextStyles.body.copyWith(fontSize: 16, color: Warna.darkgrey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${aset.Teknisi}', // Menggunakan properti idAset
                  style: TextStyles.body.copyWith(fontSize: 14, color: Warna.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}












