import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class BacaMobilExport extends StatelessWidget {
  BacaMobilExport({super.key,
    required this.dokumenAsetMobil});
  final String dokumenAsetMobil;

  CollectionReference DokumAsetMobil= FirebaseFirestore.instance.collection('Mobil');
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: DokumAsetMobil.doc(dokumenAsetMobil).get(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasError){
              return Text('Terjadi Kesalahan Saat Membaca Aset Mobil: ${snapshot.error}');
            }
            Map<String, dynamic> dataAsetPC = snapshot.data!.data() as Map<String, dynamic>;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dataAsetPC['Merek Mobil']}',
                      style: TextStyles.title.copyWith(fontSize: 20, color: Warna.darkgrey),
                    ),

                    Text(
                      '${dataAsetPC['ID Mobil']}',
                      style: TextStyles.title.copyWith(fontSize: 20, color: Warna.darkgrey),
                    ),
                  ],
                )
              ],
            );
          }else if(snapshot.connectionState == ConnectionState.waiting){
            return CircularProgressIndicator();
          }else{
            return Text('Ada Kesalahan saat loading data: ${snapshot.error}');
          }
        });
  }
}
