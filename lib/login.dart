import 'package:aplikasi_revamp/resetPassword.dart';
import 'package:aplikasi_revamp/textfield/textfields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Aplikasi Untuk Admin/DashBoard_Admin.dart';
import 'dashboard/Dashboards.dart';
import 'komponen/style.dart';

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final passwordController = TextEditingController();
  final IdController = TextEditingController();
  bool isObscure = true;

  void errorDialog(String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: "Terjadi error",
        message: message,
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<void> checkUser() async {
    String userEmail = IdController.text.trim();
    String userPassword = passwordController.text.trim();

    try {
      // Cari pengguna berdasarkan field email
      var querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Ambil dokumen pertama yang cocok
        var userDoc = querySnapshot.docs.first;

        // Ambil status dan role dari dokumen pengguna
        String userStatus = userDoc['Status'];
        String userRole = userDoc['Role'];

        // Validasi status akun
        if (userStatus == 'aktif') {
          // Validasi role akun
          if (userRole == 'User' || userRole == 'Admin') {
            await authenticateUser(userEmail, userPassword, userRole);
          } else {
            errorDialog('Role tidak valid');
          }
        } else {
          errorDialog('Akun nonaktif');
        }
      } else {
        errorDialog('Akun tidak ditemukan');
      }
    } catch (e) {
      errorDialog('Gagal memeriksa pengguna: ${e.toString()}');
    }
  }

  Future<void> authenticateUser(String userEmail, String userPassword, String userRole) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      // Simpan role pengguna
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', userRole);

      // Debug: Print the saved role
      String? savedRole = prefs.getString('userRole');
      print('Saved role: $savedRole');


      // Navigasi ke halaman yang sesuai berdasarkan role pengguna
      if (userRole == 'User') {
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboards()));
      } else if (userRole == 'Admin') {
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard_Admins()));
      }
    } catch (e) {
      errorDialog('Gagal login: ${e.toString()}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 69),
                Image.asset('gambar/logo2.png', height: 100, width: 100),
                const SizedBox(height: 30),
                Text(
                  'Login',
                  style: TextStyles.title.copyWith(fontSize: 30, color: Warna.white),
                ),
                const SizedBox(height: 40),

                // input id
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: MyTextField(
                    textInputType: TextInputType.text,
                    hint: 'Email',
                    textInputAction: TextInputAction.next,
                    controller: IdController,
                  ),
                ),

                // input password
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: MyTextField(
                    controller: passwordController,
                    textInputType: TextInputType.visiblePassword,
                    hint: 'Password',
                    isObscure: isObscure,
                    hasSuffix: true,
                    onPress: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ResetPassword()),
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyles.body.copyWith(color: Warna.white, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    await checkUser();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Warna.green,
                    minimumSize: const Size(300, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Container(
                    width: 200,
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyles.title.copyWith(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
