import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

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


Future<void> exportExcel({
  required List<String> dokumenCatatan,
  required String namafile,
  required BuildContext context
}) async {
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
    String TanggalServis = DateFormat('EEEE, dd MMMM y', 'id_ID').format(dateTime);

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
    if (await _request_per(Permission.storage)) {
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


class DatabaseItem {
  final String id;
  final String name;

  DatabaseItem({
    required this.id,
    required this.name,
  });
}

Future<List<DatabaseItem>> getAllDatabaseItems() async {
  List<DatabaseItem> items = [];

  final QuerySnapshot<Map<String, dynamic>> ACget = await FirebaseFirestore.instance.collection('Aset').get();
  items.addAll(ACget.docs.map((doc) => DatabaseItem(id: doc.id, name: doc['Aset'])));

  final QuerySnapshot<Map<String, dynamic>> PCget = await FirebaseFirestore.instance.collection('PC').get();
  items.addAll(PCget.docs.map((doc) => DatabaseItem(id: doc.id, name: doc['PC'])));

  final QuerySnapshot<Map<String, dynamic>> Laptopget = await FirebaseFirestore.instance.collection('Laptop').get();
  items.addAll(Laptopget.docs.map((doc) => DatabaseItem(id: doc.id, name: doc['Laptop'])));

  final QuerySnapshot<Map<String, dynamic>> Motorget = await FirebaseFirestore.instance.collection('Motor').get();
  items.addAll(Motorget.docs.map((doc) => DatabaseItem(id: doc.id, name: doc['Motor'])));

  final QuerySnapshot<Map<String, dynamic>> Mobilget = await FirebaseFirestore.instance.collection('Mobil').get();
  items.addAll(Mobilget.docs.map((doc) => DatabaseItem(id: doc.id, name: doc['Mobil'])));

  return items;
}

class Kebutuhan {
  String NamaKebutuhan;
  int hariKebutuhan;
  int MasaKebutuhan;

  Kebutuhan(this.NamaKebutuhan, this.hariKebutuhan, this.MasaKebutuhan);
}

class Aset{
  String NamaAset;
  String JenisAset;
  List<Kebutuhan> kebutuhan;


  Aset(this.NamaAset, this.JenisAset,this.kebutuhan);
}

void FilterLogic() async {
  // Ambil semua item dari database Firestore
  List<DatabaseItem> databaseItems = await getAllDatabaseItems();

  // Buat objek-objek Aset dan kebutuhan dari data Firestore
  var Asets = databaseItems
      .where((item) => item.name.isNotEmpty) // pastikan nama tidak kosong
      .map((item) => new Aset(item.name, item.name, [new Kebutuhan(item.name, 10, 10)]))
      .toList();

  // Tentukan jenis-jenis aset yang ingin Anda filter
  var jenisAsetFilter = {"Aset", "PC", "Laptop", "Motor", "Mobil"};

  // Gunakan filter untuk mendapatkan Aset yang JenisAset-nya sesuai dengan jenisAsetFilter
  var filter = Asets.where((e) => jenisAsetFilter.contains(e.JenisAset));
  if (filter.isNotEmpty) {
    // Loop melalui hasil filter
    filter.forEach((aset) {
      print('Nama Aset: ${aset.NamaAset}');
      aset.kebutuhan.forEach((kebutuhan) {
        print('  - Nama Kebutuhan: ${kebutuhan.NamaKebutuhan}');
        print('  - Hari Kebutuhan: ${kebutuhan.hariKebutuhan}');
        print('  - Masa Kebutuhan: ${kebutuhan.MasaKebutuhan}');
      });
    });
  } else {
    print("Tidak ada aset yang sesuai dengan kriteria filter.");
  }

  // Panggil logika filter di sini, atau gunakan hasil filter sesuai kebutuhan
  // Misalnya, Anda dapat menetapkan hasil filter ke variabel di kelas Dashboards
  // atau melakukan tindakan lain sesuai kebutuhan aplikasi Anda.
}



