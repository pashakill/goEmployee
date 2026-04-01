import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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
  late DinasBloc _bloc;
  User? _currentUser;
  bool sortByTanggal = false;
  List<PengajuanData> pengajuanData = [];
  bool isOffline = false;

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
    _bloc = DinasBloc(pengajuanApi: GetIt.I<PengajuanApi>());
    //_loadRiwayatLembur();
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
      print("CutiPage Erorr: $e");
      _forceLogout();
    }
  }

  void _fetchHistory() {
    if (_currentUser == null) return;
    _bloc.add(DinasFetchedEvent(
        userId: _currentUser!.id!
    ),
    );
  }

  /// Mengambil data lembur dari database
  Future<void> _loadRiwayatDinas() async {
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

      if(!dinasList.isEmpty){
        dinasList.clear();
      }

      if(!pengajuanData.isEmpty){
        pengajuanData.clear();
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
                    'onDinasAdded': () {
                      /*
                      setState(() {
                        dinasList.add(dinasModel);
                      });
                       */
                      _loadUserData();
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
      body: BlocConsumer<DinasBloc,
          DinasState>(
        bloc: _bloc,
        listener: (context, state) async {
          if (state is DinasPageGlobalErorr) {
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
              _loadRiwayatDinas();
            }

            LoadingDialog.hide(context);
          }

          if(state is DeleteDinasSuccessState){
            LoadingDialog.hide(context);

            ErrorBottomSheet.show(
              context,
              message: "Gagal Menghapus Data Dinas",
            );

            _loadUserData();
          }

          if(state is DeleteDinasFailedState){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Gagal Menghapus Data Dinas")),
            );

            LoadingDialog.hide(context);
          }

          if(state is DinasPageLoadingState){
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if(state is GetDataListDinasSuccessState){
            isOffline = false;
            if(!dinasList.isEmpty){
              dinasList.clear();
            }

            if(!pengajuanData.isEmpty){
              pengajuanData.clear();
            }

            List<DinasModel> listFromServer = state.dataCutiModel.data!.pengajuan
                .map((p) => DinasModel.fromApi(p, _currentUser!.id.toString()))
                .toList();

            setState(() {
              dinasList.addAll(listFromServer);
              pengajuanData.addAll(state.dataCutiModel.data!.pengajuan);
              _isLoading = false;
            });

            await DatabaseHelper.instance.replaceDinas(dinasList);
            LoadingDialog.hide(context);
          }

          if(state is DinasPageFailedState){
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat riwayat: ${state.error}')),
              );

              _loadRiwayatDinas();
              LoadingDialog.hide(context);
            }
          }

        },
        builder: (context, state) {
          return Column(
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
                    : RefreshIndicator( child:
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: dinasList.length,
                  itemBuilder: (context, index) {
                    // Panggilan CutiCard Anda sudah benar
                    return isOffline? DinasCard(dinasModel: dinasList[index]) : SlidablePengajuanItem(
                      pengajuanData: pengajuanData[index],
                      onEdit: (id) {
                        AppNavigator.to(Routes.tambahDinasPage, arguments: {
                          'onDinasAdded': () {
                            _loadUserData();
                          },
                          'editDinas': dinasList[index]
                        });
                      },
                      onDelete: (id) {
                        _bloc.add(DeleteDinasEvent(
                            userId: _currentUser!.id!, id: id
                        ));
                      },
                      child: DinasCard(dinasModel: dinasList[index]),
                    );
                  },
                ), onRefresh: () async{
                      _loadUserData();
                })
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
