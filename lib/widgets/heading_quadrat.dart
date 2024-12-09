import 'package:flutter/material.dart';

class HeadingQuadrat extends StatelessWidget {
  final String title;

  HeadingQuadrat({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft, 
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, 
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          // const Row(
          //   children: [
          //     const Icon(
          //       Icons.grass_outlined,
          //       size: 20,
          //       color: Color(0xFF023C0E),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
