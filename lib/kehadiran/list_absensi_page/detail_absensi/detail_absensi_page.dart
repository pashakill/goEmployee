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
  State<DetailAbsensiPage> createState() => _DetailAbsensiPageState();
}

class _DetailAbsensiPageState extends State<DetailAbsensiPage> {
  DateTime from = DateTime.now();
  DateTime to = DateTime.now();

  late ListAbsenBloc _bloc;

  int totalLateMinutes = 0;
  int totalLateHours = 0;

  List<dynamic> details = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _bloc = ListAbsenBloc(listAbsenApi: GetIt.I<ListAbsenApi>());
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
      setState(() => from = result);
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
      setState(() => to = result);
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

      body: BlocConsumer<ListAbsenBloc, ListAbsenState>(
        bloc: _bloc,

        listener: (context, state) {
          if (state is ListAbsenPageLoadingState) {
            setState(() => isLoading = true);
          }

          if (state is GetSummaryAbsenSuccessState) {
            setState(() {
              isLoading = false;
              totalLateMinutes = state.data.summary.totalLateMinutes ?? 0;
              totalLateHours = state.data.summary.totalLateHours ?? 0;
              details = state.data.details ?? [];
            });
          }

          if (state is ListAbsenPageGlobalErorr) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error.message)),
            );
          }
        },

        builder: (context, state) {
          return Column(
            children: [

              /// ================= FILTER =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _dateBox("From", from, pickFrom),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dateBox("To", to, pickTo),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _fetch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text("Filter", style: TextStyle(color: Colors.white),),
                    )
                  ],
                ),
              ),

              /// ================= SUMMARY =================
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nama,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Total Keterlambatan",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Text(
                      "$totalLateMinutes m",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              /// ================= LIST =================
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : details.isEmpty
                    ? const Center(child: Text("Tidak ada data"))
                    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: details.length,
                  itemBuilder: (context, i) {
                    final item = details[i];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.blue),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['tanggal'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Masuk: ${item['jam_masuk']} | Kerja: ${item['jam_kerja']}",
                                ),
                                Text(
                                  "Terlambat: ${item['late_minutes']} menit",
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

            ],
          );
        },
      ),
    );
  }

  Widget _dateBox(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(formatDate(date)),
          ],
        ),
      ),
    );
  }
}