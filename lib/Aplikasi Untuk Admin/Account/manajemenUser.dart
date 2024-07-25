import 'package:aplikasi_revamp/Aplikasi%20Untuk%20Admin/Account/LihatDataAkun.dart';
import 'package:aplikasi_revamp/Aplikasi%20Untuk%20Admin/Account/updateUser.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../Komponen/style.dart';
import 'AddUser.dart';
import 'baca_user.dart';

class ManageAcc extends StatefulWidget {
  const ManageAcc({Key? key}) : super(key: key);

  @override
  State<ManageAcc> createState() => _ManageAccState();
}

class _ManageAccState extends State<ManageAcc> {
  late List<String> docIDs = [];
  final nonaktif = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'SUCCESS',
      message: 'Akun Telah Dinonaktifkan!',
      contentType: ContentType.success,
    ),
  );

  final aktifKembali = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'SUCCESS',
      message: 'Akun telah aktif kembali!',
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

  Future<void> nonaktifkanUser(String docID) async {
    try {
      await FirebaseFirestore.instance.collection('User').doc(docID).update({
        'Status': 'nonaktif',
      });

      // Perbarui daftar dokumen pengguna
      await getDokumen();

      ScaffoldMessenger.of(context).showSnackBar(nonaktif);
    } catch (e) {
      print('Error nonaktifkanUser: $e');
    }
  }

  Future<void> AktifkanUSer(String docID) async {
    try {
      await FirebaseFirestore.instance.collection('User').doc(docID).update({
        'Status': 'aktif',
      });

      // Perbarui daftar dokumen pengguna
      await getDokumen();

      ScaffoldMessenger.of(context).showSnackBar(aktifKembali);
    } catch (e) {
      print('Error AktifkanUSer: $e');
    }
  }

  Future<String> getStatus(String docID) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('User').doc(docID).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        return data?['Status'] ?? 'aktif';
      } else {
        return 'aktif';
      }
    } catch (error) {
      print('Error getting document: $error');
      return 'nonaktif'; // Mengembalikan status default 'aktif' jika terjadi error
    }
  }

  @override
  void initState() {
    super.initState();
    getDokumen();
  }

  Icon _getIcon(String status) {
    if (status == 'aktif') {
      return const Icon(
        Icons.block,
        color: Colors.red,
      );
    } else {
      return const Icon(
        Icons.replay,
        color: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.Blue,
      appBar: AppBar(
        backgroundColor: Warna.Blue,
        title: const Text(
          'User Account',
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: 370,
            height: 690,
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
                      onTap: () async {
                        try {
                          final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
                          await FirebaseFirestore.instance
                              .collection('User')
                              .doc(docIDs[index])
                              .get();
                          if (userSnapshot.exists) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LihatAkun(data: userSnapshot.data()!),
                              ),
                            );
                          }
                        } catch (e) {
                          print(e);
                        }
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
                            FutureBuilder<String>(
                              future: getStatus(docIDs[index]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  );
                                } else {
                                  final status = snapshot.data ?? 'nonaktif';
                                  return IconButton(
                                    onPressed: () async {
                                      if (status == 'aktif') {
                                        // Show dialog if status is active
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.infoReverse,
                                          headerAnimationLoop: false,
                                          animType: AnimType.topSlide,
                                          showCloseIcon: true,
                                          closeIcon: const Icon(Icons.close),
                                          title: 'Peringatan',
                                          desc: 'Yakin ingin menonaktifkan akun?',
                                          btnOkOnPress: () async {
                                            await nonaktifkanUser(docIDs[index]);
                                            setState(() {});
                                          },
                                          btnCancelOnPress: () {},
                                          onDismissCallback: (type) {
                                            debugPrint('button yang ditekan $type');
                                          },
                                        ).show();
                                      } else {
                                        await AktifkanUSer(docIDs[index]);
                                        setState(() {});
                                      }
                                    },
                                    icon: _getIcon(status),
                                  );
                                }
                              },
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SpeedDial(
          child: const Icon(Icons.more_horiz, color: Warna.white),
          backgroundColor: Warna.Blue,
          activeIcon: Icons.close,
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.add, color: Warna.white),
              labelWidget: const Text(
                "Add Account",
                style: TextStyle(color: Warna.Blue),
              ),
              backgroundColor: Warna.Blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddUser()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
