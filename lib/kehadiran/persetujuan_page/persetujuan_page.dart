import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/goemployee.dart';

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
  bool isOffline = false;
  late PersetujuanBloc _bloc;
  String searchName = "";

  /// FILTER
  String? selectedKategori;
  String? selectedStatus;

  final List<String> kategoriList = [
    'cuti',
    'izin',
    'lembur',
    'dinas',
    'backdate',
    'wfh'
  ];

  final List<String> statusList = [
    'APPROVED',
    'REJECTED',
    'PENDING'
  ];

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
  /// FILTER DATA
  /// =========================
  List<PengajuanData> _getFilteredData() {
    return persetujuanData.where((data) {
      final finalStatus = getFinalStatus(data);

      final matchKategori =
          selectedKategori == null || data.kategori == selectedKategori;

      final matchStatus =
          selectedStatus == null || finalStatus == selectedStatus;

      final matchName = searchName.isEmpty ||
          (data.user ?? '')
              .toLowerCase()
              .contains(searchName.toLowerCase());

      return matchKategori && matchStatus && matchName;
    }).toList();
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
  /// STATUS BADGE
  /// =========================
  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case 'APPROVED':
        color = Colors.green;
        break;
      case 'REJECTED':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  List<Widget> _buildStatusChips(PengajuanData data) {
    return [
      statusChip("Manager", data.status_manager),
      const SizedBox(width: 8),
      statusChip("HRD", data.status_hrd),
    ];
  }

  /// =========================
  /// ACTION BUTTON
  /// =========================
  Widget actionButton(PengajuanData data) {
    final role = _currentUser?.role;
    final division = _currentUser?.division?.toUpperCase();

    if (role == 'karyawan') return const SizedBox();

    if (division == 'HR') {
      if (data.status_hrd == 'approve' || data.status_hrd == 'reject') {
        return const SizedBox();
      }
      return _buildButtonRow(data, 'hrd');
    }

    if (data.status_manager == 'approve' || data.status_manager == 'reject') {
      return const SizedBox();
    }

    return _buildButtonRow(data, 'manager');
  }

  Widget _buildButtonRow(PengajuanData data, String role) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              _bloc.add(
                ApprovePersetujuanEvent(
                  actor_id: _currentUser?.id.toString() ?? "",
                  pengajuanId: data.id,
                  role: role,
                  divisiId: _currentUser?.division,
                  actions: 'approve',
                ),
              );
            },
            child: const Text("Approve"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              _bloc.add(
                ApprovePersetujuanEvent(
                  actor_id: _currentUser?.id.toString() ?? "",
                  pengajuanId: data.id,
                  role: role,
                  divisiId: _currentUser?.division,
                  actions: 'reject',
                ),
              );
            },
            child: const Text("Reject"),
          ),
        ),
      ],
    );
  }

  /// =========================
  /// CARD
  /// =========================
  Widget _modernCard(PengajuanData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.kategori.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              _statusBadge(getFinalStatus(data)),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            data.user ?? "-",
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),

          const SizedBox(height: 10),

          buildKategoriCard(data),

          const SizedBox(height: 10),

          Row(children: _buildStatusChips(data)),

          const SizedBox(height: 10),

          actionButton(data),
        ],
      ),
    );
  }

  /// =========================
  /// KATEGORI CARD
  /// =========================
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
      case 'backdate':
        return PresensiBackdateCard(
            presensiBackdateModel:
            PresensiBackdateModel.fromApi(data, _currentUser!.id.toString()));
      case 'wfh':
        return WfhCard(
            wfhModel:
            WfhModel.fromApi(data, _currentUser!.id.toString()));
      default:
        return const Text("Kategori tidak dikenali");
    }
  }

  /// =========================
  /// LISTENER
  /// =========================
  void _listener(BuildContext context, PersetujuanState state) {
    if (state is PersetujuanPageLoadingState) {
      setState(() => _isLoading = true);
      LoadingDialog.show(context, message: "Tunggu Sebentar...");
    }

    if (state is GetDataListPersetujuanSuccessState) {
      setState(() {
        persetujuanData = state.dataCutiModel.data!.pengajuan.toList();
        _isLoading = false;
      });

      LoadingDialog.hide(context);
    }

    if (state is ApprovePersetujuanSuccessState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil update status")),
      );

      LoadingDialog.hide(context);
      _fetchData();
    }
  }

  /// =========================
  /// UI
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Approval",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => AppNavigator.back(),
        ),
      ),
      body: Column(
        children: [
          /// FILTER
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari nama karyawan...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onChanged: (value) {
                setState(() {
                  searchName = value;
                });
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedKategori,
                    hint: const Text("Kategori"),
                    items: kategoriList.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedKategori = val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    hint: const Text("Status"),
                    items: statusList.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedStatus = val);
                    },
                  ),
                ),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: BlocConsumer<PersetujuanBloc, PersetujuanState>(
              bloc: _bloc,
              listener: _listener,
              builder: (context, state) {
                final list = _getFilteredData();

                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (list.isEmpty) {
                  return const Center(child: Text("Tidak ada data"));
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadUser(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _modernCard(list[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}