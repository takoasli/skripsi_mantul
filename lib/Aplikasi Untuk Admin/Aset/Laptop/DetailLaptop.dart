import 'package:aplikasi_revamp/Aplikasi%20Untuk%20Admin/Aset/Laptop/moreDetailLaptop.dart';
import 'package:aplikasi_revamp/Aplikasi%20Untuk%20Admin/Komponen/boxAset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Komponen/style.dart';

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

  void _onSearchChanged() {
    searchResultList(_searchController.text);
  }

  @override
  void initState() {
    super.initState();
    getDetailLaptop();
    _searchController.addListener(_onSearchChanged);
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
        backgroundColor: Warna.Blue,
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
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
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
      );
  }
}
