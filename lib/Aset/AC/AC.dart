import 'package:flutter/material.dart';
import '../../komponen/style.dart';

class AC extends StatefulWidget {
  const AC({super.key});

  @override
  State<AC> createState() => _ACState();
}

class _ACState extends State<AC> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Warna.green,
        appBar: AppBar(
          backgroundColor: Warna.green,
          title: const Text(
            'AC',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
