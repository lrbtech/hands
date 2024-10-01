import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget eButton({
  required BuildContext context,
  required String text,
  required VoidCallback onTap,
}) {
  return Align(
    alignment: Alignment.center,
    child: Container(
      margin: const EdgeInsets.all(10),
      height: 56,
      width: 379,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.almarai(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    ),
  );
}
