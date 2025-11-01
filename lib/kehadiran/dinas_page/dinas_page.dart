import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/widget/dinas_card.dart';
import 'package:goemployee/kehadiran/widget/lembur_card.dart';

class DinasPage extends StatefulWidget {
  const DinasPage({super.key});

  @override
  State<DinasPage> createState() => _DinasPageState();
}

class _DinasPageState extends State<DinasPage> {

  List<DinasModel> dinasList = [
    DinasModel(
      tanggalMulai : '2025-10-20',
      tanggalSelesai : '2025-10-20',
      alamat : 'Jl.Cendrawasih No.25',
      latitude : '1231231312-12',
      longTitude: '202012823918923',
      radius: '2',
      alasan: 'Pengen aja',
    ),
    DinasModel(
      tanggalMulai : '2025-10-20',
      tanggalSelesai : '2025-10-20',
      alamat : 'Jl.Cendrawasih No.25',
      latitude : '1231231312-12',
      longTitude: '202012823918923',
      radius: '2',
      alasan: 'Pengen aja',
    ),
    DinasModel(
      tanggalMulai : '2025-10-20',
      tanggalSelesai : '2025-10-20',
      alamat : 'Jl.Cendrawasih No.25',
      latitude : '1231231312-12',
      longTitude: '202012823918923',
      radius: '2',
      alasan: 'Pengen aja',
    ),
  ];

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
        children: [
          // 🔼 Filter dan Sort bar
          Row(
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
          ),

          const Divider(),

          // 📋 Daftar Cuti
          Expanded(
            child: ListView.builder(
              itemCount: dinasList.length,
              itemBuilder: (context, index) {
                return DinasCard(dinasModel: dinasList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
