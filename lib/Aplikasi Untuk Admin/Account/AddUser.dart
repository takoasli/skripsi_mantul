import 'dart:convert';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../Komponen/imageField.dart';
import '../Komponen/style.dart';
import '../Komponen/textfield.dart';
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
  final _formState = GlobalKey<FormState>();
  String selectedRole = "";
  final confirmPasswordController = TextEditingController();
  bool isPassword = true;
  bool confirmisPassword = true;
  String Token = "";
  List<String> Role = [
    "User",
    "Admin",
  ];

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

  final Gagal = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Gagal',
      message: 'Email hanya huruf(a-z), angka(0-9), dan titik(.) yang diizinkan!',
      contentType: ContentType.failure,
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

  Future<String> registerUserPassword(String email, String password) async {
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
      String token = data["idToken"];
      print("User berhasil dibuat dengan token $token");
      return token;
    } else {
      throw Exception("Failed to register user: ${response.body}");
    }
  }


  Future<void> SimpanAkun() async {
    if (PasswordConfirmed()) {
      try {
        // Tunggu hingga token didapatkan
        Token = await registerUserPassword(emailController.text.trim(), passwordController.text);

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
          selectedRole,
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
        selectedRole;
      } catch (e) {
        print("error: $e");
      }
    }
  }



  Future tambahUserInfo(String Nama, String ID, int Nomor, String Email, String Alamat, String Token, String urlGambar,String selectedRole) async {
    await FirebaseFirestore.instance.collection('User').add({
      'Nama': Nama,
      'ID': ID,
      'Nomor HP': Nomor,
      'Email': Email,
      'Alamat Rumah': Alamat,
      'Token': Token,
      'Foto Profil': urlGambar,
      'Status': 'aktif',
      'Role' : selectedRole
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

  bool isEmailValid(String email) {
    // Regex pattern untuk validasi email
    String pattern =
        r'^[a-z0-9]+(?:\.[a-z0-9]+)*@[a-z0-9]+\.[a-z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  void validasiEmail() {
    final bool emailValid = isEmailValid(emailController.text.trim());
    print('Email valid: $emailValid'); // Tambahkan ini untuk debug
    if (emailValid) {
      SimpanAkun();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(Gagal);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.Blue,
      appBar: AppBar(
        backgroundColor: Warna.Blue,
        title: const Text(
          'Tambah User',
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
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: 370,
            height: 690,
            decoration: BoxDecoration(
              color: Warna.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: _formState,
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
                      inputFormatters: [LengthLimitingTextInputFormatter(8)],
                      textInputAction: TextInputAction.next,
                      controller: namaController,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                      },
                    ),
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
                        validator: (value){
                          if (value==''){
                            return "Isi kosong, Harap Diisi!";
                          }
                        },
                        controller: IdController),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Role',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSelectedItems: true,
                        fit: FlexFit.loose,
                      ),
                      items: Role,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            hintText: "...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)
                            )
                        ),
                      ),
                      onChanged: (selectedValue){
                        print(selectedValue);
                        setState(() {
                          selectedRole = selectedValue ?? "";
                        });
                      },
                    ),
                    const SizedBox(height: 25),
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
                        validator: (value){
                          if (value==''){
                            return "Isi kosong, Harap Diisi!";
                          }
                        },
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
                        validator: (value){
                          if (value==''){
                            return "Isi kosong, Harap Diisi!";
                          }
                        },
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
                        validator: (value){
                          if (value==''){
                            return "Isi kosong, Harap Diisi!";
                          }
                        },
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
                        validator: (value){
                          if (value==''){
                            return "Isi kosong, Harap Diisi!";
                          }
                        },
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
                        validator: (value){
                          if (value==''){
                            return "Isi kosong, Harap Diisi!";
                          }
                        },
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
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton(
                          onPressed: (){
                            if(_formState.currentState!.validate()){
                              validasiEmail();
                              print("tidak ada field kosong");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Warna.Blue,
                              minimumSize: const Size(300, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25))),
                          child: SizedBox(
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
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
