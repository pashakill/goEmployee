import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/widget/lembur_card.dart';

class LemburPage extends StatefulWidget {
  const LemburPage({super.key});

  @override
  State<LemburPage> createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {

  // List sekarang dimulai sebagai list kosong
  List<LemburModel> lemburList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true; // State untuk loading

  bool sortByDurasi = false;
  bool sortByTanggal = false;

  void _sortByDurasi() {
    setState(() {
      sortByDurasi = !sortByDurasi;
      lemburList.sort((a, b) => sortByDurasi
          ? a.lamaLembur.compareTo(b.lamaLembur)
          : b.lamaLembur.compareTo(a.lamaLembur));
    });
  }

  void _sortByTanggal() {
    setState(() {
      sortByTanggal = !sortByTanggal;
      lemburList.sort((a, b) {
        final dateA = DateTime.parse(a.waktuMulai);
        final dateB = DateTime.parse(b.waktuMulai);
        return sortByTanggal
            ? dateA.compareTo(dateB)
            : dateB.compareTo(dateA);
      });
    });
  }


  @override
  void initState() {
    super.initState();
    _loadRiwayatLembur();
  }

  /// Mengambil data lembur dari database
  Future<void> _loadRiwayatLembur() async {
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

      // 2. Ambil riwayat lembur berdasarkan ID user
      final List<LemburModel> riwayatLembur = await _dbHelper.getRiwayatLembur(currentUser.id!);

      // 3. Update UI dengan data baru
      setState(() {
        lemburList = riwayatLembur;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            color: Colors.white,
            onPressed: () {
              AppNavigator.to(Routes.tambahLemburPage,
                  arguments: {
                    'onLemburAdded': (LemburModel lemburModel) {
                      setState(() {
                        lemburList.add(lemburModel);
                      });
                    },
                  });
            },
          )
        ],
        backgroundColor: Colors.green,
        title: const Text('Lembur', style: TextStyle(color: Colors.white)),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔼 Filter dan Sort bar
          Row(
            children: [
              RoundedContainer(
                color: Colors.green.withOpacity(0.3),
                radius: 24,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                builder: (context) {
                  return InkWell(
                    onTap: _sortByDurasi,
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      children: [
                        Text(
                          'Durasi Lembur',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          sortByDurasi
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

          // 📋 Daftar Lembur
          Expanded(
            // --- (TAMBAHKAN PENGECEKAN LOADING & DATA KOSONG) ---
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : lemburList.isEmpty
                ? const Center(
              child: Text(
                'Belum ada riwayat Lembur.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: lemburList.length,
              itemBuilder: (context, index) {
                // Panggilan CutiCard Anda sudah benar
                return LemburCard(lemburModel: lemburList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
