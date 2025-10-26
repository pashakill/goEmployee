import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class MenuItem {
  final String iconPath;
  final String title;

  MenuItem({required this.iconPath, required this.title});
}

class MenuGridWidget extends StatelessWidget {
  final List<MenuItem> menuItems = [
    MenuItem(iconPath: 'assets/icons/ic_absen.svg', title: 'Kehadiran'),
    MenuItem(iconPath: 'assets/icons/ic_cuti.svg', title: 'Cuti'),
    MenuItem(iconPath: 'assets/icons/ic_overtime.svg', title: 'Lembur'),
    MenuItem(iconPath: 'assets/icons/ic_location.svg', title: 'Dinas'),
    MenuItem(iconPath: 'assets/icons/ic_wfh.svg', title: 'WTH'),
    MenuItem(iconPath: 'assets/icons/ic_ijin.svg', title: 'Izin'),
    MenuItem(iconPath: 'assets/icons/ic_persetujuan.svg', title: 'Persetujuan'),
    MenuItem(iconPath: 'assets/icons/ic_others.svg', title: 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
    final displayItems =
    menuItems.length > 8 ? menuItems.sublist(0, 8) : menuItems;

    return Center(
      child: SizedBox(
        width: double.infinity,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 30,
            childAspectRatio: 0.60,
          ),
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgImageWithColor(
                      path: item.iconPath,
                      width: 36,
                      color: Colors.green,
                    )

                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
