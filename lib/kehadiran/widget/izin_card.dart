import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class IzinCard extends StatelessWidget {
  final IzinConverterModel izinConverter;

  const IzinCard({
    super.key,
    required this.izinConverter,
  });

  /// TITLE
  String _getTitle(IzinTipe tipe) {
    switch (tipe) {
      case IzinTipe.telatMasuk:
        return 'Izin Telat Masuk';
      case IzinTipe.pulangAwal:
        return 'Izin Pulang Awal';
      case IzinTipe.tidakMasuk:
        return 'Izin Tidak Masuk';
      default:
        return 'Izin Tidak Dikenal';
    }
  }

  /// ICON
  IconData _getIcon(IzinTipe tipe) {
    switch (tipe) {
      case IzinTipe.telatMasuk:
        return Icons.login_rounded;
      case IzinTipe.pulangAwal:
        return Icons.logout_rounded;
      case IzinTipe.tidakMasuk:
        return Icons.block_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  /// COLOR
  Color _getColor(IzinTipe tipe) {
    switch (tipe) {
      case IzinTipe.telatMasuk:
        return Colors.orange;
      case IzinTipe.pulangAwal:
        return Colors.blue;
      case IzinTipe.tidakMasuk:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(izinConverter.tipe);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Row(
              children: [

                /// ICON BOX
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _getIcon(izinConverter.tipe),
                    color: color,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                /// TITLE & DATE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        _getTitle(izinConverter.tipe),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              DateFormat(
                                'dd MMMM yyyy',
                                'id_ID',
                              ).format(izinConverter.tanggal),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// JAM
                if (izinConverter.jam != null &&
                    izinConverter.jam!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      izinConverter.jam!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 18),

            /// ALASAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.notes_rounded,
                    color: color,
                    size: 20,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      izinConverter.alasan,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// FOOTER
            Row(
              children: [

                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    'Diajukan pada ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(izinConverter.tanggalPengajuan ?? ''))}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}