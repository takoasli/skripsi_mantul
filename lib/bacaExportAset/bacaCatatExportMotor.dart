import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class BacaMotorExport extends StatelessWidget {
  BacaMotorExport({super.key,
    required this.dokumenAsetMotor});
  final String dokumenAsetMotor;

  CollectionReference DokumAsetMotor= FirebaseFirestore.instance.collection('Motor');
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: DokumAsetMotor.doc(dokumenAsetMotor).get(),
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
                      '${dataAsetPC['Merek Motor']}',
                      style: TextStyles.title.copyWith(fontSize: 20, color: Warna.darkgrey),
                    ),

                    Text(
                      '${dataAsetPC['ID Motor']}',
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
