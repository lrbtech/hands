import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget customDialogButton({
  required String text,
  required BuildContext context,
  VoidCallback? onPressed,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 55,
        width: 171,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.onBackground,
        ),
        child: Center(
          child: TextButton(
            onPressed: onPressed,
            child: Text(
              text,
              style: GoogleFonts.almarai(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
