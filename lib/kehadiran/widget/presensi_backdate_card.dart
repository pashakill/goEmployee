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

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
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
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            /// =========================
            /// HEADER
            /// =========================
            Row(
              children: [

                /// ICON
                Container(
                  padding:
                  const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange
                            .withOpacity(0.9),
                        Colors.deepOrange
                            .withOpacity(0.8),
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: const Icon(
                    Icons.history_toggle_off_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                /// TITLE
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'Presensi Backdate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [

                          Icon(
                            Icons.calendar_month_rounded,
                            size: 16,
                            color:
                            Colors.grey.shade600,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              tanggal,
                              style: TextStyle(
                                color: Colors
                                    .grey.shade700,
                                fontSize: 13,
                                fontWeight:
                                FontWeight.w500,
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
              children: [

                /// MASUK
                Expanded(
                  child: _timeCard(
                    title: "Jam Masuk",
                    icon: Icons.login_rounded,
                    color: Colors.green,
                    value: DateHelper.formatJam(
                      presensiBackdateModel
                          .jamMasuk ??
                          "-",
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                /// KELUAR
                Expanded(
                  child: _timeCard(
                    title: "Jam Keluar",
                    icon: Icons.logout_rounded,
                    color: Colors.red,
                    value: DateHelper.formatJam(
                      presensiBackdateModel
                          .jamKeluar ??
                          "-",
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
                borderRadius:
                BorderRadius.circular(20),
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
                        padding:
                        const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(
                              12),
                        ),

                        child: const Icon(
                          Icons.notes_rounded,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        'Alasan Pengajuan',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    presensiBackdateModel
                        .alasan ??
                        '-',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color:
                      Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// =========================
            /// FOOTER
            /// =========================
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius:
                BorderRadius.circular(16),
              ),

              child: Row(
                children: [

                  Container(
                    padding:
                    const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange
                          .withOpacity(0.1),
                      borderRadius:
                      BorderRadius.circular(
                          10),
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
                      'Diajukan pada ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(presensiBackdateModel.tanggalPengajuan ?? ''))}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                        Colors.grey.shade700,
                        fontWeight:
                        FontWeight.w500,
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
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius:
        BorderRadius.circular(22),

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
                padding:
                const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                  color.withOpacity(0.12),
                  borderRadius:
                  BorderRadius.circular(
                      12),
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
                  style: TextStyle(
                    color: color,
                    fontWeight:
                    FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}