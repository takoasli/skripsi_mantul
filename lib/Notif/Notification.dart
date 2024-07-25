import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class Notifikasi extends StatefulWidget {
  const Notifikasi({super.key});

  @override
  State<Notifikasi> createState() => _NotifikasiState();
}
class _NotifikasiState extends State<Notifikasi> {
  @override
  Widget build(BuildContext context) {

    final pesan = ModalRoute.of(context)!.settings.arguments as RemoteMessage;

    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
          child: Column(
            children: [
              Text(pesan.notification!.title.toString()),
              Text(pesan.notification!.body.toString()),
              Text(pesan.notification!.body.toString()),
              Text(pesan.data.toString()),
            ],
          ),

        ),
      ),
    );
  }
}
