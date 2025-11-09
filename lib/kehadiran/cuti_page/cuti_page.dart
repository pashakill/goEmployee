import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  // List sekarang dimulai sebagai list kosong
  List<CutiModel> cutiList = [];
  // State untuk helper
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true; // State untuk loading

  bool sortByJenis = false;
  bool sortByTanggal = false;

  // --- (FUNGSI LOAD DATA) ---
  @override
  void initState() {
    super.initState();
    _loadRiwayatCuti();
  }

  /// Mengambil data cuti dari database
  Future<void> _loadRiwayatCuti() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Ambil user yang sedang login (sesuai cara kita sebelumnya)
      final User? currentUser = await _dbHelper.getSingleUser();
      if (currentUser == null || currentUser.id == null) {
        // Handle error: user tidak ditemukan
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User tidak ditemukan!')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 2. Ambil riwayat cuti berdasarkan ID user
      final List<CutiModel> riwayat = await _dbHelper.getRiwayatCuti(currentUser.id!);

      // 3. Update UI dengan data baru
      setState(() {
        cutiList = riwayat;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat: $e')),
        );
      }
    }
  }
  // ------------------------------------

  void _sortByJenis() {
    setState(() {
      sortByJenis = !sortByJenis;
      cutiList.sort((a, b) => sortByJenis
          ? a.jenisCuti.compareTo(b.jenisCuti)
          : b.jenisCuti.compareTo(a.jenisCuti));
    });
  }

  void _sortByTanggal() {
    setState(() {
      sortByTanggal = !sortByTanggal;
      cutiList.sort((a, b) {
        final dateA = DateTime.parse(a.tanggalMulai);
        final dateB = DateTime.parse(b.tanggalMulai);
        return sortByTanggal
            ? dateA.compareTo(dateB)
            : dateB.compareTo(DateTime.parse(a.tanggalMulai));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            color: Colors.white,
            onPressed: () {
              // Logika navigasi Anda sudah benar
              AppNavigator.to(Routes.tambahCutiPage, arguments: {
                'onCutiAdded': (CutiModel newCuti) {
                  // Ini akan menambah CutiModel baru ke list secara instan
                  // (tanpa perlu load ulang dari DB, UI terasa cepat)
                  setState(() {
                    cutiList.add(newCuti);
                  });
                },
              });
            },
          )
        ],
        backgroundColor: Colors.green,
        title: const Text('Cuti', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            AppNavigator.back();
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            // ... (Tombol sort Anda sudah benar) ...
            children: [
              RoundedContainer(
                color: Colors.green.withOpacity(0.3),
                radius: 24,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                builder: (context) {
                  return InkWell(
                    onTap: _sortByJenis,
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      children: [
                        Text(
                          'Jenis Cuti',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          sortByJenis
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 18,
                        ),
                      ],
                    ),
                  );
                },
              ),
              RoundedContainer(
                color: Colors.green.withOpacity(0.3),
                radius: 24,
                margin: const EdgeInsets.symmetric(vertical: 8),
                builder: (context) {
                  return InkWell(
                    onTap: _sortByTanggal,
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        Icon(
                          sortByTanggal
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 18,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),

          // 📋 Daftar Cuti
          Expanded(
            // --- (TAMBAHKAN PENGECEKAN LOADING & DATA KOSONG) ---
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : cutiList.isEmpty
                ? const Center(
              child: Text(
                'Belum ada riwayat cuti.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: cutiList.length,
              itemBuilder: (context, index) {
                // Panggilan CutiCard Anda sudah benar
                return CutiCard(cuti: cutiList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}