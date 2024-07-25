import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Aset/Motor/MoreDetailMotor.dart';
import '../../Komponen/boxAset.dart';

class DetailBacaMotor extends StatefulWidget {
  const DetailBacaMotor({super.key, required this.detailDokumenMotor});
  final String detailDokumenMotor;

  @override
  State<DetailBacaMotor> createState() => _DetailBacaMotorState();
}

class _DetailBacaMotorState extends State<DetailBacaMotor> {
  late List<String> DokMotor = [];
  @override
  Widget build(BuildContext context) {
    CollectionReference Motor = FirebaseFirestore.instance.collection('Motor');
    return FutureBuilder(
      future: Motor.doc(widget.detailDokumenMotor).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic> dataMotor = snapshot.data!.data() as Map<String, dynamic>;
          String gambarMotor = dataMotor['Gambar Motor'] ?? '';

          ImageProvider<Object>? imageProvider;
          if (gambarMotor.isNotEmpty) {
            imageProvider = NetworkImage(gambarMotor);
          } else {
            imageProvider = AssetImage('gambar/motor.png');
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BoxAset(
                text: '${dataMotor['Merek Motor']}',
                gambar: imageProvider,
                halaman: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreDetailMotor(data: dataMotor),
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
