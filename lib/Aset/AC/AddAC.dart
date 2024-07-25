import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import '../../komponen/kotakDialog.dart';
import '../../komponen/style.dart';
import '../../textfield/imageField.dart';
import '../../textfield/textfields.dart';
import '../ControllerLogic.dart';
import 'DetailAC.dart';

class AddAC extends StatefulWidget {
  const AddAC({super.key});

  @override
  State<AddAC> createState() => _AddACState();
}

class KebutuhanModelAC {
  String namaKebutuhanAC;
  int masaKebutuhanAC;
  int randomID;

  KebutuhanModelAC(
      this.namaKebutuhanAC,
      this.masaKebutuhanAC,
      this.randomID
      );
}
enum ACStatus { aktif, rusak, hilang }
ACStatus selectedStatus = ACStatus.aktif;

enum ACPriority { High, Medium, Low }
ACStatus selectedPrioritas = ACStatus.aktif;

class _AddACState extends State<AddAC> {
  final _formState = GlobalKey<FormState>();
  String selectedRuangan = "";
  String selectedKondisi = "";
  String selectedPrioritas = "";
  final MerekACController = TextEditingController();
  final TeknisiController = TextEditingController();
  final idACController = TextEditingController();
  final wattController = TextEditingController();
  final PKController = TextEditingController();
  final MasaKebutuhanController = TextEditingController();
  final isiKebutuhanAC = TextEditingController();
  final ImagePicker _gambarACIndoor = ImagePicker();
  final ImagePicker _gambarACOutdoor = ImagePicker();
  final gambarAcIndoorController = TextEditingController();
  final gambarAcOutdoorController = TextEditingController();
  List Kebutuhan_AC = [];
  List<String> Ruangan = [
    "ADM FAKTURIS",
    "ADM INKASO",
    "ADM SALES",
    "ADM PRODUKSI",
    "LAB",
    "APJ",
    "DIGITAL MARKETING",
    "Ruangan EKSPOR",
    "KASIR",
    "HRD",
    "KEPALA GUDANG",
    "MANAGER MARKETING",
    "MANAGER PRODUKSI",
    "MANAGER QC-R&D",
    "MEETING",
    "STUDIO",
    "TELE SALES",
    "MANAGER EKSPORT"
  ];

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
  final pengguna = FirebaseAuth.instance.currentUser!;
  String namaPengguna = '';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Fungsi untuk mengubah ukuran gambar
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


  void PilihFotoBuktiIndoor() async {
    final pilihLaptop = await _gambarACIndoor.pickImage(source: ImageSource.camera);
    if (pilihLaptop != null) {
      File resizedImage = await resizeImage(File(pilihLaptop.path));
      setState(() {
        gambarAcIndoorController.text = resizedImage.path;
      });
    }
  }

  void PilihFotoBuktiOutdoor() async {
    final pilihLaptop = await _gambarACOutdoor.pickImage(source: ImageSource.camera);
    if (pilihLaptop != null) {
      File resizedImage = await resizeImage(File(pilihLaptop.path));
      setState(() {
        gambarAcOutdoorController.text = resizedImage.path;
      });
    }
  }

  void PilihIndoor() async {
    final pilihIndoor = await _gambarACIndoor.pickImage(source: ImageSource.gallery);
    if (pilihIndoor != null) {
      File resizedImage = await resizeImage(File(pilihIndoor.path));
      setState(() {
        gambarAcIndoorController.text = resizedImage.path;
      });
    }
  }

  void PilihOutdoor() async {
    final pilihOutdoor = await _gambarACOutdoor.pickImage(source: ImageSource.gallery);
    if (pilihOutdoor != null) {
      File resizedImage = await resizeImage(File(pilihOutdoor.path));
      setState(() {
        gambarAcOutdoorController.text = resizedImage.path;
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
                    Icon(Icons.photo_library, size: 50,
                    color: Warna.white),
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
                    Icon(Icons.camera_alt, size: 50,color: Warna.white),
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
        PilihIndoor();
      } else {
        PilihOutdoor();
      }
    } else if (pilihSumber == 1) {
      // Ambil foto
      if (isIndoor) {
        PilihFotoBuktiIndoor();
      } else {
        PilihFotoBuktiOutdoor();
      }
    }
  }


  Future<String> unggahACIndoor(File indoor) async {
    try {
      if (!indoor.existsSync()) {
        print('File tidak ditemukan.');
        return '';
      }

      indoor = await resizeImage(indoor); // Panggil fungsi resize

      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('AC')
          .child(gambarAcIndoorController.text);

      UploadTask uploadtask = penyimpanan.putFile(indoor);

      TaskSnapshot snapshot = await uploadtask;
      String url = await snapshot.ref.getDownloadURL();

      print('Download URL Indoor: $url');

      return url;
    } catch (e) {
      print('Terjadi kesalahan saat mengunggah gambar indoor: $e');
      return '';
    }
  }

  Future<String> unggahACOutdoor(File outdoor) async {
    try {
      if (!outdoor.existsSync()) {
        print('File tidak ditemukan.');
        return '';
      }

      outdoor = await resizeImage(outdoor); // Panggil fungsi resize

      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('AC')
          .child(gambarAcOutdoorController.text);

      UploadTask uploadtask = penyimpanan.putFile(outdoor);

      TaskSnapshot snapshot = await uploadtask;
      String url = await snapshot.ref.getDownloadURL();

      print('Download URL Outdoor: $url');

      return url;
    } catch (e) {
      print('Terjadi kesalahan saat mengunggah gambar outdoor: $e');
      return '';
    }
  }


  void AlarmFunctionAC(int id) {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada Aset PC yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id, // Menggunakan ID yang diberikan sebagai parameter
    );
  }

  void SimpanKebutuhan_AC() async {
    String masaKebutuhanText = MasaKebutuhanController.text.trim();
    int randomId = generateRandomId();
    print('Random ID: $randomId');
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan_AC.add(KebutuhanModelAC(
          isiKebutuhanAC.text,
          masaKebutuhan,
          randomId,
        ));

        isiKebutuhanAC.clear();
        MasaKebutuhanController.clear();

        setState(() {});
        await AndroidAlarmManager.oneShot(
          Duration(days: masaKebutuhan),
          randomId,
              () => AlarmFunctionAC(randomId),
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
            controller: isiKebutuhanAC,
            onAdd: SimpanKebutuhan_AC,
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Kebutuhan AC',
            JangkaKebutuhan: MasaKebutuhanController,
          );
        });
  }

  int generateRandomId() {
    Random random = Random();
    return random.nextInt(400) + 1;
  }


  void ApusKebutuhan(int index) {
    setState(() {
      Kebutuhan_AC.removeAt(index);
    });
  }

  void SimpanAC() async {
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

    try {
      String lokasiGambarIndoor = gambarAcIndoorController.text;
      String fotoIndoor = '';
      String lokasiGambarOutdoor = gambarAcOutdoorController.text;
      String fotoOutdoor = '';
      List<Map<String, dynamic>> ListKebutuhan_AC = Kebutuhan_AC.map((kebutuhan) {
        var timeKebutuhan = contTimeService(kebutuhan.masaKebutuhanAC);

        return {
          'Nama Kebutuhan AC': kebutuhan.namaKebutuhanAC,
          'Masa Kebutuhan AC': kebutuhan.masaKebutuhanAC,
          'Waktu Kebutuhan AC': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan AC': daysBetween(DateTime.now(), timeKebutuhan),
          'ID': kebutuhan.randomID
        };
      }).toList();

      if (lokasiGambarIndoor.isNotEmpty && lokasiGambarOutdoor.isNotEmpty ||
          lokasiGambarIndoor.isNotEmpty && lokasiGambarOutdoor.isEmpty) {
        File indoor = File(lokasiGambarIndoor);
        fotoIndoor = await unggahACIndoor(indoor);

        File outdoor = File(lokasiGambarOutdoor);
        fotoOutdoor = await unggahACOutdoor(outdoor);
      }

      await tambahAC(
        MerekACController.text.trim(),
        idACController.text.trim(),
        int.parse(wattController.text.trim()),
        int.parse(PKController.text.trim()),
        selectedRuangan,
        selectedKondisi,
        selectedPrioritas,
        ListKebutuhan_AC,
        fotoIndoor,
        fotoOutdoor,
        TeknisiController.text,
      );

      Navigator.pop(context);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data AC Berhasil Ditambahkan',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DetailAC()),
          );
        },
      ).show();
      print('Data AC Berhasil Ditambahkan');
    } catch (e) {
      // Tutup CircularProgressIndicator jika terjadi error
      Navigator.pop(context);
      print("Error: $e");
    }
  }


  Future tambahAC(String merek, String ID, int watt, int pk, String selectedRuangan,
      String selectedKondisi,String selectedPrioritas, List<Map<String, dynamic>> kebutuhan, String UrlIndoor, String UrlOutdoor,String Teknisi) async{
    await FirebaseFirestore.instance.collection('Aset').add({
      'Merek AC' : merek,
      'ID AC' : ID,
      'Kapasitas Watt' : watt,
      'Kapasitas PK' : pk,
      'Ruangan' : selectedRuangan,
      'Kebutuhan AC' : kebutuhan,
      'Foto AC Indoor' : UrlIndoor,
      'Foto AC Outdoor' : UrlOutdoor,
      'Jenis Aset' : 'AC',
      'Status' : selectedKondisi,
      'Prioritas' : selectedPrioritas,
      'Pesan' : 'Data AC Baru telah ditambahkan!',
      'Tanggal Dibuat' : FieldValue.serverTimestamp(),
      'Teknisi Yang Menambahkan' : Teknisi
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
          'Tambah Data AC',
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
                        'Merek AC',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: MerekACController,
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
                        'ID AC',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: idACController,
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
                        'Kapasitas Watt',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.number,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: wattController,
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
                        'kapasitas PK',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.number,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: PKController,
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
                        'Ruangan',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSelectedItems: true,
                      ),
                      items: Ruangan,
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
                          selectedRuangan = selectedValue ?? "";
                        });
                      },
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Gambar AC Indoor',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    FieldImage(
                      controller: gambarAcIndoorController,
                      selectedImageName: gambarAcIndoorController.text.isNotEmpty
                          ? gambarAcIndoorController.text.split('/').last
                          : '',
                      onPressed: () {
                        pilihSumberGambar(true); // false untuk Outdoor
                      },
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Gambar AC Outdoor',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    FieldImage(
                        controller: gambarAcOutdoorController,
                        selectedImageName: gambarAcIndoorController.text.isNotEmpty
                            ? gambarAcOutdoorController.text.split('/').last
                            : '',
                      onPressed: () {
                        pilihSumberGambar(false); // false untuk Outdoor
                      },
                    ),
                    const SizedBox(height: 25),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Kebutuhan_AC.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(Kebutuhan_AC[index].namaKebutuhanAC), // Accessing the property directly
                          subtitle: Text('${Kebutuhan_AC[index].masaKebutuhanAC} Bulan'), // Accessing the property directly
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
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          onPressed: (){
                            if(_formState.currentState!.validate()){
                              SimpanAC();
                              print("validate suxxes");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Warna.green,
                              minimumSize: const Size(300, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25))),
                          child: Container(
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
                    )
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
