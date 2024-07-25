import 'package:aplikasi_revamp/Aplikasi%20Untuk%20Admin/Komponen/style.dart';
import 'package:aplikasi_revamp/Aset/Mobil/MoreDetailMobil.dart';
import 'package:aplikasi_revamp/Aset/Mobil/manajemenMobil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../komponen/boxAset.dart';

class DetailMobil extends StatefulWidget {
  const DetailMobil({super.key});

  @override
  State<DetailMobil> createState() => _DetailMobilState();
}

class _DetailMobilState extends State<DetailMobil> {
  late List<String> docDetailMobil = [];
  late List<Map<String, dynamic>> _allresult = [];
  late List<Map<String, dynamic>> _resultList = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> getDetailMobil() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('Mobil').get();
    setState(() {
      docDetailMobil = snapshot.docs.map((doc) => doc.id).toList();
      _allresult = snapshot.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>();
      _resultList = List.from(_allresult);
    });
  }

  @override
  void initState() {
    super.initState();
    getDetailMobil();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    searchResultList(_searchController.text);
  }

  void searchResultList(String query) {
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> showResult = [];
      for (var dataMobil in _allresult) {
        var name = dataMobil['Merek Mobil'].toString().toLowerCase();
        if (name.contains(query.toLowerCase())) {
          showResult.add(dataMobil);
        }
      }
      setState(() {
        _resultList = showResult;
      });
    } else {
      setState(() {
        _resultList = List.from(_allresult);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.green,
        title: const Text(
          'Detail Mobil',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Cari Mobil...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),

          Expanded(
            child: _resultList.isEmpty
                ? const Center(
              child: Text('Data tidak ditemukan'),
            )
                : Padding(
              padding: const EdgeInsets.only(top: 20, left: 30),
              child: GridView.builder(
                itemCount: _resultList.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  Map<String, dynamic> dataMobil = _resultList[index];
                  String gambarMobil = dataMobil['Gambar Mobil'] ?? '';

                  ImageProvider<Object>? imageProvider;
                  if (gambarMobil.isNotEmpty) {
                    imageProvider = NetworkImage(gambarMobil);
                  } else {
                    imageProvider = const AssetImage('gambar/mobil.png');
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BoxAset(
                        text: '${dataMobil['Merek Mobil']}',
                        gambar: imageProvider,
                        halaman: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoreDetailmobil(
                                data: dataMobil,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SpeedDial(
          child: const Icon(Icons.more_horiz,
              color: Warna.white),
          backgroundColor: Warna.green,
          activeIcon: Icons.close,
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.create_new_folder,
                  color: Warna.white),
              labelWidget: const Text("Manage Mobil",
                  style: TextStyle(color: Warna.green)
              ),
              backgroundColor: Warna.green,
              onTap: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ManajemenMobil()),
                );
              },
            ),

            SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.car_crash,
                  color: Warna.white),
              labelWidget: const Text("Detail Mobil",
                  style: TextStyle(color: Warna.green)
              ),
              backgroundColor: Warna.green,
              onTap: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailMobil()),
                );
              },
            )
          ],
        ),
      ),
      );
  }
}
