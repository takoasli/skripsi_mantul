import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Aset/Mobil/MoreDetailMobil.dart';
import '../../Komponen/boxAset.dart';

class DetailBacaMobil extends StatefulWidget {
  const DetailBacaMobil({super.key,
    required this.detailDokumenMobil});
  final String detailDokumenMobil;

  @override
  State<DetailBacaMobil> createState() => _DetailBacaMobilState();
}

class _DetailBacaMobilState extends State<DetailBacaMobil> {
  @override
  Widget build(BuildContext context) {
    CollectionReference Mobil = FirebaseFirestore.instance.collection('Mobil');
    return FutureBuilder(
      future: Mobil.doc(widget.detailDokumenMobil).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic> dataMobil = snapshot.data!.data() as Map<String, dynamic>;
          String gambarMobil = dataMobil['Gambar Mobil'] ?? '';

          ImageProvider<Object>? imageProvider;
          if (gambarMobil.isNotEmpty) {
            imageProvider = NetworkImage(gambarMobil);
          } else {
            imageProvider = AssetImage('gambar/mobil.png');
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BoxAset(
                text: '${dataMobil['Merek Mobil']}',
                gambar: imageProvider,
                halaman: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreDetailmobil(data: dataMobil),
                    ),
                  );
                },
              ),
            ],
          );
        }

        return Text('Data tidak ditemukan');
      },
    );
  }
}
