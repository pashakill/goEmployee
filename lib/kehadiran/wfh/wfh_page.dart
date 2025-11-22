import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/widget/lembur_card.dart';

class WfhPage extends StatefulWidget {
  const WfhPage({super.key});

  @override
  State<WfhPage> createState() => _WfhPageState();
}

class _WfhPageState extends State<WfhPage> {

  List<WfhModel> wfhList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true; // State untuk loading

  bool sortByDurasi = false;
  bool sortByTanggal = false;


  @override
  void initState() {
    super.initState();
    _loadRiwayatLembur();
  }

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
      final List<WfhModel> riwayatWfh = await _dbHelper.getRiwayatWfh(currentUser.id!);

      // 3. Update UI dengan data baru
      setState(() {
        wfhList = riwayatWfh;
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

  void _sortByDurasi() {
    setState(() {
      sortByDurasi = !sortByDurasi;
      wfhList.sort((a, b) => sortByDurasi
          ? a.lamaWfh.compareTo(b.lamaWfh)
          : b.lamaWfh.compareTo(a.lamaWfh));
    });
  }

  void _sortByTanggal() {
    setState(() {
      sortByTanggal = !sortByTanggal;
      wfhList.sort((a, b) {
        final dateA = DateTime.parse(a.waktuMulai);
        final dateB = DateTime.parse(b.waktuMulai);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            color: Colors.white,
            onPressed: () {
              AppNavigator.to(Routes.tambahWfh,
                  arguments: {
                    'onWfhAdded': (WfhModel wfhModel) {
                      setState(() {
                        wfhList.add(wfhModel);
                      });
                    },
                  });
            },
          )
        ],
        backgroundColor: Colors.green,
        title: const Text('WFH', style: TextStyle(color: Colors.white)),
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
                          'Durasi Wfh',
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

          Expanded(
            // --- (TAMBAHKAN PENGECEKAN LOADING & DATA KOSONG) ---
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : wfhList.isEmpty
                ? const Center(
              child: Text(
                'Belum ada riwayat Wfh.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: wfhList.length,
              itemBuilder: (context, index) {
                // Panggilan CutiCard Anda sudah benar
                return WfhCard(wfhModel: wfhList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
