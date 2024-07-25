import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Aset/ControllerLogic.dart';
import '../dashboard/Dashboards.dart';
import '../komponen/kotakBiaya.dart';
import '../komponen/kotakDialogCatatan.dart';
import '../komponen/style.dart';
import '../textfield/PhotoField.dart';
import '../textfield/textfields.dart';


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
  final TeknisiController = TextEditingController();
  final CatatanLengkapController = TextEditingController();
  final hargaIsiBiaya = TextEditingController(text: '');
  late String idAset;
  late String merekAset;
  List<String> DokJenis = [];
  final ImgFotoController = TextEditingController();
  late String jenisAset;
  late String lokasi;
  final ImagePicker _FotoBukti = ImagePicker();
  String selectedKebutuhan = "";
  List<Map<String, dynamic>> List_Kebutuhan = [];
  List biayaKebutuhans = [];
  late List<String> DokAC = [];

  final pengguna = FirebaseAuth.instance.currentUser!;
  String namaPengguna = '';


  Future<void> getAC() async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Aset');

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
      DokAC = snapshot.docs.map((doc) => doc.id).toList();
    });
  }


  void SimpanTask(BuildContext context) {
    setState(() {
      List_Kebutuhan.add({
        'Nama Kebutuhan': isiDialog.text,
        'Data Tambahan': {}, // Tambahkan map kosong jika diperlukan
      });
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

  void cekJenisAset(String jenisAset) {
    print('Jenis aset yang terpilih adalah: $jenisAset');
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
        fotoBukti,
        TeknisiController.text,
      );

      // Determine the asset type and call the appropriate update method
      switch (jenisAset) {
        case 'AC':
          await UpdateNyawaAC(idAset, List_Kebutuhan);
          break;
        default:
          print('Jenis aset tidak dikenal');
          break;
      }

      // Reset selected kebutuhan
      setState(() {
        selectedKebutuhan = '';
      });

      Navigator.pop(context);

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
            MaterialPageRoute(builder: (context) => Dashboards()),
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
              MaterialPageRoute(builder: (context) => Dashboards()),
            );
          },
          child: const Text('Menu',
            style: TextStyle(color: Warna.white)
          ),
        ),
      ).show();

      print('Data Catatan Berhasil Disimpan!');
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog if an error occurs
      print("Error: $e");
    }
  }


  Future<void> UpdateNyawaAC(String dokAC, List<Map<String, dynamic>> kebutuhanList) async {
    try {
      List<Map<String, dynamic>> ListKebutuhan_AC = kebutuhanList.map((kebutuhan) {
        var timeKebutuhan = contTimeService(int.parse(kebutuhan['Masa Kebutuhan AC'].toString()));
        return {
          'Nama Kebutuhan AC': kebutuhan['Nama Kebutuhan AC'],
          'Masa Kebutuhan AC': kebutuhan['Masa Kebutuhan AC'],
          'Waktu Kebutuhan AC': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan AC': daysBetween(DateTime.now(), timeKebutuhan),
          'ID': kebutuhan['ID'],
        };
      }).toList();

      for (var item in ListKebutuhan_AC) {
        var waktuKebutuhanAC = contTimeService(int.parse(item['Masa Kebutuhan AC'].toString()));
        Map<String, dynamic> DataACBaru = {
          'Waktu Kebutuhan AC': waktuKebutuhanAC.millisecondsSinceEpoch,
          'Hari Kebutuhan AC': daysBetween(DateTime.now(), waktuKebutuhanAC),
        };
        await FirebaseFirestore.instance.collection('Aset').doc(dokAC).update(DataACBaru);
        print('update berjalan dengan semestinya');
      }
    } catch (e) {
      print(e);
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
      String GambarBukti,
      String Teknisi) async{
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
      'Foto Bukti' : GambarBukti,
      'Teknisi Yang Mengerjakan' : Teknisi
    });
  }


  @override
  void initState() {
    super.initState();
    idAset = '${widget.ID_Aset}';
    merekAset = '${widget.Nama_Aset}';
    jenisAset = '${widget.Jenis_Aset}';
    lokasi = '${widget.lokasiAset}';
    List_Kebutuhan = List<Map<String, dynamic>>.from(widget.List_Kebutuhan.map((item) => {
      'Nama Kebutuhan AC': item['Nama Kebutuhan AC'],
      'Waktu Kebutuhan AC': item['Waktu Kebutuhan AC'],
      'Masa Kebutuhan AC' : item['Masa Kebutuhan AC'],
      'Hari Kebutuhan AC' : item['Hari Kebutuhan AC'],
      'ID' : item['ID']
    }));
    fetchNamaPengguna();
    cekJenisAset(jenisAset);

    print('Isi List_Kebutuhan:');
    for (var item in List_Kebutuhan) {
      print(item);
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
            color: Warna.white
          ),
        ),
        elevation: 0,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
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
                                const SizedBox(height: 5.0),
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
                    ),
                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Teknisi yang Bekerja',
                          style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        width: 350,
                        height: 49,
                        decoration: BoxDecoration(
                          color: Warna.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: MyTextField(
                          textInputType: TextInputType.text,
                          hint: '',
                          textInputAction: TextInputAction.next,
                          readOnly: true,
                          controller: TeknisiController,
                          validator: (value){
                            if (value==''){
                              return "Isi kosong, Harap Diisi!";
                            }
                            return null;
                          },
                        ),
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
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
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
                                fit: FlexFit.loose,
                              ),
                              items: List_Kebutuhan.map((item) => item['Nama Kebutuhan AC'].toString()).toList(),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                  hintText: "Pilih...",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                              onChanged: (selectedValue) {
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
                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
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
                            const SizedBox(height: 15),
                          ],
                        ),
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
                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
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
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '',
                            ),
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
                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
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
                    ),
                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
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
