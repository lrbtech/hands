import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';

Widget customDivider() {
  return Row(
    children: [
      const Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
            color: AppColors.purewhite,
            thickness: 0.8,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          'Or',
          style: GoogleFonts.almarai(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.greentext,
          ),
        ),
      ),
      const Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
            color: AppColors.purewhite,
            thickness: 0.8,
          ),
        ),
      ),
    ],
  );
}
