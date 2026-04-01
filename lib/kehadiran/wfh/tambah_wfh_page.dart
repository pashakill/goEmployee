import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class TambahWfhPage extends StatefulWidget {
  Function()? get onWfhAdded => Get.arguments?['onWfhAdded'];

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

  @override
  void initState() {
    super.initState();
    _tanggalPengajuan = DateTime.now();
    _tglPengajuanController.text = _tanggalPengajuan.toIso8601String().split('T').first;
    _initEditMode();
  }

  void _initEditMode() {
    final args = Get.arguments;

    if (args != null && args['editWfh'] != null) {
      wfhModel = args['editWfh'];
      isEdit = true;
      lamaWfh = int.parse(wfhModel!.lamaWfh);
      _tanggalMulai = DateTime.parse(wfhModel!.waktuMulai);
      _tanggalSelesai = DateTime.parse(wfhModel!.waktuSelesai);
      _alasanWfh = wfhModel!.alasanWfh;
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await DatePickerHelper.pickDate(context);

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _tanggalMulai = pickedDate;
        } else {
          _tanggalSelesai = pickedDate;
        }
        _hitungLamaWfh();
      });
    }
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
        widget.onWfhAdded?.call();
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
        title:
        const Text('Formulir WFH', style: TextStyle(color: Colors.white)),
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
            LoadingDialog.hide(context);
            widget.onWfhAdded?.call();
            Get.back();
          }

          if (state is CutiPageLoadingState) {
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if (state is AddWfhSuccessState) {
            widget.onWfhAdded?.call();
            LoadingDialog.hide(context);
            Get.back();
          } else if (state is WfhPageFailedState) {
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
                  InkWell(
                    onTap: () => _selectDateTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Mulai',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _tanggalMulai == null
                            ? 'Pilih tanggal mulai'
                            : _dateTimeFormat.format(_tanggalMulai!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Selesai
                  InkWell(
                    onTap: () => _selectDateTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Selesai',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _tanggalSelesai == null
                            ? 'Pilih tanggal selesai'
                            : _dateTimeFormat.format(_tanggalSelesai!),
                      ),
                    ),
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
                    decoration: const InputDecoration(
                      labelText: 'Alasan WFH',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => _alasanWfh = val,
                  ),

                  const SizedBox(height: 24),

                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_tanggalMulai == null || _tanggalSelesai == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pilih tanggal mulai dan selesai')),
                          );
                          return;
                        }

                        try {
                          final User? currentUser = await _dbHelper.getSingleUser();
                          final wfhBaru = WfhModel(
                              userId: currentUser!.id!,
                              lamaWfh: lamaWfh.toString(),
                              alasanWfh: _alasanWfh ?? '',
                              waktuMulai: _tanggalMulai!.toIso8601String().split('T').first,
                              waktuSelesai: _tanggalSelesai!.toIso8601String().split('T').first,
                              tanggalPengajuan: _tglPengajuanController.text
                          );

                          if(isEdit){
                            context.read<WfhBloc>().add(
                              EditWfhEvent(wfhBaru, userId: currentUser.id!, lamaWfh: lamaWfh.toString(),
                                  alasanWfh: _alasanWfh ?? '',
                                  waktuMulai: _tanggalMulai!.toIso8601String().split('T').first,
                                  waktuSelesai: _tanggalSelesai!.toIso8601String().split('T').first,
                                  tanggalPengajuan: _tglPengajuanController.text,
                                  alasan: _alasanWfh!,
                                  durasi: lamaWfh.toString(),
                                  id: wfhModel!.id.toString()
                              ),
                            );
                          }else{
                            context.read<WfhBloc>().add(
                              AddWfhEvent(wfhBaru, userId: currentUser.id!, lamaWfh: lamaWfh.toString(),
                                  alasanWfh: _alasanWfh ?? '',
                                  waktuMulai: _tanggalMulai!.toIso8601String().split('T').first,
                                  waktuSelesai: _tanggalSelesai!.toIso8601String().split('T').first,
                                  tanggalPengajuan: _tglPengajuanController.text,
                                  alasan: _alasanWfh!,
                                  durasi: lamaWfh.toString()
                              ),
                            );
                          }
                        } catch (e) {
                          // Tangani jika ada error saat simpan ke DB
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isEdit ? 'Edit WFH' : 'Ajukan WFH',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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

  void _hitungLamaWfh() {
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

      lamaWfh = totalHari;
    }
  }
}
