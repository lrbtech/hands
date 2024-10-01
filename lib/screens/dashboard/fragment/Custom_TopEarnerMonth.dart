import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';
import 'package:hands_user_app/screens/provider/Widgets/Image_Urls.dart';
import 'package:hands_user_app/utils/colors.dart';

Widget customTopearnerMonth(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Container(
      height: 175,
      width: 371,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 1,
            color: AppColors.greylight,
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Image.asset(
            AppIcons.logoIcon,
            height: 80,
            width: 80,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Top Earner of Week!",
                  style: GoogleFonts.almarai(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconsText(Icons.waving_hand, Colors.yellow, "Usop"),
                          iconsText(Icons.waving_hand, Colors.yellow, "Jimbe"),
                          iconsText(Icons.waving_hand, Colors.yellow, "kid"),
                        ],
                      ),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconsText(Icons.waving_hand, Colors.yellow, "Sanji"),
                          iconsText(Icons.waving_hand, Colors.yellow, "Robin"),
                          iconsText(Icons.waving_hand, Colors.yellow, "Law"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget iconsText(IconData icon, Color iconColor, String name) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: iconColor, size: 22),
      const SizedBox(width: 5),
      Text(
        name,
        style: GoogleFonts.almarai(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0XFF3D4976),
        ),
      ),
    ],
  );
}
