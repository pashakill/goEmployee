import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:goemployee/goemployee.dart';

class DetailAbsensiPage extends StatefulWidget {
  final String userId;
  final String nama;

  const DetailAbsensiPage({
    super.key,
    required this.userId,
    required this.nama,
  });

  @override
  State<DetailAbsensiPage> createState() =>
      _DetailAbsensiPageState();
}

class _DetailAbsensiPageState
    extends State<DetailAbsensiPage> {

  DateTime from = DateTime.now();
  DateTime to = DateTime.now();

  late ListAbsenBloc _bloc;

  int totalLateMinutes = 0;
  int totalLateHours = 0;

  List<AbsensiDetailItem> details = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _bloc = ListAbsenBloc(
      listAbsenApi: GetIt.I<ListAbsenApi>(),
    );

    _fetch();
  }

  String formatDate(DateTime d) {
    return d.toIso8601String().split('T')[0];
  }

  Future<void> _fetch() async {
    _bloc.add(
      FetchSummaryEvent(
        userId: widget.userId,
        from: formatDate(from),
        to: formatDate(to),
      ),
    );
  }

  Future<void> pickFrom() async {

    final result = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: from,
    );

    if (result != null) {
      setState(() {
        from = result;
      });
    }
  }

  Future<void> pickTo() async {

    final result = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: to,
    );

    if (result != null) {
      setState(() {
        to = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        title: Text(widget.nama),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: BlocConsumer<
          ListAbsenBloc,
          ListAbsenState>(

        bloc: _bloc,

        listener: (context, state) {

          if (state
          is ListAbsenPageLoadingState) {

            setState(() {
              isLoading = true;
            });
          }

          if (state
          is GetSummaryAbsenSuccessState) {

            setState(() {

              isLoading = false;

              totalLateMinutes =
                  state.data.summary
                      .totalLateMinutes ?? 0;

              totalLateHours =
                  state.data.summary
                      .totalLateHours ?? 0;

              details = state.data.details;
            });
          }

          if (state
          is ListAbsenPageGlobalErorr) {

            setState(() {
              isLoading = false;
            });

            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  state.error.message,
                ),
              ),
            );
          }
        },

        builder: (context, state) {
          return SafeArea(child: Column(
            children: [

              /// ================= FILTER =================

              Container(

                padding:
                const EdgeInsets.all(16),

                decoration:
                const BoxDecoration(
                  color: Colors.white,
                ),

                child: Row(
                  children: [

                    Expanded(
                      child: _dateBox(
                        "From",
                        from,
                        pickFrom,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _dateBox(
                        "To",
                        to,
                        pickTo,
                      ),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(

                      onPressed: _fetch,

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.blue,
                      ),

                      child: const Text(
                        "Filter",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              /// ================= SUMMARY =================

              Container(

                margin:
                const EdgeInsets.all(16),

                padding:
                const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  gradient:
                  const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.blueAccent,
                    ],
                  ),

                  borderRadius:
                  BorderRadius.circular(16),
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          widget.nama,

                          style:
                          const TextStyle(
                            color:
                            Colors.white,
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 6),

                        const Text(
                          "Total Keterlambatan",

                          style: TextStyle(
                            color:
                            Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      "$totalLateMinutes m",

                      style:
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              /// ================= LIST =================

              Expanded(

                child: isLoading

                    ? const Center(
                  child:
                  CircularProgressIndicator(),
                )

                    : details.isEmpty

                    ? const Center(
                  child: Text(
                    "Tidak ada data",
                  ),
                )

                    : ListView.builder(

                  padding: const EdgeInsets.all(16),

                  itemCount: details.length,

                  itemBuilder: (context, i) {

                    final item = details[i];

                    /// ================= STATUS =================

                    /// ================= STATUS =================

                    final backendStatus =
                    (item.status ?? "").toUpperCase();

                    final hasJamMasuk =
                        item.jamMasuk.isNotEmpty &&
                            item.jamMasuk != "-" &&
                            item.jamMasuk != "null";

                    String attendanceStatus;

                    /// ===============================
                    /// PRIORITAS STATUS IZIN / CUTI / DLL
                    /// ===============================

                    if (
                    backendStatus == "CUTI" ||
                        backendStatus == "IZIN" ||
                        backendStatus == "DINAS" ||
                        backendStatus == "WFH" ||
                        backendStatus == "BACKDATE"
                    ) {
                      attendanceStatus = backendStatus;
                    }

                    /// ===============================
                    /// BELUM ABSEN
                    /// ===============================

                    else if (!hasJamMasuk) {
                      attendanceStatus = "BELUM ABSEN";
                    }

                    /// ===============================
                    /// TERLAMBAT
                    /// ===============================

                    else if (item.lateMinutes > 0) {
                      attendanceStatus = "TERLAMBAT";
                    }

                    /// ===============================
                    /// SUDAH ABSEN
                    /// ===============================
                    else {
                      attendanceStatus = "SUDAH ABSEN";
                    }

                    /// ================= COLOR =================

                    Color chipColor;

                    switch (attendanceStatus) {

                      case "CUTI":
                        chipColor = Colors.orange;
                        break;

                      case "IZIN":
                        chipColor = Colors.blue;
                        break;

                      case "DINAS":
                        chipColor = Colors.purple;
                        break;

                      case "WFH":
                        chipColor = Colors.indigo;
                        break;

                      case "BACKDATE":
                        chipColor = Colors.teal;
                        break;

                      case "TERLAMBAT":
                        chipColor = Colors.red;
                        break;

                      case "SUDAH ABSEN":
                        chipColor = Colors.green;
                        break;

                      default:
                        chipColor = Colors.grey;
                    }

                    return Container(

                      margin: const EdgeInsets.only(
                        bottom: 14,
                      ),

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(20),

                        boxShadow: [

                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          /// ================= HEADER =================

                          Row(

                            children: [

                              Container(

                                padding: const EdgeInsets.all(10),

                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),

                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.blue,
                                  size: 22,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,

                                  children: [

                                    Text(
                                      item.tanggal,

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      item.jamKerja,

                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// ================= STATUS CHIP =================

                              Container(

                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(

                                  color:
                                  chipColor.withOpacity(0.12),

                                  borderRadius:
                                  BorderRadius.circular(30),
                                ),

                                child: Text(
                                  attendanceStatus,
                                  style: TextStyle(
                                    color: chipColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// ================= INFO =================

                          Row(

                            children: [

                              Expanded(
                                child: _timeInfo(
                                  title: "Jam Masuk",
                                  value: item.jamMasuk,
                                  color: Colors.green,
                                  icon: Icons.login,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: _timeInfo(
                                  title: "Terlambat",
                                  value:
                                  "${item.lateMinutes} menit",
                                  color: Colors.red,
                                  icon: Icons.timer_off,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ));
        },
      ),
    );
  }

  Widget _dateBox(
      String label,
      DateTime date,
      VoidCallback onTap,
      ) {

    return InkWell(

      onTap: onTap,

      child: Container(

        padding:
        const EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(

          borderRadius:
          BorderRadius.circular(12),

          border: Border.all(
            color: Colors.grey.shade300,
          ),

          color: Colors.white,
        ),

        child: Column(
          children: [

            Text(
              label,
              style:
              const TextStyle(
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              formatDate(date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeInfo({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {

    return Container(

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),

      decoration: BoxDecoration(

        color: color.withOpacity(0.08),

        borderRadius:
        BorderRadius.circular(14),
      ),

      child: Column(

        children: [

          Icon(
            icon,
            color: color,
            size: 20,
          ),

          const SizedBox(height: 8),

          Text(
            title,

            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),

            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}