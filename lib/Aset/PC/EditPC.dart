import 'dart:io';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:aplikasi_revamp/Aset/PC/ManajemenPC.dart';
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
import '../../textfield/imageField.dart';
import '../../textfield/textfields.dart';
import '../ControllerLogic.dart';
import 'package:image/image.dart' as img;

class EditPC extends StatefulWidget {
  const EditPC({super.key,
    required this.dokumenPC});
  final String dokumenPC;

  @override
  State<EditPC> createState() => _EditPCState();
}

class KebutuhanModelUpdate {
  String namaKebutuhan;
  int masaKebutuhan;
  int randomID;

  KebutuhanModelUpdate(
      this.namaKebutuhan,
      this.masaKebutuhan,
      this.randomID);

  Map<String, dynamic> toMap() {
    return {
      'Kebutuhan PC': namaKebutuhan,
      'Masa Kebutuhan': masaKebutuhan,
      'ID' : randomID
    };
  }
}
enum PCStatus { aktif, rusak, hilang }
PCStatus selectedStatus = PCStatus.aktif;

class _EditPCState extends State<EditPC> {
  String selectedRuangan = "";
  String selectedKondisi = "";
  String selectedPrioritas = "";
  final TeknisiController = TextEditingController();
  final merekPCController = TextEditingController();
  final IdPCController = TextEditingController();
  final CPUController = TextEditingController();
  final RamController = TextEditingController();
  final VGAController = TextEditingController();
  final ImgPCController = TextEditingController();
  final StorageController = TextEditingController();
  final isiKebutuhan = TextEditingController();
  final PSUController = TextEditingController();
  final _formState = GlobalKey<FormState>();
  final MasaKebutuhanController = TextEditingController();
  String oldphotoPC = '';
  Map <String, dynamic> dataPC = {};
  final ImagePicker _gambarPC = ImagePicker();
  List Kebutuhan = [];
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
    "Hilang"
  ];

  List<String> Prioritas = [
    "High",
    "Medium",
    "Low",
  ];

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

  void PilihGambarPC() async{
    final pilihPC = await _gambarPC.pickImage(source: ImageSource.gallery);
    if(pilihPC != null) {
      File resizedImage = await resizeImage(File(pilihPC.path));
      setState(() {
        ImgPCController.text = resizedImage.path;
      });
    }
  }

  void PilihFotoPC() async {
    final pilihPC =
    await _gambarPC.pickImage(source: ImageSource.camera);
    if (pilihPC != null) {
      File resizedImage = await resizeImage(File(pilihPC.path));
      setState(() {
        ImgPCController.text = resizedImage.path;
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
                    Icon(Icons.photo_library, size: 50),
                    SizedBox(height: 5),
                    Text('Galeri', style: TextStyle(fontSize: 18)),
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
                    Icon(Icons.camera_alt, size: 50),
                    SizedBox(height: 5),
                    Text('Kamera', style: TextStyle(fontSize: 18)),
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
        PilihGambarPC();
      }
    } else if (pilihSumber == 1) {
      // Ambil foto
      if (isIndoor) {
        PilihFotoPC();
      }
    }
  }

  int generateRandomId() {
    Random random = Random();
    return random.nextInt(400) + 1;
  }

  void SimpanKebutuhan_PC() async {
    String masaKebutuhanText = MasaKebutuhanController.text.trim();
    int randomId = generateRandomId();
    print('Random ID: $randomId');
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan.add({
          'Kebutuhan PC': isiKebutuhan.text,
          'Masa Kebutuhan': masaKebutuhan,
          'ID' : randomId,
        });

        isiKebutuhan.clear();
        MasaKebutuhanController.clear();

        setState(() {});
        await AndroidAlarmManager.oneShot(
          Duration(days: masaKebutuhan),
          randomId,
              () => myAlarmFunctionMotor(randomId),
          exact: true,
          wakeup: true,
        );

        print('Alarm berhasil diset');
        Navigator.of(context).pop();
      } catch (error) {
        print('Error saat mengatur alarm: $error');
      }
    } else {
      print('Input Masa Kebutuhan tidak boleh kosong');
      // Tindakan jika input kosong
    }
  }

  void myAlarmFunctionMotor(int id) {
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada PC yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id,
    );
  }


  void tambahKebutuhan(){
    showDialog(
        context: context,
        builder: (context){
          return DialogBox(
            controller: isiKebutuhan,
            onAdd: SimpanKebutuhan_PC,
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Kebutuhan PC',
            JangkaKebutuhan: MasaKebutuhanController,
          );
        });
  }

  void ApusKebutuhan(int index) {
    setState(() {
      Kebutuhan.removeAt(index);
    });
  }

  void myAlarmFunction() {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    print('Alarm terpicu untuk kebutuhan PC!');
  }

  Future<String> unggahGambarPC(File gambarPC) async {
    try{
      if(!gambarPC.existsSync()){
        print('File tidak ditemukan!');
        return '';
      }
      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('Personal Conputer')
          .child(ImgPCController.text.split('/').last);

      UploadTask uploadPC = penyimpanan.putFile(gambarPC);
      await uploadPC;
      String fotoPC = await penyimpanan.getDownloadURL();
      return fotoPC;
    }catch (e){
      print('$e');
      return '';
    }
  }

  Future<void> UpdatePC(String dokPC, Map<String, dynamic> DataPC) async {
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
      String GambarPC;
      List<Map<String, dynamic>> listKebutuhan = Kebutuhan.map((kebutuhan) {
        var timeKebutuhan = contTimeService(int.parse(kebutuhan['Masa Kebutuhan'].toString()));
        return {
          'Kebutuhan PC': kebutuhan['Kebutuhan PC'],
          'Masa Kebutuhan': kebutuhan['Masa Kebutuhan'],
          'Waktu Kebutuhan PC': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan PC': daysBetween(DateTime.now(), timeKebutuhan),
          'ID' : kebutuhan['ID'],
        };
      }).toList();

      if (ImgPCController.text.isNotEmpty) {
        File gambarPCBaru = File(ImgPCController.text);
        GambarPC = await unggahGambarPC(gambarPCBaru);
      } else {
        GambarPC = oldphotoPC;
      }

      // Menjalankan proses update untuk setiap item kebutuhan
      for (var item in listKebutuhan) {
        var waktuKebutuhan = contTimeService(int.parse(item['Masa Kebutuhan'].toString()));
        Map<String, dynamic> DataPCBaru = {
          'Merek PC': merekPCController.text,
          'ID PC': IdPCController.text,
          'Ruangan' : selectedRuangan,
          'CPU': CPUController.text,
          'RAM': RamController.text,
          'Kapasitas Penyimpanan': StorageController.text,
          'VGA': VGAController.text,
          'Kapasitas Power Supply': PSUController.text,
          'kebutuhan': listKebutuhan,
          'Gambar PC': GambarPC,
          'Jenis Aset' : 'PC',
          'Waktu Kebutuhan PC': waktuKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan PC': daysBetween(DateTime.now(), waktuKebutuhan),
          'Status' : selectedKondisi,
          'Prioritas' : selectedPrioritas,
          'Teknisi Yang Menambahkan' : TeknisiController.text
        };

        // Update dokumen Firestore sesuai dengan dokPC
        await FirebaseFirestore.instance.collection('PC').doc(dokPC).update(DataPCBaru);
      }

      Navigator.pop(context);

      // Menampilkan dialog sukses setelah update berhasil
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data PC Berhasil Diupdate',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ManajemenPC()),
          );
        },
        autoHide: Duration(seconds: 5),
      ).show();

      print('Data PC Berhasil Diupdate');
    } catch (e) {
      print(e);
    }
  }

  final pengguna = FirebaseAuth.instance.currentUser!;
  String namaPengguna = '';

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

  void initState(){
    super.initState();
    getData();
    fetchNamaPengguna();
  }

  Future<void> getData() async{
    try{
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('PC').doc(widget.dokumenPC).get();
      final data = snapshot.data();

      setState(() {
        merekPCController.text = data?['Merek PC'] ?? '';
        IdPCController.text = data?['ID PC'] ?? '';
        selectedRuangan = data?['Ruangan'] ?? '';
        selectedKondisi = data?['Status'] ?? '';
        selectedPrioritas = data?['Prioritas'] ?? '';
        CPUController.text = data?['CPU'] ?? '';
        RamController.text = (data?['RAM'] ?? '').toString();
        StorageController.text = (data?['Kapasitas Penyimpanan'] ?? '').toString();
        VGAController.text = data?['VGA'] ?? '';
        PSUController.text = (data?['Kapasitas Power Supply'] ?? '').toString();
        final UrlPC = data?['Gambar PC'] ?? '';
        oldphotoPC = UrlPC;
        Kebutuhan = List<Map<String, dynamic>>.from(data?['kebutuhan'] ?? []);
      });
    }catch(e){
      print('Terjadi kesalahan: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: Warna.green,
        title: const Text(
          'Edit Data PC',
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
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: 370,
            height: 690,
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
                        'Merek PC',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: merekPCController,
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
                        'ID PC',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: IdPCController,
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
                            hintText: "Pilih Ruangan...",
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
                        'CPU',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: CPUController,
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
                        'RAM (GB)',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.number,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: RamController,
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
                        'Storage (GB)',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.number,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: StorageController,
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
                        'VGA',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: VGAController,
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
                        'Kapasitas PSU (watt)',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.number,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: PSUController,
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
                        'Gambar PC',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    FieldImage(
                        controller: ImgPCController,
                        selectedImageName: ImgPCController.text.isNotEmpty
                            ? ImgPCController.text.split('/').last
                            : '',
                        onPressed: (){
                          pilihSumberGambar(true);
                        }),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'Kebutuhan',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Kebutuhan.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(Kebutuhan[index]['Kebutuhan PC']),
                          subtitle: Text('${Kebutuhan[index]['Masa Kebutuhan']} Bulan'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              ApusKebutuhan(index); // Fungsi untuk menghapus kebutuhan
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
                            UpdatePC(widget.dokumenPC, dataPC);
                            print("validate suxxes");

                          }else{

                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Warna.green,
                            minimumSize: const Size(300, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25))
                        ),
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
