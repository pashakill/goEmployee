import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/goemployee.dart';


class LemburPage extends StatefulWidget {
  const LemburPage({super.key});

  @override
  State<LemburPage> createState() => _LemburPageState();
}

class _LemburPageState extends State<LemburPage> {

  // List sekarang dimulai sebagai list kosong
  List<LemburModel> lemburList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isLoading = true; // State untuk loading
  late LemburBloc _bloc;
  User? _currentUser;

  bool sortByDurasi = false;
  bool sortByTanggal = false;
  List<PengajuanData> pengajuanData=[];
  bool isOffline = false;


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


  @override
  void initState() {
    super.initState();
    _bloc = LemburBloc(pengajuanApi: GetIt.I<PengajuanApi>());
    //_loadRiwayatLembur();
    _loadUserData();
  }

  Future<void> _forceLogout() async {
    await _dbHelper.deleteCurrentUserAndLogout();
    if (mounted) {
      AppNavigator.offAll(Routes.login);
    }
  }

  /// Mengambil data lembur dari database
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

      if(!lemburList.isEmpty){
        lemburList.clear();
      }

      if(!pengajuanData.isEmpty){
        pengajuanData.clear();
      }

      // 2. Ambil riwayat lembur berdasarkan ID user
      final List<LemburModel> riwayatLembur = await _dbHelper.getRiwayatLembur(currentUser.id!);

      // 3. Update UI dengan data baru
      setState(() {
        lemburList = riwayatLembur;
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
    _bloc.add(LemburFetchedEvent(
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
            onPressed: () async {
              final result = await Get.toNamed(Routes.tambahLemburPage);
              if (result == true) {
                _loadUserData();
              }
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
      body: BlocConsumer<LemburBloc, LemburState>(
        bloc: _bloc,
        listener: (context, state) async {
          if (state is LemburPageGlobalErorr) {
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
              _loadRiwayatLembur();
            }
          }

          if(state is DeleteLemburFailedState){
            ErrorBottomSheet.show(
              context,
              message: "Gagal Menghapus Data Lembur",
            );
            LoadingDialog.hide(context);
          }

          if(state is DeleteLemburSuccessState){
            LoadingDialog.hide(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Berhasil Menghapus Data Lembur")));

            _loadUserData();
          }

          if(state is LemburPageLoadingState){
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if(state is GetDataListLemburiSuccessState){
            isOffline = false;

            if(!lemburList.isEmpty){
              lemburList.clear();
            }

            if(!pengajuanData.isEmpty){
              pengajuanData.clear();
            }

            List<LemburModel> listFromServer = state.dataCutiModel.data!.pengajuan
                .map((p) => LemburModel.fromApi(p, _currentUser!.id.toString()))
                .toList();

            setState(() {
              lemburList.addAll(listFromServer);
              pengajuanData.addAll(state.dataCutiModel.data!.pengajuan);
              _isLoading = false;
            });

            await DatabaseHelper.instance.replaceLembur(lemburList);
            LoadingDialog.hide(context);
          }

          if(state is LemburPageFailedState){
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat riwayat: ${state.error}')),
              );

              _loadRiwayatLembur();
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

              // 📋 Daftar Lembur
              Expanded(
                // --- (TAMBAHKAN PENGECEKAN LOADING & DATA KOSONG) ---
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : lemburList.isEmpty
                    ? const Center(
                  child: Text(
                    'Belum ada riwayat Lembur.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : RefreshIndicator(child:
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: lemburList.length,
                  itemBuilder: (context, index) {
                    // Panggilan CutiCard Anda sudah benar
                    return isOffline ? LemburCard(lemburModel: lemburList[index]) : SlidablePengajuanItem(
                      pengajuanData: pengajuanData[index],
                      onEdit: (id) {
                        AppNavigator.to(Routes.tambahLemburPage, arguments: {
                          'onLemburAdded': () {
                            _loadUserData();
                          },
                          'editLembur': lemburList[index]
                        });
                      },
                      onDelete: (id) {
                        _bloc.add(DeleteLemburEvent(
                            userId: _currentUser!.id!, pengajuanId: id.toString()
                        ));
                      },
                      child: LemburCard(lemburModel: lemburList[index]),
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
