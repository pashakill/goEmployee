import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class AppMenuItem {
  final String iconPath;
  final String title;
  final String? routeName;

  AppMenuItem({
    required this.iconPath,
    required this.title,
    this.routeName,
  });
}

class MenuGridWidget extends StatelessWidget {
  final bool canCheckIn;
  final String role;

  MenuGridWidget({
    super.key,
    required this.canCheckIn,
    required this.role,
  });

  final List<AppMenuItem> allMenuItems = [
    AppMenuItem(
      iconPath: 'assets/icons/ic_absen.svg',
      title: 'Kehadiran',
      routeName: Routes.kehadiranPage,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_cuti.svg',
      title: 'Cuti',
      routeName: Routes.cutiPage,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_overtime.svg',
      title: 'Lembur',
      routeName: Routes.lemburPage,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_location.svg',
      title: 'Dinas',
      routeName: Routes.dinasPage,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_wfh.svg',
      title: 'WFH',
      routeName: Routes.wfhPage,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_ijin.svg',
      title: 'Izin',
      routeName: Routes.izinPage,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_persetujuan.svg',
      title: 'Persetujuan',
      routeName: Routes.persetujuanPage,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_others.svg',
      title: 'Lainnya',
      routeName: null,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_back_date.svg',
      title: 'Presensi Backdate',
      routeName: Routes.presensiBackdatePage,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_report_money.svg',
      title: 'Slip Gaji',
      routeName: Routes.slipGajiPage,
    ),
    AppMenuItem(
      iconPath: 'assets/icons/ic_report.svg',
      title: 'Laporan Absensi',
      routeName: Routes.listAbsen,
    ),
  ];

  List<AppMenuItem> get filteredMenu {
    return allMenuItems.where((item) {
      if (item.title == 'Laporan Absensi') {
        final r = role.toUpperCase();
        return r == 'HRD' || r == 'MANAGER';
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = allMenuItems.length > 8
        ? allMenuItems.sublist(0, 8)
        : allMenuItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;

        // Responsive spacing
        final double spacing = availableWidth < 350 ? 10 : 16;

        // Ukuran icon menyesuaikan layar
        final double iconSize = availableWidth < 350 ? 52 : 58;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          padding: EdgeInsets.symmetric(
            horizontal: spacing,
            vertical: 8,
          ),

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 14,
            crossAxisSpacing: 10,
            mainAxisExtent: 105,
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
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,

                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(11),

                      child: SvgImageWithColor(
                        path: item.iconPath,
                        width: iconSize - 20,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Expanded(
                    child: Text(
                      item.title,

                      textAlign: TextAlign.center,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAllMenuBottomSheet(BuildContext context) {
    final otherMenus = allMenuItems.skip(8).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: GridView.builder(
              shrinkWrap: true,

              padding: const EdgeInsets.only(
                bottom: 20,
              ),

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
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
                        width: 56,
                        height: 56,

                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius:
                          BorderRadius.circular(16),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(11),

                          child: SvgImageWithColor(
                            path: menu.iconPath,
                            width: 34,
                            color: Colors.green,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      SizedBox(
                        height: 30,

                        child: Text(
                          menu.title,

                          textAlign: TextAlign.center,

                          maxLines: 2,

                          overflow:
                          TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}