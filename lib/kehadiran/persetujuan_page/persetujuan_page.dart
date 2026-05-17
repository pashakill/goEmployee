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

  bool isManager() => _currentUser?.role == 'manager';

  bool isHR() =>
      _currentUser?.division?.toUpperCase() == 'HR';

  bool isKaryawan() =>
      _currentUser?.role == 'karyawan';

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
      debugPrint("ERROR LOAD USER: $e");
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
          selectedKategori == null ||
              data.kategori == selectedKategori;

      final matchStatus =
          selectedStatus == null ||
              finalStatus == selectedStatus;

      final matchName =
          searchName.isEmpty ||
              (data.user ?? '')
                  .toLowerCase()
                  .contains(searchName.toLowerCase());

      return matchKategori &&
          matchStatus &&
          matchName;
    }).toList();
  }

  /// =========================
  /// FINAL STATUS
  /// =========================
  String getFinalStatus(PengajuanData data) {
    final manager = data.status_manager;
    final hrd = data.status_hrd;

    if (manager == 'reject' ||
        hrd == 'reject') {
      return 'REJECTED';
    }

    if (manager == 'approve' &&
        hrd == 'approve') {
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
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
  /// STATUS CHIP
  /// =========================
  Widget statusChip(
      String label,
      String status,
      ) {
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$label : ${status.toUpperCase()}",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  List<Widget> _buildStatusChips(
      PengajuanData data,
      ) {
    List<Widget> chips = [];

    if (!isManager()) {
      chips.add(
        statusChip(
          "Manager",
          data.status_manager,
        ),
      );
    }

    chips.add(
      statusChip(
        "HRD",
        data.status_hrd,
      ),
    );

    return chips;
  }

  /// =========================
  /// ACTION BUTTON
  /// =========================
  Widget actionButton(PengajuanData data) {

    final role = _currentUser?.role;

    final division =
    _currentUser?.division?.toUpperCase();

    /// HR APPROVAL
    if (division == 'HR') {

      if (data.status_hrd == 'approve' ||
          data.status_hrd == 'reject') {
        return const SizedBox();
      }

      return _buildButtonRow(data, 'hrd');
    }

    /// KARYAWAN TIDAK BISA APPROVE
    if (role == 'karyawan') {
      return const SizedBox();
    }

    /// MANAGER APPROVAL
    if (data.status_manager == 'approve' ||
        data.status_manager == 'reject') {
      return const SizedBox();
    }

    return _buildButtonRow(data, 'manager');
  }

  Widget _buildButtonRow(
      PengajuanData data,
      String role,
      ) {
    return Row(
      children: [

        /// APPROVE
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              _bloc.add(
                ApprovePersetujuanEvent(
                  actor_id:
                  _currentUser?.id.toString() ?? "",
                  pengajuanId: data.id,
                  role: role,
                  divisiId:
                  _currentUser?.division,
                  actions: 'approve',
                ),
              );
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text("Approve"),
          ),
        ),

        const SizedBox(width: 12),

        /// REJECT
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              _bloc.add(
                ApprovePersetujuanEvent(
                  actor_id:
                  _currentUser?.id.toString() ?? "",
                  pengajuanId: data.id,
                  role: role,
                  divisiId:
                  _currentUser?.division,
                  actions: 'reject',
                ),
              );
            },
            icon: const Icon(Icons.close_rounded),
            label: const Text("Reject"),
          ),
        ),
      ],
    );
  }

  /// =========================
  /// MODERN CARD
  /// =========================
  Widget _modernCard(PengajuanData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [

                /// ICON
                Container(
                  padding:
                  const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withOpacity(0.1),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                /// TITLE
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        data.kategori
                            .toUpperCase(),
                        style:
                        const TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        data.user ?? '-',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                          Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                /// STATUS
                if (!isManager())
                  _statusBadge(
                    getFinalStatus(data),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            /// CONTENT
            buildKategoriCard(data),

            const SizedBox(height: 16),

            /// STATUS CHIP
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
              _buildStatusChips(data),
            ),

            const SizedBox(height: 18),

            /// BUTTON
            actionButton(data),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// BUILD KATEGORI CARD
  /// =========================
  Widget buildKategoriCard(
      PengajuanData data,
      ) {
    switch (data.kategori) {

      case 'cuti':
        return CutiCard(
          cuti: CutiModel.fromApi(
            data,
            _currentUser!.id.toString(),
          ),
        );

      case 'izin':
        return IzinCard(
          izinConverter:
          IzinConverterModel.fromApi(
            data,
            _currentUser!.id.toString(),
          ),
        );

      case 'lembur':
        return LemburCard(
          lemburModel:
          LemburModel.fromApi(
            data,
            _currentUser!.id.toString(),
          ),
        );

      case 'dinas':
        return DinasCard(
          dinasModel:
          DinasModel.fromApi(
            data,
            _currentUser!.id.toString(),
          ),
        );

      case 'backdate':
        return PresensiBackdateCard(
          presensiBackdateModel:
          PresensiBackdateModel.fromApi(
            data,
            _currentUser!.id.toString(),
          ),
        );

      case 'wfh':
        return WfhCard(
          wfhModel:
          WfhModel.fromApi(
            data,
            _currentUser!.id.toString(),
          ),
        );

      default:
        return const Text(
          "Kategori tidak dikenali",
        );
    }
  }

  /// =========================
  /// LISTENER
  /// =========================
  void _listener(
      BuildContext context,
      PersetujuanState state,
      ) {

    if (state
    is PersetujuanPageLoadingState) {

      setState(() {
        _isLoading = true;
      });

      LoadingDialog.show(
        context,
        message: "Tunggu Sebentar...",
      );
    }

    if (state
    is GetDataListPersetujuanSuccessState) {

      setState(() {
        persetujuanData =
            state.dataCutiModel.data!
                .pengajuan
                .toList();

        _isLoading = false;
      });

      LoadingDialog.hide(context);
    }

    if (state
    is ApprovePersetujuanSuccessState) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Berhasil update status",
          ),
        ),
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
      backgroundColor:
      const Color(0xFFF4F7FB),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        title: const Text(
          "Persetujuan",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () =>
              AppNavigator.back(),
        ),
      ),

      body: Column(
        children: [

          /// =========================
          /// SEARCH + FILTER
          /// =========================
          Container(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              const BorderRadius.only(
                bottomLeft:
                Radius.circular(28),
                bottomRight:
                Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withOpacity(
                      0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              children: [

                /// SEARCH
                if (!isKaryawan())
                  Container(
                    decoration: BoxDecoration(
                      color:
                      const Color(0xFFF6F7FB),
                      borderRadius:
                      BorderRadius.circular(
                          18),
                    ),

                    child: TextField(
                      decoration:
                      InputDecoration(
                        hintText:
                        "Cari nama karyawan...",
                        hintStyle: TextStyle(
                          color: Colors
                              .grey.shade500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors
                              .grey.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),

                      onChanged: (value) {
                        setState(() {
                          searchName = value;
                        });
                      },
                    ),
                  ),

                const SizedBox(height: 14),

                /// FILTER
                Row(
                  children: [

                    /// KATEGORI
                    Expanded(
                      child: Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 12,
                        ),

                        decoration:
                        BoxDecoration(
                          color: const Color(
                              0xFFF6F7FB),
                          borderRadius:
                          BorderRadius
                              .circular(
                              16),
                        ),

                        child:
                        DropdownButtonHideUnderline(
                          child:
                          DropdownButton<
                              String>(
                            value:
                            selectedKategori,
                            isExpanded: true,
                            hint: const Text(
                                "Kategori"),
                            icon: const Icon(
                              Icons
                                  .keyboard_arrow_down_rounded,
                            ),

                            items:
                            kategoriList
                                .map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.toUpperCase(),
                                ),
                              );
                            }).toList(),

                            onChanged: (val) {
                              setState(() {
                                selectedKategori =
                                    val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// STATUS
                    Expanded(
                      child: Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 12,
                        ),

                        decoration:
                        BoxDecoration(
                          color: const Color(
                              0xFFF6F7FB),
                          borderRadius:
                          BorderRadius
                              .circular(
                              16),
                        ),

                        child:
                        DropdownButtonHideUnderline(
                          child:
                          DropdownButton<
                              String>(
                            value:
                            selectedStatus,
                            isExpanded: true,
                            hint: const Text(
                                "Status"),

                            icon: const Icon(
                              Icons
                                  .keyboard_arrow_down_rounded,
                            ),

                            items: statusList
                                .map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child:
                                Text(e),
                              );
                            }).toList(),

                            onChanged: (val) {
                              setState(() {
                                selectedStatus =
                                    val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// =========================
          /// LIST
          /// =========================
          Expanded(
            child: BlocConsumer<
                PersetujuanBloc,
                PersetujuanState>(
              bloc: _bloc,
              listener: _listener,

              builder: (context, state) {

                final list =
                _getFilteredData();

                if (_isLoading) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [

                        Container(
                          padding:
                          const EdgeInsets
                              .all(24),
                          decoration:
                          BoxDecoration(
                            color: Colors
                                .grey.shade100,
                            shape:
                            BoxShape.circle,
                          ),

                          child: Icon(
                            Icons
                                .inbox_rounded,
                            size: 56,
                            color: Colors
                                .grey.shade500,
                          ),
                        ),

                        const SizedBox(
                            height: 18),

                        const Text(
                          "Tidak ada data approval",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),

                        const SizedBox(
                            height: 6),

                        Text(
                          "Data approval akan muncul di sini",
                          style: TextStyle(
                            color: Colors
                                .grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadUser();
                  },

                  child: ListView.builder(
                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      16,
                      10,
                      16,
                      24,
                    ),

                    itemCount: list.length,

                    itemBuilder:
                        (context, index) {

                      return Padding(
                        padding:
                        const EdgeInsets
                            .only(
                          bottom: 14,
                        ),

                        child: _modernCard(
                          list[index],
                        ),
                      );
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