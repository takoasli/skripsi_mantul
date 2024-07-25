import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class BacaACExport extends StatelessWidget {
  BacaACExport({super.key,
    required this.dokumenAsetAC});
  final String dokumenAsetAC;

  CollectionReference DokumAsetAC = FirebaseFirestore.instance.collection('Aset');
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: DokumAsetAC.doc(dokumenAsetAC).get(),
        builder: (context, snapshot){
    if(snapshot.connectionState == ConnectionState.done){
    if(snapshot.hasError){
      return Text('Terjadi Kesalahan Saat Membaca Aset AC: ${snapshot.error}');
        }
        Map<String, dynamic> dataAsetAC = snapshot.data!.data() as Map<String, dynamic>;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${dataAsetAC['Merek AC']}',
              style: TextStyles.title.copyWith(fontSize: 20, color: Warna.darkgrey),
            ),

            Text(
              '${dataAsetAC['ID AC']}',
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
