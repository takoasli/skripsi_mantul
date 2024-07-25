import 'package:aplikasi_revamp/Aset/Motor/DetailMotor.dart';
import 'package:aplikasi_revamp/baca%20data/bacaMotor.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../komponen/style.dart';
import 'AddMotor.dart';
import 'editMotor.dart';

class ManajemenMotor extends StatefulWidget {
  const ManajemenMotor({super.key});

  @override
  State<ManajemenMotor> createState() => _ManajemenMotorState();
}

class _ManajemenMotorState extends State<ManajemenMotor> {
  late List<String> DokMotor = [];
  final berhasil = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'SUCCESS',
      message: 'Data Motor berhasil Dihapus!',
      contentType: ContentType.success,
    ),
  );

  Future<void> getMotor() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('Motor').get();
    setState(() {
      DokMotor = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  void initState(){
    super.initState();
    getMotor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: Warna.green,
        title: const Text(
          'Manajemen Motor',
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Warna.white,
                hintText: 'Cari Motor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none
                ),
              ),

              // onChanged: (value) {
              //   performSearch(value);
              // },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Warna.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: DokMotor.length,

                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          // Action when tapped
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: BacaMotor(
                                  dokumenMotor: DokMotor[index],
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditMotor(
                                        dokumenMotor: DokMotor[index],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.lightBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          Container(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25, right: 10),
              child: SpeedDial(
                child: const Icon(Icons.more_horiz,
                    color: Warna.white),
                backgroundColor: Warna.green,
                activeIcon: Icons.close,
                curve: Curves.bounceIn,
                children: [
                  SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.add,
                        color: Warna.white),
                    labelWidget: const Text("Add",
                        style: TextStyle(color: Warna.green)
                    ),
                    backgroundColor: Warna.green,
                    onTap: (){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMotor()),
                      );
                    },
                  ),

                  SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.create_new_folder,
                        color: Warna.white),
                    labelWidget: const Text("Manage Motor",
                        style: TextStyle(color: Warna.green)
                    ),
                    backgroundColor: Warna.green,
                    onTap: (){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const ManajemenMotor()),
                      );
                    },
                  ),

                  SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.motorcycle,
                        color: Warna.white),
                    labelWidget: const Text("Detail Motor",
                        style: TextStyle(color: Warna.green)
                    ),
                    backgroundColor: Warna.green,
                    onTap: (){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DetailMotor()),
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
