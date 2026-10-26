import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class TambahWfhPage extends StatefulWidget {
  const TambahWfhPage({super.key});

  @override
  State<TambahWfhPage> createState() => _TambahWfhPageState();
}

class _TambahWfhPageState extends State<TambahWfhPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String? _alasanWfh;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  int lamaWfh = 0;
  late DateTime _tanggalPengajuan;
  final TextEditingController _tglPengajuanController = TextEditingController();

  // Format tanggal dan waktu lokal Indonesia
  final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy HH:mm', 'id');
  WfhModel? wfhModel;
  bool isEdit = false;

  Function()? _onWfhAdded;

  @override
  void initState() {
    super.initState();
    _tanggalPengajuan = DateTime.now();
    _tglPengajuanController.text = _tanggalPengajuan.toIso8601String().split('T').first;
    _initEditMode();
  }

  void _initEditMode() {
    final args = Get.arguments;
    _onWfhAdded = args?['onWfhAdded'];
    if (args != null && args['editWfh'] != null) {
      wfhModel = args['editWfh'];
      isEdit = true;
      lamaWfh = int.parse(wfhModel!.lamaWfh);
      _tanggalMulai = DateTime.parse(wfhModel!.waktuMulai);
      _tanggalSelesai = DateTime.parse(wfhModel!.waktuSelesai);
      _alasanWfh = wfhModel!.alasanWfh;
    }
  }

  Future<void> _selectDateTime(
      BuildContext context,
      bool isStart,
      ) async {
    final DateTime? pickedDate =
    await DatePickerHelper.pickDate(context);

    if (pickedDate == null || !mounted) return;

    setState(() {
      final selectedDate = DateUtils.dateOnly(pickedDate);

      if (isStart) {
        _tanggalMulai = selectedDate;

        // Reset tanggal selesai apabila lebih kecil
        // daripada tanggal mulai.
        if (_tanggalSelesai != null &&
            _tanggalSelesai!.isBefore(selectedDate)) {
          _tanggalSelesai = null;
        }
      } else {
        _tanggalSelesai = selectedDate;
      }

      _hitungLamaWfh();
    });

    _formKey.currentState?.validate();
  }

  Future<void> _simpanWfh() async {
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

        // 3. Buat model wfh
        final wfhBaru = WfhModel(
            userId: currentUser.id!,
            lamaWfh: lamaWfh.toString(), alasanWfh: _alasanWfh ?? '',
            waktuMulai: _tanggalMulai.toString(), waktuSelesai: _tanggalSelesai.toString(),
            tanggalPengajuan: _tglPengajuanController.text
        );

        // 4. PANGGIL FUNGSI INSERT DARI DATABASEHELPER
        //    Ini akan menyimpan data ke database SQLCipher
        final int dinasId = await _dbHelper.insertWfh(wfhBaru);
        print('Dinas baru berhasil disimpan ke DB dengan ID: $dinasId');
        // 5. PANGGIL CALLBACK (kode Anda sudah benar)
        //    Ini akan meng-update UI di halaman DaftarCutiPage
        _onWfhAdded?.call();
        Navigator.pop(context);
      } catch (e) {
        // Tangani jika ada error saat simpan ke DB
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit WFH" : "Tambah WFH", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<WfhBloc, WfhState>(
        listener: (context, state) async {
          if (state is WfhPageGlobalErorr) {
            LoadingDialog.hide(context);
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

          if(state is EditWfhSuccessState){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sukses merubah data WFH')),
            );
            LoadingDialog.hide(context);
            _onWfhAdded?.call();
            Get.back();
          }

          if (state is WfhPageLoadingState) {
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if (state is AddWfhSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sukses Menambahkan WFH')),
            );

            LoadingDialog.hide(context);
            _onWfhAdded?.call();
            Get.back();
          }

          if (state is WfhPageFailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal Menambahkan WFH: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Tanggal Mulai
                  FormField<DateTime>(
                    initialValue: _tanggalMulai,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      if (_tanggalMulai == null) {
                        return 'Tanggal mulai wajib dipilih';
                      }

                      return null;
                    },
                    builder: (field) {
                      return InkWell(
                        onTap: () async {
                          await _selectDateTime(context, true);
                          field.didChange(_tanggalMulai);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tanggal Mulai',
                            border: const OutlineInputBorder(),
                            suffixIcon:
                            const Icon(Icons.calendar_month),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            _tanggalMulai == null
                                ? 'Pilih tanggal mulai'
                                : _dateTimeFormat.format(
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

                  // Tanggal Selesai
                  FormField<DateTime>(
                    initialValue: _tanggalSelesai,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      if (_tanggalSelesai == null) {
                        return 'Tanggal selesai wajib dipilih';
                      }

                      if (_tanggalMulai != null &&
                          _tanggalSelesai!
                              .isBefore(_tanggalMulai!)) {
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

                          await _selectDateTime(context, false);
                          field.didChange(_tanggalSelesai);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Tanggal Selesai',
                            border: const OutlineInputBorder(),
                            suffixIcon:
                            const Icon(Icons.calendar_month),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            _tanggalSelesai == null
                                ? 'Pilih tanggal selesai'
                                : _dateTimeFormat.format(
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

                  // Durasi WFH (readonly)
                  const SizedBox(height: 16),

                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Durasi WFH',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      lamaWfh > 0 ? '$lamaWfh hari' : '-',
                    ),
                  ),


                  const SizedBox(height: 16),

                  // Alasan
                  TextFormField(
                    maxLines: 3,
                    initialValue: _alasanWfh ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Alasan WFH',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => _alasanWfh = val,
                  ),

                  const SizedBox(height: 24),

                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: _submitWfh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      isEdit
                          ? 'Simpan Perubahan'
                          : 'Simpan WFH',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
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

  Future<void> _submitWfh() async {
    FocusScope.of(context).unfocus();

    final bool formValid =
        _formKey.currentState?.validate() ?? false;

    if (!formValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi data pengajuan WFH terlebih dahulu',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tanggalMulai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal mulai wajib dipilih',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal selesai wajib dipilih',
          ),
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

    final String alasan =
    (_alasanWfh ?? '').trim();

    if (alasan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alasan WFH wajib diisi',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _hitungLamaWfh();

    if (lamaWfh <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Durasi WFH tidak valid',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final User? currentUser =
      await _dbHelper.getSingleUser();

      if (!mounted) return;

      if (currentUser == null ||
          currentUser.id == null) {
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

      final String waktuMulai =
          _tanggalMulai!
              .toIso8601String()
              .split('T')
              .first;

      final String waktuSelesai =
          _tanggalSelesai!
              .toIso8601String()
              .split('T')
              .first;

      final WfhModel wfhBaru = WfhModel(
        userId: currentUser.id!,
        lamaWfh: lamaWfh.toString(),
        alasanWfh: alasan,
        waktuMulai: waktuMulai,
        waktuSelesai: waktuSelesai,
        tanggalPengajuan:
        _tglPengajuanController.text,
      );

      if (!mounted) return;

      if (isEdit) {
        if (wfhModel?.id == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'ID pengajuan WFH tidak ditemukan',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        context.read<WfhBloc>().add(
          EditWfhEvent(
            wfhBaru,
            id: wfhModel!.id.toString(),
            userId: currentUser.id!,
            lamaWfh: lamaWfh.toString(),
            alasanWfh: alasan,
            waktuMulai: waktuMulai,
            waktuSelesai: waktuSelesai,
            tanggalPengajuan:
            _tglPengajuanController.text,
            alasan: alasan,
            durasi: lamaWfh.toString(),
          ),
        );
      } else {
        context.read<WfhBloc>().add(
          AddWfhEvent(
            wfhBaru,
            userId: currentUser.id!,
            lamaWfh: lamaWfh.toString(),
            alasanWfh: alasan,
            waktuMulai: waktuMulai,
            waktuSelesai: waktuSelesai,
            tanggalPengajuan:
            _tglPengajuanController.text,
            alasan: alasan,
            durasi: lamaWfh.toString(),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _hitungLamaWfh() {
    if (_tanggalMulai == null ||
        _tanggalSelesai == null ||
        _tanggalSelesai!.isBefore(_tanggalMulai!)) {
      lamaWfh = 0;
      return;
    }

    int totalHari = 0;
    DateTime current = DateUtils.dateOnly(_tanggalMulai!);
    final DateTime tanggalAkhir =
    DateUtils.dateOnly(_tanggalSelesai!);

    while (!current.isAfter(tanggalAkhir)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        totalHari++;
      }

      current = current.add(const Duration(days: 1));
    }

    lamaWfh = totalHari;
  }
}
