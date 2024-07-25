import 'package:aplikasi_revamp/settings/GantiPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'komponen/style.dart';
import 'login.dart';

class Profiles extends StatefulWidget {
  Profiles({Key? key}) : super(key: key);

  final pengguna = FirebaseAuth.instance.currentUser!;

  @override
  State<Profiles> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
  final double tiggiBackground = 200;
  final double tinggiProfile = 60;

  void logout() {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement;
    FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Warna.white
          ),
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .where("Email", isEqualTo: widget.pengguna.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak Ada Data'));
          } else {

            var doc = snapshot.data!.docs[0];
            var dataUser = doc.data() as Map;
            return ListView(
              children: <Widget>[
                buildTop(dataUser),
                const SizedBox(height: 65),
                buildNama(dataUser),
                buildKonten(dataUser),
                const SizedBox(height: 40),
                buildLogout(),
                const SizedBox(height: 40),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildLogout() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GantiPass()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Warna.green,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(200, 50),
          ),
          child: Container(
            width: 200,
            child: Center(
              child: Text(
                'Change Password',
                style: TextStyles.title
                    .copyWith(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Warna.green,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(200, 50),
          ),
          child: Container(
            width: 200,
            child: Center(
              child: Text(
                'Logout',
                style: TextStyles.title
                    .copyWith(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildNama(Map<dynamic, dynamic> dataUser) {
    return Positioned(
      top: tiggiBackground - (tinggiProfile / 2),
      child: Column(
        children: [
          Text(
            dataUser['Nama'] ?? 'No Name',
            style: TextStyles.title.copyWith(fontSize: 30, color: Warna.black),
          ),
          const SizedBox(height: 6),
          Text(
            dataUser['ID'] ?? 'No ID',
            style:
            TextStyles.body.copyWith(fontSize: 15, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget buildKonten(Map<dynamic, dynamic> dataUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildInfoText('HP', '${dataUser['Nomor HP']}'),
          const SizedBox(height: 20),
          buildInfoText('Email', dataUser['Email'] ?? '-'),
          const SizedBox(height: 20),
          buildInfoText('Alamat', dataUser['Alamat Rumah'] ?? '-'),
        ],
      ),
    );
  }

  Widget buildInfoText(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: TextStyles.body.copyWith(color: Warna.black, fontSize: 17)),
        const SizedBox(height: 6),
        Text(content,
            style:
            TextStyles.body.copyWith(color: Colors.black38, fontSize: 15)),
      ],
    );
  }

  Widget buildTop(Map<dynamic, dynamic> dataUser) {
    final atas = tiggiBackground - tinggiProfile;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        gambarBackground(),
        Positioned(
          top: atas,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  gambarProfile(dataUser['Foto Profil']),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget gambarBackground() => Container(
    color: Colors.green,
    child: Image.asset(
      'gambar/background_profile.jpg',
      width: double.infinity,
      height: tiggiBackground,
      fit: BoxFit.cover,
    ),
  );

  Widget gambarProfile(url) => CircleAvatar(
    radius: tinggiProfile,
    backgroundImage: NetworkImage(url),
    backgroundColor: Colors.white,
  );
}
