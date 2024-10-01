import 'package:flutter/material.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';
import 'package:hands_user_app/screens/provider/Widgets/Image_Urls.dart';

Widget socialMediaContainer() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildSocialMediaButton(AppIcons.appleIcon),
      const SizedBox(width: 20),
      _buildSocialMediaButton(AppIcons.googleIcon),
    ],
  );
}

Widget _buildSocialMediaButton(String assetPath) {
  return Container(
    width: 160,
    height: 60,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: const [
        BoxShadow(offset: Offset(0, 1), color: AppColors.greylight)
      ],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Image.asset(assetPath),
  );
}
