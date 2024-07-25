import 'package:aplikasi_revamp/Aset/Laptop/manajemenLaptop.dart';
import 'package:aplikasi_revamp/Aset/Laptop/moreDetailLaptop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../komponen/boxAset.dart';
import '../../komponen/style.dart';

class DetailLaptop extends StatefulWidget {
  const DetailLaptop({super.key});

  @override
  State<DetailLaptop> createState() => _DetailLaptopState();
}

class _DetailLaptopState extends State<DetailLaptop> {
  late List<String> docDetailLaptop = [];
  late List<Map<String, dynamic>> _allresult = [];
  late List<Map<String, dynamic>> _resultList = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> getDetailLaptop() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('Laptop').get();
    setState(() {
      docDetailLaptop = snapshot.docs.map((doc) => doc.id).toList();
      _allresult = snapshot.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>();
      _resultList = List.from(_allresult);
    });
  }

  @override
  void initState() {
    super.initState();
    getDetailLaptop();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    searchResultList(_searchController.text);
  }

  void searchResultList(String query) {
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> showResult = [];
      for (var dataLaptop in _allresult) {
        var name = dataLaptop['Merek Laptop'].toString().toLowerCase();
        if (name.contains(query.toLowerCase())) {
          showResult.add(dataLaptop);
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
          'Detail Laptop',
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
                hintText: 'Cari Laptop...',
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
                  Map<String, dynamic> dataLaptop = _resultList[index];
                  String gambarLaptop = dataLaptop['Gambar Laptop'] ?? '';

                  ImageProvider<Object>? imageProvider;
                  if (gambarLaptop.isNotEmpty) {
                    imageProvider = NetworkImage(gambarLaptop);
                  } else {
                    imageProvider = const AssetImage('gambar/laptop.png');
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BoxAset(
                        text: '${dataLaptop['Merek Laptop']}',
                        gambar: imageProvider,
                        halaman: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoreDetailLaptop(
                                data: dataLaptop,
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
              labelWidget: const Text("Manage Laptop",
                  style: TextStyle(color: Warna.green)
              ),
              backgroundColor: Warna.green,
              onTap: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ManajemenLaptop()),
                );
              },
            ),

            SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.computer,
                  color: Warna.white),
              labelWidget: const Text("Detail Laptop",
                  style: TextStyle(color: Warna.green)
              ),
              backgroundColor: Warna.green,
              onTap: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailLaptop()),
                );
              },
            )
          ],
        ),
      ),
      );
  }
}
