import 'package:flutter/material.dart';
import '../Komponen/style.dart';

class LihatAkun extends StatefulWidget {
  const LihatAkun({Key? key, required this.data}) : super(key: key);

  final Map<String, dynamic> data;

  @override
  State<LihatAkun> createState() => _LihatAkunState();
}


class _LihatAkunState extends State<LihatAkun> {
  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.data['Foto Profil'] ?? '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.Blue,
        title: Text('${widget.data['Nama']}',
            style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white)),
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 370,
              height: 570,
              decoration: BoxDecoration(
                color: Warna.Blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CircleAvatar(
                        radius: 75, // Ukuran radius sesuai dengan ukuran gambar yang diinginkan
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : AssetImage('gambar/users.png') as ImageProvider,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 170,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: 320,
                        height: 380,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildInfo('Nama', widget.data['Nama']),
                                  buildInfo('ID', widget.data['ID']),
                                  buildInfo('Email', widget.data['Email']),
                                  buildInfo('Nomor HP', widget.data['Nomor HP']),
                                  buildInfo('Alamat', widget.data['Alamat Rumah']),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

      ),
    );
  }

  Widget buildInfo(String title, dynamic content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.title.copyWith(
              fontSize: 18,
              color: Warna.darkgrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            content?.toString() ?? '-', // Ensure content is a String or default to '-'
            style: const TextStyle(
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

