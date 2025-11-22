import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:goemployee/goemployee.dart';

class TambahIzinPage extends StatefulWidget {
  Function(IzinConverterModel)? get onIzinAdded => Get.arguments?['onIzinAdded'];

  const TambahIzinPage({super.key});

  @override
  State<TambahIzinPage> createState() => _TambahIzinPageState();
}

// HAPUS: 'with SingleTickerProviderStateMixin'
class _TambahIzinPageState extends State<TambahIzinPage> {
  // --- State untuk Dropdown ---
  final List<String> _izinTypes = ['Telat Masuk', 'Pulang Awal', 'Tidak Masuk'];
  late String _selectedIzinType;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- State Form ---
  final TextEditingController _telatTanggalController = TextEditingController();
  final TextEditingController _telatJamController = TextEditingController();
  final TextEditingController _telatAlasanController = TextEditingController();
  DateTime? _telatTanggal;
  TimeOfDay? _telatJam;

  final TextEditingController _pulangTanggalController = TextEditingController();
  final TextEditingController _pulangJamController = TextEditingController();
  final TextEditingController _pulangAlasanController = TextEditingController();
  DateTime? _pulangTanggal;
  TimeOfDay? _pulangJam;

  final TextEditingController _absenTanggalController = TextEditingController();
  final TextEditingController _absenAlasanController = TextEditingController();
  DateTime? _absenTanggal;

  @override
  void initState() {
    super.initState();

    // Inisialisasi nilai default dropdown
    _selectedIzinType = _izinTypes[0]; // Default 'Telat Masuk'

    // --- Inisialisasi Nilai Default (Tanggal/Jam Hari Ini) ---
    // (Logika ini semua tetap sama dan sudah benar)
    final DateTime now = DateTime.now();
    final TimeOfDay timeNow = TimeOfDay.now();
    final String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    final String formattedTime =
        "${timeNow.hour.toString().padLeft(2, '0')}:${timeNow.minute.toString().padLeft(2, '0')}";
    _telatTanggal = now;
    _telatTanggalController.text = formattedDate;
    _telatJam = timeNow;
    _telatJamController.text = formattedTime;
    _pulangTanggal = now;
    _pulangTanggalController.text = formattedDate;
    _pulangJam = timeNow;
    _pulangJamController.text = formattedTime;
    _absenTanggal = now;
    _absenTanggalController.text = formattedDate;
  }

  @override
  void dispose() {
    // HAPUS: '_tabController.dispose();'
    _telatTanggalController.dispose();
    _telatJamController.dispose();
    _telatAlasanController.dispose();
    _pulangTanggalController.dispose();
    _pulangJamController.dispose();
    _pulangAlasanController.dispose();
    _absenTanggalController.dispose();
    _absenAlasanController.dispose();
    super.dispose();
  }

  // --- Fungsi Helper untuk Picker (Tetap sama) ---
  Future<void> _pilihTanggal(
      BuildContext context,
      TextEditingController controller,
      Function(DateTime) onDateSelected,
      ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Future<void> _pilihJam(
      BuildContext context,
      TextEditingController controller,
      Function(TimeOfDay) onTimeSelected,
      ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      onTimeSelected(picked);
      // ignore: use_build_context_synchronously
      controller.text = picked.format(context);
    }
  }

  // --- Logika Submit ---
  Future<void> _handleSubmit() async {
    final currentUser = await _dbHelper.getCurrentLoggedInUser();
    if (currentUser == null || currentUser.id == null) {
      _showSnackBar("Gagal: Sesi pengguna tidak ditemukan. Silakan login ulang.", isError: true);
      Get.back();
      return;
    }

    final int userId = currentUser.id!;
    final String currentTanggalPengajuan = DateFormat('yyyy-MM-dd').format(DateTime.now());

    IzinConverterModel? izinModelFinal; // Gunakan ini sebagai model final untuk DB

    // 2. Gunakan switch untuk memvalidasi dan membuat IzinConverterModel
    switch (_selectedIzinType) {
      case 'Telat Masuk':
        if (_telatTanggal == null || _telatJam == null || _telatAlasanController.text.isEmpty) {
          _showSnackBar('Harap lengkapi semua field Izin Telat.', isError: true);
          return;
        }

        final fullTime = DateTime(
          _telatTanggal!.year, _telatTanggal!.month, _telatTanggal!.day,
          _telatJam!.hour, _telatJam!.minute,
        );

        izinModelFinal = IzinConverterModel(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}', // ID unik sementara
          userId: userId, // ID Pengguna
          tipe: IzinTipe.telatMasuk,
          status: IzinStatus.pending,
          tanggal: _telatTanggal!,
          alasan: _telatAlasanController.text,
          jam: fullTime,
          tanggalPengajuan: currentTanggalPengajuan, // Tanggal hari ini
        );
        break;

      case 'Pulang Awal':
        if (_pulangTanggal == null || _pulangJam == null || _pulangAlasanController.text.isEmpty) {
          _showSnackBar('Harap lengkapi semua field Pulang Awal.', isError: true);
          return;
        }

        final fullTime = DateTime(
          _pulangTanggal!.year, _pulangTanggal!.month, _pulangTanggal!.day,
          _pulangJam!.hour, _pulangJam!.minute,
        );

        izinModelFinal = IzinConverterModel(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          tipe: IzinTipe.pulangAwal,
          status: IzinStatus.pending,
          tanggal: _pulangTanggal!,
          alasan: _pulangAlasanController.text,
          jam: fullTime,
          tanggalPengajuan: currentTanggalPengajuan,
        );
        break;

      case 'Tidak Masuk':
        if (_absenTanggal == null || _absenAlasanController.text.isEmpty) {
          _showSnackBar('Harap lengkapi semua field Izin Tidak Masuk.', isError: true);
          return;
        }

        izinModelFinal = IzinConverterModel(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          tipe: IzinTipe.tidakMasuk,
          status: IzinStatus.pending,
          tanggal: _absenTanggal!,
          alasan: _absenAlasanController.text,
          jam: null,
          tanggalPengajuan: currentTanggalPengajuan,
        );
        break;

      default:
        _showSnackBar('Gagal: Jenis izin tidak valid.', isError: true);
        return;
    }

    // 4. Kirim data ke DatabaseHelper
    if (izinModelFinal != null) {
      try {
        final int newDbId = await _dbHelper.insertIzin(izinModelFinal); // Panggil fungsi insert DB
        // Panggil callback (jika ada) dan kembali
        widget.onIzinAdded?.call(izinModelFinal.copyWith(id: newDbId.toString()));
        _showSnackBar('Pengajuan Izin berhasil disimpan! (DB ID: $newDbId)', isError: false);
        Get.back();

      } catch (e) {
        _showSnackBar('Gagal menyimpan pengajuan Izin: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Izin'),
        backgroundColor: Colors.green, // Sesuaikan dengan tema Anda
        // HAPUS: 'bottom: TabBar(...)'
      ),
      // UBAH: 'TabBarView' menjadi 'SingleChildScrollView'
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Dropdown Pilihan Izin ---
            _buildDropdownIzin(),
            const SizedBox(height: 24),

            // --- 2. Form yang Tampil Dinamis ---
            _buildConditionalForm(),
            const SizedBox(height: 24),

            // --- 3. Tombol Submit (Hanya satu) ---
            _buildSubmitButton(_handleSubmit),
          ],
        ),
      ),
    );
  }

  // --- Widget Builder Baru ---

  // Widget untuk Dropdown
  Widget _buildDropdownIzin() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Jenis Izin',
        border: OutlineInputBorder(),
      ),
      value: _selectedIzinType,
      items: _izinTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedIzinType = newValue!;
        });
      },
    );
  }

  // Widget untuk menampilkan form yang sesuai
  Widget _buildConditionalForm() {
    switch (_selectedIzinType) {
      case 'Telat Masuk':
        return _buildFieldsTelatMasuk();
      case 'Pulang Awal':
        return _buildFieldsPulangAwal();
      case 'Tidak Masuk':
        return _buildFieldsTidakMasuk();
      default:
        return Container(); // Seharusnya tidak pernah terjadi
    }
  }

  // --- Widget Builder untuk Field (Dipisah dari submit button) ---

  // 1. Field Izin Telat Masuk
  Widget _buildFieldsTelatMasuk() {
    return Column(
      children: [
        _buildDatePickerField(
          'Tanggal',
          _telatTanggalController,
              () => _pilihTanggal(
            context,
            _telatTanggalController,
                (pickedDate) => setState(() => _telatTanggal = pickedDate),
          ),
        ),
        const SizedBox(height: 16),
        _buildTimePickerField(
          'Jam Akan Masuk',
          _telatJamController,
              () => _pilihJam(
            context,
            _telatJamController,
                (pickedTime) => setState(() => _telatJam = pickedTime),
          ),
        ),
        const SizedBox(height: 16),
        _buildAlasanField('Alasan Telat Masuk', _telatAlasanController),
      ],
    );
  }

  // 2. Field Izin Pulang Awal
  Widget _buildFieldsPulangAwal() {
    return Column(
      children: [
        _buildDatePickerField(
          'Tanggal',
          _pulangTanggalController,
              () => _pilihTanggal(
            context,
            _pulangTanggalController,
                (pickedDate) => setState(() => _pulangTanggal = pickedDate),
          ),
        ),
        const SizedBox(height: 16),
        _buildTimePickerField(
          'Jam Akan Pulang',
          _pulangJamController,
              () => _pilihJam(
            context,
            _pulangJamController,
                (pickedTime) => setState(() => _pulangJam = pickedTime),
          ),
        ),
        const SizedBox(height: 16),
        _buildAlasanField('Alasan Pulang Awal', _pulangAlasanController),
      ],
    );
  }

  // 3. Field Izin Tidak Masuk
  Widget _buildFieldsTidakMasuk() {
    return Column(
      children: [
        _buildDatePickerField(
          'Tanggal Izin',
          _absenTanggalController,
              () => _pilihTanggal(
            context,
            _absenTanggalController,
                (pickedDate) => setState(() => _absenTanggal = pickedDate),
          ),
        ),
        const SizedBox(height: 16),
        _buildAlasanField('Alasan Tidak Masuk', _absenAlasanController),
      ],
    );
  }

  // --- Widget Helper Reusable (Bisa Dipakai Ulang) ---
  // (Fungsi-fungsi ini tidak berubah sama sekali)

  Widget _buildDatePickerField(
      String label, TextEditingController controller, VoidCallback onTap) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: onTap,
    );
  }

  Widget _buildTimePickerField(
      String label, TextEditingController controller, VoidCallback onTap) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.access_time),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAlasanField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Tuliskan alasan Anda di sini...',
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSubmitButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, // Warna hijau
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed, // Memanggil fungsi _handleSubmit
        child: const Text(
          'Submit Pengajuan',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // Helper untuk menampilkan SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }
}