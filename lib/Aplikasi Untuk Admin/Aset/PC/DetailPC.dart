import 'package:aplikasi_revamp/Aplikasi%20Untuk%20Admin/Aset/PC/MoreDetailPC.dart';
import 'package:aplikasi_revamp/Aplikasi%20Untuk%20Admin/Komponen/boxAset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../komponen/style.dart';

class DetailPC extends StatefulWidget {
  const DetailPC({Key? key}) : super(key: key);

  @override
  State<DetailPC> createState() => _DetailPCState();
}

class _DetailPCState extends State<DetailPC> {
  late List<String> docDetailPc = [];
  late List<Map<String, dynamic>> _allresult = [];
  late List<Map<String, dynamic>> _resultList = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> getDetailPC() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('PC').get();
    setState(() {
      docDetailPc = snapshot.docs.map((doc) => doc.id).toList();
      _allresult = snapshot.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>();
      _resultList = List.from(_allresult);
    });
  }

  void _onSearchChanged() {
    searchResultList(_searchController.text);
  }

  void searchResultList(String query) {
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> showResult = [];
      for (var dataPC in _allresult) {
        var name = dataPC['Merek PC'].toString().toLowerCase();
        if (name.contains(query.toLowerCase())) {
          showResult.add(dataPC);
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
  void initState() {
    super.initState();
    getDetailPC();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.Blue,
        title: const Text(
          'Detail PC',
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
                hintText: 'Cari PC...',
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
              padding: const EdgeInsets.only(top: 20, left: 20, bottom: 20),
              child: GridView.builder(
                itemCount: _resultList.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  Map<String, dynamic> dataPC = _resultList[index];
                  String gambarPC = dataPC['Gambar PC'] ?? '';

                  ImageProvider<Object>? imageProvider;
                  if (gambarPC.isNotEmpty) {
                    imageProvider = NetworkImage(gambarPC);
                  } else {
                    imageProvider = const AssetImage('gambar/pc.png');
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BoxAset(
                        text: '${dataPC['Merek PC']}',
                        gambar: imageProvider,
                        halaman: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoreDetail(
                                data: dataPC,
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