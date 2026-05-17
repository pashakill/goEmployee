import 'package:flutter/material.dart';

class KonfirmasiDialog {
  static Future<bool> show({
    required BuildContext context,
    String title = "Konfirmasi",
    String message = "Apakah Anda yakin?",
    String confirmText = "Ya",
    String cancelText = "Batal",
    Color confirmColor = Colors.red,
    IconData icon = Icons.warning_rounded,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,

      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// ICON
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: confirmColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: confirmColor,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                /// TITLE
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                /// MESSAGE
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 24),

                /// BUTTON
                Row(
                  children: [

                    /// CANCEL
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },

                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),

                        child: Text(cancelText),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// CONFIRM
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),

                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }
}