import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/screens/notification/notification_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

class WelcomeUser extends StatelessWidget {
  const WelcomeUser({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Container(
            decoration: boxDecorationDefault(
              border:
                  Border.all(color: context.scaffoldBackgroundColor, width: 4),
              shape: BoxShape.circle,
            ),
            child: CachedImageWidget(
              url: appStore.userProfileImage,
              height: 44,
              width: 44,
              fit: BoxFit.cover,
              radius: 44 / 2,
            ),
          ),
          10.width,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language.lblWelcome + ' ,',
                style: primaryTextStyle().copyWith(fontSize: 14, color: white),
              ),
              Text(
                (appStore.userFirstName == ''
                        ? (appStore.selectedLanguageCode == 'ar'
                            ? 'يا زائر'
                            : 'Guest')
                        : appStore.userFirstName) +
                    ' !',
                style: boldTextStyle().copyWith(fontSize: 18, color: white),
              )
            ],
          ),
          Spacer(),
          if (appStore.isLoggedIn)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: Theme.of(context).colorScheme.background,
                color: primaryColor,
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 1.8),
                      color: Colors.white54,
                      spreadRadius: 0.2,
                      blurRadius: 1),
                ],
              ),
              height: 45,
              width: 45,
              padding: EdgeInsets.all(4),
              child: Align(
                alignment: Alignment.center,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Iconsax.notification,
                      color: white,
                    ),
                    Observer(builder: (context) {
                      return Positioned(
                        top: -15,
                        right: -10,
                        child: appStore.unreadCount.validate() > 0
                            ? Container(
                                padding: EdgeInsets.all(4),
                                child: FittedBox(
                                  child: Text(appStore.unreadCount.toString(),
                                      style: boldTextStyle(
                                          size: 12, color: Colors.white)),
                                ),
                                decoration: boxDecorationDefault(
                                    color: Color(0xFF20B08D),
                                    shape: BoxShape.circle),
                              )
                            : Offstage(),
                      );
                    })
                  ],
                ),
              ),
            ).onTap(() {
              NotificationScreen().launch(context);
            }, borderRadius: BorderRadius.circular(50)),
          10.width
        ],
      ),
    );
  }
}
