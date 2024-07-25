import 'dart:io';
import 'dart:math';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../komponen/kotakDialog.dart';
import '../../komponen/style.dart';
import '../../main.dart';
import '../../textfield/imageField.dart';
import '../../textfield/textfields.dart';
import '../ControllerLogic.dart';
import 'manajemenLaptop.dart';

class AddLaptop extends StatefulWidget {
  const AddLaptop({super.key});

  @override
  State<AddLaptop> createState() => _AddLaptopState();
}

class KebutuhanModelLaptop {
  String namaKebutuhanLaptop;
  int masaKebutuhanLaptop;
  int randomID;

  KebutuhanModelLaptop(
      this.namaKebutuhanLaptop,
      this.masaKebutuhanLaptop,
      this.randomID
      );
}
enum LaptopStatus { aktif, rusak, hilang }
LaptopStatus selectedStatus = LaptopStatus.aktif;

class _AddLaptopState extends State<AddLaptop> {
  String selectedRuangan = "";
  String selectedKondisi = "";
  String selectedPrioritas = "";
  final TeknisiController = TextEditingController();
  final merekLaptopController = TextEditingController();
  final IdLaptopController = TextEditingController();
  final CPUController = TextEditingController();
  final RamController = TextEditingController();
  final VGAController = TextEditingController();
  final ImglaptopController = TextEditingController();
  final StorageController = TextEditingController();
  final isiKebutuhan_Laptop = TextEditingController();
  final MonitorController = TextEditingController();
  final _formState = GlobalKey<FormState>();
  final MasaKebutuhanController = TextEditingController();
  final ImagePicker _gambarLaptop = ImagePicker();
  List Kebutuhan_Laptop = [
  ];
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
                    Icon(Icons.photo_library, size: 50, color: Warna.white,),
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
                    Icon(Icons.camera_alt, size: 50, color: Warna.white,),
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

  void PilihGambarLaptop() async {
    final pilihLaptop =
        await _gambarLaptop.pickImage(source: ImageSource.gallery);
    if (pilihLaptop != null) {
      File resizedImage = await resizeImage(File(pilihLaptop.path));
      setState(() {
        ImglaptopController.text = resizedImage.path;
      });
    }
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

  Future<String> unggahGambarLaptop(File gambarLaptop) async {
    try {
      if (!gambarLaptop.existsSync()) {
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
    } catch (e) {
      print('$e');
      return '';
    }
  }

  void myAlarmFunctionLaptop() {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    print('Alarm terpicu untuk kebutuhan Laptop!');
  }

  void SimpanKebutuhan_Laptop() async {
    String masaKebutuhanText = MasaKebutuhanController.text.trim();
    int randomId = generateRandomId();
    print('Random ID: $randomId');
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan_Laptop.add(KebutuhanModelLaptop(
          isiKebutuhan_Laptop.text,
          masaKebutuhan,
          randomId
        ));

        isiKebutuhan_Laptop.clear();
        MasaKebutuhanController.clear();

        setState(() {});
        await AndroidAlarmManager.oneShot(
          Duration(days: masaKebutuhan),
          randomId,
              () => AlarmFunctionLaptop(randomId),
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

  void AlarmFunctionLaptop(int id) {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada Aset Laptop yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id, // Menggunakan ID yang diberikan sebagai parameter
    );
  }

  void ApusKebutuhan(int index) {
    setState(() {
      Kebutuhan_Laptop.removeAt(index);
    });
  }

  void SimpanLaptop() async{
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
      String lokasiGambarPC = ImglaptopController.text;
      String fotoLaptop = '';
      // String status = getStatusLaptop(selectedStatus);
      List<Map<String, dynamic>> ListKebutuhan_Laptop = Kebutuhan_Laptop.map((kebutuhan) {
        var timeKebutuhan = contTimeService(kebutuhan.masaKebutuhanLaptop);
        return {
          'Nama Kebutuhan Laptop': kebutuhan.namaKebutuhanLaptop,
          'Masa Kebutuhan Laptop': kebutuhan.masaKebutuhanLaptop,
          'Waktu Kebutuhan Laptop': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan Laptop': daysBetween(DateTime.now(), timeKebutuhan),
          'ID' : kebutuhan.randomID
        };
      }).toList();


      if (lokasiGambarPC.isNotEmpty) {
        File imgLaptop = File(lokasiGambarPC);
        fotoLaptop = await unggahGambarLaptop(imgLaptop);
      }

      await tambahLaptop(
        merekLaptopController.text.trim(),
        IdLaptopController.text.trim(),
        selectedRuangan,
        selectedKondisi,
        selectedPrioritas,
        CPUController.text.trim(),
        int.parse(RamController.text.trim()),
        int.parse(StorageController.text.trim()),
        VGAController.text.trim(),
        MonitorController.text.trim(),
        ListKebutuhan_Laptop,
        fotoLaptop,
        TeknisiController.text,
      );

      Navigator.pop(context);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data Laptop Berhasil Ditambahkan',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ManajemenLaptop()),
          );
        },
      ).show();
      print('Data Laptop Berhasil Ditambahkan');
      // myAlarmFunctionLaptop();

    } catch (e) {
      print("Error : $e");
    }
  }

  Future tambahLaptop (String merek, String ID, String selectedRuangan,selectedKondisi,String selectedPrioritas,
      String CPU, int ram, int storage, String vga, String monitor,List<Map<String, dynamic>> kebutuhan, String gambarLaptop, String Teknisi
      ) async{
    await FirebaseFirestore.instance.collection('Laptop').add({
      'Merek Laptop' : merek,
      'ID Laptop' : ID,
      'Ruangan' : selectedRuangan,
      'CPU' : CPU,
      'RAM' : ram,
      'Kapasitas Penyimpanan' : storage,
      'VGA' : vga,
      'Ukuran Monitor' : monitor,
      'Kebutuhan Laptop' : kebutuhan,
      'Gambar Laptop' : gambarLaptop,
      'Jenis Aset' : 'Laptop',
      'Status' : selectedKondisi,
      'Prioritas' : selectedPrioritas,
      'Pesan' : 'Data Laptop Baru telah ditambahkan!',
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
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Tambah Data Laptop',
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
                        style: TextStyles.title.copyWith(fontSize: 15, color: Warna.darkgrey),
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
                        textInputType: TextInputType.number,
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

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Kebutuhan_Laptop.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(Kebutuhan_Laptop[index].namaKebutuhanLaptop),
                          subtitle: Text('${Kebutuhan_Laptop[index].masaKebutuhanLaptop} Bulan'),
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
                            SimpanLaptop();
                            print("validate succes");

                          }else{
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
