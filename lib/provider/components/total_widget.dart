import 'package:flutter/material.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalWidget extends StatelessWidget {
  final String title;
  final String total;
  final String icon;
  final Color? color;
  final bool fullWidth;

  TotalWidget({
    required this.title,
    required this.total,
    required this.icon,
    this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: boxDecorationDefault(
        color: Color(0xFFF5F8FE),
      ),
      width: fullWidth ? double.infinity : context.width() / 2 - 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox(
                  // width: context.width() / 2 - 94,
                  child: Marquee(
                    child: Marquee(
                        child: Text(total.validate(),
                            style: boldTextStyle(color: primaryColor, size: 16),
                            maxLines: 1)),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appStore.isDarkMode ? primaryColor : Colors.white),
                child: Image.asset(icon,
                    width: 18,
                    height: 18,
                    color: appStore.isDarkMode ? white : context.primaryColor),
              ),
            ],
          ),
          8.height,
          Marquee(
              child: Text(title,
                  style: secondaryTextStyle(size: 14, color: primaryColor))),
        ],
      ),
    );
  }
}
