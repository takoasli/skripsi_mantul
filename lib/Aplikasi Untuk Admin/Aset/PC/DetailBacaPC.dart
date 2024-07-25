import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Aset/PC/MoreDetailPC.dart';
import '../../Komponen/boxAset.dart';

class DetailBacaPC extends StatefulWidget {
  const DetailBacaPC({Key? key, required this.detailDokumenPC}) : super(key: key);
  final String detailDokumenPC;

  @override
  State<DetailBacaPC> createState() => _DetailBacaPCState();
}

class _DetailBacaPCState extends State<DetailBacaPC> {
  late List<String> DokPC = [];
  @override
  Widget build(BuildContext context) {
    CollectionReference komputer = FirebaseFirestore.instance.collection('PC');

    return FutureBuilder(
      future: komputer.doc(widget.detailDokumenPC).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic> dataPC = snapshot.data!.data() as Map<String, dynamic>;
          String gambarPC = dataPC['Gambar PC'] ?? '';

          ImageProvider<Object>? imageProvider;
          if (gambarPC.isNotEmpty) {
            imageProvider = NetworkImage(gambarPC);
          } else {
            imageProvider = AssetImage('gambar/pc.png');
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BoxAset(
                text: '${dataPC['Merek PC']}',
                gambar: imageProvider,
                halaman: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreDetail(data: dataPC),
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
