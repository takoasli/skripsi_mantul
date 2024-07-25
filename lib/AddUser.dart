import 'dart:convert';
import 'dart:io';
import 'package:aplikasi_revamp/textfield/imageField.dart';
import 'package:aplikasi_revamp/textfield/textfields.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'komponen/style.dart';
import 'manajemenUser.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final nomorController = TextEditingController();
  final emailController = TextEditingController();
  final alamatController = TextEditingController();
  final namaController = TextEditingController();
  final IdController = TextEditingController();
  final ImgController = TextEditingController();
  final ImagePicker _img = ImagePicker();
  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();
  bool isPassword = true;
  bool confirmisPassword = true;
  String Token = "";

  final Sukses = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'SUCCESS',
      message: 'Data user berhasil Ditambahkan!',
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

  Future<void> registerUserPassword(email, password) async {
    const apiUrl =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDzrffwFrYR5Ngvik6I27VezoOHZrB2zqc";
    var response = await http.post(Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      Token = data["idToken"];

      print("User berhasil dibuat dengan token $Token");
    }
  }

  Future SimpanAkun() async {
    if (PasswordConfirmed()) {
      try {
        registerUserPassword(emailController.text, passwordController.text);

        String lokasiGambar = ImgController.text;
        String foto = '';

        if (lokasiGambar.isNotEmpty) {
          File profil = File(lokasiGambar);
          foto = await unggahGambar(profil);
        }

        await tambahUserInfo(
          namaController.text.trim(),
          IdController.text.trim(),
          int.parse(nomorController.text.trim()),
          emailController.text.trim(),
          alamatController.text.trim(),
          Token,
          foto,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManageAcc()),
        );

        ScaffoldMessenger.of(context).showSnackBar(Sukses);
        namaController.clear();
        IdController.clear();
        nomorController.clear();
        emailController.clear();
        alamatController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        Token = "";
      } catch (e) {
        print("error: $e");
      }
    }
  }

  Future tambahUserInfo(String Nama, String ID, int Nomor,
      String Email, String Alamat,String Token, String urlGambar) async {
    await FirebaseFirestore.instance.collection('User').add({
      'Nama': Nama,
      'ID': ID,
      'Nomor HP': Nomor,
      'Email': Email,
      'Alamat Rumah': Alamat,
      'Token': Token,
      'Foto Profil': urlGambar,
    });
  }

  bool PasswordConfirmed() {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Tambah User',
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
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
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
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
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
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
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
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
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
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
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
                    'Password',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                MyTextField(
                    textInputType: TextInputType.visiblePassword,
                    hint: 'password',
                    textInputAction: TextInputAction.done,
                    isObscure: isPassword,
                    hasSuffix: true,
                    onPress: () {
                      setState(() {
                        isPassword = !isPassword;
                      });
                    },
                    controller: passwordController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    're-Password',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                MyTextField(
                    textInputType: TextInputType.visiblePassword,
                    hint: 're-Password',
                    isObscure: confirmisPassword,
                    hasSuffix: true,
                    onPress: () {
                      setState(() {
                        confirmisPassword = !confirmisPassword;
                      });
                    },
                    textInputAction: TextInputAction.done,
                    controller: confirmPasswordController),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Gambar Profil',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                FieldImage(
                  controller: ImgController,
                  selectedImageName: ImgController.text.isNotEmpty
                      ? ImgController.text
                          .split('/')
                          .last // Display only the image name
                      : '',
                  onPressed:
                      PilihGambar, // Pass the pickImage method to FieldImage
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: SimpanAkun,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Warna.green,
                        minimumSize: const Size(300, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                    child: Container(
                      width: 200,
                      child: Center(
                        child: Text(
                          'Save',
                          style: TextStyles.title
                              .copyWith(fontSize: 20, color: Colors.white),
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
