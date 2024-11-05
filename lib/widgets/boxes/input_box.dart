import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputBox extends StatefulWidget {
  final String hint;
  final TextEditingController controller;

  const InputBox({
    super.key,
    required this.hint,
    required this.controller,
  });

  @override
  _InputBoxState createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    final padding = _calculatePadding(size.width);
    final borderRadius = _calculateBorderRadius(size.width);
    // final fontSize = _calculateFontSize(size.width);
    // final iconSize = _calculateIconSize(size.width);
    final verticalPadding = _calculateVerticalPadding(size.height);
    final hintFontSize = _calculateHintFontSize(size.width * 1.5);
    final textFieldFontSize =
        _calculateTextFieldFontSize(size.width, textScaleFactor);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF097500).withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: verticalPadding),
          TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: hintFontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF097500),
              ),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF023C0E)),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF097500)),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: textFieldFontSize,
              fontWeight: FontWeight.w200,
              color: const Color(0xFF097500),
            ),
            onChanged: (value) {
              setState(() {
                _isFocused = true;
              });
            },
          ),
        ],
      ),
    );
  }

  EdgeInsets _calculatePadding(double width) {
    return const EdgeInsets.symmetric(horizontal: 5);
  }

  double _calculateBorderRadius(double width) {
    return width * 0.02;
  }

  // double _calculateFontSize(double width) {
  //   return width * 0.025;
  // }

  // double _calculateIconSize(double width) {
  //   return width * 0.03;
  // }

  double _calculateVerticalPadding(double height) {
    return height * 0.01;
  }

  double _calculateHintFontSize(double width) {
    return width * 0.015;
  }

  double _calculateTextFieldFontSize(double width, double textScaleFactor) {
    return width * 0.022 * textScaleFactor;
  }
}
