import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/goemployee.dart';

class WfhPage extends StatefulWidget {
  const WfhPage({super.key});

  @override
  State<WfhPage> createState() => _WfhPageState();
}

class _WfhPageState extends State<WfhPage> {

  List<WfhModel> wfhList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true;

  bool sortByDurasi = false;
  bool sortByTanggal = false;
  User? _currentUser;
  late WfhBloc _bloc;
  List<PengajuanData> pengajuanData = [];
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _bloc = WfhBloc(pengajuanApi: GetIt.I<PengajuanApi>());
    _loadUserData();
    //_loadRiwayatLembur();
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
    _bloc.add(WfhFetchedEvent(
        userId: _currentUser!.id!
    ));
  }

  Future<void> _loadRiwayatWfh() async {
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
                    'onWfhAdded': () {
                      /*
                       setState(() {
                        wfhList.add();
                      });
                       */
                      _loadUserData();
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
      body: BlocConsumer<WfhBloc,
          WfhState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is WfhPageGlobalErorr) {
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
              _loadRiwayatWfh();
            }
          }

          if(state is DeleteWfhFailedState){
            LoadingDialog.hide(context);

            ErrorBottomSheet.show(
              context,
              message: "Gagal Menghapus Data Wfh",
            );
          }

          if(state is DeleteWfhSuccessState){
            LoadingDialog.hide(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Berhasil Menghapus Data Wfh")));

            _loadUserData();
          }

          if(state is WfhPageLoadingState){
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if(state is GetDataListWfhSuccessState){
            isOffline = false;

            List<WfhModel> listFromServer = state.dataCutiModel.data!.pengajuan
                .map((p) => WfhModel.fromApi(p, _currentUser!.id.toString()))
                .toList();

            setState(() {
              wfhList.addAll(listFromServer);
              pengajuanData.addAll(state.dataCutiModel.data!.pengajuan);
              _isLoading = false;
            });

            LoadingDialog.hide(context);
          }

          if(state is WfhPageFailedState){
            if (mounted) {
              LoadingDialog.hide(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat riwayat: ${state.error}')),
              );

              _loadRiwayatWfh();
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
                    : RefreshIndicator(child:
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: wfhList.length,
                  itemBuilder: (context, index) {
                    return isOffline ? WfhCard(wfhModel: wfhList[index]) : SlidablePengajuanItem(
                      pengajuanData: pengajuanData[index],
                      onEdit: (id) {
                        AppNavigator.to(Routes.tambahWfh, arguments: {
                          'onWfhAdded': () {
                            _loadUserData();
                          },
                          'editWfh': wfhList[index]
                        });
                      },
                      onDelete: (id) {
                        _bloc.add(DeleteWfhEvent(
                            userId: _currentUser!.id!, id: id.toString()
                        ));
                      },
                      child: WfhCard(wfhModel: wfhList[index]),
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

  Future<void> _forceLogout() async {
    await _dbHelper.deleteCurrentUserAndLogout();
    if (mounted) {
      AppNavigator.offAll(Routes.login);
    }
  }
}
