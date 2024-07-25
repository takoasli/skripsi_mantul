import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../komponen/style.dart';
import '../Aset/ControllerLogic.dart';
import '../DashBoard_Admin.dart';
import '../Komponen/PhotoField.dart';
import '../Komponen/kotakBiaya.dart';
import '../Komponen/kotakDialogCatatan.dart';


class Catatan extends StatefulWidget {
  const Catatan({Key? key,
    required this.List_Kebutuhan,
    required this.ID_Aset,
    required this.Nama_Aset,
    required this.Jenis_Aset,
    this.lokasiAset,}) : super(key: key);

  final List<dynamic> List_Kebutuhan;
  final String ID_Aset;
  final String Nama_Aset;
  final String Jenis_Aset;
  final String? lokasiAset;

  @override
  State<Catatan> createState() => _CatatanState();
}

class _CatatanState extends State<Catatan> {

  final isiDialog = TextEditingController();
  final isiBiaya = TextEditingController();
  final CatatanLengkapController = TextEditingController();
  final hargaIsiBiaya = TextEditingController(text: '');
  late String idAset;
  late String merekAset;
  final ImgFotoController = TextEditingController();
  late String jenisAset;
  late String lokasi;
  final ImagePicker _FotoBukti = ImagePicker();
  String selectedKebutuhan = "";
  List<List<dynamic>> List_Kebutuhan = [];
  List biayaKebutuhans = [];


  void checkBoxberubah(bool? value, int index) {
    setState(() {
      if (value != null) {
        List_Kebutuhan[index][1] = value;
      }
    });
  }


  void SimpanTask(BuildContext context) {
    setState(() {
      List_Kebutuhan.add([isiDialog.text, false]);
      isiDialog.clear();
    });
    Navigator.of(context).pop();
  }

  void PilihFotoBukti() async {
    final pilihLaptop =
    await _FotoBukti.pickImage(source: ImageSource.camera);
    if (pilihLaptop != null) {
      setState(() {
        ImgFotoController.text = pilihLaptop.path;
      });
    }
  }

  void tambahTugas() {
    showDialog(
        context: context,
        builder: (context) {
          return KotakCatatanKebutuhan(
              controller: isiDialog,
              TextJudul: 'Kebutuhan Tambahan',
              onAdd: () => SimpanTask(context),
              onCancel: () => Navigator.of(context).pop());
        });
  }


  void ApusTask(int index){
  setState(() {
    List_Kebutuhan.removeAt(index);
  });
  }

  void SimpanBiaya(BuildContext context) {
    setState(() {
      // Pastikan isiBiaya dan hargaIsiBiaya tidak kosong
      if (isiBiaya.text.isNotEmpty && hargaIsiBiaya.text.isNotEmpty) {
        // Tambahkan nama biaya dan harga ke Biaya_Kebutuhan
        biayaKebutuhans.add(
            CatatanBiaya(isiBiaya.text, double.parse(hargaIsiBiaya.text.replaceAll(".", ""))));
        isiBiaya.clear();
        hargaIsiBiaya.clear();
      } else {
        print('tolong tambahkan informasi yang diminta');
      }
    });
    Navigator.of(context).pop();
  }

  void tambahListBiaya() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBiaya(
            NamaBiayacontroller: isiBiaya,
            HargaBiayacontroller: hargaIsiBiaya,
            onAdd: () => SimpanBiaya(context),
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Nama Biaya',
          );
        });
  }

  void ApusBiayaAC(int index) {
    setState(() {
      biayaKebutuhans.removeAt(index);
    });
  }

  double hitungTotalBiaya() {
    double totalBiaya = 0.0;
    for (int i = 0; i < biayaKebutuhans.length; i++) {
      totalBiaya += biayaKebutuhans[i].biaya;
    }
    return totalBiaya;
  }

  Future<String> unggahFotoBukti(File FotoBukti) async {
    try {
      if (!FotoBukti.existsSync()) {
        print('File tidak ditemukan!');
        return '';
      }
      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('Catatan Servis')
          .child(ImgFotoController.text.split('/').last);

      UploadTask uploadBukti = penyimpanan.putFile(FotoBukti);
      await uploadBukti;
      String BuktiFoto = await penyimpanan.getDownloadURL();
      return BuktiFoto;
    } catch (e) {
      print('pennyimpanan foto bukti gagal : $e');
      return '';
    }
  }

  void SimpanCatatan() async {
    try {
      String lokasiFotoBukti = ImgFotoController.text;
      String fotoBukti = '';

      List<Map<String, dynamic>> CatatanBiaya = [];
      for (int i = 0; i < biayaKebutuhans.length; i++) {
        CatatanBiaya.add({
          'Nama Biaya': biayaKebutuhans[i].nama,
          'Harga Biaya': biayaKebutuhans[i].biaya,
        });
      }

      if (lokasiFotoBukti.isNotEmpty) {
        File imgBukti = File(lokasiFotoBukti);
        fotoBukti = await unggahFotoBukti(imgBukti);
      }

      // Save data into Firestore
      await tambahCatatan(
          merekAset,
          idAset,
          lokasi,
          selectedKebutuhan,
          CatatanBiaya,
          CatatanLengkapController.text,
          hitungTotalBiaya(),
          jenisAset,
          fotoBukti
      );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Catatan Berhasil Ditambahkan!',
        btnOkOnPress: () {
          Navigator.of(context).pop();
        },
        btnOkText: 'Ok',
        btnCancelOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Dashboard_Admins()),
          );
        },
        btnCancelText: 'Dashboard',
        btnCancel: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Warna.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard_Admins()),
            );
          },
          child: Text('Dashboard'),
        ),
      ).show();

      print('Data Catatan Berhasil Disimpan!');
    } catch (e) {
      print("Error: $e");
    }
  }

  Future tambahCatatan (
      String merekAset,
      String idAset,
      String lokasi,
      String selectedKebutuhan,
      List<Map<String, dynamic>> CatatanBiaya,
      String CatatanLengkap,
      double totalBiaya,
      String jenisAset,
      String GambarBukti) async{
    await FirebaseFirestore.instance.collection('Catatan Servis').add({
      'Nama Aset': merekAset,
      'ID Aset': idAset,
      'Lokasi Aset' : lokasi,
      'Kebutuhan yg dikerjakan' : selectedKebutuhan,
      'Catatan Biaya' : CatatanBiaya,
      'Catatan Tambahan' : CatatanLengkap,
      'Total Biaya' : totalBiaya,
      'Jenis Aset' : jenisAset,
      'Tanggal Dilakukan Servis': FieldValue.serverTimestamp(),
      'Foto Bukti' : GambarBukti
    });
  }




  @override
  void initState(){
    super.initState();
    idAset = '${widget.ID_Aset}';
    merekAset = '${widget.Nama_Aset}';
    jenisAset = '${widget.Jenis_Aset}';
    lokasi = '${widget.lokasiAset}';
    List_Kebutuhan = List<List<dynamic>>.from(widget.List_Kebutuhan.map((item) => [item, false]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: Warna.green,
        title: const Text(
          'Catatan Servis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 1,
        centerTitle: false,
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Stack(
            children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Aset yang terpilih...',
                          style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 370,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          const Padding(
                              padding: EdgeInsets.all(10),
                          child:
                          Icon(Icons.home_repair_service_outlined,
                          size: 40
                          ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(merekAset,
                              style: TextStyles.title.copyWith(fontSize: 20)
                              ),
                              SizedBox(height: 5.0),
                              Text(idAset,
                              style: TextStyles.body.copyWith(fontSize: 17),
                              ),
                              Text(jenisAset,
                                style: TextStyles.body.copyWith(fontSize: 17),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Kebutuhan',
                        style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Warna.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25),
                          bottomRight: Radius.circular(25), bottomLeft: Radius.circular(25)),
                        ),
                        child: Column(
                          children: [
                            DropdownSearch<String>(
                              popupProps: const PopupProps.menu(
                                showSelectedItems: true,
                              ),
                              items: List_Kebutuhan.map((item) => item[0].toString()).toList(),
                              dropdownDecoratorProps: const DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    hintText: "Pilih...",
                                  border: InputBorder.none,
                                ),
                              ),
                              onChanged: (selectedValue){
                                print(selectedValue);
                                setState(() {
                                  selectedKebutuhan = selectedValue ?? "";
                                });
                              },
                            ),

                            selectedKebutuhan.isEmpty ? const Text(
                              'Mohon pilih setidaknya satu kebutuhan.',
                              style: TextStyle(
                                color: Colors.red, // Warna teks menjadi merah
                                fontStyle: FontStyle.italic, // Teks miring
                              ),
                            ) : Container(),

                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: InkWell(
                                onTap: tambahTugas,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add),
                                      SizedBox(width: 5),
                                      Text('Tambah Kebutuhan Lainnya...'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Catatan Biaya',
                          style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white)
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    Container(
                      width: 350,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListView(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: biayaKebutuhans.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(biayaKebutuhans[index].nama),
                                  subtitle: Text(convertToRupiah(
                                      biayaKebutuhans[index].biaya)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      ApusBiayaAC(index);
                                    },
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          ),
                          InkWell(
                            onTap: tambahListBiaya,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Row(
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 5),
                                  Text('Tambah Biaya Penyeluaran...'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Catatan Lengkap',
                          style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      width: 350,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: CatatanLengkapController,
                          maxLines: null, // Untuk mengizinkan multiple baris teks
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Masukkan catatan tambahan...',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Foto Bukti',
                          style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      width: 350,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: PhotoField(
                            controller: ImgFotoController,
                            selectedPhotoName: ImgFotoController.text.isNotEmpty
                                ? ImgFotoController.text.split('/').last
                                : '',
                            onPressed: PilihFotoBukti),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Container(
                      width: 350,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Total:',
                              style: TextStyles.title.copyWith(
                                fontSize: 18,
                                color: Warna.darkgrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                convertToRupiah(hitungTotalBiaya()),
                                style: TextStyles.title.copyWith(
                                  fontSize: 18,
                                  color: Warna.darkgrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                          onPressed: SimpanCatatan,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Warna.lightgreen,
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(color: Warna.lightgreen, width: 5),
                              )
                          ),
                          child: Container(
                            width: 200,
                            child: Center(
                              child: Text(
                                'Simpan Catatan',
                                style: TextStyles.title
                                    .copyWith(fontSize: 20, color: Warna.white),
                              ),
                            ),
                          ),
                        ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
