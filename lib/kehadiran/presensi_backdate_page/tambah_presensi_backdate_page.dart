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

  /// ================= INIT EDIT =================
  void _initEditMode() {
    final args = Get.arguments;
    _onBackdatePresensiAdded = args?['onPresensiBackdateAdded'];
    if (args != null && args['editBackdate'] != null) {
      backdateModel = args['editBackdate'];
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
    final DateTime? pickedDate = await DatePickerHelper.pickDate(context);

    if (pickedDate != null) {
      setState(() {
        _tanggal = pickedDate;
      });

      _hitungTerlambat();
    }
  }

  /// ================= PICK TIME =================
  Future<void> _pickTime(bool isMasuk) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isMasuk) {
          _jamMasuk = picked;
        } else {
          _jamKeluar = picked;
        }
      });
    }
    _hitungTerlambat();
  }

  /// ================= SUBMIT =================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggal == null ||
        _jamMasuk == null ||
        _jamKeluar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi tanggal & jam')),
      );
      return;
    }

    final user = await _dbHelper.getSingleUser();
    if (user == null) return;

    /// combine date + time
    final tanggalMulai = DateTime(
      _tanggal!.year,
      _tanggal!.month,
      _tanggal!.day,
      _jamMasuk!.hour,
      _jamMasuk!.minute,
    );

    final tanggalSelesai = DateTime(
      _tanggal!.year,
      _tanggal!.month,
      _tanggal!.day,
      _jamKeluar!.hour,
      _jamKeluar!.minute,
    );

    /// model lokal
    final presensi = PresensiBackdateModel(
      userId: user.id!,
      tanggal: DateHelper.dateOnly(tanggalMulai),
      jamMasuk: DateHelper.timeOnly(tanggalMulai),
      jamKeluar: DateHelper.timeOnly(tanggalSelesai),
      alasan: _alasan ?? '',
    );

    if (isEdit) {
      context.read<PresensiBackdateBloc>().add(
        EditPresensiBackdateEvent(
          pengajuanId: backdateModel!.id.toString(),
          userId: user.id!,
          kategori: PengajuanKategori.presensiBackdate.name,
          tanggal_mulai: DateHelper.dateOnly(tanggalMulai),
          tanggal_selesai: DateHelper.dateOnly(tanggalMulai),
          jam_mulai:
          DateHelper.timeOnly(tanggalMulai),
          jam_selesai:
          DateHelper.timeOnly(tanggalSelesai),
          alasan: _alasan!,
          presensiBackdateModel: presensi,
        ),
      );
    } else {
      context.read<PresensiBackdateBloc>().add(
        AddPresensiBackdateEvent(
          presensi,
          userId: user.id!,
          berkas: _dokumen ?? '',
          kategori: PengajuanKategori.presensiBackdate.name,
          tanggal_mulai:
          DateHelper.dateOnly(tanggalMulai),
          tanggal_selesai:
          DateHelper.dateOnly(tanggalSelesai),
          jam_mulai:
          DateHelper.timeOnly(tanggalMulai),
          jam_selesai:
          DateHelper.timeOnly(tanggalSelesai),
          alasan: _alasan!,
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
        title: const Text('Presensi Backdate',
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
            _onBackdatePresensiAdded?.call();
            LoadingDialog.hide(context);
            Get.back();
          }

          /// SUCCESS EDIT
          if (state is EditPresensiBackdateSuccessState) {
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
                  InkWell(
                    onTap: () => _pickDate(context),
                      child: InputDecorator(
                        decoration:
                        const InputDecoration(
                          labelText: 'Tanggal',
                          border:
                          OutlineInputBorder(),
                        ),
                        child: Text(
                          _tanggal == null
                              ? 'Pilih tanggal'
                              : DateFormat(
                              'dd MMM yyyy')
                              .format(_tanggal!),
                        ),
                      ),
                  ),

                  const SizedBox(height: 16),

                  /// JAM MASUK
                  InkWell(
                    onTap: () => _pickTime(true),
                    child: InputDecorator(
                      decoration:
                      const InputDecoration(
                        labelText: 'Jam Masuk',
                        border:
                        OutlineInputBorder(),
                      ),
                      child: Text(
                        _jamMasuk == null
                            ? 'Pilih jam masuk'
                            : _jamMasuk!
                            .format(context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// JAM KELUAR
                  InkWell(
                    onTap: () => _pickTime(false),
                    child: InputDecorator(
                      decoration:
                      const InputDecoration(
                        labelText: 'Jam Keluar',
                        border:
                        OutlineInputBorder(),
                      ),
                      child: Text(
                        _jamKeluar == null
                            ? 'Pilih jam keluar'
                            : _jamKeluar!
                            .format(context),
                      ),
                    ),
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
                    decoration:
                    const InputDecoration(
                      labelText: 'Alasan',
                      border:
                      OutlineInputBorder(),
                    ),
                    onChanged: (val) => _alasan = val,
                    validator: (val) =>
                    val == null || val.isEmpty
                        ? 'Alasan wajib diisi'
                        : null,
                  ),

                  const SizedBox(height: 16),

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
                      backgroundColor: Colors.green,
                      padding:
                      const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                    child: Text(
                      isEdit
                          ? 'Update Backdate'
                          : 'Submit Backdate',
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