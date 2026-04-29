import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/widget/presensi_backdate_card.dart';


class PresensiBackdatePage extends StatefulWidget {
  const PresensiBackdatePage({super.key});

  @override
  State<PresensiBackdatePage> createState() => _PresensiBackdatePageState();
}

class _PresensiBackdatePageState extends State<PresensiBackdatePage> {

  // List sekarang dimulai sebagai list kosong
  List<PresensiBackdateModel> presensiList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true; // State untuk loading
  late PresensiBackdateBloc _bloc;
  User? _currentUser;

  bool sortByDurasi = false;
  bool sortByTanggal = false;
  List<PengajuanData> pengajuanData=[];
  bool isOffline = false;

  void _sortByTanggal() {
    setState(() {
      sortByTanggal = !sortByTanggal;
      presensiList.sort((a, b) {
        final dateA = a.tanggal;
        final dateB = a.tanggal;
        return sortByTanggal
            ? dateA.compareTo(dateB)
            : dateB.compareTo(dateA);
      });
    });
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
      print("BackdatePage Erorr: $e");
      _forceLogout();
    }
  }


  @override
  void initState() {
    super.initState();
    _bloc = PresensiBackdateBloc(pengajuanApi: GetIt.I<PengajuanApi>());
    //_loadRiwayatLembur();
    _loadUserData();
  }

  Future<void> _forceLogout() async {
    await _dbHelper.deleteCurrentUserAndLogout();
    if (mounted) {
      AppNavigator.offAll(Routes.login);
    }
  }

  /// Mengambil data Presensi Backdate dari database
  Future<void> _loadRiwayatBackdate() async {
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

      if(!presensiList.isEmpty){
        presensiList.clear();
      }

      if(!pengajuanData.isEmpty){
        pengajuanData.clear();
      }

      // 2. Ambil riwayat Presensi Backdate berdasarkan ID user
      final List<PresensiBackdateModel> presensiBackdateModel = await _dbHelper.getPresensiBackdate(currentUser.id!);

      // 3. Update UI dengan data baru
      setState(() {
        presensiList = presensiBackdateModel;
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

  void _fetchHistory() {
    if (_currentUser == null) return;
    _bloc.add(PresensiBackdateFetchedEvent(
        userId: _currentUser!.id!
    ),
    );
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
              AppNavigator.to(Routes.tambahPresensiBackdatePage,
                  arguments: {
                    'onPresensiBackdateAdded': () {
                      /*
                      setState(() {
                        lemburList.add(lemburModel);
                      });
                       */
                      _loadUserData();
                    },
                  });
            },
          )
        ],
        backgroundColor: Colors.green,
        title: const Text('Backdate Presensi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            AppNavigator.back();
          },
        ),
      ),
      body: BlocConsumer<PresensiBackdateBloc, PresensiBackdateState>(
        bloc: _bloc,
        listener: (context, state) async {
          if (state is PresensiBackdatePageGlobalErorr) {
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
              _loadRiwayatBackdate();
            }
          }

          if(state is DeletePresensiBackdateFailedState){
            ErrorBottomSheet.show(
              context,
              message: "Gagal Menghapus Data Presensi Backdate",
            );
            LoadingDialog.hide(context);
          }

          if(state is DeletePresensiBackdateSuccessState){
            LoadingDialog.hide(context);

            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Berhasil Menghapus Data Presensi Backdate")));

            _loadUserData();
          }

          if(state is PresensiBackdatePageLoadingState){
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if(state is GetDataListPresensiBackdateSuccessState){
            isOffline = false;

            if(!presensiList.isEmpty){
              presensiList.clear();
            }

            if(!pengajuanData.isEmpty){
              pengajuanData.clear();
            }

            List<PresensiBackdateModel> listFromServer = state.dataCutiModel.data!.pengajuan
                .map((p) => PresensiBackdateModel.fromApi(p, _currentUser!.id.toString()))
                .toList();

            setState(() {
              presensiList.addAll(listFromServer);
              pengajuanData.addAll(state.dataCutiModel.data!.pengajuan);
              _isLoading = false;
            });

            await DatabaseHelper.instance.replacePresensiBackdate(presensiList);
            LoadingDialog.hide(context);
          }

          if(state is PresensiBackdatePageFailedState){
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat riwayat: ${state.error}')),
              );

              _loadRiwayatBackdate();
              LoadingDialog.hide(context);
            }
          }

        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

              // 📋 Daftar Presensi Backdate
              Expanded(
                  // --- (TAMBAHKAN PENGECEKAN LOADING & DATA KOSONG) ---
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : presensiList.isEmpty
                      ? const Center(
                    child: Text(
                      'Belum ada riwayat Presensi Backdate.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                      : RefreshIndicator(child:
                  ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: presensiList.length,
                    itemBuilder: (context, index) {
                      // Panggilan CutiCard Anda sudah benar
                      return isOffline ? PresensiBackdateCard(presensiBackdateModel: presensiList[index]) : SlidablePengajuanItem(
                        pengajuanData: pengajuanData[index],
                        onEdit: (id) {
                          AppNavigator.to(Routes.tambahPresensiBackdatePage, arguments: {
                            'onPresensiBackdateAdded': () {
                              _loadUserData();
                            },
                            'editBackdate': presensiList[index]
                          });
                        },
                        onDelete: (id) {
                          _bloc.add(DeletePresensiBackdateEvent(userId: _currentUser!.id!, pengajuanId: id
                          ));
                        },
                        child: PresensiBackdateCard(presensiBackdateModel: presensiList[index]),
                      );
                    },
                  ), onRefresh: () async {
                    _loadUserData();
                  })
              ),
            ],
          );
        },
      ),
    );
  }
}
