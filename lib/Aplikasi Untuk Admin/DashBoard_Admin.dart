import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Aset/ControllerLogic.dart';
import 'Komponen/MenuBoxContent.dart';
import 'Komponen/style.dart';
import 'Thingies/ExportCatatan.dart';
import 'Thingies/Profile.dart';

class Dashboard_Admins extends StatefulWidget {
  Dashboard_Admins({super.key});
  final pengguna = FirebaseAuth.instance.currentUser!;

  @override
  State<Dashboard_Admins> createState() => _Dashboard_AdminsState();
}

class _Dashboard_AdminsState extends State<Dashboard_Admins> {
  String selectedKategori = "";
  late List<DocumentSnapshot<Map<String, dynamic>>> DokAC = [];
  late List<DocumentSnapshot<Map<String, dynamic>>> DokPC = [];
  late List<DocumentSnapshot<Map<String, dynamic>>> DokLaptop = [];
  late List<DocumentSnapshot<Map<String, dynamic>>> DokMotor = [];
  late List<DocumentSnapshot<Map<String, dynamic>>> DokMobil = [];
  List<DocumentSnapshot<Map<String, dynamic>>> DokStatus = [];
  List<String> kategoriTerpilih = [];
  final List<String> KategoriWaktu = [
    "2 Hari",
    "Minggu",
    "Bulan",
    "Semua"
  ];
  List<Widget> filteredWidgets = [];

  Future<void> getAC() async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('Aset');
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
      DokAC = snapshot.docs;
    });
  }

  Future<void> getPC() async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('PC');
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
      DokPC = snapshot.docs;
    });
  }

  Future<void> getLaptop() async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('Laptop');
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
      DokLaptop = snapshot.docs;
    });
  }

  Future<void> getMotor() async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('Motor');
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
      DokMotor = snapshot.docs;
    });
  }

  Future<void> getMobil() async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('Mobil');
    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
      DokMobil = snapshot.docs;
    });
  }

  Future<void> getStatus(List<String> selectedKategori) async {
    DokStatus.clear(); // Clear DokStatus before adding new data
    for (String waktu in selectedKategori){
      switch (waktu) {
        case 'AC':
          await getAC();
          DokStatus.addAll(DokAC);
          break;
        case 'PC':
          await getPC();
          DokStatus.addAll(DokPC);
          break;
        case 'Laptop':
          await getLaptop();
          DokStatus.addAll(DokLaptop);
          break;
        case 'Motor':
          await getMotor();
          DokStatus.addAll(DokMotor);
          break;
        case 'Mobil':
          await getMobil();
          DokStatus.addAll(DokMobil);
          break;
        default:
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getStatus(kategoriTerpilih).then((_){
      filterLogic_Admin(kategoriTerpilih).then((filteredItems){
        setState(() {
          filteredWidgets = filteredItems;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.Blue,
      appBar: AppBar(
        backgroundColor: Warna.Blue,
        title: const Text(
          'ADMIN',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Warna.white,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profiles()),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportCatatans()),
              );
            },
            icon: const Icon(Icons.file_present_rounded, color: Colors.white),
          ),
          const SizedBox(width: 23),
        ],
        centerTitle: false,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 20, top: 10),
            child: BoxMenuContent(),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Message',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          showSelectedItems: true,
                          fit: FlexFit.loose,
                        ),
                        items: KategoriWaktu,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            hintText: "Pilih...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        onChanged: (selectedValue) async {
                          setState(() {
                            selectedKategori = selectedValue ?? "";
                            if (selectedKategori.isNotEmpty) {
                              kategoriTerpilih = [selectedKategori];
                            } else {
                              kategoriTerpilih = [];
                            }
                          });

                          // Panggil getStatus dan filterLogic di sini
                          await getStatus(kategoriTerpilih);
                          filteredWidgets = await filterLogic_Admin(kategoriTerpilih);
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: filteredWidgets.isEmpty
                            ? const Center(
                          child: Text(
                            'Tidak ada pesan terkini',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        )
                            : ListView.builder(
                          itemCount: filteredWidgets.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: filteredWidgets[index],
                              ),
                            );
                          },
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
    );
  }
}
