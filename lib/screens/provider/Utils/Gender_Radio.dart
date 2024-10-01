import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';

Widget genderSelection({
  required BuildContext context,
  required String? selectedGender,
  required ValueChanged<String?> onChanged,
  bool? error,
  Color? activeColor,
  Color? inactiveColor = AppColors.greylight,
  Color? textColor,
  double spacing = 5.0,
  double fontSize = 12.0,
  FontWeight fontWeight = FontWeight.w700,
  String fontFamily = 'Almarai',
}) {
  activeColor = activeColor ?? Theme.of(context).colorScheme.onBackground;
  textColor = textColor ?? Theme.of(context).colorScheme.onSecondary;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Radio<String>(
                value: 'male',
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
                'Male',
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
                value: 'female',
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
                'Female',
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
      ),
      error == true
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Please select gender!",
                style: TextStyle(color: Colors.red),
              ),
            )
          : SizedBox()
    ],
  );
}
