import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget heading({
  required BuildContext context,
  required String text,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, left: 15, bottom: 5),
    child: Text(
      text,
      style: GoogleFonts.almarai(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSecondary,
      ),
    ),
  );
}
