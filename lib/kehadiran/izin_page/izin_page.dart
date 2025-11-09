import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class IzinPage extends StatefulWidget {
  const IzinPage({super.key});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage> {
  List<IzinConverterModel> izinList = [
    IzinConverterModel(
        id: "123",
        tipe: IzinTipe.telatMasuk,
        status: IzinStatus.approved,
        tanggal: DateTime.parse("2025-11-10T00:00:00Z"),
        jam: DateTime.parse("2025-11-10T09:30:00Z"), // Jam 9:30
        alasan: "Ada urusan keluarga sebentar di pagi hari."
    ),
    IzinConverterModel(
        id: "124",
        tipe: IzinTipe.tidakMasuk,
        status: IzinStatus.pending,
        tanggal: DateTime.parse("2025-11-09T00:00:00Z"),
        jam: null,
        alasan: "Sakit demam, surat dokter menyusul."
    ),
    IzinConverterModel(
        id: "125",
        tipe: IzinTipe.pulangAwal,
        status: IzinStatus.rejected,
        tanggal: DateTime.parse("2025-11-08T00:00:00Z"),
        jam: DateTime.parse("2025-11-08T15:00:00Z"),
        alasan: "Ingin menonton film."
    ),
  ];

  @override
  void initState() {
    super.initState();
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
              child: Padding(padding: EdgeInsets.only(left: 16.0, right: 16.0),
                  child: ListView.builder(
                    itemCount: izinList.length,
                    itemBuilder: (context, index) {
                      return IzinCard(izinConverter: izinList[index]);
                    },
                  )
              )
          ),
        ],
      )
    );
  }
}