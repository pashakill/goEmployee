import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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
  User? _currentUser;
  late IzinBloc _bloc;
  List<PengajuanData> pengajuanData = [];
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    //_loadRiwayatIzin();
    _bloc = IzinBloc(pengajuanApi: GetIt.I<PengajuanApi>());
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Panggil fungsi getSingleUser (sesuai permintaan terakhir Anda)
      final User? user = await _dbHelper.getSingleUser();
      if (user != null) {
        // Sukses! Simpan data ke state
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });

        _fetchHistory();
      } else {
        // Gagal (Tabel 'users' ternyata kosong)
        _forceLogout(); // Paksa kembali ke login
      }
    } catch (e) {
      // Error saat loading data
      print("IzinPage Erorr: $e");
      _forceLogout();
    }
  }

  void _fetchHistory() {
    if (_currentUser == null) return;
    _bloc.add(IzinFetchedEvent(
        userId: _currentUser!.id!
    ));
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

      if(!izinList.isEmpty){
        izinList.clear();
      }

      if(!pengajuanData.isEmpty){
        pengajuanData.clear();
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
                      /*
                      setState(() {
                        izinList.add(izinConverterModel);
                      });
                       */

                      _loadUserData();
                    },
                  });
            },
          )
        ],
        title: const Text('Pengajuan Izin', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: BlocConsumer<IzinBloc,
          IzinState>(
        bloc: _bloc,
        listener: (context, state) async {
          if (state is IzinPageGlobalErorr) {
            final error = state.error;

            if (error is NoInternetError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("TIdak Ada Koneksi Internet")),
              );
            } else if (error is TimeoutError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Server lambat")),
              );
            } else if (error is ServerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Server error ${error.code}")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message)),
              );
            }
            isOffline = true;

            if(mounted){
              _loadRiwayatIzin();
            }
          }

          if(state is DeleteIzinFailedState){
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Gagal Menghapus Data Izin")));
          }

          if(state is DeleteIzinSuccessState){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Berhasil Menghapus Data Izin")));

            _loadUserData();
          }

          if(state is IzinPageLoadingState){

          }

          if(state is GetDataListIzinSuccessState){
            isOffline = false;

            if(!izinList.isEmpty){
              izinList.clear();
            }

            if(!pengajuanData.isEmpty){
              pengajuanData.clear();
            }

            List<IzinConverterModel> listFromServer = state.dataCutiModel.data!.pengajuan
                .map((p) => IzinConverterModel.fromApi(p, _currentUser!.id.toString()))
                .toList();

            setState(() {
              izinList.addAll(listFromServer);
              pengajuanData.addAll(state.dataCutiModel.data!.pengajuan);
              _isLoading = false;
            });

            await DatabaseHelper.instance.replaceIzin(izinList);
          }

          if(state is IzinPageFailedState){
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat riwayat: ${state.error}')),
              );

              _loadRiwayatIzin();
            }
          }

        },
        builder: (context, state) {
          return Column(
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
                    'Belum ada riwayat Izin.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: izinList.length,
                  itemBuilder: (context, index) {
                    return isOffline ? IzinCard(izinConverter: izinList[index]) : SlidablePengajuanItem(
                      pengajuanData: pengajuanData[index],
                      onEdit: (id) {
                        AppNavigator.to(Routes.tambahIzinPage, arguments: {
                          'onIzinAdded': (IzinConverterModel izinConverterModel) {
                            _loadUserData();
                          },
                          'editIzin': izinList[index]
                        });
                      },
                      onDelete: (id) {
                        _bloc.add(DeleteIzinEvent(
                            userId: _currentUser!.id!, id: id.toString()
                        ));
                      },
                      child: IzinCard(izinConverter: izinList[index]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _forceLogout() async {
    await _dbHelper.deleteCurrentUserAndLogout();
    if (mounted) {
      AppNavigator.offAll(Routes.login);
    }
  }
}