import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class BacaAC extends StatelessWidget {
  const BacaAC({super.key,
    required this.dokumenAC});

  final String dokumenAC;



  @override
  Widget build(BuildContext context) {
    CollectionReference AirConditioner = FirebaseFirestore.instance.collection('Aset');
    return FutureBuilder(
        future: AirConditioner.doc(dokumenAC).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.hasError){
              return Text('Error: ${snapshot.error}');
            }

            Map<String, dynamic> dataAc = snapshot.data!.data() as Map<String, dynamic>;
            String urlGambarIndoor = dataAc['Foto AC Indoor'] ?? '';

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: urlGambarIndoor.isNotEmpty ? NetworkImage(urlGambarIndoor)
                  as ImageProvider<Object> : AssetImage('gambar/ac.png') as ImageProvider<Object>,
                  radius: 25,
                  backgroundColor: Warna.green,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${dataAc['Merek AC']}',
                      style: TextStyles.title.copyWith(
                        fontSize: 17,
                        color: Warna.darkgrey,
                        letterSpacing: 0.5
                      ),
                    ),
                    SizedBox(height: 4),

                    Text(
                        '${dataAc['ID AC']}',
                      style: TextStyles.body.copyWith(
                          fontSize: 15,
                      color: Warna.darkgrey),
                    ),
                  ],
                )
              ],
            );
          }else if(snapshot.connectionState == ConnectionState.waiting){
            return CircularProgressIndicator();
          }else {
            return Text ('Memuat Data, silahkan tunggu');
          }
        });
  }
}
