import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarBrightness: Brightness.light));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.about,
      child: AnimatedScrollView(
        crossAxisAlignment: CrossAxisAlignment.center,
        listAnimationType: ListAnimationType.FadeIn,
        padding: EdgeInsets.symmetric(horizontal: 16),
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        children: [
          Image.asset(about_us_page),
          16.height,
          Text(APP_NAME, style: boldTextStyle(size: 16)),
          8.height,
          Text(APP_NAME_TAG_LINE, style: secondaryTextStyle(), maxLines: 2),
          30.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (appStore.helplineNumber.isNotEmpty)
                Container(
                  // height: 80,
                  // width: 80,
                  padding: EdgeInsets.all(16),
                  decoration: boxDecorationWithRoundedCorners(borderRadius: radius(), backgroundColor: context.scaffoldBackgroundColor),
                  child: Column(
                    children: [
                      Image.asset(ic_calling, height: 22, color: appStore.isDarkMode ? white : primaryColor),
                      4.height,
                      Text(language.lblCall, style: secondaryTextStyle(), textAlign: TextAlign.center),
                    ],
                  ),
                ).onTap(
                  () {
                    log(appStore.helplineNumber);
                    toast(appStore.helplineNumber);
                    launchCall(appStore.helplineNumber);
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
              if (appStore.inquiryEmail.isNotEmpty)
                Container(
                  // height: 80,
                  // width: 80,
                  padding: EdgeInsets.all(16),
                  decoration: boxDecorationWithRoundedCorners(borderRadius: radius(), backgroundColor: context.scaffoldBackgroundColor),
                  child: Column(
                    children: [
                      Image.asset(ic_message, height: 22, color: appStore.isDarkMode ? white : primaryColor),
                      4.height,
                      Text(
                        language.email,
                        style: secondaryTextStyle(),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ).onTap(
                  () {
                    launchMail(appStore.inquiryEmail);
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
            ],
          ),
          25.height,
          Align(
            alignment: !appStore.isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(appStore.isArabic ? getStringAsync(SITE_DESCRIPTION_AR) : getStringAsync(SITE_DESCRIPTION), style: primaryTextStyle(), textAlign: TextAlign.justify),
          ),
          30.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // if (getStringAsync(FACEBOOK_URL).isNotEmpty)
                IconButton(
                  icon: Image.asset(ic_facebook, height: 35),
                  onPressed: () {
                    commonLaunchUrl('https://www.facebook.com/profile.php?id=61559767691065', launchMode: LaunchMode.externalApplication);
                  },
                ),
                // if (getStringAsync(INSTAGRAM_URL).isNotEmpty)
                IconButton(
                  icon: Image.asset(ic_instagram, height: 35),
                  onPressed: () {
                    commonLaunchUrl('https://www.instagram.com/handsappuae/', launchMode: LaunchMode.externalApplication);
                    // commonLaunchUrl(getStringAsync(INSTAGRAM_URL), launchMode: LaunchMode.externalApplication);
                  },
                ),
                // if (getStringAsync(TWITTER_URL).isNotEmpty)
                IconButton(
                  icon: Image.asset(ic_x, height: 35),
                  onPressed: () {
                    commonLaunchUrl('https://x.com/handsappuae', launchMode: LaunchMode.externalApplication);
                    // commonLaunchUrl(getStringAsync(TWITTER_URL), launchMode: LaunchMode.externalApplication);
                  },
                ),
                // if (getStringAsync(LINKEDIN_URL).isNotEmpty)
                IconButton(
                  icon: Image.asset(ic_snapchat, height: 35),
                  onPressed: () {
                    commonLaunchUrl('https://www.snapchat.com/add/handsappuae', launchMode: LaunchMode.externalApplication);
                    // commonLaunchUrl(getStringAsync(LINKEDIN_URL), launchMode: LaunchMode.externalApplication);
                  },
                ),
                // if (getStringAsync(YOUTUBE_URL).isNotEmpty)
                IconButton(
                  icon: Image.asset(ic_tiktok, height: 35),
                  onPressed: () {
                    commonLaunchUrl('https://www.tiktok.com/@handsappuae?lang=en', launchMode: LaunchMode.externalApplication);
                    // commonLaunchUrl(getStringAsync(YOUTUBE_URL), launchMode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ),
          ),
          25.height,
        ],
      ),
    );
  }
}
