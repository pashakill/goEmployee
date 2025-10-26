import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:get/get.dart';

class MenuItem {
  final String iconPath;
  final String title;
  final String? routeName;

  MenuItem({
    required this.iconPath,
    required this.title,
    this.routeName,
  });
}

class MenuGridWidget extends StatelessWidget {
  MenuGridWidget({super.key});

  // Semua menu aplikasi
  final List<MenuItem> allMenuItems = [
    MenuItem(iconPath: 'assets/icons/ic_absen.svg', title: 'Kehadiran', routeName: Routes.kehadiranPage),
    MenuItem(iconPath: 'assets/icons/ic_cuti.svg', title: 'Cuti', routeName: Routes.cutiPage),
    MenuItem(iconPath: 'assets/icons/ic_overtime.svg', title: 'Lembur', routeName: Routes.lemburPage),
    MenuItem(iconPath: 'assets/icons/ic_location.svg', title: 'Dinas', routeName: Routes.dinasPage),
    MenuItem(iconPath: 'assets/icons/ic_wfh.svg', title: 'WFH', routeName: Routes.wfhPage),
    MenuItem(iconPath: 'assets/icons/ic_ijin.svg', title: 'Izin', routeName: Routes.izinPage),
    MenuItem(iconPath: 'assets/icons/ic_persetujuan.svg', title: 'Persetujuan', routeName: Routes.persetujuanPage),
    MenuItem(iconPath: 'assets/icons/ic_others.svg', title: 'Lainnya', routeName: null),

    // Menu tambahan di bawah ini akan muncul di bottom sheet
    MenuItem(iconPath: 'assets/icons/ic_history.svg', title: 'Riwayat', routeName: '/riwayat'),
    MenuItem(iconPath: 'assets/icons/ic_salary.svg', title: 'Gaji', routeName: '/gaji'),
    MenuItem(iconPath: 'assets/icons/ic_task.svg', title: 'Tugas', routeName: '/tugas'),
    MenuItem(iconPath: 'assets/icons/ic_team.svg', title: 'Tim', routeName: '/tim'),
    MenuItem(iconPath: 'assets/icons/ic_report.svg', title: 'Laporan', routeName: '/laporan'),
  ];

  @override
  Widget build(BuildContext context) {
    // Tampilkan hanya 8 item pertama (termasuk “Lainnya”)
    final displayItems = allMenuItems.length > 8 ? allMenuItems.sublist(0, 8) : allMenuItems;

    return Center(
      child: SizedBox(
        width: double.infinity,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 30,
            childAspectRatio: 0.60,
          ),
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            final item = displayItems[index];
            return GestureDetector(
              onTap: () {
                if (item.title == 'Lainnya') {
                  _showAllMenuBottomSheet(context);
                } else if (item.routeName != null) {
                  AppNavigator.to(item.routeName!);
                }
              },
              child: Column(
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Bottom sheet untuk menampilkan semua menu
  void _showAllMenuBottomSheet(BuildContext context) {
    final otherMenus = allMenuItems.skip(8).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Semua Menu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: otherMenus.length,
                  itemBuilder: (context, index) {
                    final menu = otherMenus[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        if (menu.routeName != null) {
                          AppNavigator.to(menu.routeName!);
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgImageWithColor(
                                path: menu.iconPath,
                                width: 36,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            menu.title,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
