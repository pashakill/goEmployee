import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  List<CutiModel> cutiList = [
    CutiModel(
      jenisCuti: 'Cuti Tahunan',
      tanggalMulai: '2025-10-20',
      tanggalSelesai: '2025-10-23',
      alasan: 'Liburan keluarga',
      dokumenUrl: '',
    ),
    CutiModel(
      jenisCuti: 'Cuti Sakit',
      tanggalMulai: '2025-09-15',
      tanggalSelesai: '2025-09-18',
      alasan: 'Sakit demam tinggi',
      dokumenUrl: 'surat_dokter.pdf',
    ),
    CutiModel(
      jenisCuti: 'Cuti Melahirkan',
      tanggalMulai: '2025-08-01',
      tanggalSelesai: '2025-09-30',
      alasan: 'Persalinan',
      dokumenUrl: '',
    ),
  ];

  bool sortByJenis = false;
  bool sortByTanggal = false;

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
              AppNavigator.to(Routes.tambahCutiPage,
                arguments: {
                  'onCutiAdded': (CutiModel newCuti) {
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
          // 🔼 Filter dan Sort bar
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

          // 📋 Daftar Cuti
          Expanded(
            child: ListView.builder(
              itemCount: cutiList.length,
              itemBuilder: (context, index) {
                return CutiCard(cuti: cutiList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
