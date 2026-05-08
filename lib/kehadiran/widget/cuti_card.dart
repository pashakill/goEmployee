import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class CutiCard extends StatelessWidget {
  final CutiModel cuti;

  const CutiCard({
    Key? key,
    required this.cuti,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ================= HEADER =================
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cuti.jenisCuti,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Pengajuan Cuti Karyawan",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ================= TANGGAL =================
              _buildInfoTile(
                icon: Icons.calendar_month_rounded,
                title: "Tanggal Cuti",
                value:
                "${DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(cuti.tanggalMulai))}"
                    " - "
                    "${DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(cuti.tanggalSelesai))}",
              ),

              const SizedBox(height: 14),

              /// ================= DURASI =================
              _buildInfoTile(
                icon: Icons.timelapse_rounded,
                title: "Durasi",
                value: "${cuti.lamaCuti} Hari",
              ),

              const SizedBox(height: 16),

              /// ================= ALASAN =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),

                        const SizedBox(width: 8),

                        const Text(
                          "Alasan Pengajuan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      cuti.alasan.isEmpty
                          ? "-"
                          : cuti.alasan,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= DOKUMEN =================
              if (cuti.dokumenUrl.isNotEmpty) ...[
                const SizedBox(height: 18),

                const Text(
                  "Dokumen Lampiran",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return Dialog(
                          backgroundColor: Colors.black,
                          insetPadding: const EdgeInsets.all(12),
                          child: Stack(
                            children: [

                              /// IMAGE FULLSCREEN
                              InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.grey.shade100,
                                    padding: const EdgeInsets.all(8),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Base64ImageWidget(
                                        base64String: cuti.dokumenUrl,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              /// CLOSE BUTTON
                              Positioned(
                                top: 12,
                                right: 12,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },

                  child: Hero(
                    tag: cuti.dokumenUrl,

                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Base64ImageWidget(
                          base64String: cuti.dokumenUrl,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              Divider(
                color: Colors.grey.shade200,
              ),

              const SizedBox(height: 10),

              /// ================= FOOTER =================
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      "Diajukan pada "
                          "${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(cuti.tanggalPengajuan ?? DateTime.now().toString()))}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= INFO TILE =================
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.green,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}