import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/goemployee.dart';

import '../../common_module/helper/format.dart';

class ListAbsenPage extends StatefulWidget {
  const ListAbsenPage({super.key});

  @override
  State<ListAbsenPage> createState() => _ListAbsenPageState();
}

class _ListAbsenPageState extends State<ListAbsenPage> {
  late ListAbsenBloc _bloc;

  DateTime? fromDate;
  DateTime? toDate;

  String? selectedStatus;

  List<AbsensiModel> absensiList = [];

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isLoading = true;
  User? _currentUser;

  final List<String> statusList = [
    "ALL",
    "HADIR",
    "CUTI",
    "IZIN",
    "WFH",
    "DINAS",
    "BACKDATE",
    "ALPHA",
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month, now.day);
    toDate = DateTime(now.year, now.month, now.day);

    _bloc = ListAbsenBloc(listAbsenApi: GetIt.I<ListAbsenApi>());

    _fetch();
  }

  Future<void> _fetch() async {
    final user = await _dbHelper.getSingleUser();

    if (user == null) {
      await _forceLogout();
      return;
    }

    setState(() {
      _currentUser = user;
      _isLoading = false;
    });

    _fetchHistory();
  }

  void _fetchHistory() {
    if (_currentUser == null) return;

    _bloc.add(
      ListAbsenFetchedEvent(
        userId: _currentUser!.id!.toString(),
        from: formatDate(fromDate!),
        to: formatDate(toDate!),
        status: (selectedStatus == null || selectedStatus == "ALL")
            ? ""
            : selectedStatus!,
      ),
    );
  }

  /// =========================
  /// STATUS COLOR
  /// =========================
  Color _statusColor(String status) {
    switch (status) {
      case 'CUTI':
        return Colors.orange;
      case 'IZIN':
        return Colors.blue;
      case 'WFH':
        return Colors.indigo;
      case 'DINAS':
        return Colors.purple;
      case 'BACKDATE':
        return Colors.teal;
      case 'ALPHA':
        return Colors.red;
      case 'HADIR':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// =========================
  /// STATUS CHIP
  /// =========================
  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
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
  /// CARD UI
  /// =========================
  Widget _card(AbsensiModel item) {
    final status = (item.status ?? 'HADIR').toUpperCase();
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Divisi: ${item.division ?? '-'}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(status),
            ],
          ),

          const SizedBox(height: 12),

          /// DATE
          Row(
            children: [
              const Icon(Icons.calendar_month,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(item.tanggal),
            ],
          ),

          const SizedBox(height: 12),

          /// TIME
          Row(
            children: [
              _timeBox("Masuk", item.jamMasuk, Colors.green),
              _timeBox("Pulang", item.jamPulang, Colors.red),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _timeBox(String label, String? time, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time ?? '-',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// FILTER UI
  /// =========================
  Widget _filterSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [

          /// DATE FILTER
          Row(
            children: [
              Expanded(
                child: _dateBox(
                  label: fromDate.toString().split(" ")[0],
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDate: DateTime.now(),
                    );

                    if (date != null) {
                      setState(() => fromDate = date);
                      _fetchHistory();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dateBox(
                  label: toDate.toString().split(" ")[0],
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDate: DateTime.now(),
                    );

                    if (date != null) {
                      setState(() => toDate = date);
                      _fetchHistory();
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// STATUS FILTER
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: statusList.length,
              itemBuilder: (context, i) {
                final status = statusList[i];
                final isSelected = selectedStatus == status;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStatus = status;
                    });
                    _fetchHistory();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color:
                        isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateBox({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label),
      ),
    );
  }

  /// =========================
  /// BUILD
  /// =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Laporan Absensi"),
        backgroundColor: Colors.green,
      ),

      body: BlocConsumer<ListAbsenBloc, ListAbsenState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is GetDataListAbsenSuccessState) {
            setState(() {
              absensiList = state.data;
              _isLoading = false;
            });
          }
        },

        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _filterSection(),

              Expanded(
                child: absensiList.isEmpty
                    ? const Center(child: Text("Belum ada data absensi"))
                    : RefreshIndicator(
                  onRefresh: () async => _fetch(),
                  child: ListView.builder(
                    itemCount: absensiList.length,
                    itemBuilder: (context, i) {
                      return _card(absensiList[i]);
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

  Future<void> _forceLogout() async {
    await _dbHelper.deleteCurrentUserAndLogout();
    if (mounted) {
      AppNavigator.offAll(Routes.login);
    }
  }
}