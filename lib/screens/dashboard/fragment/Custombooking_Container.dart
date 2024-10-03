import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';
import 'package:hands_user_app/screens/provider/Widgets/Image_Urls.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/main.dart';

Widget custombookingContainer(BuildContext context, int totalJobs, num today) {
  return Container(
    color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
    child: Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          doublecontainer(
            context: context,
            assetPath: AppIcons.incomeIcon,
            title: "Today's\n Earnings",
            value: "AED ${today}",
          ),
          doublecontainer(
              context: context,
              assetPath: AppIcons.fireIcon,
              title: "Total Jobs",
              value: "${totalJobs}",
              valueColor: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ),
        ],
      ),
    ),
  );
}

Widget doublecontainer({
  required BuildContext context,
  required String assetPath,
  required String title,
  required String value,
  Color? valueColor,
}) {
  double width = MediaQuery.sizeOf(context).width;
  return Container(
    height: 117,
    width: width - width * 0.58,
    decoration: BoxDecoration(
      color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: const [
        BoxShadow(
          color: AppColors.greylight,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Image.asset(
              assetPath,
              height: 50,
              width: 50,
            ),
            const SizedBox(width: 3),
            Text(
              title,
              style: GoogleFonts.balooBhaina2(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: value,
            style: GoogleFonts.balooBhaina2(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.pricecolor,
            ),
            children: [
              TextSpan(
                text: '',
                style: GoogleFonts.balooBhaina2(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
