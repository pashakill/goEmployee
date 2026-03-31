import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../repo/pengajuan_response.dart';

class SlidablePengajuanItem extends StatelessWidget {
  final PengajuanData? pengajuanData;
  final Widget child;

  final Function(int data) onEdit;
  final Function(int data) onDelete;

  const SlidablePengajuanItem({
    super.key,
    this.pengajuanData,
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    bool isLocked = pengajuanData!.status_hrd == 'approve' || pengajuanData!.status_manager == 'approve';
    if(isLocked){
      return child;
    }

    return Slidable(
      key: ValueKey(pengajuanData!.id),
      /// 👉 SWIPE KIRI → EDIT
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(pengajuanData!.id),
            backgroundColor: Colors.blue,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(pengajuanData!.id),
            backgroundColor: Colors.red,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),

      child: child,
    );
  }
}