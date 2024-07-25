import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Aset/AC/moreDetailAC.dart';
import '../../Komponen/boxAset.dart';

class DetailBacaAC extends StatefulWidget {
  const DetailBacaAC({super.key,
    required this.detailDokumenAC});
  final String detailDokumenAC;

  @override
  State<DetailBacaAC> createState() => _DetailBacaACState();
}

class _DetailBacaACState extends State<DetailBacaAC> {
  @override
  Widget build(BuildContext context) {
    CollectionReference AC = FirebaseFirestore.instance.collection('Aset');
    return FutureBuilder(
      future: AC.doc(widget.detailDokumenAC).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic> dataAC = snapshot.data!.data() as Map<String, dynamic>;
          String gambarAC = dataAC['Foto AC Indoor'] ?? '';

          ImageProvider<Object>? imageProvider;
          if (gambarAC.isNotEmpty) {
            imageProvider = NetworkImage(gambarAC);
          } else {
            imageProvider = AssetImage('gambar/ac.png');
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BoxAset(
                text: '${dataAC['Merek AC']}',
                gambar: imageProvider,
                halaman: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreDetailAC(data: dataAC),
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
