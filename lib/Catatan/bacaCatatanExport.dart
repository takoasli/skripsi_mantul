import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../komponen/style.dart';

class BacaCatatExport extends StatelessWidget {
  BacaCatatExport({super.key,
    required this.dokumenCatatanEx});
  final String dokumenCatatanEx;

  CollectionReference CatatEX = FirebaseFirestore.instance.collection('Catatan Servis');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: CatatEX.doc(dokumenCatatanEx).get(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasError){
              return Text('Terjadi Kesalahan Saat Membaca Catatan: ${snapshot.error}');
            }
            Map<String, dynamic> dataCatatEX = snapshot.data!.data() as Map<String, dynamic>;
            Timestamp timestamp = dataCatatEX['Tanggal Dilakukan Servis'];
            // Mengonversi Timestamp jadi objek DateTime
            DateTime dateTime = timestamp.toDate();
            // Mengonversi objek DateTime ke format tanggal
            String formattedDate = DateFormat('EEEE, dd MMMM y', 'id_ID').format(dateTime);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dataCatatEX['Nama Aset']}',
                      style: TextStyles.title.copyWith(fontSize: 20, color: Warna.darkgrey),
                    ),
                    Text(
                      formattedDate, // tampilin tanggal dalam format yang diinginkan
                      style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ],
                )
              ],
            );
          }else if(snapshot.connectionState == ConnectionState.waiting){
            return const CircularProgressIndicator();
          }else{
            return Text('Ada Kesalahan saat loading data: ${snapshot.error}');
          }
        });
  }
}
