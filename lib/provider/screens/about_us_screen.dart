import 'package:flutter/material.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/about_model.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/data_provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../components/base_scaffold_widget.dart';
import '../../provider/utils/constant.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<AboutModel> aboutList = getAboutDataModel(context: context);

    return AppScaffold(
      appBarTitle: languages.lblAbout,
      body: AnimatedWrap(
        spacing: 16,
        runSpacing: 16,
        itemCount: aboutList.length,
        listAnimationType: ListAnimationType.FadeIn,
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        scaleConfiguration: ScaleConfiguration(
            duration: 400.milliseconds, delay: 50.milliseconds),
        itemBuilder: (context, index) {
          return Container(
            width: context.width() * 0.5 - 26,
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(),
              backgroundColor: context.cardColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(aboutList[index].image.toString(),
                    height: 22, width: 22, color: context.iconColor),
                8.height,
                Text(aboutList[index].title.toString(),
                    style: boldTextStyle(size: LABEL_TEXT_SIZE)),
              ],
            ),
          ).onTap(
            () async {
              if (index == 0) {
                log(appStore.termConditions.validate());
                if (appStore.selectedLanguageCode == 'en')
                  appStore.setTermConditions(cachedProviderDashboardResponse
                          ?.termConditions?.value
                          .validate() ??
                      TERMS_CONDITION_URL);
                else
                  appStore.setTermConditions(cachedProviderDashboardResponse
                          ?.termConditions?.valueAr
                          .validate() ??
                      TERMS_CONDITION_URL);
                checkIfLink(context, appStore.termConditions.validate(),
                    title: languages.lblTermsAndConditions);
              } else if (index == 1) {
                if (appStore.selectedLanguageCode == 'en')
                  appStore.setPrivacyPolicy(cachedProviderDashboardResponse
                          ?.privacyPolicy?.value
                          .validate() ??
                      TERMS_CONDITION_URL);
                else
                  appStore.setPrivacyPolicy(cachedProviderDashboardResponse
                          ?.privacyPolicy?.valueAr
                          .validate() ??
                      PRIVACY_POLICY_URL);
                checkIfLink(context, appStore.privacyPolicy.validate(),
                    title: languages.lblPrivacyPolicy);
              } else if (index == 2) {
                checkIfLink(context, appStore.inquiryEmail.validate(),
                    title: languages.lblHelpAndSupport);
              } else if (index == 3) {
                checkIfLink(context, appStore.helplineNumber.validate(),
                    title: languages.lblHelpLineNum);
              } else if (index == 4) {
                {
                  if (isAndroid) {
                    if (getStringAsync(PROVIDER_PLAY_STORE_URL).isNotEmpty) {
                      commonLaunchUrl(getStringAsync(PROVIDER_PLAY_STORE_URL),
                          launchMode: LaunchMode.externalApplication);
                    } else {
                      commonLaunchUrl(
                          '${getSocialMediaLink(LinkProvider.PLAY_STORE)}${await getPackageName()}',
                          launchMode: LaunchMode.externalApplication);
                    }
                  } else if (isIOS) {
                    if (getStringAsync(PROVIDER_APPSTORE_URL).isNotEmpty) {
                      commonLaunchUrl(getStringAsync(PROVIDER_APPSTORE_URL),
                          launchMode: LaunchMode.externalApplication);
                    } else {
                      commonLaunchUrl(IOS_LINK_FOR_PARTNER,
                          launchMode: LaunchMode.externalApplication);
                    }
                  }
                }
              }
            },
            borderRadius: radius(),
          );
        },
      ).paddingAll(16),
    );
  }
}
