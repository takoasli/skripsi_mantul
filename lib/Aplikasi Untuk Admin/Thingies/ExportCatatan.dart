import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Aset/ControllerLogic.dart';
import '../komponen/style.dart';

class ExportCatatans extends StatefulWidget {
  const ExportCatatans({Key? key}) : super(key: key);

  @override
  State<ExportCatatans> createState() => _ExportCatatanState();
}

class _ExportCatatanState extends State<ExportCatatans> {
  String selectedWaktu = "";
  String selectedJenis = "";
  String selectedTimeOrType = "";
  int totalCatatan = 0;
  int totalCatatanJenisAset = 0;
  List<String> kategoriTerpilih = [];
  List<String> TimeAtauType = [];
  List<String> JenisTerpilih = [];
  late List<String> DokCatatanEX = [];
  late List<String> DokJenisEX = [];
  final namaFile = TextEditingController();
  final List<String> Waktu = [
    "Bulan ini",
    "Tahun ini",
    "Semua",
  ];

  final List<String> JenisAset = [
    "AC",
    "PC",
    "Laptop",
    "Motor",
    "Mobil"
  ];

  final List<String> byTimeOrJenis = [
    "Berdasarkan Waktu Diservis",
    "Berdasarkan Jenis Aset",
  ];

  void hitungTotalCatatan(List<String> dataCatatan) {
    setState(() {
      totalCatatan = dataCatatan.length;
    });
  }

  void hitungJenisCatatan(List<String> jenisCatatan) {
    setState(() {
      totalCatatanJenisAset = jenisCatatan.length;
    });
  }

  Future<void> getTypeorTime(List<String> selectedCategories) async {
    if (selectedCategories.contains('Berdasarkan Waktu Diservis')) {
      print('waktu servis ini');
      return;
    }

    if (selectedCategories.contains('Berdasarkan Jenis Aset')) {
      print('waktu servis ini');
      return;
    }
  }

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

  Future<void> getJenis(List<String> selectedCategories) async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Catatan Servis');

    if (selectedCategories.isNotEmpty) {
      query = query.where('Jenis Aset', whereIn: selectedCategories);
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    setState(() {
      DokJenisEX = snapshot.docs.map((doc) => doc.id).toList();
      // Hitung total catatan berdasarkan jenis
      hitungJenisCatatan(DokJenisEX);
    });
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
      hitungTotalCatatan(DokCatatanEX);
    });
  }

  Future<void> getCatatanBulanIni() async {
    DateTime now = DateTime.now();
    Timestamp startDate = Timestamp.fromDate(DateTime(now.year, now.month, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(now.year, now.month + 1, 0));

    await getCatatanByDateRange(startDate, endDate);
    hitungTotalCatatan(DokCatatanEX);
  }

  Future<void> getCatatanTahunIni() async {
    DateTime now = DateTime.now();
    Timestamp startDate = Timestamp.fromDate(DateTime(now.year, 1, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(now.year, 12, 31));

    await getCatatanByDateRange(startDate, endDate);
    hitungTotalCatatan(DokCatatanEX);
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
      hitungTotalCatatan(DokCatatanEX);
    });
  }

  @override
  void initState() {
    super.initState();
    getCatatan(kategoriTerpilih);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.Blue,
      appBar: AppBar(
        backgroundColor: Warna.Blue,
        title: const Text(
          'Export Catatan',
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
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 55),
              child: Image.asset(
                'gambar/gambar file.png',
                fit: BoxFit.contain,
                width: 217,
                height: 217,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 25, right: 25),
                              child: Container(
                                width: 350,
                                decoration: BoxDecoration(
                                  color: Warna.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueGrey.shade500.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: DropdownSearch<String>(
                                  popupProps: const PopupProps.menu(
                                    showSelectedItems: true,
                                    fit: FlexFit.loose,
                                    constraints: BoxConstraints(
                                      maxHeight: 200, // Adjust the max height here
                                    ),
                                  ),
                                  items: byTimeOrJenis,
                                  dropdownDecoratorProps: DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                        hintText: "Pilih Opsi Export...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        )
                                    ),
                                  ),
                                  onChanged: (selectedValue){
                                    print(selectedValue);
                                    setState(() {
                                      selectedTimeOrType = selectedValue ?? "";
                                      // Menambahkan reset state di sini:
                                      selectedWaktu = "";
                                      selectedJenis = "";
                                      totalCatatan = 0;
                                      totalCatatanJenisAset = 0;
                                      if (selectedTimeOrType.isNotEmpty) {
                                        if (selectedTimeOrType == "Berdasarkan Waktu Diservis") {
                                          TimeAtauType = ["Berdasarkan Waktu Diservis"];
                                        } else if (selectedTimeOrType == "Berdasarkan Jenis Aset") {
                                          TimeAtauType = ["Berdasarkan Jenis Aset"];
                                        }
                                        getTypeorTime(TimeAtauType);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (selectedTimeOrType == "Berdasarkan Waktu Diservis") ...[
                              Padding(
                                padding: const EdgeInsets.only(left: 25, right: 25),
                                child: Container(
                                  width: 350,
                                  decoration: BoxDecoration(
                                    color: Warna.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueGrey.shade500.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 3,
                                        offset: const Offset(0, 2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: DropdownSearch<String>(
                                    popupProps: const PopupProps.menu(
                                      showSelectedItems: true,
                                      fit: FlexFit.loose,
                                      constraints: BoxConstraints(
                                        maxHeight: 200, // Adjust the max height here
                                      ),
                                    ),
                                    items: Waktu,
                                    selectedItem: selectedWaktu.isEmpty ? null : selectedWaktu,
                                    dropdownDecoratorProps: DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          hintText: "Sort Tempo Waktu...",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          )
                                      ),
                                    ),
                                    onChanged: (selectedValue){
                                      print(selectedValue);
                                      setState(() {
                                        selectedWaktu = selectedValue ?? "";
                                        if (selectedWaktu.isNotEmpty) {
                                          if (selectedWaktu == "Semua") {
                                            kategoriTerpilih = ["Semua"];
                                          } else if (selectedWaktu == "Bulan ini") {
                                            kategoriTerpilih = ["Bulan ini"];
                                          } else if (selectedWaktu == "Tahun ini") {
                                            kategoriTerpilih = ["Tahun ini"];
                                          }
                                          getCatatan(kategoriTerpilih);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 35, bottom: 10),
                                    child: Text(
                                      "Total Item: $totalCatatan",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (selectedTimeOrType == "Berdasarkan Jenis Aset") ...[
                              Padding(
                                padding: const EdgeInsets.only(left: 25, right: 25),
                                child: Container(
                                  width: 350,
                                  decoration: BoxDecoration(
                                    color: Warna.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueGrey.shade500.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 3,
                                        offset: const Offset(0, 2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: DropdownSearch<String>(
                                    popupProps: const PopupProps.menu(
                                      showSelectedItems: true,
                                      fit: FlexFit.loose,
                                      constraints: BoxConstraints(
                                        maxHeight: 200, // Adjust the max height here
                                      ),
                                    ),
                                    items: JenisAset,
                                    selectedItem: selectedJenis.isEmpty ? null : selectedJenis,
                                    dropdownDecoratorProps: DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          hintText: "Jenis Aset...",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          )
                                      ),
                                    ),
                                    onChanged: (selectedValue) async {
                                      print(selectedValue);
                                      setState(() {
                                        selectedJenis = selectedValue ?? "";
                                        if (selectedJenis.isNotEmpty) {
                                          getJenis([selectedJenis]);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 35, bottom: 10),
                                    child: Text(
                                      "Total Jenis: $totalCatatanJenisAset",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 10),

                            Padding(
                              padding: const EdgeInsets.only(left: 25, right: 25),
                              child: Container(
                                width: 350,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Warna.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueGrey.shade500.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: namaFile,
                                  decoration: const InputDecoration(
                                    hintText: 'Nama File',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                String namaFileExport = namaFile.text.isNotEmpty ? namaFile.text : "Laporan Catatan ${DateFormat('dd-MM-yyyy').format(DateTime.now())}";
                                if (selectedTimeOrType == "Berdasarkan Waktu Diservis") {
                                  exportExcel(
                                    dokumenCatatan: DokCatatanEX,
                                    namafile: namaFileExport,
                                    context: context,
                                  );
                                } else if (selectedTimeOrType == "Berdasarkan Jenis Aset") {
                                  exportExcel(
                                    dokumenCatatan: DokJenisEX,
                                    namafile: namaFileExport,
                                    context: context,
                                  );
                                } else {
                                  // Tampilkan pesan jika dropdown belum dipilih
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Pilih opsi export terlebih dahulu.'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Convert',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    color: Warna.white
                                ),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Warna.Blue,
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
