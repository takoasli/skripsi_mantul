import 'dart:io';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:aplikasi_revamp/Aset/Mobil/manajemenMobil.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../komponen/kotakDialog.dart';
import '../../komponen/style.dart';
import '../../main.dart';
import 'package:image/image.dart' as img;
import '../../textfield/imageField.dart';
import '../../textfield/textfields.dart';
import '../ControllerLogic.dart';

class AddMobil extends StatefulWidget {
  const AddMobil({super.key});

  @override
  State<AddMobil> createState() => _AddMobilState();
}

class KebutuhanModelMobil {
  String namaKebutuhanMobil;
  int masaKebutuhanMobil;
  int randomID;

  KebutuhanModelMobil(
      this.namaKebutuhanMobil,
      this.masaKebutuhanMobil,
      this.randomID
      );
}

enum MobilStatus { aktif, rusak, hilang }
MobilStatus selectedStatus = MobilStatus.aktif;

class _AddMobilState extends State<AddMobil> {
  final merekMobilController = TextEditingController();
  String selectedKondisi = "";
  String selectedPrioritas = "";
  final _formState = GlobalKey<FormState>();
  final TeknisiController = TextEditingController();
  final idMobilCOntroller = TextEditingController();
  final tipemesinController = TextEditingController();
  final tipeBahanBakarController = TextEditingController();
  final pendinginController = TextEditingController();
  final transmisController = TextEditingController();
  final kapasitasBBController = TextEditingController();
  final ukuranBanController = TextEditingController();
  final akiController = TextEditingController();
  final MasaKebutuhanController = TextEditingController();
  final isiKebutuhan_Mobil = TextEditingController();
  final imgMobilController = TextEditingController();
  final ImagePicker _gambarMobil = ImagePicker();
  List Kebutuhan_Mobil = [];
  List<String> Status = [
    "Aktif",
    "Rusak",
    "Hilang",
  ];
  List<String> Prioritas = [
    "High",
    "Medium",
    "Low",
  ];

  void PilihGambarMobil() async {
    final pilihMobil =
        await _gambarMobil.pickImage(source: ImageSource.gallery);
    if (pilihMobil != null) {
      File resizedImage = await resizeImage(File(pilihMobil.path));
      setState(() {
        imgMobilController.text = resizedImage.path;
      });
    }
  }

  Future<void> pilihSumberGambar(bool isIndoor) async {
    final pilihSumber = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Pilih Sumber Gambar'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        contentPadding: const EdgeInsets.all(20.0),
        content: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                onPressed: () => Navigator.of(context).pop(0), // Pilih dari galeri
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library, size: 50, color: Warna.white),
                    SizedBox(height: 5),
                    Text('Galeri', style: TextStyle(fontSize: 18, color: Warna.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                onPressed: () => Navigator.of(context).pop(1), // Ambil foto
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: Warna.white),
                    SizedBox(height: 5),
                    Text('Kamera', style: TextStyle(fontSize: 18, color: Warna.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (pilihSumber == 0) {
      // Pilih dari galeri
      if (isIndoor) {
        PilihGambarMobil();
      }
    } else if (pilihSumber == 1) {
      // Ambil foto
      if (isIndoor) {
        PilihFotoMobil();
      }
    }
  }

  void fetchNamaPengguna() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('User')
        .where("Email", isEqualTo: pengguna.email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        namaPengguna = snapshot.docs.first.data()['Nama'];
        TeknisiController.text = namaPengguna;
      });
    }
  }

  final pengguna = FirebaseAuth.instance.currentUser!;
  String namaPengguna = '';

  Future<File> resizeImage(File imageFile, {int maxWidth = 500, int maxHeight = 500}) async {
    final image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) {
      throw Exception('Could not decode image');
    }

    double aspectRatio = image.width / image.height;

    int newWidth, newHeight;
    if (aspectRatio > 1) {
      newWidth = maxWidth;
      newHeight = (maxWidth / aspectRatio).round();
    } else {
      newHeight = maxHeight;
      newWidth = (maxHeight * aspectRatio).round();
    }

    final resizedImage = img.copyResize(image, width: newWidth, height: newHeight);
    final resizedImageFile = File(imageFile.path)..writeAsBytesSync(img.encodePng(resizedImage));

    return resizedImageFile;
  }

  void PilihFotoMobil() async {
    final pilihMobil =
    await _gambarMobil.pickImage(source: ImageSource.camera);
    if (pilihMobil != null) {
      File resizedImage = await resizeImage(File(pilihMobil.path));
      setState(() {
        imgMobilController.text = resizedImage.path;
      });
    }
  }

  Future<String> unggahGambarMobil(File gambarMobil) async {
    try {
      if (!gambarMobil.existsSync()) {
        print('File tidak ditemukan!');
        return '';
      }
      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('Mobil')
          .child(imgMobilController.text.split('/').last);

      UploadTask uploadMobil = penyimpanan.putFile(gambarMobil);
      await uploadMobil;
      String fotoMobil = await penyimpanan.getDownloadURL();
      return fotoMobil;
    } catch (e) {
      print('$e');
      return '';
    }
  }

  void SimpanKebutuhan_Mobil() async {
    String masaKebutuhanText = MasaKebutuhanController.text.trim();
    int randomId = generateRandomId();
    print('Random ID: $randomId');
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan_Mobil.add(KebutuhanModelMobil(
          isiKebutuhan_Mobil.text,
          masaKebutuhan,
          randomId
        ));

        isiKebutuhan_Mobil.clear();
        MasaKebutuhanController.clear();

        setState(() {});
        await AndroidAlarmManager.oneShot(
          Duration(days: masaKebutuhan),
          randomId,
              () => myAlarmFunctionMobil(randomId),
          exact: true,
          wakeup: true,
        );

        print('Alarm berhasil diset');
        Navigator.of(context).pop();
        // SetAlarmLaptop(Kebutuhan_Laptop.last);
      } catch (error) {
        print('Error saat mengatur alarm: $error');
        // Lakukan penanganan kesalahan jika parsing gagal
      }
    } else {
      print('Input Masa Kebutuhan tidak boleh kosong');
      // Tindakan jika input kosong
    }
  }

  void tambahKebutuhan(){
    showDialog(
        context: context,
        builder: (context){
          return DialogBox(
            controller: isiKebutuhan_Mobil,
            onAdd: SimpanKebutuhan_Mobil,
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Kebutuhan Mobil',
            JangkaKebutuhan: MasaKebutuhanController,
          );
        });
  }

  void myAlarmFunctionMobil(int id) {
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada Mobil yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id,
    );
  }

  void ApusKebutuhan(int index) {
    setState(() {
      Kebutuhan_Mobil.removeAt(index);
    });
  }

  int generateRandomId() {
    Random random = Random();
    return random.nextInt(400) + 1;
  }


  void SimpanMobil() async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    try{
      String lokasiGambarMobil = imgMobilController.text;
      String fotoMobil = '';
      List<Map<String, dynamic>> ListKebutuhan_Mobil = Kebutuhan_Mobil.map((kebutuhan) {
        var timeKebutuhan = contTimeService(kebutuhan.masaKebutuhanMobil);
        return {
          'Nama Kebutuhan Mobil': kebutuhan.namaKebutuhanMobil,
          'Masa Kebutuhan Mobil': kebutuhan.masaKebutuhanMobil,
          'Waktu Kebutuhan Mobil': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan Mobil': daysBetween(DateTime.now(), timeKebutuhan),
          'ID' : kebutuhan.randomID
        };
      }).toList();

      if (lokasiGambarMobil.isNotEmpty) {
        File imgMobil = File(lokasiGambarMobil);
        fotoMobil = await unggahGambarMobil(imgMobil);
      }

      await tambahMobil(
        merekMobilController.text.trim(),
        idMobilCOntroller.text.trim(),
        int.parse(tipemesinController.text.trim()),
        tipeBahanBakarController.text.trim(),
        pendinginController.text.trim(),
        transmisController.text.trim(),
        int.parse(kapasitasBBController.text.trim()),
        ukuranBanController.text.trim(),
        int.parse(akiController.text.trim()),
        ListKebutuhan_Mobil,
        fotoMobil,
        selectedKondisi,
        selectedPrioritas,
      );

      Navigator.pop(context);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data Mobil Berhasil Ditambahkan',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ManajemenMobil()),
          );
        },
      ).show();
      print('Data Mobil Berhasil Ditambahkan');

    } catch (e) {
      print("Error : $e");
    }
  }

  Future tambahMobil (String merek, String ID, int tipemesin,
      String tipeBB, String pendingin, String transmisi, int kapasitasBB, String ban, int Aki,List<Map<String, dynamic>> kebutuhan, String GambarMobil,
      String selectedKondisi,String selectedPrioritas) async{
    await FirebaseFirestore.instance.collection('Mobil').add({
      'Merek Mobil' : merek,
      'ID Mobil' : ID,
      'Tipe Mesin' : tipemesin,
      'Jenis Bahan Bakar' : tipeBB,
      'Sistem Pendingin Mesin' : pendingin,
      'Tipe Transmisi' : transmisi,
      'Kapasitas Bahan Bakar' : kapasitasBB,
      'Ukuran Ban' : ban,
      'Aki' : Aki,
      'Kebutuhan Mobil' : kebutuhan,
      'Gambar Mobil' : GambarMobil,
      'Jenis Aset' : 'Mobil',
      'Lokasi' : 'Parkiran',
      'Status' : selectedKondisi,
      'Prioritas' : selectedPrioritas,
      'Pesan' : 'Data Mobil Baru telah ditambahkan!',
      'Tanggal Dibuat' : FieldValue.serverTimestamp(),
    });
  }

  @override
  void initState(){
    super.initState();
    fetchNamaPengguna();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: Warna.green,
        title: const Text(
          'Tambah Data Mobil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Warna.white
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: 370,
            height: 650,
            decoration: BoxDecoration(
              color: Warna.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: _formState,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Merek Mobil',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: merekMobilController,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'ID Mobil',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: idMobilCOntroller,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Status',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSelectedItems: true,
                        fit: FlexFit.loose,
                      ),
                      items: Status,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            hintText: "...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)
                            )
                        ),
                      ),
                      onChanged: (selectedValue){
                        print(selectedValue);
                        setState(() {
                          selectedKondisi = selectedValue ?? "";
                        });
                      },
                    ),

                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Prioritas',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSelectedItems: true,
                        fit: FlexFit.loose,
                      ),
                      items: Prioritas,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            hintText: "...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)
                            )
                        ),
                      ),
                      onChanged: (selectedValue){
                        print(selectedValue);
                        setState(() {
                          selectedPrioritas = selectedValue ?? "";
                        });
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Kapasitas Mesin (cc)',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.number,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: tipemesinController,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Jenis Bahan Bakar',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: tipeBahanBakarController,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Sistem Pendingin',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: pendinginController,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Tipe Transmisi',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: transmisController,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Kapasitas Bahan Bakar (perliter)',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.number,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: kapasitasBBController,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Ukuran Ban',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: ukuranBanController,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Kapasitas Aki (Ah)',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.number,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: akiController,
                      validator: (value){
                        if (value==''){
                          return "Isi kosong, Harap Diisi!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Gambar Mobil',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    FieldImage(
                        controller: imgMobilController,
                        selectedImageName: imgMobilController.text.isNotEmpty
                            ? imgMobilController.text.split('/').last
                            : '',
                        onPressed: (){
                          pilihSumberGambar(true);
                        }),

                    const SizedBox(height: 25),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Kebutuhan_Mobil.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(Kebutuhan_Mobil[index].namaKebutuhanMobil),
                          subtitle: Text('${Kebutuhan_Mobil[index].masaKebutuhanMobil} Bulan'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              ApusKebutuhan(index);
                            },
                            color: Colors.red,
                          ),
                        );
                      },
                    ),

                    InkWell(
                      onTap: tambahKebutuhan,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Row(
                          children: [Icon(Icons.add),
                            SizedBox(width: 5),
                            Text('Tambah Kebutuhan...')],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: (){
                          if(_formState.currentState!.validate()){
                            SimpanMobil();
                            print("validate suxxes");

                          }else{

                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Warna.green,
                            minimumSize: const Size(300, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25))),
                        child: SizedBox(
                          width: 200,
                          child: Center(
                            child: Text(
                              'Save',
                              style: TextStyles.title
                                  .copyWith(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
