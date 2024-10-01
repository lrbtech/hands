import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';

Widget offerSelect({
  required BuildContext context,
  required String? selectedGender,
  required ValueChanged<String?> onChanged,
  Color? activeColor,
  Color? inactiveColor = Colors.black,
  Color? textColor,
  double spacing = 5.0,
  double fontSize = 12.0,
  FontWeight fontWeight = FontWeight.w700,
  String fontFamily = 'Almarai',
}) {
  activeColor = activeColor ?? Theme.of(context).colorScheme.onBackground;
  textColor = textColor ?? Theme.of(context).colorScheme.onSecondary;

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Radio<String>(
            value: 'Yes',
            groupValue: selectedGender,
            onChanged: onChanged,
            activeColor: activeColor,
            fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (!states.contains(MaterialState.selected)) {
                  return inactiveColor;
                }
                return null;
              },
            ),
          ),
          SizedBox(width: spacing),
          Text(
            'Yes',
            style: GoogleFonts.getFont(
              fontFamily,
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
      SizedBox(width: 10.0),
      Row(
        children: <Widget>[
          Radio<String>(
            value: 'No',
            groupValue: selectedGender,
            onChanged: onChanged,
            activeColor: activeColor,
            fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (!states.contains(MaterialState.selected)) {
                  return inactiveColor;
                }
                return null;
              },
            ),
          ),
          SizedBox(width: spacing),
          Text(
            'No',
            style: GoogleFonts.getFont(
              fontFamily,
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    ],
  );
}
