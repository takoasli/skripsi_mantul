import 'package:aplikasi_revamp/Aplikasi%20Untuk%20Admin/Aset/Motor/MoreDetailMotor.dart';
import 'package:aplikasi_revamp/Aplikasi%20Untuk%20Admin/Komponen/boxAset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Komponen/style.dart';

class DetailMotor extends StatefulWidget {
  const DetailMotor({super.key});

  @override
  State<DetailMotor> createState() => _DetailMotorState();
}

class _DetailMotorState extends State<DetailMotor> {
  late List<String> docDetailMotor = [];
  late List<Map<String, dynamic>> _allresult = [];
  late List<Map<String, dynamic>> _resultList = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> getDetailMotor() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('Motor').get();
    setState(() {
      docDetailMotor = snapshot.docs.map((doc) => doc.id).toList();
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
      for (var dataMotor in _allresult) {
        var name = dataMotor['Merek Motor'].toString().toLowerCase();
        if (name.contains(query.toLowerCase())) {
          showResult.add(dataMotor);
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
    getDetailMotor();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.Blue,
        title: const Text(
          'Detail Motor',
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
                hintText: 'Cari Motor...',
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
                  Map<String, dynamic> dataMotor = _resultList[index];
                  String gambarMotor = dataMotor['Gambar Motor'] ?? '';

                  ImageProvider<Object>? imageProvider;
                  if (gambarMotor.isNotEmpty) {
                    imageProvider = NetworkImage(gambarMotor);
                  } else {
                    imageProvider = const AssetImage('gambar/motor.png');
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BoxAset(
                        text: '${dataMotor['Merek Motor']}',
                        gambar: imageProvider,
                        halaman: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoreDetailMotor(
                                data: dataMotor,
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
