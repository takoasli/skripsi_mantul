import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../komponen/style.dart';

class BacaNotif extends StatelessWidget {
  const BacaNotif({super.key,
    required this.dokumenNotif});
  final String dokumenNotif;

  @override
  Widget build(BuildContext context) {
    CollectionReference Notif = FirebaseFirestore.instance.collection('List Notif');

    return FutureBuilder<DocumentSnapshot>(
        future: Notif.doc(dokumenNotif).get(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasError){
              return Text('Error : ${snapshot.error}');
            }
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            Timestamp timestamp = data['Tanggal Dilakukan Servis'];

            // Mengonversi Timestamp jadi objek DateTime
            DateTime dateTime = timestamp.toDate();

            // Mengonversi objek DateTime ke format tanggal
            String formattedDate = DateFormat('EEEE, dd MMMM y', 'id_ID').format(dateTime);


            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.notification_add),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${data['judul']}',
                      style: TextStyles.title.copyWith(
                        fontSize: 17,
                        color: Warna.darkgrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${data['isi']}',
                      style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                    Text(
                      formattedDate, // Menampilkan tanggal dalam format yang diinginkan
                      style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ],
                )
              ],
            );
          }else if(snapshot.connectionState == ConnectionState.waiting){
            return CircularProgressIndicator();
          }else{
            return Text('Loading failed!');
          }
        });
  }
}
