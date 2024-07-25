import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:aplikasi_revamp/Aset/Laptop/manajemenLaptop.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../komponen/kotakDialog.dart';
import '../../komponen/style.dart';
import '../../main.dart';
import '../../textfield/imageField.dart';
import '../../textfield/textfields.dart';
import '../ControllerLogic.dart';

class editLaptop extends StatefulWidget {
  const editLaptop({super.key,
    required this.dokumenLaptop});
  final String dokumenLaptop;

  @override
  State<editLaptop> createState() => _editLaptopState();
}

class KebutuhanModelUpdateLaptop {
  String namaKebutuhanLaptop;
  int masaKebutuhanLaptop;
  int randomID;

  KebutuhanModelUpdateLaptop(
      this.namaKebutuhanLaptop,
      this.masaKebutuhanLaptop,
      this.randomID);

  Map<String, dynamic> toMap() {
    return {
      'Nama Kebutuhan Laptop': namaKebutuhanLaptop,
      'Masa Kebutuhan Laptop': masaKebutuhanLaptop,
      'ID' : randomID
    };
  }
}

class _editLaptopState extends State<editLaptop> {
  String selectedRuangan = "";
  String selectedKondisi = "";
  String selectedPrioritas = "";
  final _formState = GlobalKey<FormState>();
  final TeknisiController = TextEditingController();
  final merekLaptopController = TextEditingController();
  final IdLaptopController = TextEditingController();
  final CPUController = TextEditingController();
  final RamController = TextEditingController();
  final VGAController = TextEditingController();
  final ImglaptopController = TextEditingController();
  final StorageController = TextEditingController();
  final MonitorController = TextEditingController();
  final MasaKebutuhanController = TextEditingController();
  final isiKebutuhan_Laptop = TextEditingController();
  final ImagePicker _gambarLaptop = ImagePicker();
  String oldphotoLaptop = '';
  List Kebutuhan_Laptop = [];
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

  Map <String, dynamic> dataLaptop = {};

  void SimpanKebutuhan_Laptop() async {
    String masaKebutuhanText = MasaKebutuhanController.text.trim();
    int randomId = generateRandomId();
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan_Laptop.add({
          'Nama Kebutuhan Laptop': isiKebutuhan_Laptop.text,
          'Masa Kebutuhan Laptop': masaKebutuhan,
          'ID' : randomId,
        });

        isiKebutuhan_Laptop.clear();
        MasaKebutuhanController.clear();

        setState(() {});
        await AndroidAlarmManager.oneShot(
          Duration(days: masaKebutuhan),
          randomId,
              () => myAlarmFunctionLaptop(randomId),
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
        PilihGambarLaptop();
      }
    } else if (pilihSumber == 1) {
      // Ambil foto
      if (isIndoor) {
        PilihFotoLaptop();
      }
    }
  }

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

  void PilihFotoLaptop() async {
    final pilihLaptop =
    await _gambarLaptop.pickImage(source: ImageSource.camera);
    if (pilihLaptop != null) {
      File resizedImage = await resizeImage(File(pilihLaptop.path));
      setState(() {
        ImglaptopController.text = resizedImage.path;
      });
    }
  }

  void myAlarmFunctionLaptop(int id) {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada Aset Laptop yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id,
    );
  }

  int generateRandomId() {
    Random random = Random();
    return random.nextInt(400) + 1;
  }

  void tambahKebutuhan_Laptop(){
    showDialog(
        context: context,
        builder: (context){
          return DialogBox(
            controller: isiKebutuhan_Laptop,
            onAdd: SimpanKebutuhan_Laptop,
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Kebutuhan Laptop',
            JangkaKebutuhan: MasaKebutuhanController,
          );
        });
  }

  void ApusKebutuhan_laptop(int index) {
    setState(() {
      Kebutuhan_Laptop.removeAt(index);
    });
  }

  void PilihGambarLaptop() async{
    final pilihLaptop = await _gambarLaptop.pickImage(source: ImageSource.gallery);
    if(pilihLaptop != null) {
      File resizedImage = await resizeImage(File(pilihLaptop.path));
      setState(() {
        ImglaptopController.text = resizedImage.path;
      });
    }
  }

  Future<String> unggahGambarLaptop(File gambarLaptop) async {
    try{
      if(!gambarLaptop.existsSync()){
        print('File tidak ditemukan!');
        return '';
      }
      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('Laptop')
          .child(ImglaptopController.text.split('/').last);

      UploadTask uploadLaptop = penyimpanan.putFile(gambarLaptop);
      await uploadLaptop;
      String fotoLaptop = await penyimpanan.getDownloadURL();
      return fotoLaptop;
    }catch (e){
      print('$e');
      return '';
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

  Future<void> UpdateLaptop(String dokLaptop, Map<String, dynamic> DataLaptop) async{
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
      String GambarLaptop;
      List<Map<String, dynamic>> ListKebutuhan_Laptop = Kebutuhan_Laptop.map((kebutuhan) {
        var timeKebutuhan = contTimeService(int.parse(kebutuhan['Masa Kebutuhan Laptop'].toString()));
        return {
          'Nama Kebutuhan Laptop': kebutuhan['Nama Kebutuhan Laptop'],
          'Masa Kebutuhan Laptop': kebutuhan['Masa Kebutuhan Laptop'],
          'Waktu Kebutuhan Laptop': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan Laptop': daysBetween(DateTime.now(), timeKebutuhan),
          'ID' : kebutuhan['ID'],
        };
      }).toList();

      if(ImglaptopController.text.isNotEmpty){
        File gambarLaptopBaru = File(ImglaptopController.text);
        GambarLaptop = await unggahGambarLaptop(gambarLaptopBaru);
      }else{
        GambarLaptop = oldphotoLaptop;
      }

      for(var item in ListKebutuhan_Laptop){
        var waktuKebutuhanLaptop = contTimeService(int.parse(item['Masa Kebutuhan Laptop'].toString()));
        Map<String, dynamic> DataLaptopBaru = {
          'Merek Laptop' : merekLaptopController.text,
          'ID Laptop' : IdLaptopController.text,
          'Ruangan' : selectedRuangan,
          'CPU' : CPUController.text,
          'RAM' : RamController.text,
          'Kapasitas Penyimpanan' : StorageController.text,
          'VGA' : VGAController.text,
          'Ukuran Monitor' : MonitorController.text,
          'Kebutuhan Laptop' : ListKebutuhan_Laptop,
          'Gambar Laptop' : GambarLaptop,
          'Jenis Aset' : 'Laptop',
          'Waktu Service Laptop': waktuKebutuhanLaptop.millisecondsSinceEpoch,
          'Hari Service Laptop': daysBetween(DateTime.now(), waktuKebutuhanLaptop),
          'Status' : selectedKondisi,
          'Prioritas' : selectedPrioritas,
          'Pesan' : 'Data Laptop Baru telah ditambahkan!',
        };
        await FirebaseFirestore.instance.collection('Laptop').doc(dokLaptop).update(DataLaptopBaru);
      }

      Navigator.pop(context);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data Laptop Berhasil Diupdate',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const ManajemenLaptop()),
          );
        },
      ).show();
      print('Data Laptop Berhasil Diupdate');

    }catch (e){
      print(e);
    }
  }

  void initState(){
    super.initState();
    getLaptop();
    fetchNamaPengguna();
  }

  Future<void> getLaptop() async{
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('Laptop').doc(widget.dokumenLaptop).get();
    final data = snapshot.data();

    setState(() {
      merekLaptopController.text = data?['Merek Laptop'] ?? '';
      IdLaptopController.text = data?['ID Laptop'] ?? '';
      selectedRuangan = data?['Ruangan'] ?? '';
      selectedKondisi = data?['Status'] ?? '';
      selectedPrioritas = data?['Prioritas'] ?? '';
      CPUController.text = data?['CPU'] ?? '';
      RamController.text = (data?['RAM'] ?? '').toString();
      StorageController.text = (data?['Kapasitas Penyimpanan'] ?? '').toString();
      VGAController.text = data?['VGA'] ?? '';
      MonitorController.text = data?['Ukuran Monitor'] ?? '';
      final Urllaptop = data?['Gambar Laptop'] ?? '';
      oldphotoLaptop = Urllaptop;
      Kebutuhan_Laptop = List<Map<String, dynamic>>.from(data?['Kebutuhan Laptop'] ?? []);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: Warna.green,
        title: const Text(
          'Edit Data Laptop',
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
                        'Merek Laptop',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: merekLaptopController,
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
                        'ID Laptop',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: IdLaptopController,
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
                        'Ukuran Layar (inch)',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    MyTextField(
                        textInputType: TextInputType.text,
                        hint: '',
                        textInputAction: TextInputAction.next,
                        controller: MonitorController,
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
                        'Gambar Laptop',
                        style: TextStyles.title
                            .copyWith(fontSize: 15, color: Warna.darkgrey),
                      ),
                    ),
                    const SizedBox(height: 5),

                    FieldImage(
                        controller: ImglaptopController,
                        selectedImageName: ImglaptopController.text.isNotEmpty
                            ? ImglaptopController.text.split('/').last
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
                      itemCount: Kebutuhan_Laptop.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(Kebutuhan_Laptop[index]['Nama Kebutuhan Laptop']),
                          subtitle: Text('${Kebutuhan_Laptop[index]['Masa Kebutuhan Laptop']} Bulan'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              ApusKebutuhan_laptop(index);
                            },
                            color: Colors.red,
                          ),
                        );
                      },
                    ),



                    InkWell(
                      onTap: tambahKebutuhan_Laptop,
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
                            UpdateLaptop(widget.dokumenLaptop, dataLaptop);
                            print("validate success");

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
