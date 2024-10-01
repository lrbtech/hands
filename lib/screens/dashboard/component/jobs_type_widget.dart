import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hands_user_app/main.dart';
import 'package:nb_utils/nb_utils.dart';

class JobsTypeWidget extends StatelessWidget {
  final bool urgent;
  final bool today;
  final bool scheduled;

  final VoidCallback onPressed;

  const JobsTypeWidget({
    super.key,
    this.urgent = false,
    this.today = false,
    this.scheduled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Container(
        height: 165,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  urgent ? language.urgentDescription : (today ? language.todayDescription : language.scheduledDescription),
                  style: boldTextStyle(color: appStore.isDarkMode ? white : context.primaryColor, size: 16),
                ),
                5.height,
                Row(
                  children: [
                    Text(
                      '${language.offeredByHands}',
                      style: secondaryTextStyle(color: appStore.isDarkMode ? white : context.primaryColor, size: 10),
                    ),
                    Text(
                      '${appStore.isArabic ? 'هاندز' : 'Hands'}',
                      style: boldTextStyle(color: darkGray, size: 12),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      urgent
                          ? appStore.selectedLanguageCode == 'en'
                              ? 'Urgent'
                              : 'طلب عاجل'
                          : (today ? language.today : language.scheduled),
                      style: boldTextStyle(color: white, size: 16),
                    ),
                  ),
                ),
              ],
            ).expand(),
            20.width,
            SvgPicture.asset(
              urgent ? "assets/icons/urgent_card.svg" : (today ? "assets/icons/today_card.svg" : "assets/icons/scheduled_card.svg"),
              // height: 100,
              width: 120,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
