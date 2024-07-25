import 'package:aplikasi_revamp/pilihInfoAset.dart';
import 'package:aplikasi_revamp/settings/ExportCatatan.dart';
import 'package:flutter/material.dart';
import 'Catatan/ListCatatan.dart';
import 'komponen/style.dart';

class BoxMenuContent extends StatelessWidget {
  const BoxMenuContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _kotak() {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PilihInfoAset()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 3,
                    shadowColor: Warna.green,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Warna.green,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_repair_service,
                            size: 30,
                            color: Warna.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Aset Info",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ListCatatan()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 3,
                    shadowColor: Warna.green,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Warna.green,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt,
                            size: 30,
                            color: Warna.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Catatan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExportCatatans()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    elevation: 3,
                    shadowColor: Warna.green,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Warna.green,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_present_rounded,
                            size: 30,
                            color: Warna.white,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Convert",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 140,
          width: 330,
          decoration: BoxDecoration(
            color: Warna.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: _kotak(),
          ),
        ),
      ],
    );
  }
}
