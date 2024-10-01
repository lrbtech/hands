import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';

Widget customDialogContainer(
    {required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required String buttonText,
    String? error_text,
    bool? error,
    bool? network}) {
  return Padding(
    padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 100,
          width: 387,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.purewhite,
              border: Border.all(
                  color: error == true ? Colors.red : AppColors.purewhite)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.almarai(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkstheme,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.almarai(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkstheme,
                    ),
                  ),
                ],
              ),
              Container(
                height: 68,
                width: 79,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.skyblue.withOpacity(0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    network == true
                        ? Image.file(
                            File(imagePath),
                            width: 50,
                            height: 50,
                          )
                        : Image.asset(imagePath),
                    Text(
                      buttonText,
                      style: GoogleFonts.almarai(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkstheme,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        error == true
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "$error_text",
                  style: TextStyle(color: Colors.red),
                ),
              )
            : SizedBox()
      ],
    ),
  );
}
