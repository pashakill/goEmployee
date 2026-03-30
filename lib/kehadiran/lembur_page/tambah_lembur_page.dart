import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class TambahLemburPage extends StatefulWidget {
  Function()? get onLemburAdded => Get.arguments?['onLemburAdded'];

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
  final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  bool isEdit = false;
  LemburModel? lemburModel;

  void _initEditMode() {
    final args = Get.arguments;

    if (args != null && args['editLembur'] != null) {
      lemburModel = args['editLembur'];
      isEdit = true;
      lamaLembur = int.parse(lemburModel!.lamaLembur);
      _tanggalMulai = DateTime.parse(lemburModel!.waktuMulai);
      _tanggalSelesai = DateTime.parse(lemburModel!.waktuSelesai);
      _catatanLembur = lemburModel!.catatanLembur;
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );


    if (picked == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final DateTime pickedDateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _tanggalMulai = pickedDateTime;
      } else {
        _tanggalSelesai = pickedDateTime;
      }

      if (_tanggalMulai != null && _tanggalSelesai != null) {
        lamaLembur = _tanggalSelesai!
            .difference(_tanggalMulai!)
            .inHours
            .abs();
      }
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
          waktuMulai: _dateTimeFormat.format(_tanggalMulai!),
          waktuSelesai: _dateTimeFormat.format(_tanggalSelesai!), userId: currentUser.id!,
        );
        _dbHelper.insertLembur(lemburBaru);
        widget.onLemburAdded?.call();
        Navigator.pop(context);
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
        const Text('Formulir Lembur', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<LemburBloc, LemburState>(
        listener: (context, state) async {
          if(state is EditLemburSuccessState){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sukses Melakukan update Lembur')));

            widget.onLemburAdded?.call();
            Get.back();
          }

          if (state is LemburPageLoadingState) {

          }

          if (state is AddLemburSuccessState) {
            /*
            final User? currentUser = await _dbHelper.getSingleUser();
            final lemburBaru = LemburModel(
              lamaLembur: lamaLembur.toString(),
              catatanLembur: _catatanLembur ?? '',
              waktuMulai: _dateTimeFormat.format(_tanggalMulai!),
              waktuSelesai: _dateTimeFormat.format(_tanggalSelesai!), userId: currentUser!.id!,
            );
            _dbHelper.insertLembur(lemburBaru);
             */
            widget.onLemburAdded?.call();
            Get.back();
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
                    decoration: const InputDecoration(
                      labelText: 'Alasan Lembur',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => _catatanLembur = val,
                  ),

                  const SizedBox(height: 24),

                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: () async {
                      final User? currentUser = await _dbHelper.getSingleUser();
                      final lemburBaru = LemburModel(
                        lamaLembur: lamaLembur.toString(),
                        catatanLembur: _catatanLembur ?? '',
                        waktuMulai: _dateTimeFormat.format(_tanggalMulai!),
                        waktuSelesai: _dateTimeFormat.format(_tanggalSelesai!), userId: currentUser!.id!,
                      );
                      if(isEdit){
                        context.read<LemburBloc>().add(
                          EditLemburEvent(pengajuanId: lemburModel!.id.toString(), lemburBaru, userId: currentUser.id!,
                              kategori: PengajuanKategori.lembur.toString(), tanggal_mulai: _dateTimeFormat.format(_tanggalMulai!),
                              alasan: _catatanLembur ?? '', tanggal_selesai: _dateTimeFormat.format(_tanggalSelesai!), durasi: lamaLembur.toString()),
                        );
                      }else{
                        context.read<LemburBloc>().add(
                          AddLemburEvent(lemburBaru, userId: currentUser.id!,
                              kategori: PengajuanKategori.lembur.toString(), tanggal_mulai: _dateTimeFormat.format(_tanggalMulai!),
                              alasan: _catatanLembur ?? '', tanggal_selesai: _dateTimeFormat.format(_tanggalSelesai!), durasi: lamaLembur.toString()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Simpan Data Lembur',
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
}
