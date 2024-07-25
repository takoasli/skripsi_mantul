import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Komponen/style.dart';

class GantiPass extends StatefulWidget {
  GantiPass({Key? key});

  final pengguna = FirebaseAuth.instance.currentUser;
  @override
  State<GantiPass> createState() => _GantiPassState();
}

class _GantiPassState extends State<GantiPass> {
  final newPasswordController = TextEditingController();
  final reenterPasswordController = TextEditingController();
  final passwordSekarang = TextEditingController();
  User? pengguna; // Tambahkan variabel untuk menyimpan data pengguna

  @override
  void initState() {
    super.initState();
    // Ambil informasi pengguna saat widget diinisialisasi
    pengguna = FirebaseAuth.instance.currentUser;
  }

  Future execSendEmail(BuildContext context) async {
    if (pengguna != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: pengguna!.email!,
        );
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              content: Text('Email reset password telah dikirim ke ${pengguna!.email}'),
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        print(e);
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          },
        );
      }
    } else {
      // Handle jika pengguna belum login
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text('Tidak ada pengguna yang sedang login.'),
          );
        },
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
          'Export Catatan',
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 55),
              child: Image.asset(
                'gambar/gambar_Avatar.png',
                fit: BoxFit.contain,
                width: 240,
                height: 240,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 30, right: 30),
                          child: Icon(
                            Icons.account_circle_rounded,
                            size: 55,
                            color: Warna.Blue,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Akun yang sedang aktif',
                                style: TextStyles.title.copyWith(color: Warna.darkgrey.withOpacity(0.7), fontSize: 17),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  pengguna?.email ?? 'No user logged in',
                                  style: TextStyles.title.copyWith(
                                    color: Warna.darkgrey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    // Column di sini
                    Column(
                      children: [

                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Text("Reset akun akan dikirim ke email anda",
                            style: TextStyles.body.copyWith(color: Warna.darkgrey.withOpacity(0.6), fontSize: 15),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: (){
                                execSendEmail(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Warna.Blue,
                                  minimumSize: const Size(150, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25))
                              ),
                              child: SizedBox(
                                width: 200,
                                child: Center(
                                  child: Text(
                                    'Change Password',
                                    style: TextStyles.title
                                        .copyWith(fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
