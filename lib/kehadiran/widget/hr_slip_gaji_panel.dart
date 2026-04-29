

import 'package:flutter/material.dart';

import '../../common_module/model/user_model.dart';

class HrSlipGajiPanel extends StatelessWidget {
  final bool isHRD;
  final List<UserModel> users;
  final UserModel? selectedUser;
  final Function(UserModel?) onUserChanged;
  final VoidCallback onUpload;

  const HrSlipGajiPanel({
    super.key,
    required this.isHRD,
    required this.users,
    required this.selectedUser,
    required this.onUserChanged,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    if (!isHRD) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// 🔽 USER SELECT
            DropdownButtonFormField<UserModel>(
              value: selectedUser,
              hint: const Text("Pilih Karyawan"),
              items: users.map((user) {
                return DropdownMenuItem(
                  value: user,
                  child: Text(user.nama),
                );
              }).toList(),
              onChanged: onUserChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            /// 📤 UPLOAD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text("Upload Slip Gaji"),
                onPressed: onUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}