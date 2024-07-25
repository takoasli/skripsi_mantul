import 'package:aplikasi_revamp/Catatan/bacaCatatanExport.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Aset/ControllerLogic.dart';
import '../komponen/style.dart';
import '../textfield/textfields.dart';

class ExportCatatan extends StatefulWidget {
  const ExportCatatan({Key? key});

  @override
  State<ExportCatatan> createState() => _ExportCatatanState();
}

final List<String> kategoriWaktu = ['Bulan ini', 'Tahun ini', 'Semua'];
List<String> kategoriTerpilih = [];
late List<String> DokCatatanEX = [];

class _ExportCatatanState extends State<ExportCatatan> {

  final namaFile = TextEditingController();

  Future<void> getCatatan(List<String> selectedCategories) async {
    if (selectedCategories.contains('Semua')) {
      await getAllCatatan();
      return;
    }

    if (selectedCategories.contains('Bulan ini')) {
      await getCatatanBulanIni();
      return;
    }

    if (selectedCategories.contains('Tahun ini')) {
      await getCatatanTahunIni();
      return;
    }
  }

  Future<void> getAllCatatan() async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Catatan Servis');

    setState(() {
      DokCatatanEX = [];
    });

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    setState(() {
      DokCatatanEX = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> getCatatanBulanIni() async {
    DateTime now = DateTime.now();
    Timestamp startDate = Timestamp.fromDate(DateTime(now.year, now.month, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(now.year, now.month + 1, 0));

    await getCatatanByDateRange(startDate, endDate);
  }

  Future<void> getCatatanTahunIni() async {
    DateTime now = DateTime.now();
    Timestamp startDate = Timestamp.fromDate(DateTime(now.year, 1, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(now.year, 12, 31));

    await getCatatanByDateRange(startDate, endDate);
  }

  Future<void> getCatatanByDateRange(
      Timestamp startDate, Timestamp endDate) async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Catatan Servis');

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query
        .where('Tanggal Dilakukan Servis', isGreaterThanOrEqualTo: startDate)
        .where('Tanggal Dilakukan Servis', isLessThanOrEqualTo: endDate)
        .get();

    setState(() {
      DokCatatanEX = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getCatatan(kategoriTerpilih);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Export Catatan',
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
        child: Container(
          width: 370,
          height: 570,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(
                    kategoriWaktu.length,
                        (waktu) {
                      return FilterChip(
                        selected: kategoriTerpilih.contains(kategoriWaktu[waktu]),
                        showCheckmark: false,
                        label: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            kategoriWaktu[waktu],
                            style: TextStyle(
                              color: kategoriTerpilih.contains(
                                  kategoriWaktu[waktu])
                                  ? Warna.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        backgroundColor: kategoriTerpilih.contains(
                            kategoriWaktu[waktu])
                            ? Warna.lightgreen // Warna kalo dipilih
                            : Warna.white,
                        // Warna kalo tidak dipilih
                        selectedColor: Warna.lightgreen,
                        // Warna latar belakang
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              kategoriTerpilih.clear();
                              kategoriTerpilih.add(kategoriWaktu[waktu]);
                            } else {
                              kategoriTerpilih.remove(kategoriWaktu[waktu]);
                            }
                            getCatatan(kategoriTerpilih);
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 250,
                  width: 320,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Warna.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: DokCatatanEX.length,
                            itemBuilder: (BuildContext context, int indeks) {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10),
                                  elevation: 5,
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: BacaCatatExport(
                                            dokumenCatatanEx: DokCatatanEX[indeks],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Nama File',
                          style: TextStyles.title.copyWith(fontSize: 17, color: Warna.darkgrey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MyTextField(
                      textInputType: TextInputType.text,
                      hint: '',
                      textInputAction: TextInputAction.done,
                      controller: namaFile,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: (){
                      exportExcel(
                          dokumenCatatan: DokCatatanEX,
                          namafile: namaFile.text,
                          context: context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Warna.green,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))
                    ),
                    child: SizedBox(
                      width: 200,
                      child: Center(
                        child: Text(
                          'Export',
                          style: TextStyles.title
                              .copyWith(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

