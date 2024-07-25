import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../Catatan/catatanAset.dart';
import '../../komponen/style.dart';
import '../../qrView.dart';
import '../ControllerLogic.dart';

class MoreDetailAC extends StatefulWidget {
  const MoreDetailAC({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  State<MoreDetailAC> createState() => _MoreDetailACState();
}

class _MoreDetailACState extends State<MoreDetailAC> {
  late DateTime targetDate = DateTime(2024, 2, 1);
  late Timer timer;
  double progressValue = 1.0;
  late List<String> DokAC = [];
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (DateTime.now().isBefore(targetDate)) {
        setState(() {
          progressValue = targetDate.difference(DateTime.now()).inSeconds /
              targetDate
                  .difference(DateTime(targetDate.year, targetDate.month, 0))
                  .inSeconds;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEEE, dd MMMM y', 'id_ID').format(dateTime);
  }

  Future<void> getAC() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('Aset').get();
    setState(() {
      DokAC = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = [
      widget.data['Foto AC Indoor'] ?? '',
      widget.data['Foto AC Outdoor'] ?? '',
    ];

    Widget buildPriorityLabel(String priority) {
      Color color;
      switch (priority.toLowerCase()) {
        case 'low':
          color = Colors.green;
          break;
        case 'medium':
          color = Colors.yellow.shade600;
          break;
        case 'high':
          color = Colors.red;
          break;
        default:
          color = Colors.grey;
      }

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          priority,
          style: TextStyle(color: color),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor:Warna.green,
        title: Text('${widget.data['ID AC']}',
            style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white)),
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 370,
                  height: 570,
                  decoration: BoxDecoration(
                    color: Warna.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: imageUrls.length,
                              onPageChanged: (int page) {
                                setState(() {
                                  _currentPage = page;
                                });
                              },
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.zero,
                                          content: Stack(
                                            children: [
                                              Image.network(imageUrls[index]),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 180,
                        child: SmoothPageIndicator(
                          controller: _pageController,  // PageController
                          count: imageUrls.length,
                          effect: const ExpandingDotsEffect(
                            dotWidth: 8.0,
                            dotHeight: 8.0,
                            activeDotColor: Warna.white,
                            dotColor: Warna.darkgrey,
                          ),  // your preferred effect
                        ),
                      ),
                      Positioned(
                          top: 30,
                          right: 20,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Warna.white,
                            ),
                            child: IconButton(
                              onPressed: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QRView(
                                        assetCollection: "AC",
                                        assetId: widget.data['ID AC'],
                                        assetName: widget.data['Merek AC'],
                                      ),
                                    ));
                              },
                              icon: const Icon(Icons.qr_code_2, size: 33),
                            ),
                          )
                      ),
              Positioned(
                  top: 100,
                  right: 20,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Warna.white,
                    ),
                    child: IconButton(
                      onPressed: (){
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.infoReverse,
                          headerAnimationLoop: false,
                          animType: AnimType.topSlide,
                          showCloseIcon: true,
                          closeIcon: const Icon(Icons.close),
                          title: 'Peringatan',
                          desc: 'Silahkan Periksa Aset! Apa Perlu Diservis?',
                          btnOkOnPress: () {
                            List<dynamic> kebutuhanAC = widget.data['Kebutuhan AC'] ?? [];

                            // Debugging: Cek hasil
                            print('Kebutuhan AC: $kebutuhanAC');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Catatan(
                                  List_Kebutuhan: kebutuhanAC,
                                  ID_Aset: widget.data['ID AC'],
                                  Nama_Aset: widget.data['Merek AC'],
                                  Jenis_Aset: widget.data['Jenis Aset'],
                                  lokasiAset: widget.data['Ruangan'],
                                ),
                              ),
                            );
                          },
                          btnCancelOnPress: () {},
                          onDismissCallback: (type) {
                            debugPrint('button yang ditekan $type');
                          },
                        ).show();
                      },
                      icon: const Icon(Icons.border_color_outlined, size: 33),
                    ),
                  )
              ),

                      Positioned(
                        top: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Expanded(
                            child: Container(
                              width: 300,
                              height: 420,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Kebutuhan Servis',
                                            style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          buildPriorityLabel(widget.data['Prioritas']),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: widget.data['Kebutuhan AC'].length,
                                            itemBuilder: (context, index) {
                                              final kebutuhanAC = widget.data['Kebutuhan AC']
                                              [index]['Nama Kebutuhan AC'];
                                              final hariKebutuhanAC =
                                              widget.data['Kebutuhan AC'][index]
                                              ['Hari Kebutuhan AC'];
                                              final waktuKebutuhanAC =
                                              widget.data['Kebutuhan AC'][index]
                                              ['Waktu Kebutuhan AC'];

                                              final part = kebutuhanAC.split(': ');
                                              final hasSplit =
                                              part.length > 1 ? part[1] : kebutuhanAC;

                                              return SizedBox(
                                                height: 80,
                                                child: ListTile(
                                                  dense: true,
                                                  contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                                  title: Padding(
                                                    padding: const EdgeInsets.only(bottom: 8.0),
                                                    child: Text(
                                                      '- $hasSplit',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                    children: [
                                                      showIndicator(
                                                        getValueIndicator(
                                                            hariKebutuhanAC,
                                                            epochTimeToData(
                                                                waktuKebutuhanAC)),
                                                        getProgressColor(
                                                            waktuKebutuhanAC),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            overflow:
                                                            TextOverflow.ellipsis,
                                                            getRemainingTime(
                                                                waktuKebutuhanAC),
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                          'Ditambahkan oleh',
                                          style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${widget.data['Teknisi Yang Menambahkan']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 15),

                                      Text(
                                          'Tanggal dibuat',
                                          style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        formatDate(widget.data['Tanggal Dibuat']),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                          'Merek AC',
                                          style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${widget.data['Merek AC']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                          'Ruangan',
                                          style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${widget.data['Ruangan']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                          'Status',
                                          style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${widget.data['Status']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text('ID AC',
                                          style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${widget.data['ID AC']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text('Lokasi Ruangan',
                                          style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${widget.data['Ruangan']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text('Kapasitas Watt',
                                          style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${widget.data['Kapasitas Watt']} watt',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text('Kapasitas PK',
                                          style: TextStyles.title.copyWith(
                                              fontSize: 18,
                                              color: Warna.darkgrey,
                                              fontWeight: FontWeight.w500)),
                                      Text(
                                        '${widget.data['Kapasitas PK']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
