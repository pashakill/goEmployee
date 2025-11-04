import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.green,
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   SvgImageWithColor(color: Colors.white,
                     path: 'assets/icons/app_icon_with_text.svg',
                     width: 90,
                   ),
                   Row(
                     children: [
                       SvgImageWithColor(color: Colors.white,
                         path: 'assets/icons/ic_notification.svg',
                         width: 24,
                       ),
                       SizedBox(
                         width: 12,
                       ),
                       SvgImageWithColor(color: Colors.white,
                         path: 'assets/icons/ic_setting.svg',
                         width: 32,
                       ),
                     ],
                   )
                 ],
                ),
                SizedBox(height: 16,),
                RoundedCardWidget(widget: ContentCardHomePage()),
                const SizedBox(height: 16),
                RoundedCardWidget(widget: MenuGridWidget()),
                // Expanded agar ListView punya tinggi terbatas
                const SizedBox(height: 16),
                RoundedCardWidget(
                    widget:
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              'Pemberitahuan'
                          ),

                          SizedBox(height: 20,),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/image/null_notifcation.jpg',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                                Text(
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    'Tidak ada pemberitahuan'
                                ),
                              ],
                            )
                          ),
                        ]
                      )
                    )
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
