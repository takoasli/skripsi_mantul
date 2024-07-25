import 'dart:convert';
import 'package:aplikasi_revamp/updateUser.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'AddUser.dart';
import 'baca data/baca_user.dart';
import 'komponen/style.dart';

class ManageAcc extends StatefulWidget {
  const ManageAcc({Key? key}) : super(key: key);

  @override
  State<ManageAcc> createState() => _ManageAccState();
}

class _ManageAccState extends State<ManageAcc> {
  late List<String> docIDs = [];
  final berhasil = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'SUCCESS',
      message: 'Data user berhasil Dihapus!',
      contentType: ContentType.success,
    ),
  );

  Future<void> getDokumen() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('User').get();
    setState(() {
      docIDs = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> removeRegisterUser(token) async {
    const apiUrl =
        "https://identitytoolkit.googleapis.com/v1/accounts:delete?key=AIzaSyDzrffwFrYR5Ngvik6I27VezoOHZrB2zqc";
    var response = await http.post(Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "idToken": token,
        }));
    if (response.statusCode == 200) {
      print("User berhasil dihapus dengan token $token");
    }
  }

  Future<void> hapusUser(String docID) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('User').doc(docID).get();
      final data = snapshot.data();

      var token = data?['Token'];

      await removeRegisterUser(token);

      await FirebaseFirestore.instance.collection('User').doc(docID).delete();

      getDokumen();
      ScaffoldMessenger.of(context).showSnackBar(berhasil);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getDokumen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Manajemen User',
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
          height: 580,
          decoration: BoxDecoration(
            color: Warna.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: docIDs.length,
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
                            child: BacaUser(
                              dokumenUser: docIDs[index],
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateUser(
                                    dokumenUser: docIDs[index],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.lightBlue,
                            ),
                          ),
                          const SizedBox(width: 5),
                          IconButton(
                            onPressed: () {
                              hapusUser(docIDs[index]);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(bottom: 25, right: 10),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddUser()),
            );
          },
          backgroundColor: Warna.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: const Icon(
            Icons.add,
            color: Warna.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
