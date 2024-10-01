import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BackWidget extends StatelessWidget {
  final Function()? onPressed;
  final Color? iconColor;

  BackWidget({this.onPressed, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Color(0xFFF3F4F6),
      ),
      onPressed: onPressed ??
          () {
            finish(context);
          },
      icon: RotatedBox(quarterTurns: appStore.selectedLanguageCode == "ar" ? 2 : 0, child: ic_arrow_left.iconImage(color: iconColor ?? primaryColor)),
    ).paddingAll(10);
  }
}
