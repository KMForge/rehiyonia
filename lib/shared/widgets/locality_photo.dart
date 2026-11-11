import 'package:flutter/material.dart';

import '../../features/word_search/models/regional_word.dart';

class LocalityPhoto extends StatelessWidget {
  const LocalityPhoto({super.key, required this.locality});
  final RegionalWord locality;
  @override
  Widget build(BuildContext context) => Image.asset(
    locality.resolvedImagePath,
    fit: BoxFit.cover,
    semanticLabel: locality.displayNameEn,
    errorBuilder: (_, _, _) => Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/localities/${locality.regionId <= 8
              ? 'banaue'
              : [9, 10, 11, 18].contains(locality.regionId)
              ? 'cebu'
              : 'davao'}.jpg',
          fit: BoxFit.cover,
        ),
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ColoredBox(
            color: Color(0xCC16324F),
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Text(
                'Regional scenery • Tanawin ng pangkat ng isla',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
