import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../komponen/style.dart';

class BacaLaptopExport extends StatelessWidget {
  BacaLaptopExport({super.key,
    required this.dokumenAsetLaptop});
  final String dokumenAsetLaptop;

  CollectionReference DokumAsetLaptop = FirebaseFirestore.instance.collection('Laptop');
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: DokumAsetLaptop.doc(dokumenAsetLaptop).get(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasError){
              return Text('Terjadi Kesalahan Saat Membaca Aset Laptop: ${snapshot.error}');
            }
            Map<String, dynamic> dataAsetLaptop = snapshot.data!.data() as Map<String, dynamic>;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dataAsetLaptop['Merek Laptop']}',
                      style: TextStyles.title.copyWith(fontSize: 20, color: Warna.darkgrey),
                    ),

                    Text(
                      '${dataAsetLaptop['ID Laptop']}',
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