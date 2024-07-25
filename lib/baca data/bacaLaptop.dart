import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class BacaLaptop extends StatelessWidget {
  const BacaLaptop({super.key,
    required this.dokumenLaptop});
  final String dokumenLaptop;

  @override
  Widget build(BuildContext context) {
    CollectionReference laptop = FirebaseFirestore.instance.collection('Laptop');
    return FutureBuilder(
      future: laptop.doc(dokumenLaptop).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> dataLaptop = snapshot.data!.data() as Map<String, dynamic>;
            String gambarLaptop = dataLaptop['Gambar Laptop'] ?? '';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: gambarLaptop.isNotEmpty ? NetworkImage(gambarLaptop) as ImageProvider<Object> : AssetImage('gambar/laptop.png') as ImageProvider<Object>,
                  radius: 25,
                  backgroundColor: Warna.green,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dataLaptop['Merek Laptop']}',
                      style: TextStyles.title.copyWith(fontSize: 17, color: Warna.darkgrey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${dataLaptop['ID Laptop']}',
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
