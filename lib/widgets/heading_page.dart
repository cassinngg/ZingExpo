import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HeadingText extends StatelessWidget {
  final String title;
  final String description;

  HeadingText({
    required this.title,
    required this.description,
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
              fontSize: 19,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              const PhosphorIcon(
                PhosphorIconsRegular.flowerLotus,
                color: Color(0xFF023C0E),
                // White color
                size: 20,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF023C0E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
