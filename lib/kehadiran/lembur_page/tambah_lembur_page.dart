import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';

class TambahLemburPage extends StatefulWidget {
  const TambahLemburPage({super.key});

  @override
  State<TambahLemburPage> createState() => _TambahLemburPageState();
}

class _TambahLemburPageState extends State<TambahLemburPage> {
  final _formKey = GlobalKey<FormState>();
  String? _catatanLembur;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  int lamaLembur = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Format tanggal dan waktu lokal Indonesia
  bool isEdit = false;
  LemburModel? lemburModel;
  Function()? _onLemburAdded;


  void _initEditMode() {
    final args = Get.arguments;
    _onLemburAdded = args?['onLemburAdded'];

    if (args != null && args['editLembur'] != null) {
      lemburModel = args['editLembur'];
      isEdit = true;
      lamaLembur = int.parse(lemburModel!.lamaLembur);
      _tanggalMulai = DateHelper.fromBackend(lemburModel!.waktuMulai);
      _tanggalSelesai = DateHelper.fromBackend(lemburModel!.waktuSelesai);
      _catatanLembur = lemburModel!.catatanLembur;
      _hitungDurasi();
    }
  }

  void _hitungDurasi() {
    if (_tanggalMulai == null || _tanggalSelesai == null) {
      lamaLembur = 0;
      return;
    }

    if (!_tanggalSelesai!.isAfter(_tanggalMulai!)) {
      lamaLembur = 0;
      return;
    }

    final int selisihMenit =
        _tanggalSelesai!.difference(_tanggalMulai!).inMinutes;

    lamaLembur = (selisihMenit / 60).ceil();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final current = isStart ? _tanggalMulai : _tanggalSelesai;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current ?? DateTime.now()),
    );

    if (pickedTime == null) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _tanggalMulai = newDateTime;
      } else {
        _tanggalSelesai = newDateTime;
      }

      _hitungDurasi();
    });
  }

  Future<void> _simpanLembur() async {
    if (_formKey.currentState!.validate()) {
      if (_tanggalMulai == null || _tanggalSelesai == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal mulai dan selesai')),
        );
        return;
      }

      try{
        final User? currentUser = await _dbHelper.getSingleUser();
        if (currentUser == null || currentUser.id == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Gagal mendapatkan data user!')),
          );
          return;
        }

        final lemburBaru = LemburModel(
          lamaLembur: lamaLembur.toString(),
          catatanLembur: _catatanLembur ?? '',
          waktuMulai: DateHelper.toBackend(_tanggalMulai!),
          waktuSelesai: DateHelper.toBackend(_tanggalSelesai!), userId: currentUser.id!,
        );
        _dbHelper.insertLembur(lemburBaru);
        _onLemburAdded?.call();
        Get.back();
      }catch(e){
        e.printError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _initEditMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text(isEdit ? "Edit Lembur" : "Tambah Lembur", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<LemburBloc, LemburState>(
        listener: (context, state) async {
          if (state is LemburPageGlobalErorr) {
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

          if(state is EditLemburSuccessState){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sukses Melakukan edit Lembur')));

            _onLemburAdded?.call();
            LoadingDialog.hide(context);
            Get.back();
          }

          if (state is LemburPageLoadingState) {
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if (state is AddLemburSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Lembur berhasil ditambahkan"),
              ),
            );
            _onLemburAdded?.call();
            LoadingDialog.hide(context);
            Get.back(result: true);
          } else if (state is LemburPageFailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal Menambahkan Lembur: ${state.error}')),
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
                    key: ValueKey(
                      'tanggal_mulai_${_tanggalMulai?.millisecondsSinceEpoch}',
                    ),
                    initialValue: _tanggalMulai,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            suffixIcon: const Icon(Icons.calendar_month),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            _tanggalMulai == null
                                ? 'Pilih tanggal mulai'
                                : DateHelper.formatDisplay(_tanggalMulai!),
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
                    key: ValueKey(
                      'tanggal_selesai_${_tanggalSelesai?.millisecondsSinceEpoch}',
                    ),
                    initialValue: _tanggalSelesai,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (_) {
                      if (_tanggalSelesai == null) {
                        return 'Tanggal selesai wajib dipilih';
                      }

                      if (_tanggalMulai != null &&
                          !_tanggalSelesai!.isAfter(_tanggalMulai!)) {
                        return 'Tanggal selesai harus setelah tanggal mulai';
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
                            suffixIcon: const Icon(Icons.calendar_month),
                            errorText: field.errorText,
                          ),
                          child: Text(
                            _tanggalSelesai == null
                                ? 'Pilih tanggal selesai'
                                : DateHelper.formatDisplay(_tanggalSelesai!),
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

                  // Durasi Lembur (readonly)
                  const SizedBox(height: 16),

                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Durasi Lembur',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      lamaLembur > 0 ? '$lamaLembur jam' : '-',
                    ),
                  ),


                  const SizedBox(height: 16),

                  // Alasan
                  TextFormField(
                    initialValue: _catatanLembur ?? '',
                    maxLines: 3,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Alasan Lembur',
                      hintText: 'Masukkan alasan lembur',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    onChanged: (value) {
                      _catatanLembur = value;
                    },
                    validator: (value) {
                      final alasan = value?.trim() ?? '';

                      if (alasan.isEmpty) {
                        return 'Alasan lembur wajib diisi';
                      }

                      if (alasan.length < 5) {
                        return 'Alasan lembur minimal 5 karakter';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: _submitLembur,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Simpan Lembur',
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

  Future<void> _submitLembur() async {
    FocusScope.of(context).unfocus();

    final bool formValid =
        _formKey.currentState?.validate() ?? false;

    if (!formValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi data lembur terlebih dahulu',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

    if (!_tanggalSelesai!.isAfter(_tanggalMulai!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal selesai harus setelah tanggal mulai',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if ((_catatanLembur ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alasan lembur wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _hitungDurasi();

    if (lamaLembur <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Durasi lembur harus lebih dari 0 jam',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final User? currentUser =
    await _dbHelper.getSingleUser();

    if (!mounted) return;

    if (currentUser == null || currentUser.id == null) {
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

    final LemburModel lemburBaru = LemburModel(
      lamaLembur: lamaLembur.toString(),
      catatanLembur: _catatanLembur!.trim(),
      waktuMulai: DateHelper.toBackend(_tanggalMulai!),
      waktuSelesai: DateHelper.toBackend(_tanggalSelesai!),
      userId: currentUser.id!,
    );

    if (isEdit) {
      if (lemburModel?.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ID lembur tidak ditemukan',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<LemburBloc>().add(
        EditLemburEvent(
          pengajuanId: lemburModel!.id.toString(),
          lemburBaru,
          userId: currentUser.id!,
          kategori: PengajuanKategori.lembur.toString(),
          tanggal_mulai:
          DateHelper.toBackend(_tanggalMulai!),
          tanggal_selesai:
          DateHelper.toBackend(_tanggalSelesai!),
          alasan: _catatanLembur!.trim(),
          durasi: lamaLembur.toString(),
        ),
      );
    } else {
      context.read<LemburBloc>().add(
        AddLemburEvent(
          lemburBaru,
          userId: currentUser.id!,
          kategori: PengajuanKategori.lembur.toString(),
          tanggal_mulai:
          DateHelper.toBackend(_tanggalMulai!),
          tanggal_selesai:
          DateHelper.toBackend(_tanggalSelesai!),
          alasan: _catatanLembur!.trim(),
          durasi: lamaLembur.toString(),
        ),
      );
    }
  }
}
