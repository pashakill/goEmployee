import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:goemployee/goemployee.dart';

class TambahPresensiBackdatePage extends StatefulWidget {
  const TambahPresensiBackdatePage({super.key});

  @override
  State<TambahPresensiBackdatePage> createState() =>
      _TambahPresensiBackdatePageState();
}

class _TambahPresensiBackdatePageState
    extends State<TambahPresensiBackdatePage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  DateTime? _tanggal;
  TimeOfDay? _jamMasuk;
  TimeOfDay? _jamKeluar;
  String? _alasan;
  String? _dokumen;

  bool _isProcessingDocument = false;

  String keterlambatan = "-";

  bool isEdit = false;
  PresensiBackdateModel? backdateModel;
  Function()? _onBackdatePresensiAdded;

  void _hitungTerlambat() {
    if (_tanggal == null || _jamMasuk == null) {
      setState(() {
        keterlambatan = "-";
      });
      return;
    }

    final jamMasukDateTime = DateTime(
      _tanggal!.year,
      _tanggal!.month,
      _tanggal!.day,
      _jamMasuk!.hour,
      _jamMasuk!.minute,
    );

    final jamNormal = DateTime(
      _tanggal!.year,
      _tanggal!.month,
      _tanggal!.day,
      9, // jam masuk normal
      0,
    );

    if (jamMasukDateTime.isBefore(jamNormal) ||
        jamMasukDateTime.isAtSameMomentAs(jamNormal)) {
      setState(() {
        keterlambatan = "0 menit";
      });
    } else {
      final selisih = jamMasukDateTime.difference(jamNormal);

      final jam = selisih.inHours;
      final menit = selisih.inMinutes % 60;

      setState(() {
        if (jam > 0) {
          keterlambatan = "$jam jam $menit menit";
        } else {
          keterlambatan = "$menit menit";
        }
      });
    }
  }

  Future<void> _ambilDokumenDariKamera() async {
    if (_isProcessingDocument) return;

    setState(() {
      _isProcessingDocument = true;
    });

    try {
      final String? result =
      await CameraHelper.pickFromCamera(quality: 70);

      if (!mounted) return;

      if (result == null || result.trim().isEmpty) {
        return;
      }

      setState(() {
        _dokumen = result;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memproses dokumen: $error',
          ),
          backgroundColor: Colors.red,
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

  bool _isNetworkImage(String source) {
    final value = source.trim().toLowerCase();

    return value.startsWith('http://') ||
        value.startsWith('https://');
  }

  String _cleanBase64(String value) {
    final source = value.trim();

    if (source.contains(',')) {
      return source.split(',').last;
    }

    return source;
  }

  Widget _buildDocumentImage(
      String source, {
        double? width,
        double? height,
        BoxFit fit = BoxFit.cover,
      }) {
    if (_isNetworkImage(source)) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            color: Colors.grey.shade200,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _buildImageError(
            width: width,
            height: height,
          );
        },
      );
    }

    try {
      final imageBytes = base64Decode(
        _cleanBase64(source),
      );

      return Image.memory(
        imageBytes,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _buildImageError(
            width: width,
            height: height,
          );
        },
      );
    } catch (_) {
      return _buildImageError(
        width: width,
        height: height,
      );
    }
  }

  Widget _buildImageError({
    double? width,
    double? height,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 150,
      alignment: Alignment.center,
      color: Colors.grey.shade200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
            size: 36,
          ),
          SizedBox(height: 8),
          Text('Gambar tidak dapat ditampilkan'),
        ],
      ),
    );
  }

  void _tampilkanGambarPenuh(String source) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: const Text('Dokumen Presensi'),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5,
                  boundaryMargin: const EdgeInsets.all(30),
                  child: _buildDocumentImage(
                    source,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ================= INIT EDIT =================
  void _initEditMode() {
    final args = Get.arguments;
    _onBackdatePresensiAdded = args?['onPresensiBackdateAdded'];
    if (args != null && args['editBackdate'] != null) {
      backdateModel = args['editBackdate'];
      print('${backdateModel.toString()}');
      isEdit = true;
      _tanggal = DateTime.parse(backdateModel?.tanggal ?? '');
      _jamMasuk = DateHelper.stringToTimeOfDay(backdateModel?.jamMasuk ?? '');
      _jamKeluar = DateHelper.stringToTimeOfDay(backdateModel?.jamKeluar ?? '');
      _alasan = backdateModel!.alasan;
      _dokumen = backdateModel!.dokumenUrl;
    }
  }

  @override
  void initState() {
    super.initState();
    _initEditMode();
  }

  /// ================= PICK DATE =================

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate =
    await DatePickerHelper.pickDate(context);

    if (pickedDate == null || !mounted) return;

    setState(() {
      _tanggal = DateUtils.dateOnly(pickedDate);
    });

    _hitungTerlambat();
    _formKey.currentState?.validate();
  }

  /// ================= PICK TIME =================
  Future<void> _pickTime(bool isMasuk) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isMasuk
          ? (_jamMasuk ?? TimeOfDay.now())
          : (_jamKeluar ?? TimeOfDay.now()),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isMasuk) {
        _jamMasuk = picked;
      } else {
        _jamKeluar = picked;
      }
    });

    _hitungTerlambat();
    _formKey.currentState?.validate();
  }

  int _timeToMinutes(TimeOfDay time) {
    return (time.hour * 60) + time.minute;
  }

  bool _jamKeluarValid() {
    if (_jamMasuk == null || _jamKeluar == null) {
      return false;
    }

    return _timeToMinutes(_jamKeluar!) >
        _timeToMinutes(_jamMasuk!);
  }

  /// ================= SUBMIT =================
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

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

    final bool isValid =
        _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi seluruh data presensi backdate',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tanggal == null ||
        _jamMasuk == null ||
        _jamKeluar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal dan jam wajib dilengkapi',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_jamKeluarValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jam keluar harus setelah jam masuk',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String alasan =
    (_alasan ?? '').trim();

    if (alasan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alasan wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final User? user =
    await _dbHelper.getSingleUser();

    if (!mounted) return;

    if (user == null || user.id == null) {
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

    final DateTime tanggalMulai = DateTime(
      _tanggal!.year,
      _tanggal!.month,
      _tanggal!.day,
      _jamMasuk!.hour,
      _jamMasuk!.minute,
    );

    final DateTime tanggalSelesai = DateTime(
      _tanggal!.year,
      _tanggal!.month,
      _tanggal!.day,
      _jamKeluar!.hour,
      _jamKeluar!.minute,
    );

    final PresensiBackdateModel presensi =
    PresensiBackdateModel(
      userId: user.id!,
      tanggal: DateHelper.dateOnly(tanggalMulai),
      jamMasuk: DateHelper.timeOnly(tanggalMulai),
      jamKeluar: DateHelper.timeOnly(tanggalSelesai),
      alasan: alasan,
      dokumenUrl: _dokumen ?? '',
    );

    if (!mounted) return;

    if (isEdit) {
      if (backdateModel?.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ID presensi tidak ditemukan',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('EDIT');
      print('${backdateModel?.id.toString()}');

      context.read<PresensiBackdateBloc>().add(
        EditPresensiBackdateEvent(
          pengajuanId: backdateModel?.id.toString() ?? '',
          userId: user.id!,
          kategori:
          PengajuanKategori
              .presensiBackdate
              .name,
          tanggal_mulai:
          DateHelper.dateOnly(
            tanggalMulai,
          ),
          tanggal_selesai:
          DateHelper.dateOnly(
            tanggalSelesai,
          ),
          jam_mulai:
          DateHelper.timeOnly(
            tanggalMulai,
          ),
          jam_selesai:
          DateHelper.timeOnly(
            tanggalSelesai,
          ),
          berkas: _dokumen ?? '',
          alasan: alasan,
          presensiBackdateModel: presensi,
        ),
      );
    } else {
      print('TAMBAH');
      context.read<PresensiBackdateBloc>().add(
        AddPresensiBackdateEvent(
          presensi,
          userId: user.id!,
          berkas: _dokumen ?? '',
          kategori:
          PengajuanKategori
              .presensiBackdate
              .name,
          tanggal_mulai:
          DateHelper.dateOnly(
            tanggalMulai,
          ),
          tanggal_selesai:
          DateHelper.dateOnly(
            tanggalSelesai,
          ),
          jam_mulai:
          DateHelper.timeOnly(
            tanggalMulai,
          ),
          jam_selesai:
          DateHelper.timeOnly(
            tanggalSelesai,
          ),
          alasan: alasan,
          terlambat: keterlambatan,
        ),
      );
    }
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Presensi Backdate" : "Presensi Backdate",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme:
        const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<PresensiBackdateBloc,
          PresensiBackdateState>(
        listener: (context, state) {
          /// ERROR GLOBAL
          if (state is PresensiBackdatePageGlobalErorr) {
            ErrorBottomSheet.show(
              context,
              message: state.error.message,
            );
          }

          /// LOADING
          if (state is PresensiBackdatePageLoadingState) {
            LoadingDialog.show(context,
                message: "Tunggu Sebentar...");
          }

          /// SUCCESS ADD
          if (state is AddPresensiBackdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                  Text('Berhasil Menambahkan Presensi Backdate')),
            );

            _onBackdatePresensiAdded?.call();
            LoadingDialog.hide(context);
            Get.back();
          }

          /// SUCCESS EDIT
          if (state is EditPresensiBackdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                  Text('Berhasil Edit Presensi Backdate')),
            );
            _onBackdatePresensiAdded?.call();
            LoadingDialog.hide(context);
            Get.back();
          }

          /// FAILED
          if (state is PresensiBackdatePageFailedState) {
            LoadingDialog.hide(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                  Text('Gagal: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  /// TANGGAL
                  FormField<DateTime>(
                    initialValue: _tanggal,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      if (_tanggal == null) {
                        return 'Tanggal wajib dipilih';
                      }

                      return null;
                    },
                    builder: (field) {
                      return InkWell(
                        onTap: () async {
                          await _pickDate(context);
                          field.didChange(_tanggal);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tanggal',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(
                              Icons.calendar_month,
                            ),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            _tanggal == null
                                ? 'Pilih tanggal'
                                : DateFormat('dd MMM yyyy').format(
                              _tanggal!,
                            ),
                            style: TextStyle(
                              color: _tanggal == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// JAM MASUK
                  FormField<TimeOfDay>(
                    initialValue: _jamMasuk,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      if (_jamMasuk == null) {
                        return 'Jam masuk wajib dipilih';
                      }

                      return null;
                    },
                    builder: (field) {
                      return InkWell(
                        onTap: () async {
                          await _pickTime(true);
                          field.didChange(_jamMasuk);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Jam Masuk',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(
                              Icons.access_time,
                            ),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            _jamMasuk == null
                                ? 'Pilih jam masuk'
                                : _jamMasuk!.format(context),
                            style: TextStyle(
                              color: _jamMasuk == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// JAM KELUAR
                  FormField<TimeOfDay>(
                    initialValue: _jamKeluar,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      if (_jamKeluar == null) {
                        return 'Jam keluar wajib dipilih';
                      }

                      if (_jamMasuk != null &&
                          !_jamKeluarValid()) {
                        return 'Jam keluar harus setelah jam masuk';
                      }

                      return null;
                    },
                    builder: (field) {
                      return InkWell(
                        onTap: () async {
                          if (_jamMasuk == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pilih jam masuk terlebih dahulu',
                                ),
                              ),
                            );
                            return;
                          }

                          await _pickTime(false);
                          field.didChange(_jamKeluar);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Jam Keluar',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(
                              Icons.access_time,
                            ),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            _jamKeluar == null
                                ? 'Pilih jam keluar'
                                : _jamKeluar!.format(context),
                            style: TextStyle(
                              color: _jamKeluar == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Keterlambatan',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      keterlambatan,
                      style: TextStyle(
                        color: keterlambatan == "0 menit"
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ALASAN
                  TextFormField(
                    initialValue: _alasan ?? '',
                    maxLines: 3,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Alasan',
                      hintText:
                      'Masukkan alasan presensi backdate',
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

                  FormField<String>(
                    initialValue: _dokumen,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dokumen Pendukung',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Opsional, boleh dikosongkan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 8),

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
                                _dokumen == null || _dokumen!.trim().isEmpty
                                    ? Icons.camera_alt
                                    : Icons.check_circle,
                              ),
                              label: Text(
                                _isProcessingDocument
                                    ? 'Memproses gambar, tunggu...'
                                    : _dokumen == null || _dokumen!.trim().isEmpty
                                    ? 'Ambil Dokumen dari Kamera'
                                    : 'Ganti Dokumen',
                              ),
                            ),
                          ),

                          if (_isProcessingDocument) ...[
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Sedang menyiapkan gambar...',
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (!_isProcessingDocument &&
                              _dokumen != null &&
                              _dokumen!.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),

                            GestureDetector(
                              onTap: () {
                                _tampilkanGambarPenuh(_dokumen!);
                              },
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _buildDocumentImage(
                                      _dokumen!,
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
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                    child: Text(
                      isEdit
                          ? 'Simpan Presensi Backdate'
                          : 'Simpan Presensi Backdate',
                      style: const TextStyle(
                          color: Colors.white),
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