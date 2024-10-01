import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Widgets/Image_Urls.dart';

floatingActionButton(context) {
  return Column(
    children: [
      const Spacer(),
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          AppIcons.logoIcon,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 6),
      Text('Offered By HANDS',
          style: GoogleFonts.abel(
              fontSize: 6,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSecondary)),
    ],
  );
}
