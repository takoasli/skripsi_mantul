import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';
class BacaMobil extends StatelessWidget {
  const BacaMobil({super.key,
    required this.dokumenMobil});
  final String dokumenMobil;

  @override
  Widget build(BuildContext context) {
    CollectionReference mobil = FirebaseFirestore.instance.collection('Mobil');
    return FutureBuilder(
      future: mobil.doc(dokumenMobil).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> dataMobil = snapshot.data!.data() as Map<String, dynamic>;
            String gambarMobil = dataMobil['Gambar Mobil'] ?? '';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: gambarMobil.isNotEmpty ? NetworkImage(gambarMobil) as ImageProvider<Object> : AssetImage('gambar/mobil.png') as ImageProvider<Object>,
                  radius: 25,
                  backgroundColor: Warna.green,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dataMobil['Merek Mobil']}',
                      style: TextStyles.title.copyWith(fontSize: 17, color: Warna.darkgrey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${dataMobil['ID Mobil']}',
                      style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ],
                )
              ],
            );
          } else {
            return Text('Data Kosong');
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return Text('Gagal Memuat Data');
        }
      },
    );
  }
}
