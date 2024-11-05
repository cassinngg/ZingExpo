import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeadingQuadrat extends StatelessWidget {
  final String title;

  HeadingQuadrat({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft, // Ensure the text is aligned to the left
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start (left)
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
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
