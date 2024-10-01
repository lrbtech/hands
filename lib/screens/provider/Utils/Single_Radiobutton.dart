import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget agreeToPolicyRadioButton({
  required bool isSelected,
  required ValueChanged<bool?> onChanged,
  required BuildContext context,
  bool? error,
  String text = 'I agree to the policy',
  Color? textColor,
  Color? activeColor,
  Color inactiveColor = Colors.grey,
  double fontSize = 16.0,
  FontWeight fontWeight = FontWeight.normal,
  String fontFamily = 'Almarai',
  double spacing = 8.0,
}) {
  activeColor = activeColor ?? Theme.of(context).colorScheme.onBackground;
  textColor = textColor ?? Theme.of(context).colorScheme.onSecondary;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Radio<bool>(
            value: true,
            groupValue: isSelected,
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
            text,
            style: GoogleFonts.getFont(
              fontFamily,
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
      error == true
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Please Agree to Policy!",
                style: TextStyle(color: Colors.red),
              ),
            )
          : SizedBox()
    ],
  );
}
