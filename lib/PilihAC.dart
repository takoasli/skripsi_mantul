import 'package:flutter/material.dart';
import 'Aset/AC/AC.dart';
import 'Aset/Laptop/Laptop.dart';
import 'Aset/Mobil/Mobil.dart';
import 'Aset/Motor/Motor.dart';
import 'Aset/PC/PC.dart';
import 'komponen/style.dart';

class PilihAset extends StatefulWidget {
  const PilihAset({super.key});

  @override
  State<PilihAset> createState() => _PilihAsetState();
}

class _PilihAsetState extends State<PilihAset> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Aset Info',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          width: 370,
          height: 560,
          decoration: BoxDecoration(
            color: Warna.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AC()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Warna.green, // Warna latar belakang kotak
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Warna bayangan
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Geser bayangan pada sumbu Y
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Air Conditioner (AC)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PC()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Warna.green, // Warna latar belakang kotak
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Warna bayangan
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Geser bayangan pada sumbu Y
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Personal Computer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Laptop()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Warna.green, // Warna latar belakang kotak
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Warna bayangan
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Geser bayangan pada sumbu Y
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Laptop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Motor()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Warna.green, // Warna latar belakang kotak
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Warna bayangan
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Geser bayangan pada sumbu Y
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Motor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Mobil()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Warna.green, // Warna latar belakang kotak
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Warna bayangan
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Mobil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
