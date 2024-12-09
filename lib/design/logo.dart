import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    // double baseWidth = 375;
    // double fem = MediaQuery.of(context).size.width / baseWidth;
    // double ffem = fem * 0.97;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      child: Column(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                    text: 'Zing',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 30)
                    // style: GoogleFonts.poppins(
                    //   color: Colors.black,
                    //   fontWeight: FontWeight.w500,
                    //   fontSize: 30,
                    // ),
                    ),
                TextSpan(
                    text: 'Expo',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF097500),
                        fontWeight: FontWeight.w500,
                        fontSize: 30)
                    // style: GoogleFonts.poppins(
                    //   color: Colors.black,
                    //   fontWeight: FontWeight.w500,
                    //   fontSize: 30,
                    // ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
