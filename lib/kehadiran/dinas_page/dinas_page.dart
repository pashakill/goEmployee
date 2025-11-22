import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class DinasPage extends StatefulWidget {
  const DinasPage({super.key});

  @override
  State<DinasPage> createState() => _DinasPageState();
}

class _DinasPageState extends State<DinasPage> {

  List<DinasModel> dinasList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true; // State untuk loading

  bool sortByTanggal = false;

  void _sortByTanggal() {
    setState(() {
      sortByTanggal = !sortByTanggal;
      dinasList.sort((a, b) {
        final dateA = DateTime.parse(a.tanggalMulai);
        final dateB = DateTime.parse(b.tanggalSelesai);
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
      final List<DinasModel> riwayatLembur = await _dbHelper.getRiwayatDinas(currentUser.id!);

      // 3. Update UI dengan data baru
      setState(() {
        dinasList = riwayatLembur;
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
              AppNavigator.to(Routes.tambahDinasPage,
                  arguments: {
                    'onCutiAdded': (DinasModel dinasModel) {
                      setState(() {
                        dinasList.add(dinasModel);
                      });
                    },
                  });
            },
          )
        ],
        backgroundColor: Colors.green,
        title: const Text('Dinas', style: TextStyle(color: Colors.white)),
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
          // 🔼 Filter dan Sort bar
          Padding(padding: EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            children: [
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
          )),

          Expanded(
            // --- (TAMBAHKAN PENGECEKAN LOADING & DATA KOSONG) ---
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : dinasList.isEmpty
                ? const Center(
              child: Text(
                'Belum ada riwayat Dinas.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: dinasList.length,
              itemBuilder: (context, index) {
                // Panggilan CutiCard Anda sudah benar
                return DinasCard(dinasModel: dinasList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
