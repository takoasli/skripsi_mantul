import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class BacaMotor extends StatelessWidget {
  const BacaMotor({super.key,
    required this.dokumenMotor});

  final String dokumenMotor;
  @override
  Widget build(BuildContext context) {
    CollectionReference motor = FirebaseFirestore.instance.collection('Motor');
    return FutureBuilder(
      future: motor.doc(dokumenMotor).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> dataMotor = snapshot.data!.data() as Map<String, dynamic>;
            String gambarMotor = dataMotor['Gambar Motor'] ?? '';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: gambarMotor.isNotEmpty ? NetworkImage(gambarMotor) as ImageProvider<Object> : AssetImage('gambar/motor.png') as ImageProvider<Object>,
                  radius: 25,
                  backgroundColor: Warna.green,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dataMotor['Merek Motor']}',
                      style: TextStyles.title.copyWith(fontSize: 17, color: Warna.darkgrey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${dataMotor['ID Motor']}',
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
