import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';

Widget customTextField({
  required BuildContext context,
  required String hintText,
  required String assets1,
  required bool obscureText,
  bool? error,
  TextEditingController? controller,
  TextInputType keyboardType = TextInputType.text,
  String? assets2,
  String Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 15),
    child: Container(
      decoration: BoxDecoration(
        boxShadow: [
          error == true
              ? BoxShadow(
                  color: Colors.red,
                  offset: Offset(0, 0),
                )
              : BoxShadow(
                  color: AppColors.greylight,
                  offset: Offset(0, 2),
                )
        ],
        border:
            Border.all(color: error == true ? Colors.red : Colors.transparent),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: controller,
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
        decoration: InputDecoration(
          fillColor: AppColors.purewhite,
          filled: true,
          hintText: hintText,
          hintStyle: GoogleFonts.almarai(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.greylight,
          ),
          prefixIcon: assets1.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    assets1,
                    width: 24,
                    height: 24,
                    color: AppColors.greylight,
                  ),
                )
              : null,
          suffixIcon: assets2 != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Image.asset(
                    assets2,
                    width: 24,
                    height: 24,
                    color: AppColors.greylight,
                  ),
                )
              : null,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide.none,
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    ),
  );
}
