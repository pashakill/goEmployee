import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class ContentCardHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded untuk mencegah overflow
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoundedTextBlock(
                    title: 'PT. Jatelindo Perkasa Abadi',
                    textSize: 15,
                    textColor: Colors.white,
                    bgColor: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Barry Vasyah, Skom, Mkom',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dosen Unpam',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16), // jarak antara text dan image

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/image/images.jpeg',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        SizedBox(height: 16,),
        Align(
          alignment: Alignment.centerLeft,
          child:  RoundedTextBlock(
            title: '26 Oktober 2025',
            textSize: 15,
            textColor: Colors.white,
            bgColor: Colors.green,
          ),
        )  ,
        AttendanceTimeline()
      ],
    );
  }
}
