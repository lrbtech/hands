import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';

Widget notaMemberText({
  required BuildContext context,
  String? text,
  VoidCallback? onPressed,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text(
        'Not a member?',
        style: GoogleFonts.almarai(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.unselectedcolor,
        ),
      ),
      TextButton(
        onPressed: onPressed,
        child: Text(
          text ?? '',
          style: GoogleFonts.almarai(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    ],
  );
}
