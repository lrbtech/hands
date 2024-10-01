import 'package:flutter/material.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/disabled_rating_bar_widget.dart';
import 'package:hands_user_app/components/image_border_component.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/user_data.dart';
import 'package:hands_user_app/models/user_info_response.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/store/AppStore.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class MyProviderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      color: context.cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(languages.lblMyProvider, style: boldTextStyle(size: 16)),
          32.height,
          SnapHelperWidget<UserInfoResponse>(
            future: getUserDetail(appStorePro.providerId.validate()),
            loadingWidget: LoaderWidget(),
            onSuccess: (snap) {
              UserDatas data = snap.data!;

              return Container(
                padding: EdgeInsets.all(16),
                decoration: boxDecorationDefault(
                    color: context.scaffoldBackgroundColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ImageBorder(
                            src: data.profileImage.validate(), height: 70),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(data.displayName.validate(),
                                        style: boldTextStyle())
                                    .flexible(),
                                16.width,
                              ],
                            ),
                            4.height,
                            DisabledRatingBarWidget(
                                rating: data.providerServiceRating.validate()),
                          ],
                        ).expand(),
                      ],
                    ),
                    16.height,
                    TextIcon(
                      spacing: 10,
                      onTap: () {
                        launchMail("${data.email.validate()}");
                      },
                      prefix: Image.asset(ic_message,
                          width: 20,
                          height: 20,
                          color: appStore.isDarkMode
                              ? Colors.white
                              : Colors.black),
                      text: data.email.validate(),
                      expandedText: true,
                    ),
                    if (data.address.validate().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          8.height,
                          TextIcon(
                            spacing: 10,
                            onTap: () {
                              launchMap("${data.address.validate()}");
                            },
                            expandedText: true,
                            prefix: Image.asset(ic_location,
                                width: 20,
                                height: 20,
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Colors.black),
                            text: '${data.address.validate()}',
                          ),
                        ],
                      ),
                    8.height,
                    TextIcon(
                      spacing: 10,
                      onTap: () {
                        launchCall(data.contactNumber.validate());
                      },
                      prefix: Image.asset(calling,
                          width: 20,
                          height: 20,
                          color: appStore.isDarkMode
                              ? Colors.white
                              : Colors.black),
                      text: '${data.contactNumber.validate()}',
                      expandedText: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
