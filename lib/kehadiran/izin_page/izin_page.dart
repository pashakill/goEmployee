import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({super.key});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  List<IzinConverterModel> izinList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true; // State untuk loading

  @override
  void initState() {
    super.initState();
    _loadRiwayatIzin();
  }

  Future<void> _loadRiwayatIzin() async {
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
      final List<IzinConverterModel> riwayatIzin = await _dbHelper.getRiwayatIzin(currentUser.id!);

      // 3. Update UI dengan data baru
      setState(() {
        izinList = riwayatIzin;
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

  bool sortByJenis = false;
  bool sortByTanggal = false;

  void _sortByJenis() {
    setState(() {
      sortByJenis = !sortByJenis;
      izinList.sort((a, b) => sortByJenis
          ? a.tipe.toString().compareTo(b.tipe.toString())
          : b.tipe.toString().compareTo(a.tipe.toString()));
    });
  }

  void _sortByTanggal() {
    setState(() {
      sortByTanggal = !sortByTanggal;
      izinList.sort((a, b) {
        final dateA = DateTime.parse(a.tanggal.toIso8601String());
        final dateB = DateTime.parse(b.tanggal.toIso8601String());
        return sortByTanggal
            ? dateA.compareTo(dateB)
            : dateB.compareTo(dateA);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            AppNavigator.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            color: Colors.white,
            onPressed: () {
              AppNavigator.to(Routes.tambahIzinPage,
                  arguments: {
                    'onIzinAdded': (IzinConverterModel izinConverterModel) {
                      setState(() {
                        izinList.add(izinConverterModel);
                      });
                      print('berhasil di tambahkan');
                    },
                  });
            },
          )
        ],
        title: const Text('Pengajuan Izin', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Row(
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
          Expanded(
            // --- (TAMBAHKAN PENGECEKAN LOADING & DATA KOSONG) ---
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : izinList.isEmpty
                ? const Center(
              child: Text(
                'Belum ada riwayat Dinas.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: izinList.length,
              itemBuilder: (context, index) {
                // Panggilan CutiCard Anda sudah benar
                return IzinCard(izinConverter: izinList[index]);
              },
            ),
          ),
        ],
      )
    );
  }
}