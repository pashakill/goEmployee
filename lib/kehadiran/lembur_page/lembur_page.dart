import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/widget/lembur_card.dart';

class LemburPage extends StatefulWidget {
  const LemburPage({super.key});

  @override
  State<LemburPage> createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {

  List<LemburModel> lemburList = [
    LemburModel(
      lamaLembur: '1',
      catatanLembur: 'Melakukan migrasi aplikasi A',
      waktuMulai: '2025-10-20 17:00',
      waktuSelesai: '2025-10-20 18:00',
    ),
    LemburModel(
      lamaLembur: '2',
      catatanLembur: 'Menyelesaikan data-data KPI',
      waktuMulai: '2025-10-22 17:00',
      waktuSelesai: '2025-10-22 19:20',
    ),
    LemburModel(
      lamaLembur: '3',
      catatanLembur: 'Membuat Laporan Bulanan',
      waktuMulai: '2025-10-21 17:00',
      waktuSelesai: '2025-10-21 19:00',
    ),
  ];

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

          // 📋 Daftar Cuti
          Expanded(
            child: ListView.builder(
              itemCount: lemburList.length,
              itemBuilder: (context, index) {
                return LemburCard(lemburModel: lemburList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
