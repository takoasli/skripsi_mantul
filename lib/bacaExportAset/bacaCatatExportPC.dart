import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class BacaPCExport extends StatelessWidget {
  BacaPCExport({super.key,
    required this.dokumenAsetPC});
  final String dokumenAsetPC;

  CollectionReference DokumAsetPC= FirebaseFirestore.instance.collection('PC');
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: DokumAsetPC.doc(dokumenAsetPC).get(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasError){
              return Text('Terjadi Kesalahan Saat Membaca Aset Motor: ${snapshot.error}');
            }
            Map<String, dynamic> dataAsetPC = snapshot.data!.data() as Map<String, dynamic>;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dataAsetPC['Merek PC']}',
                      style: TextStyles.title.copyWith(fontSize: 20, color: Warna.darkgrey),
                    ),

                    Text(
                      '${dataAsetPC['ID PC']}',
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
