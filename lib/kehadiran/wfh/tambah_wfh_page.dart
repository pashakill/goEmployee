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
  String? _alasanWfh;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  int lamaWfh = 0;

  // Format tanggal dan waktu lokal Indonesia
  final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy HH:mm', 'id');

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

  void _simpanWfh() {
    if (_formKey.currentState!.validate()) {
      if (_tanggalMulai == null || _tanggalSelesai == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal mulai dan selesai')),
        );
        return;
      }

      final wfhBaru = WfhModel(
        lamaWfh: lamaWfh.toString(),
        alsanWfh: _alasanWfh ?? '',
        waktuMulai: _dateTimeFormat.format(_tanggalMulai!),
        waktuSelesai: _dateTimeFormat.format(_tanggalSelesai!),
      );

      widget.onWfhAdded?.call(wfhBaru);
      Navigator.pop(context);
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
