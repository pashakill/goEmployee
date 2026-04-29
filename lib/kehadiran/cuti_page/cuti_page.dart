import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/goemployee.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  // List sekarang dimulai sebagai list kosong
  List<CutiModel> cutiList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true; // State untuk loading
  User? _currentUser;
  List<PengajuanData> pengajuanData = [];
  bool sortByJenis = false;
  bool sortByTanggal = false;
  late CutiBloc _bloc;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _bloc = CutiBloc(pengajuanApi: GetIt.I<PengajuanApi>());
    _loadUserData();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
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
      _forceLogout();
    }
  }


  void simpan(){
    /*

    final List<dynamic> pengajuanList = response['data']['pengajuan'];

        // Parsing semua pengajuan
        final List<PengajuanData> daftarPengajuan = pengajuanList
            .map((item) => PengajuanData.fromJson(item))
            .toList();

        // Filter hanya kategori cuti
        final List<PengajuanData> cutiList =
        daftarPengajuan.where((p) => p.kategori == 'cuti').toList();

     */
  }

  void _fetchHistory() {
    if (_currentUser == null) return;
    _bloc.add(CutiFetchedEvent(
        userId: _currentUser!.id!
    ),
    );
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

      if(!cutiList.isEmpty){
        cutiList.clear();
      }

      if(!pengajuanData.isEmpty){
        pengajuanData.clear();
      }

      // 2. Ambil riwayat cuti berdasarkan ID user
      final List<CutiModel> riwayat = await _dbHelper.getRiwayatCuti(currentUser.id!);
      if(riwayat.isEmpty){
        setState(() {
          cutiList = [];
          _isLoading = false;
        });
      }else{
        // 3. Update UI dengan data baru
        setState(() {
          cutiList = riwayat;
          _isLoading = false;
        });
      }
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
                'onCutiAdded': () {
                  // Ini akan menambah CutiModel baru ke list secara instan
                  // (tanpa perlu load ulang dari DB, UI terasa cepat)
                  /*
                  setState(() {
                    cutiList.add(newCuti);
                  });

                   */
                  _loadUserData();
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
      body: BlocConsumer<CutiBloc,
          CutiState>(
        bloc: _bloc,
        listener: (context, state) async {
          if (state is CutiPageGlobalErorr) {
            LoadingDialog.hide(context);
            final error = state.error;

            if (error is NoInternetError) {
              ErrorBottomSheet.show(
                context,
                message: "Tidak Ada Koneksi Internet",
              );
            } else if (error is TimeoutError) {
              ErrorBottomSheet.show(
                context,
                message: "Server Lambat",
              );
            } else if (error is ServerError) {
              ErrorBottomSheet.show(
                context,
                message: "Server error ${error.code}",
              );
            } else {
              ErrorBottomSheet.show(
                context,
                message: "${error.message}",
              );
            }
            isOffline = true;

            if(mounted){
              _loadRiwayatCuti();
            }
            LoadingDialog.hide(context);
          }

          if(state is CutiPageLoadingState){
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if(state is DeleteCutiSuccessState){
            LoadingDialog.hide(context);

            ErrorBottomSheet.show(
              context,
              message: "Gagal Menghapus Data Cuti",
            );

            _loadUserData();
          }

          if(state is DeleteCutiFailedState){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Gagal Menghapus Data Cuti")),
            );
            LoadingDialog.hide(context);
          }

          if(state is GetDataListCutiSuccessState){
            isOffline = false;

            if(!cutiList.isEmpty){
              cutiList.clear();
            }

            if(!pengajuanData.isEmpty){
              pengajuanData.clear();
            }

            List<CutiModel> listFromServer = state.dataCutiModel.data!.pengajuan
                .map((p) => CutiModel.fromApi(p, _currentUser!.id.toString()))
                .toList();

            if(listFromServer.isEmpty){
              cutiList.clear();
              pengajuanData.clear();
            }

            setState(() {
              cutiList.addAll(listFromServer);
              pengajuanData.addAll(state.dataCutiModel.data!.pengajuan);
              _isLoading = false;
            });

            await DatabaseHelper.instance.replaceCuti(cutiList, _currentUser!.id!);
            LoadingDialog.hide(context);
          }

          if(state is CutiPageFailedState){
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat riwayat: ${state.error}')),
              );

              _loadRiwayatCuti();
              LoadingDialog.hide(context);
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
                    : RefreshIndicator(child:
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: cutiList.length,
                  itemBuilder: (context, index) {
                    // Panggilan CutiCard Anda sudah benar
                    return isOffline ? CutiCard(cuti: cutiList[index]) : SlidablePengajuanItem(
                      pengajuanData: pengajuanData[index],
                      onEdit: (id) {
                        AppNavigator.to(Routes.tambahCutiPage, arguments: {
                          'onCutiAdded': () {
                            _loadUserData();
                          },
                          'editCuti': cutiList[index]
                        });
                      },
                      onDelete: (id) {
                        _bloc.add(DeleteCutiEvent(
                            userId: _currentUser!.id!, id: id.toString()
                        ));
                      },
                      child: CutiCard(cuti: cutiList[index]),
                    );
                  },
                ), onRefresh: () async {
                  _loadUserData();
                }),
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