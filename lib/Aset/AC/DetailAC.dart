import 'package:aplikasi_revamp/Aset/AC/ManajemenAC.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../komponen/boxAset.dart';
import '../../komponen/style.dart';
import 'moreDetailAC.dart';

class DetailAC extends StatefulWidget {
  const DetailAC({Key? key}) : super(key: key);

  @override
  State<DetailAC> createState() => _DetailACState();
}

class _DetailACState extends State<DetailAC> {
  late List<String> docDetailAC = [];
  late List<Map<String, dynamic>> _allresult = [];
  late List<Map<String, dynamic>> _resultList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDetailAC();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    searchResultList(_searchController.text);
  }

  void searchResultList(String query) {
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> showResult = [];
      for (var dataAC in _allresult) {
        var name = dataAC['Merek AC'].toString().toLowerCase();
        if (name.contains(query.toLowerCase())) {
          showResult.add(dataAC);
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

  Future<void> getDetailAC() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('Aset').get();
    setState(() {
      docDetailAC = snapshot.docs.map((doc) => doc.id).toList();
      _allresult = snapshot.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>();
      _resultList = List.from(_allresult);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.green,
        title: const Text(
          'Detail AC',
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
                hintText: 'Cari AC...',
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
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: GridView.builder(
                itemCount: _resultList.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  Map<String, dynamic> dataAC = _resultList[index];
                  String gambarAC = dataAC['Foto AC Indoor'] ?? '';

                  ImageProvider<Object>? imageProvider;
                  if (gambarAC.isNotEmpty) {
                    imageProvider = NetworkImage(gambarAC);
                  } else {
                    imageProvider = const AssetImage('gambar/ac.png');
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BoxAset(
                        text: '${dataAC['Merek AC']}',
                        gambar: imageProvider,
                        halaman: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoreDetailAC(
                                data: dataAC,
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
          backgroundColor: Warna.green,
          activeIcon: Icons.close,
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.create_new_folder, color: Warna.white),
              labelWidget: const Text(
                  "Manage AC", style: TextStyle(color: Warna.green)),
              backgroundColor: Warna.green,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ManajemenAC()),
                );
              },
            ),
            SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.ac_unit, color: Warna.white),
              labelWidget: const Text(
                  "Detail AC", style: TextStyle(color: Warna.green)),
              backgroundColor: Warna.green,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailAC()),
                );
              },
            ),
          ],
          child: const Icon(Icons.more_horiz, color: Warna.white),
        ),
      ),
    );
  }
}
