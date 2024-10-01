import 'package:hands_user_app/component/image_border_component.dart';
import 'package:hands_user_app/model/user_data_model.dart';
import 'package:hands_user_app/screens/auth/sign_in_screen.dart';
import 'package:hands_user_app/screens/booking/provider_info_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../network/rest_apis.dart';
import '../screens/booking/component/why_choose_me_bottom_sheet.dart';

class UserInfoWidget extends StatefulWidget {
  final UserData data;
  final bool? isOnTapEnabled;
  final bool forProvider;
  final VoidCallback? onUpdate;

  UserInfoWidget(
      {required this.data,
      this.isOnTapEnabled,
      this.forProvider = true,
      this.onUpdate});

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  @override
  void initState() {
    setStatusBarColor(primaryColor);
    super.initState();
  }

  //Favourite provider
  Future<bool> addProviderToWishList({required int providerId}) async {
    Map req = {"id": "", "provider_id": providerId, "user_id": appStore.userId};
    return await addProviderWishList(req).then((res) {
      toast(language.providerAddedToFavourite);
      return true;
    }).catchError((error) {
      toast(error.toString());
      return false;
    });
  }

  Future<bool> removeProviderToWishList({required int providerId}) async {
    Map req = {"user_id": appStore.userId, 'provider_id': providerId};

    return await removeProviderWishList(req).then((res) {
      toast(language.providerRemovedFromFavourite);
      return true;
    }).catchError((error) {
      toast(error.toString());
      return false;
    });
  }

  Future<void> onTapFavouriteProvider() async {
    if (widget.data.isFavourite == 1) {
      widget.data.isFavourite = 0;
      setState(() {});

      await removeProviderToWishList(providerId: widget.data.id.validate())
          .then((value) {
        if (!value) {
          widget.data.isFavourite = 1;
          setState(() {});
          widget.onUpdate!.call();
        }
      });
    } else {
      widget.data.isFavourite = 1;
      setState(() {});

      await addProviderToWishList(providerId: widget.data.id.validate())
          .then((value) {
        if (!value) {
          widget.data.isFavourite = 0;
          setState(() {});
          widget.onUpdate!.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isOnTapEnabled.validate(value: false)
          ? null
          : () {
              ProviderInfoScreen(providerId: widget.data.id).launch(context);
            },
      child: SizedBox(
        width: context.width(),
        child: Stack(
          children: [
            Container(
              height: context.height() * 0.25,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: radiusCircular()),
                color: context.primaryColor,
              ),
            ),
            Positioned(
              child: Container(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                margin: EdgeInsets.only(top: 0, left: 16, right: 16),
                decoration: boxDecorationDefault(
                  color: context.scaffoldBackgroundColor,
                  border: Border.all(color: context.dividerColor, width: 1),
                  borderRadius: radius(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        //Favourite provider
                        if (widget.data.isProvider)
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: boxDecorationWithShadow(
                                boxShape: BoxShape.circle,
                                backgroundColor: context.cardColor),
                            child: widget.data.isFavourite == 1
                                ? ic_fill_heart.iconImage(
                                    color: favouriteColor, size: 20)
                                : ic_heart.iconImage(
                                    color: unFavouriteColor, size: 20),
                          ).onTap(() async {
                            if (appStore.isLoggedIn) {
                              onTapFavouriteProvider();
                            } else {
                              bool? res = await push(
                                  SignInScreen(returnExpected: true));

                              if (res ?? false) {
                                onTapFavouriteProvider();
                              }
                            }
                          }),
                      ],
                    ),
                    Center(
                      child: ImageBorder(
                        src: widget.data.profileImage.validate(),
                        height: 90,
                      ),
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Marquee(
                              child: Text(widget.data.displayName.validate(),
                                  style: boldTextStyle(size: 18))),
                        ),
                        8.width,
                        Image.asset(ic_verified,
                                height: 18, width: 18, color: verifyAcColor)
                            .visible(widget.data.isVerifyProvider == 1),
                      ],
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.data.designation.validate().isNotEmpty)
                          Marquee(
                            child: Text(
                              widget.data.designation.validate(),
                              style: secondaryTextStyle(
                                size: 12,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(language.lblMemberSince,
                            style: secondaryTextStyle(
                                size: 12, weight: FontWeight.bold)),
                        Text(
                            " ${DateTime.parse(widget.data.createdAt.validate()).year}",
                            style: secondaryTextStyle(
                                size: 12, weight: FontWeight.bold)),
                        8.width,
                        ic_star_fill.iconImage(color: ratingBarColor, size: 11),
                        Text(
                            " ${widget.data.providersServiceRating.validate().toStringAsPrecision(2)}",
                            style: secondaryTextStyle(
                                size: 12, weight: FontWeight.bold)),
                      ],
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            isScrollControlled: true,
                            isDismissible: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: radiusOnly(
                                    topLeft: defaultRadius,
                                    topRight: defaultRadius)),
                            builder: (_) {
                              return DraggableScrollableSheet(
                                initialChildSize: 0.50,
                                minChildSize: 0.50,
                                maxChildSize: 1,
                                builder: (context, scrollController) {
                                  return WhyChooseMeBottomSheet(
                                    whyChooseMe: widget.data.whyChooseMeObj,
                                    aboutMe: widget.data.description.validate(),
                                    scrollController: scrollController,
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Text(language.whyChooseMe,
                            style: boldTextStyle(color: primaryColor)),
                      ),
                    ).visible(widget.data.description.validate().isNotEmpty),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
