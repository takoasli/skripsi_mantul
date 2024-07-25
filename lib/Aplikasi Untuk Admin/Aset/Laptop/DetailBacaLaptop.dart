import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Aset/Laptop/moreDetailLaptop.dart';
import '../../Komponen/boxAset.dart';

class DetailBacaLaptop extends StatefulWidget {
  const DetailBacaLaptop({super.key,
    required this.detailDokumenLaptop});
  final String detailDokumenLaptop;

  @override
  State<DetailBacaLaptop> createState() => _DetailBacaLaptopState();
}

class _DetailBacaLaptopState extends State<DetailBacaLaptop> {
  late List<String> DokLaptop = [];
  @override
  Widget build(BuildContext context) {
    CollectionReference Laptop = FirebaseFirestore.instance.collection('Laptop');
    return FutureBuilder(
      future: Laptop.doc(widget.detailDokumenLaptop).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic> dataLaptop = snapshot.data!.data() as Map<String, dynamic>;
          String gambarLaptop = dataLaptop['Gambar Laptop'] ?? '';

          ImageProvider<Object>? imageProvider;
          if (gambarLaptop.isNotEmpty) {
            imageProvider = NetworkImage(gambarLaptop);
          } else {
            imageProvider = AssetImage('gambar/laptop.png');
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BoxAset(
                text: '${dataLaptop['Merek Laptop']}',
                gambar: imageProvider,
                halaman: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreDetailLaptop(data: dataLaptop),
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
