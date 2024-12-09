import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SubmitButtonWithAddIcon extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double fontSize;
  final double iconSize;

  const SubmitButtonWithAddIcon({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color(0xFF023C0E),
    this.fontSize = 9,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    // final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    // Adjust font sizes based on screen width
    final adjustedFontSize = fontSize * size.width / 375;
    final adjustedIconSize = iconSize * size.width / 375;
    final boxWidth = 250 * size.width / 375;

    return Container(
      width: boxWidth,
      height: 50, // Fixed height of 50
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(foregroundColor),
          foregroundColor: MaterialStatePropertyAll(foregroundColor),
          padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 48)),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: foregroundColor,
              width: 2,
            ),
          )),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsBold.plus,
              color: backgroundColor,
              size: adjustedIconSize,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: adjustedFontSize,
                fontWeight: FontWeight.w600,
                color: backgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
