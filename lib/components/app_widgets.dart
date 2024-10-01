import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:hands_user_app/components/spin_kit_chasing_dots.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/booking_list_response.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:super_circle/super_circle.dart';
import 'package:toggle_rotate/toggle_rotate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../provider/utils/common.dart';

Widget placeHolderWidget(
    {String? placeHolderImage,
    double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment}) {
  return PlaceHolderWidget(
    height: height,
    width: width,
    alignment: alignment ?? Alignment.center,
  );
}

String commonPrice(num price) {
  var formatter = NumberFormat('#,##,000.00');
  return formatter.format(price);
}

class LoaderWidget extends StatelessWidget {
  final double? size;

  LoaderWidget({this.size});

  @override
  Widget build(BuildContext context) {
    // return SpinKitChasingDots(color: primaryColor, size: size ?? 50);
    return 1 == 1
        ? Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/ic_launcher-playstore.png',
                      width: 80,
                    ).center(),
                    LoadingAnimationWidget.threeArchedCircle(
                      color: primaryColor,
                      size: 100,
                    ).center()
                  ],
                ),
              ),
            ),
          )
        : Center(
            child: SuperCircle(
              size: 150,
              rotateBegin: 1.0,
              rotateEnd: 0.0,
              backgroundCircleColor: Colors.transparent,
              speedRotateCircle: 6000,
              speedChangeShadowColorInner: 2000,
              speedChangeShadowColorOuter: 2000,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.transparent,
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
  }
}

Widget aboutCustomerWidget(
    {BuildContext? context, BookingDatas? bookingDetail}) {
  return Row(
    children: [
      Text(languages.lblAboutCustomer,
              style: boldTextStyle(size: LABEL_TEXT_SIZE))
          .expand(),
      if (bookingDetail!.canCustomerContact)
        Align(
          alignment: Alignment.topRight,
          child: AppButton(
            child: Text(languages.lblGetDirection,
                style: boldTextStyle(color: primaryColor, size: 12)),
            shapeBorder: RoundedRectangleBorder(
                borderRadius: radius(),
                side: BorderSide(color: context!.dividerColor)),
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            elevation: 0,
            enableScaleAnimation: false,
            onTap: () async {
              if (isAndroid) {
                final AndroidIntent intent = AndroidIntent(
                  action: 'action_view',
                  data:
                      'google.navigation:q=${bookingDetail.address.validate()}',
                  package: 'package:com.google.android.apps.maps',
                );
                await intent.launch();
              } else {
                commonLaunchUrl(
                    '$GOOGLE_MAP_PREFIX${Uri.encodeFull(bookingDetail.address.validate())}',
                    launchMode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
    ],
  );
}
