import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';

class TambahCutiPage extends StatefulWidget {
  Function(CutiModel)? get onCutiAdded => Get.arguments?['onCutiAdded'];

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

  final List<String> _jenisCutiList = [
    'Semua Cuti',
    'Cuti Tahunan',
    'Cuti Melahirkan',
    'Cuti Nikah',
    'Cuti Khusus',
  ];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _tanggalMulai = picked;
        } else {
          _tanggalSelesai = picked;
        }

        if (_tanggalMulai != null && _tanggalSelesai != null) {
          _lamaCuti = _tanggalSelesai!
              .difference(_tanggalMulai!)
              .inDays
              .abs() + 1; // +1 agar hitung hari penuh
        }
      });
    }
  }

  void _simpanCuti() {
    if (_formKey.currentState!.validate()) {
      if (_tanggalMulai == null || _tanggalSelesai == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal mulai dan selesai')),
        );
        return;
      }

      final cutiBaru = CutiModel(
        jenisCuti: _jenisCuti!,
        tanggalMulai: _tanggalMulai!.toIso8601String().split('T').first,
        tanggalSelesai: _tanggalSelesai!.toIso8601String().split('T').first,
        alasan: _alasan ?? '',
        dokumenUrl: _dokumen ?? '',
      );

      widget.onCutiAdded!(cutiBaru);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Cuti', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Jenis Cuti
              DropdownButtonFormField<String>(
                value: _jenisCuti,
                decoration: const InputDecoration(
                  labelText: 'Jenis Cuti',
                  border: OutlineInputBorder(),
                ),
                items: _jenisCutiList.map((jenis) {
                  return DropdownMenuItem(
                    value: jenis,
                    child: Text(jenis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _jenisCuti = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Pilih jenis cuti_page' : null,
              ),
              const SizedBox(height: 16),

              // Tanggal Mulai
              InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Mulai',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_tanggalMulai == null
                      ? 'Pilih tanggal mulai'
                      : _tanggalMulai!.toString().split(' ')[0]),
                ),
              ),
              const SizedBox(height: 16),

              // Tanggal Selesai
              InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Selesai',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_tanggalSelesai == null
                      ? 'Pilih tanggal selesai'
                      : _tanggalSelesai!.toString().split(' ')[0]),
                ),
              ),
              const SizedBox(height: 16),

              // Lama Cuti
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Lama Cuti (hari)',
                  border: OutlineInputBorder(),
                ),
                controller:
                TextEditingController(text: _lamaCuti.toString()),
              ),
              const SizedBox(height: 16),

              // Alasan
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alasan Cuti',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => _alasan = val,
              ),
              const SizedBox(height: 16),

              // Dokumen Upload (simulasi)
              ElevatedButton.icon(
                onPressed: () {
                  // bisa integrasi dengan file picker nanti
                  setState(() {
                    _dokumen = 'dokumen_cuti.pdf';
                  });
                },
                icon: const Icon(Icons.upload_file),
                label: Text(
                    _dokumen == null ? 'Upload Dokumen' : 'File: $_dokumen'),
              ),

              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _simpanCuti,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Simpan Cuti',
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
