import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class PresensiBackdateCard extends StatelessWidget {
  final PresensiBackdateModel presensiBackdateModel;

  const PresensiBackdateCard({
    super.key,
    required this.presensiBackdateModel,
  });

  @override
  Widget build(BuildContext context) {
    final tanggal = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(
      DateTime.parse(
        presensiBackdateModel.tanggal,
      ),
    );

    final dokumenUrl =
        presensiBackdateModel.dokumenUrl ?? '';

    final alasan =
    presensiBackdateModel.alasan?.trim().isNotEmpty == true
        ? presensiBackdateModel.alasan!
        : '-';

    String tanggalPengajuan = '-';

    if (presensiBackdateModel.tanggalPengajuan != null &&
        presensiBackdateModel.tanggalPengajuan!.isNotEmpty) {
      try {
        tanggalPengajuan = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(
          DateTime.parse(
            presensiBackdateModel.tanggalPengajuan!,
          ),
        );
      } catch (_) {
        tanggalPengajuan = '-';
      }
    }

    return Container(
      // Tidak perlu margin horizontal karena card ini
      // sudah berada di dalam _modernCard PersetujuanPage.
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFF8FAFC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// =========================
            /// HEADER
            /// =========================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.9),
                        Colors.deepOrange.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.history_toggle_off_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Presensi Backdate',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              tanggal,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            /// =========================
            /// JAM MASUK & KELUAR
            /// =========================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _timeCard(
                    title: "Jam Masuk",
                    icon: Icons.login_rounded,
                    color: Colors.green,
                    value: DateHelper.formatJam(
                      presensiBackdateModel.jamMasuk ?? "-",
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _timeCard(
                    title: "Jam Keluar",
                    icon: Icons.logout_rounded,
                    color: Colors.red,
                    value: DateHelper.formatJam(
                      presensiBackdateModel.jamKeluar ?? "-",
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            /// =========================
            /// ALASAN
            /// =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notes_rounded,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Alasan Pengajuan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    alasan,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),

            /// =========================
            /// DOKUMEN
            /// =========================
            if (dokumenUrl.isNotEmpty) ...[
              const SizedBox(height: 18),

              const Text(
                "Dokumen Lampiran",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                        insetPadding:
                        const EdgeInsets.all(12),
                        child: Stack(
                          children: [
                            InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4,
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  padding:
                                  const EdgeInsets.all(8),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Base64ImageWidget(
                                      base64String:
                                      dokumenUrl,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 12,
                              right: 12,
                              child: InkWell(
                                onTap: () =>
                                    Navigator.pop(context),
                                child: Container(
                                  padding:
                                  const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                    BorderRadius.circular(
                                      30,
                                    ),
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
                  tag: dokumenUrl,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(18),
                      child: Base64ImageWidget(
                        base64String: dokumenUrl,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 18),

            /// =========================
            /// FOOTER
            /// =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Diajukan pada $tanggalPengajuan',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// TIME CARD
  /// =========================
  Widget _timeCard({
    required String title,
    required IconData icon,
    required Color color,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius:
                  BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}