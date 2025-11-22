import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class TambahWfhPage extends StatefulWidget {
  Function(WfhModel)? get onWfhAdded => Get.arguments?['onWfhAdded'];

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


  @override
  void initState() {
    super.initState();
    _tanggalPengajuan = DateTime.now();
    _tglPengajuanController.text = DateFormat('dd-MM-yyyy').format(_tanggalPengajuan);
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    // Pilih tanggal dulu
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );

    if (pickedDate == null) return;

    // Gabungkan tanggal & waktu
    final DateTime pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );

    setState(() {
      if (isStart) {
        _tanggalMulai = pickedDateTime;
      } else {
        _tanggalSelesai = pickedDateTime;
      }

      if (_tanggalMulai != null && _tanggalSelesai != null) {
        lamaWfh = _tanggalSelesai!
            .difference(_tanggalMulai!)
            .inDays
            .abs(); // hitung durasi dalam hari
      }
    });
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
        widget.onWfhAdded?.call(wfhBaru);
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
      body: Padding(
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
                onPressed: _simpanWfh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Ajukam WFH',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
