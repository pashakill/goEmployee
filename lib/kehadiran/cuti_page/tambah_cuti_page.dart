import 'dart:convert';

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
  bool _isProcessingDocument = false;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _lamaCutiController =
  TextEditingController(text: '0');

  final List<String> _jenisCutiList = [
    'Cuti Tahunan',
    'Cuti Melahirkan',
    'Cuti Nikah',
    'Cuti Khusus',
  ];

  Future<void> _ambilDokumenDariKamera() async {
    if (_isProcessingDocument) return;

    setState(() {
      _isProcessingDocument = true;
    });

    try {
      final String? base64Image =
      await CameraHelper.pickFromCamera(quality: 70);

      if (!mounted) return;

      if (base64Image == null || base64Image.isEmpty) {
        return;
      }

      setState(() {
        _dokumen = base64Image;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memproses dokumen: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingDocument = false;
        });
      }
    }
  }

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
      _tanggalMulai =
          DateTime.tryParse(editData!.tanggalMulai);
      _tanggalSelesai =
          DateTime.tryParse(editData!.tanggalSelesai);
      _alasan = editData!.alasan;
      _dokumen = editData!.dokumenUrl;

      _hitungLamaCuti();
    }
  }

  /// =========================
  /// HITUNG LAMA CUTI
  /// =========================
  void _hitungLamaCuti() {
    int totalHari = 0;

    if (_tanggalMulai != null &&
        _tanggalSelesai != null &&
        !_tanggalSelesai!.isBefore(_tanggalMulai!)) {
      DateTime current = DateUtils.dateOnly(_tanggalMulai!);
      final DateTime tanggalAkhir =
      DateUtils.dateOnly(_tanggalSelesai!);

      while (!current.isAfter(tanggalAkhir)) {
        final bool hariKerja =
            current.weekday != DateTime.saturday &&
                current.weekday != DateTime.sunday;

        if (hariKerja) {
          totalHari++;
        }

        current = current.add(
          const Duration(days: 1),
        );
      }
    }

    _lamaCuti = totalHari;
    _lamaCutiController.text = totalHari.toString();
  }

  /// =========================
  /// DATE PICKER
  /// =========================
  Future<void> _selectDate(
      BuildContext context,
      bool isStart,
      ) async {
    final DateTime? pickedDate =
    await DatePickerHelper.pickDate(context);

    if (pickedDate == null || !mounted) return;

    setState(() {
      if (isStart) {
        _tanggalMulai = DateUtils.dateOnly(pickedDate);

        // Jika tanggal selesai lebih awal dari tanggal mulai,
        // reset tanggal selesai.
        if (_tanggalSelesai != null &&
            _tanggalSelesai!.isBefore(_tanggalMulai!)) {
          _tanggalSelesai = null;
        }
      } else {
        _tanggalSelesai = DateUtils.dateOnly(pickedDate);
      }

      _hitungLamaCuti();
    });
  }


  void _tampilkanGambarPenuh(String base64Image) {
    try {
      final String cleanBase64 = base64Image.contains(',')
          ? base64Image.split(',').last
          : base64Image;

      final imageBytes = base64Decode(cleanBase64);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                title: const Text('Dokumen'),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    boundaryMargin: const EdgeInsets.all(20),
                    child: Image.memory(
                      imageBytes,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Center(
                          child: Text(
                            'Gambar gagal ditampilkan',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Format gambar tidak valid',
          ),
        ),
      );
    }
  }

  /// =========================
  /// SUBMIT (ADD / EDIT)
  /// =========================
  Future<void> _submit() async {
    if (_isProcessingDocument) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tunggu sampai dokumen selesai diproses',
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final bool formValid =
        _formKey.currentState?.validate() ?? false;

    if (!formValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi data pengajuan cuti terlebih dahulu',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Perlindungan tambahan agar tidak terjadi null assertion error.
    if (_tanggalMulai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal mulai wajib dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal selesai wajib dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tanggalSelesai!.isBefore(_tanggalMulai!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal selesai tidak boleh sebelum tanggal mulai',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if ((_alasan ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alasan wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = await _dbHelper.getSingleUser();

    if (!mounted) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data pengguna tidak ditemukan',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cuti = CutiModel(
      lamaCutiInteger: _lamaCuti,
      id: editData?.id,
      jenisCuti: _jenisCuti!,
      tanggalMulai:
      _tanggalMulai!.toIso8601String().split('T').first,
      tanggalSelesai:
      _tanggalSelesai!.toIso8601String().split('T').first,
      alasan: _alasan!.trim(),
      dokumenUrl: _dokumen ?? '',
    );

    if (isEdit) {
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
          lamaCuti: _lamaCuti,
        ),
      );
    } else {
      context.read<CutiBloc>().add(
        AddCutiEvent(
          lamaCuti: _lamaCuti,
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
          lamaCutiInteger: _lamaCuti,
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

  @override
  void dispose() {
    _lamaCutiController.dispose();
    super.dispose();
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Cuti" : "Tambah Cuti", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                  FormField<DateTime>(
                    initialValue: _tanggalMulai,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (_tanggalMulai == null) {
                        return 'Tanggal mulai wajib dipilih';
                      }

                      return null;
                    },
                    builder: (field) {
                      return InkWell(
                        onTap: () async {
                          await _selectDate(context, true);

                          field.didChange(_tanggalMulai);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tanggal Mulai',
                            border: const OutlineInputBorder(),
                            errorText: field.errorText,
                            suffixIcon: const Icon(Icons.calendar_month),
                          ),
                          child: Text(
                            _tanggalMulai == null
                                ? 'Pilih tanggal mulai'
                                : DateFormat('yyyy-MM-dd').format(
                              _tanggalMulai!,
                            ),
                            style: TextStyle(
                              color: _tanggalMulai == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// TANGGAL SELESAI
                  FormField<DateTime>(
                    initialValue: _tanggalSelesai,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (_tanggalSelesai == null) {
                        return 'Tanggal selesai wajib dipilih';
                      }

                      if (_tanggalMulai != null &&
                          _tanggalSelesai!.isBefore(_tanggalMulai!)) {
                        return 'Tanggal selesai tidak boleh sebelum tanggal mulai';
                      }

                      return null;
                    },
                    builder: (field) {
                      return InkWell(
                        onTap: () async {
                          if (_tanggalMulai == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pilih tanggal mulai terlebih dahulu',
                                ),
                              ),
                            );
                            return;
                          }

                          await _selectDate(context, false);

                          field.didChange(_tanggalSelesai);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tanggal Selesai',
                            border: const OutlineInputBorder(),
                            errorText: field.errorText,
                            suffixIcon: const Icon(Icons.calendar_month),
                          ),
                          child: Text(
                            _tanggalSelesai == null
                                ? 'Pilih tanggal selesai'
                                : DateFormat('yyyy-MM-dd').format(
                              _tanggalSelesai!,
                            ),
                            style: TextStyle(
                              color: _tanggalSelesai == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// LAMA CUTI
                  TextFormField(
                    controller: _lamaCutiController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Lama Cuti',
                      hintText: '0',
                      suffixText: 'hari',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ALASAN
                  TextFormField(
                    initialValue: _alasan,
                    maxLines: 3,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Alasan',
                      hintText: 'Masukkan alasan pengajuan cuti',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    onChanged: (value) {
                      _alasan = value;
                    },
                    validator: (value) {
                      final alasan = value?.trim() ?? '';

                      if (alasan.isEmpty) {
                        return 'Alasan wajib diisi';
                      }

                      if (alasan.length < 5) {
                        return 'Alasan minimal 5 karakter';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Dokumen Upload (simulasi)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessingDocument
                              ? null
                              : _ambilDokumenDariKamera,
                          icon: _isProcessingDocument
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : Icon(
                            _dokumen == null || _dokumen!.isEmpty
                                ? Icons.camera_alt
                                : Icons.check_circle,
                          ),
                          label: Text(
                            _isProcessingDocument
                                ? 'Memproses gambar, tunggu...'
                                : _dokumen == null || _dokumen!.isEmpty
                                ? 'Ambil Dokumen dari Kamera'
                                : 'Dokumen berhasil dipilih',
                          ),
                        ),
                      ),

                      if (_isProcessingDocument) ...[
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Sedang mengompres dan menyiapkan gambar...',
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (!_isProcessingDocument &&
                          _dokumen != null &&
                          _dokumen!.isNotEmpty) ...[
                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: () {
                            _tampilkanGambarPenuh(_dokumen!);
                          },
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  base64Decode(
                                    _dokumen!.contains(',')
                                        ? _dokumen!.split(',').last
                                        : _dokumen!,
                                  ),
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.zoom_in,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Lihat gambar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Ketuk gambar untuk memperbesar',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Hapus dokumen',
                              onPressed: () {
                                setState(() {
                                  _dokumen = null;
                                });
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
                      isEdit ? "Simpan Cuti" : "Simpan Cuti",
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