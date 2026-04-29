import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';


class TambahCutiPage extends StatefulWidget {
  const TambahCutiPage({super.key});

  @override
  State<TambahCutiPage> createState() => _TambahCutiPageState();
}

class _TambahCutiPageState extends State<TambahCutiPage> {
  final _formKey = GlobalKey<FormState>();

  String? _jenisCuti;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  String? _alasan;
  String? _dokumen;
  int _lamaCuti = 0;

  bool isEdit = false;
  CutiModel? editData;
  Function()? _onCutiAdded;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final List<String> _jenisCutiList = [
    'Cuti Tahunan',
    'Cuti Melahirkan',
    'Cuti Nikah',
    'Cuti Khusus',
  ];

  @override
  void initState() {
    super.initState();
    _initEditMode();
  }

  /// =========================
  /// INIT EDIT MODE
  /// =========================
  void _initEditMode() {
    final args = Get.arguments;
    _onCutiAdded = args?['onCutiAdded'];

    if (args != null && args['editCuti'] != null) {
      editData = args['editCuti'];
      isEdit = true;

      _jenisCuti = editData!.jenisCuti;
      _tanggalMulai = DateTime.parse(editData!.tanggalMulai);
      _tanggalSelesai = DateTime.parse(editData!.tanggalSelesai);
      _alasan = editData!.alasan;
      _dokumen = editData!.dokumenUrl;

      _hitungLamaCuti();
    }
  }

  /// =========================
  /// HITUNG LAMA CUTI
  /// =========================
  void _hitungLamaCuti() {
    if (_tanggalMulai != null && _tanggalSelesai != null) {
      int totalHari = 0;
      DateTime current = _tanggalMulai!;

      while (!current.isAfter(_tanggalSelesai!)) {
        if (current.weekday != DateTime.saturday &&
            current.weekday != DateTime.sunday) {
          totalHari++;
        }
        current = current.add(const Duration(days: 1));
      }

      _lamaCuti = totalHari;
    }
  }

  /// =========================
  /// DATE PICKER
  /// =========================
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await DatePickerHelper.pickDate(context);

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _tanggalMulai = pickedDate;
        } else {
          _tanggalSelesai = pickedDate;
        }
        _hitungLamaCuti();
      });
    }
  }

  /// =========================
  /// SUBMIT (ADD / EDIT)
  /// =========================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await _dbHelper.getSingleUser();

    if (user == null) return;

    final cuti = CutiModel(
      id: editData?.id, // penting untuk edit
      jenisCuti: _jenisCuti!,
      tanggalMulai: _tanggalMulai!.toIso8601String().split('T').first,
      tanggalSelesai: _tanggalSelesai!.toIso8601String().split('T').first,
      alasan: _alasan ?? '',
      dokumenUrl: _dokumen ?? '',
    );

    if (isEdit) {
      /// 🔥 EDIT MODE
      context.read<CutiBloc>().add(
        UpdateCutiEvent(
          id: cuti.id!.toString(),
          userId: user.id!,
          kategori: PengajuanKategori.cuti.toString(),
          jenis_cuti: cuti.jenisCuti,
          tanggal_mulai: cuti.tanggalMulai,
          tanggal_selesai: cuti.tanggalSelesai,
          alasan: cuti.alasan,
          berkas: cuti.dokumenUrl,
          cutiModel: cuti,
        ),
      );
    } else {
      /// 🔥 ADD MODE
      context.read<CutiBloc>().add(
        AddCutiEvent(
          userId: user.id!,
          kategori: PengajuanKategori.cuti.toString(),
          jenis_cuti: cuti.jenisCuti,
          tanggal_mulai: cuti.tanggalMulai,
          tanggal_selesai: cuti.tanggalSelesai,
          alasan: cuti.alasan,
          berkas: cuti.dokumenUrl,
          cutiModel: cuti,
        ),
      );
    }
  }

  void _simpanCuti() async { // 1. Tambahkan 'async'
    if (_formKey.currentState!.validate()) {
      if (_tanggalMulai == null || _tanggalSelesai == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal mulai dan selesai')),
        );
        return;
      }

      try {
        // 2. Ambil user yang sedang login (sesuai cara kita sebelumnya)
        final User? currentUser = await _dbHelper.getSingleUser();
        if (currentUser == null || currentUser.id == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Gagal mendapatkan data user!')),
          );
          return;
        }

        // 3. Buat model Cuti (kode Anda sudah benar)
        final cutiBaru = CutiModel(
          jenisCuti: _jenisCuti!,
          tanggalMulai: _tanggalMulai!.toIso8601String().split('T').first,
          tanggalSelesai: _tanggalSelesai!.toIso8601String().split('T').first,
          alasan: _alasan ?? '',
          dokumenUrl: _dokumen ?? '',
        );

        // 4. PANGGIL FUNGSI INSERT DARI DATABASEHELPER
        //    Ini akan menyimpan data ke database SQLCipher
        final int cutiId = await _dbHelper.insertCuti(cutiBaru, currentUser.id!);
        print('Cuti baru berhasil disimpan ke DB dengan ID: $cutiId');
        // 5. PANGGIL CALLBACK (kode Anda sudah benar)
        //    Ini akan meng-update UI di halaman DaftarCutiPage
        _onCutiAdded?.call();
        Get.back();
      } catch (e) {
        // Tangani jika ada error saat simpan ke DB
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Cuti" : "Tambah Cuti"),
        backgroundColor: Colors.green,
      ),
      body: BlocConsumer<CutiBloc, CutiState>(
        listener: (context, state) async {

          if (state is CutiPageLoadingState) {
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if (state is CutiPageGlobalErorr) {
            final error = state.error;

            if (error is NoInternetError) {
              ErrorBottomSheet.show(
                context,
                message: "Tidak Ada Koneksi Internet",
              );
            } else if (error is TimeoutError) {
              ErrorBottomSheet.show(
                context,
                message: "Server Lambat",
              );
            } else if (error is ServerError) {
              ErrorBottomSheet.show(
                context,
                message: "Server error ${error.code}",
              );
            } else {
              ErrorBottomSheet.show(
                context,
                message: "${error.message}",
              );
            }
          }

          if(state is UpdateCutiSuccessState){
            _onCutiAdded?.call();
            LoadingDialog.hide(context);
            Get.back();
          }

          if (state is AddCutiSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEdit
                    ? "Cuti berhasil diupdate"
                    : "Cuti berhasil ditambahkan"),
              ),
            );

            /*
            final cutiBaru = CutiModel(
              jenisCuti: _jenisCuti!,
              tanggalMulai: _tanggalMulai!.toIso8601String().split('T').first,
              tanggalSelesai: _tanggalSelesai!.toIso8601String().split('T').first,
              alasan: _alasan ?? '',
              dokumenUrl: _dokumen ?? '',
            );

            final User? currentUser = await _dbHelper.getSingleUser();
            final int cutiId = await _dbHelper.insertCuti(cutiBaru, currentUser!.id!);
            print('Cuti baru berhasil disimpan ke DB dengan ID: $cutiId');
             */
            _onCutiAdded?.call();
            LoadingDialog.hide(context);
            Get.back();
          }

          if (state is CutiPageFailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );

            LoadingDialog.hide(context);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  /// JENIS CUTI
                  DropdownButtonFormField<String>(
                    value: _jenisCuti,
                    items: _jenisCutiList
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                        .toList(),
                    onChanged: (val) => setState(() => _jenisCuti = val),
                    decoration: const InputDecoration(
                      labelText: 'Jenis Cuti',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                    val == null ? "Wajib pilih jenis cuti" : null,
                  ),

                  const SizedBox(height: 16),

                  /// TANGGAL MULAI
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Mulai',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_tanggalMulai == null
                          ? 'Pilih tanggal'
                          : DateFormat('yyyy-MM-dd')
                          .format(_tanggalMulai!)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TANGGAL SELESAI
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Selesai',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_tanggalSelesai == null
                          ? 'Pilih tanggal'
                          : DateFormat('yyyy-MM-dd')
                          .format(_tanggalSelesai!)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// LAMA CUTI
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Lama Cuti',
                      border: OutlineInputBorder(),
                    ),
                    controller:
                    TextEditingController(text: _lamaCuti.toString()),
                  ),

                  const SizedBox(height: 16),

                  /// ALASAN
                  TextFormField(
                    initialValue: _alasan,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Alasan',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => _alasan = val,
                  ),

                  const SizedBox(height: 16),

                  // Dokumen Upload (simulasi)
                  ElevatedButton.icon(
                    onPressed: () async {
                      _dokumen = await CameraHelper.pickFromCamera();
                    },
                    icon: const Icon(Icons.upload_file),
                    label: Text(_dokumen == null ? 'Upload Dokumen' : 'File: Memilih Gambar Dari Camera'),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isEdit ? Colors.orange : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isEdit ? "Update Cuti" : "Simpan Cuti",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}