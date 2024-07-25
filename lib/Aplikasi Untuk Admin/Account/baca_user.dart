import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Komponen/style.dart';

class BacaUser extends StatelessWidget {
  const BacaUser({super.key, required this.dokumenUser});

  final String dokumenUser;

  @override
  Widget build(BuildContext context) {
    CollectionReference user = FirebaseFirestore.instance.collection('User');

    return FutureBuilder<DocumentSnapshot>(
      future: user.doc(dokumenUser).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          String urlGambar = data['Foto Profil'] ?? '';
          String role = data['Role'] ?? '';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: urlGambar.isNotEmpty
                    ? NetworkImage(urlGambar) as ImageProvider<Object>
                    : const AssetImage('gambar/user.png') as ImageProvider<Object>,
                radius: 25,
                backgroundColor: Warna.Blue,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${data['Nama']}',
                        style: TextStyles.title.copyWith(
                          fontSize: 17,
                          color: Warna.darkgrey,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyles.body.copyWith(
                      fontSize: 17,
                      color: role == 'Admin' ? Warna.green : Warna.darkgrey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data['ID']}',
                    style: TextStyles.body.copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ],
              ),
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return const Text('loading bang');
        }
      },
    );
  }
}
