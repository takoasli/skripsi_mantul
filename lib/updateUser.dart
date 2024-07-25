import 'dart:io';

import 'package:aplikasi_revamp/textfield/imageField.dart';
import 'package:aplikasi_revamp/textfield/textfields.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'komponen/style.dart';
import 'manajemenUser.dart';

class UpdateUser extends StatefulWidget {
  const UpdateUser({super.key,
    required this.dokumenUser});
  final String dokumenUser;

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final nomorController = TextEditingController();
  final emailController = TextEditingController();
  final ImgController = TextEditingController();
  final ImagePicker _img= ImagePicker();
  final alamatController = TextEditingController();
  final namaController = TextEditingController();
  final IdController = TextEditingController();
  String oldphoto = '';
  Map<String, dynamic> databaru = {};

  final Sukses = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'SUCCESS',
      message:
      'Data user berhasil Diupdate!',
      contentType: ContentType.success,
    ),
  );

  final gagal = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'FAILED',
      message:
      'Data Gagal Dibuat',
      contentType: ContentType.success,
    ),
  );

  Future PilihGambar() async {
    final pilihGambar = await _img.pickImage(source: ImageSource.gallery);
    if (pilihGambar != null) {
      setState(() {
        ImgController.text = pilihGambar.path;
      });
    }
  }


  Future<String> unggahGambar(File profil) async {
    try {
      if (!profil.existsSync()) {
        print('File tidak ditemukan.');
        return '';
      }

      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('gambar')
          .child(ImgController.text.split('/').last);

      UploadTask uploadGambar = penyimpanan.putFile(profil);
      await uploadGambar;
      String foto = await penyimpanan.getDownloadURL();
      return foto;
    } catch (e) {
      print('$e');
      return '';
    }
  }


  Future<void> updateData(String docID, Map<String, dynamic> newData) async {
    try {
      String foto;
      if (ImgController.text.isNotEmpty) {
        File profil = File(ImgController.text);
        foto = await unggahGambar(profil);
      } else {
        foto = oldphoto;
      }

      Map<String, dynamic> databaru = {
        'Nomor HP': nomorController.text,
        'Email': emailController.text,
        'Alamat Rumah': alamatController.text,
        'Nama': namaController.text,
        'ID': IdController.text,
        'Foto Profil' : foto,

      };

      await FirebaseFirestore.instance.collection('User').doc(docID).update(databaru);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ManageAcc()),
      );
      ScaffoldMessenger.of(context).showSnackBar(Sukses);
    } catch (e) {
      print(e);
    }
  }


  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('User').doc(widget.dokumenUser).get();
    final data = snapshot.data();

    setState(() {
      nomorController.text = (data?['Nomor HP'] ?? '').toString();
      emailController.text = data?['Email'] ?? '';
      alamatController.text = data?['Alamat Rumah'] ?? '';
      namaController.text = data?['Nama'] ?? '';
      IdController.text = data?['ID'] ?? '';
      final imageUrl = data?['Foto Profil'] ?? '';
      oldphoto = imageUrl;

    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Update User',
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Nama',
                    style: TextStyles.title.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: "Nama",
                    textInputAction: TextInputAction.next,
                    controller: namaController),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'ID',
                    style: TextStyles.title.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: 'ID',
                    textInputAction: TextInputAction.next,
                    controller: IdController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Nomor HP',
                    style: TextStyles.title.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.number,
                    hint: "Nomor HP",
                    textInputAction: TextInputAction.next,
                    controller: nomorController),
                const SizedBox(height: 10),


                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Email',
                    style: TextStyles.title.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                MyTextField(
                    textInputType: TextInputType.emailAddress,
                    hint: "Email",
                    textInputAction: TextInputAction.next,
                    controller: emailController),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Alamat Rumah',
                    style: TextStyles.title.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                ),

                MyTextField(
                    textInputType: TextInputType.streetAddress,
                    hint: "Alamat Rumah",
                    textInputAction: TextInputAction.done,
                    controller: alamatController),
                const SizedBox(height: 10),


                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Gambar Profil',
                    style: TextStyles.title.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                FieldImage(
                  controller: ImgController,
                  selectedImageName: ImgController.text.isNotEmpty
                      ? ImgController.text.split('/').last // Display only the image name
                      : '',
                  onPressed: PilihGambar, // Pass the pickImage method to FieldImage
                ),
                const SizedBox(height: 30),



                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      updateData(widget.dokumenUser, databaru);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Warna.green,
                        minimumSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)
                        ),
                    ),
                    child: Container(
                      width: 200,
                      child: Center(
                        child: Text(
                          'Update!',
                          style: TextStyles.title.copyWith(
                              fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
