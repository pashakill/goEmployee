import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/slip_gaji/bloc/slip_gaji_bloc.dart';
import '../widget/hr_slip_gaji_panel.dart';
import 'model/data_slip_gaji_models.dart';

class SlipGajiPage extends StatefulWidget {
  const SlipGajiPage({super.key});

  @override
  State<SlipGajiPage> createState() => _SlipGajiPageState();
}

class _SlipGajiPageState extends State<SlipGajiPage> {
  List<DataSlipGajiModels> list = [];

  late SlipGajiBloc _bloc;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  User? _currentUser;

  bool _isLoading = true;

  /// 🔥 USER LIST (API)
  List<UserModel> users = [];
  UserModel? selectedUser;

  @override
  void initState() {
    super.initState();
    _bloc = SlipGajiBloc(slipGajiApi: GetIt.I<SlipGajiApi>());
    _loadUserData();
    _bloc.add(FetchUserEvent());
  }

  /// ================= LOAD USER =================
  Future<void> _loadUserData() async {
    final user = await _dbHelper.getSingleUser();

    if (user != null) {
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });

      _fetchHistory();
    }
  }

  /// ================= FETCH DATA =================
  void _fetchHistory() {
    if (_currentUser == null) return;

    _bloc.add(
      SlipGajiFetchedEvent(userId: _currentUser!.id!),
    );
  }

  /// ================= UPLOAD =================
  Future<void> _uploadSlip() async {
    if (_currentUser?.role != 'hrd') return;

    if (selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih karyawan dulu")),
      );
      return;
    }

    final file = await CameraHelper.pickFromCamera();

    if (file == null) return;

    final now = DateTime.now();

    _bloc.add(
      UploadSlipGajiEvent(
        userId: selectedUser!.id, // 🔥 dari dropdown
        bulan: DateHelper.getMonthName(now.month),
        tahun: now.year.toString(),
        fileBase64: file,
      ),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isHRD = _currentUser?.role == 'hrd';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Slip Gaji', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => AppNavigator.back(),
        ),
      ),

      body: BlocConsumer<SlipGajiBloc, SlipGajiState>(
        bloc: _bloc,
        listener: (context, state) {
          /// ERROR
          if (state is SlipGajiPageGlobalErorr) {
            LoadingDialog.hide(context);
            ErrorBottomSheet.show(
              context,
              message: state.error.message,
            );
          }

          /// 🔥 GET USER SUCCESS
          if (state is FetchUserSuccessState) {
            setState(() {
              users = state.userModel;
            });
          }

          /// LOADING
          if (state is SlipGajiPageLoadingState) {
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          /// LIST
          if (state is GetDataListSlipGajiSuccessState) {
            print('CALL GetDataListSlipGajiSuccessState');
            list.clear();

            final data = state.slipGajiResponseModel.data;

            if (data.isNotEmpty) {
              list.addAll(data);
            }

            setState(() {
              _isLoading = false;
            });

            LoadingDialog.hide(context);
          }

          /// UPLOAD SUCCESS
          if (state is UploadSlipGajiSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Upload berhasil")),
            );

            LoadingDialog.hide(context);
            _fetchHistory();
          }

          /// FAILED
          if (state is SlipGajiPageFailedState) {
            LoadingDialog.hide(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },

        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (isHRD)
                HrSlipGajiPanel(
                  isHRD: isHRD,
                  users: users,
                  selectedUser: selectedUser,
                  onUserChanged: (val) {
                    setState(() {
                      selectedUser = val;
                    });
                  },
                  onUpload: _uploadSlip,
                ),

              /// LIST
              Expanded(
                child: list.isEmpty
                    ? const Center(
                  child: Text(
                    'Belum ada slip gaji',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () async => _fetchHistory(),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// HEADER
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                "${item.bulan} ${item.tahun}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            /// IMAGE
                            ClipRRect(
                              borderRadius:
                              const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                              child: Image.memory(
                                base64Decode(item.file),
                                fit: BoxFit.cover,
                              )
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}