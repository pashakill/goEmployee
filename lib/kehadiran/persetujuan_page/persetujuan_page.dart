import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/goemployee.dart';

import 'package:goemployee/kehadiran/persetujuan_page/api/api.dart';
import 'package:goemployee/kehadiran/persetujuan_page/bloc/bloc.dart';

import '../../common_module/helper/database_helper.dart';
import '../../common_module/helper/routes.dart';
import '../../user/user_view/auth/model/user_model.dart';
import '../model/cuti_model.dart';
import '../model/dinas_model.dart';
import '../model/izin_converter_model.dart';
import '../model/lembur_model.dart';
import '../widget/cuti_card.dart';
import '../widget/dinas_card.dart';
import '../widget/izin_card.dart';
import '../widget/lembur_card.dart';

class PersetujuanPage extends StatefulWidget {
  const PersetujuanPage({super.key});

  @override
  State<PersetujuanPage> createState() => _PersetujuanPageState();
}

class _PersetujuanPageState extends State<PersetujuanPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<PengajuanData> persetujuanData = [];

  bool _isLoading = true;
  User? _currentUser;

  late PersetujuanBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PersetujuanBloc(
      persetujuanApi: GetIt.I<PersetujuanApi>(),
    );
    _loadUser();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  /// =========================
  /// LOAD USER
  /// =========================
  Future<void> _loadUser() async {
    try {
      final user = await _dbHelper.getSingleUser();

      if (user != null) {
        setState(() {
          _currentUser = user;
        });

        _fetchData();
      }
    } catch (e) {
      print("ERROR LOAD USER: $e");
    }
  }

  /// =========================
  /// FETCH DATA API
  /// =========================
  void _fetchData() {
    if (_currentUser == null) return;

    _bloc.add(
      PersetujuanFetchedEvent(
        userId: _currentUser!.id!,
        divisiId: _currentUser!.division ?? '',
        role: _currentUser!.role ?? '',
      ),
    );
  }

  /// =========================
  /// FINAL STATUS
  /// =========================
  String getFinalStatus(PengajuanData data) {
    final manager = data.status_manager;
    final hrd = data.status_hrd;

    if (manager == 'reject' || hrd == 'reject') {
      return 'REJECTED';
    }

    if (manager == 'approve' && hrd == 'approve') {
      return 'APPROVED';
    }

    return 'PENDING';
  }

  /// =========================
  /// STATUS CHIP
  /// =========================
  Widget statusChip(String label, String status) {
    Color color;

    switch (status) {
      case 'approve':
        color = Colors.green;
        break;
      case 'reject':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text("$label: $status"),
      backgroundColor: color.withOpacity(0.2),
    );
  }

  /// =========================
  /// STATUS CHIPS LOGIC
  /// =========================
  List<Widget> _buildStatusChips(PengajuanData data) {
    final role = _currentUser?.role;
    final myName = _currentUser?.nama;

    List<Widget> chips = [];

    if (role == 'manager') {
      /// Manager lihat pengajuan sendiri → hanya HRD
      if (data.user.toString() == myName) {
        chips.add(statusChip("HRD", data.status_hrd));
        return chips;
      }
    }

    /// Default semua lihat 2 status
    chips.add(statusChip("Manager", data.status_manager));
    chips.add(const SizedBox(width: 8));
    chips.add(statusChip("HRD", data.status_hrd));

    return chips;
  }

  /// =========================
  /// ACTION BUTTON
  /// =========================
  Widget actionButton(PengajuanData data) {
    final role = _currentUser?.role;
    final division = _currentUser?.division?.toUpperCase();
    final myName = _currentUser?.nama;

    /// ❌ Karyawan tidak bisa approve
    if (role == 'karyawan') return const SizedBox();

    /// =========================
    /// 🔥 HRD (BERDASARKAN DIVISI)
    /// =========================
    if (division == 'HRD') {
      if (data.status_hrd == 'approve' || data.status_hrd == 'reject') {
        return const SizedBox();
      }

      return _buildButtonRow(data, 'hrd');
    }

    /// =========================
    /// 👨‍💼 MANAGER
    /// =========================

    /// ❌ Pengajuan sendiri
    if (role == 'manager' && data.user == myName) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "Menunggu persetujuan HRD",
          style: TextStyle(color: Colors.orange),
        ),
      );
    }

    /// ❌ Sudah diproses manager
    if (data.status_manager == 'approve' || data.status_manager == 'reject') {
      return const SizedBox();
    }

    return _buildButtonRow(data, 'manager');
  }

  /// BUTTON ROW (REUSABLE)
  Widget _buildButtonRow(PengajuanData data, String role) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              _bloc.add(
                ApprovePersetujuanEvent(
                  userId: data.id,
                  role: role,
                  divisiId: _currentUser?.division,
                  actions: 'approve',
                ),
              );
            },
            child: const Text("Approve", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _bloc.add(
                ApprovePersetujuanEvent(
                  userId: data.id,
                  role: role,
                  divisiId: _currentUser?.division,
                  actions: 'reject',
                ),
              );
            },
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  /// =========================
  /// CARD
  /// =========================
  Widget buildCard(PengajuanData data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.kategori.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 6),
            Text("User: ${data.user}"),

            const SizedBox(height: 6),
            buildKategoriCard(data),

            const SizedBox(height: 8),

            Row(children: _buildStatusChips(data)),

            const SizedBox(height: 6),

            Text("Status: ${getFinalStatus(data)}"),

            const SizedBox(height: 10),

            actionButton(data),
          ],
        ),
      ),
    );
  }

  Widget buildKategoriCard(PengajuanData data) {
    switch (data.kategori) {
      case 'cuti':
        return CutiCard(
            cuti: CutiModel.fromApi(data, _currentUser!.id.toString()));
      case 'izin':
        return IzinCard(
            izinConverter:
            IzinConverterModel.fromApi(data, _currentUser!.id.toString()));
      case 'lembur':
        return LemburCard(
            lemburModel:
            LemburModel.fromApi(data, _currentUser!.id.toString()));
      case 'dinas':
        return DinasCard(
            dinasModel:
            DinasModel.fromApi(data, _currentUser!.id.toString()));

      case 'wfh':
        return WfhCard(
            wfhModel:
            WfhModel.fromApi(data, _currentUser!.id.toString()));
      default:
        return const Text("Kategori tidak dikenali");
    }
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Persetujuan"),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppNavigator.back(),
        ),
      ),
      body: BlocConsumer<PersetujuanBloc, PersetujuanState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is PersetujuanPageLoadingState) {
            setState(() => _isLoading = true);
          }

          if (state is GetDataListPersetujuanSuccessState) {
            setState(() {
              persetujuanData =
                  state.dataCutiModel.data!.pengajuan.toList();
              _isLoading = false;
            });
          }

          if (state is ApprovePersetujuanSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Berhasil update status")),
            );
            _fetchData();
          }

          if (state is PersetujuanPageFailedState) {
            setState(() => _isLoading = false);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (persetujuanData.isEmpty) {
            return const Center(child: Text("Tidak ada data"));
          }

          return ListView.builder(
            itemCount: persetujuanData.length,
            itemBuilder: (context, index) {
              return buildCard(persetujuanData[index]);
            },
          );
        },
      ),
    );
  }
}