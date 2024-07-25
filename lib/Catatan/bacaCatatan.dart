import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../komponen/style.dart';
import 'package:intl/intl.dart';

class BacaCatatan extends StatelessWidget {
  const BacaCatatan({
    Key? key,
    required this.dokumenCatatan,
  }) : super(key: key);

  final String dokumenCatatan;

  @override
  Widget build(BuildContext context) {
    CollectionReference Catatan = FirebaseFirestore.instance.collection('Catatan Servis');
    return FutureBuilder<DocumentSnapshot>(
      future: Catatan.doc(dokumenCatatan).get(),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasError){
            return Text('Error: ${snapshot.error}');
          }
          Map<String, dynamic> dataCatatan = snapshot.data!.data() as Map<String, dynamic>;

          // dapet Timestamp dari Firestore
          Timestamp timestamp = dataCatatan['Tanggal Dilakukan Servis'];

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
                    '${dataCatatan['Nama Aset']}',
                    style: TextStyles.title.copyWith(fontSize: 20, color: Warna.darkgrey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${dataCatatan['ID Aset']}',
                    style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                  Text(
                    '${dataCatatan['Jenis Aset']}',
                    style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ],
              )
            ],
          );
        } else if(snapshot.connectionState == ConnectionState.waiting){
          return CircularProgressIndicator();
        } else {
          return Text('Loading...');
        }
      },
    );
  }
}
