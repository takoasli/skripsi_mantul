import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class BacaPC extends StatelessWidget {
  const BacaPC({super.key,
    required this.dokumenPC});
  final String dokumenPC;

  @override
  Widget build(BuildContext context) {
    CollectionReference komputer = FirebaseFirestore.instance.collection('PC');
    return FutureBuilder(
      future: komputer.doc(dokumenPC).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> dataPC = snapshot.data!.data() as Map<String, dynamic>;
            String gambarPC = dataPC['Gambar PC'] ?? '';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: gambarPC.isNotEmpty ? NetworkImage(gambarPC) as ImageProvider<Object> : AssetImage('gambar/pc.png') as ImageProvider<Object>,
                  radius: 25,
                  backgroundColor: Warna.green,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dataPC['Merek PC']}',
                      style: TextStyles.title.copyWith(fontSize: 17, color: Warna.darkgrey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${dataPC['ID PC']}',
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
