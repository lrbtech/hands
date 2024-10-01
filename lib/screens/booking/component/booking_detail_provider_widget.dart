import 'package:hands_user_app/component/disabled_rating_bar_widget.dart';
import 'package:hands_user_app/component/image_border_component.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/user_data_model.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../chat/user_chat_screen.dart';

class BookingDetailProviderWidget extends StatefulWidget {
  final UserData providerData;
  final bool canCustomerContact;
  final bool providerIsHandyman;

  BookingDetailProviderWidget({required this.providerData, this.canCustomerContact = false, this.providerIsHandyman = false});

  @override
  BookingDetailProviderWidgetState createState() => BookingDetailProviderWidgetState();
}

class BookingDetailProviderWidgetState extends State<BookingDetailProviderWidget> {
  UserData userData = UserData();

  int? flag;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    userData = widget.providerData;

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ImageBorder(src: widget.providerData.profileImage.validate(), height: 70),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.providerData.displayName.validate(), style: boldTextStyle(size: 16)).flexible(),
                      Image.asset(ic_verified, height: 15, width: 15, color: verifyAcColor).paddingSymmetric(horizontal: 5).visible(widget.providerData.isVerifyProvider == 1),
                      16.width,
                      ic_info.iconImage(size: 20),
                    ],
                  ),
                  4.height,
                  DisabledRatingBarWidget(rating: widget.providerData.providersServiceRating.validate()),
                ],
              ).expand(),
            ],
          ),
          if (widget.canCustomerContact)
            Column(
              children: [
                16.height,
                TextIcon(
                  spacing: 10,
                  onTap: () {
                    launchMail("${widget.providerData.email.validate()}");
                  },
                  prefix: Image.asset(ic_message, width: 20, height: 20, color: appStore.isDarkMode ? Colors.white : Colors.black),
                  text: widget.providerData.email.validate(),
                  expandedText: true,
                ),
                if (widget.providerData.address.validate().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      8.height,
                      TextIcon(
                        spacing: 10,
                        onTap: () {
                          launchMap("${widget.providerData.address.validate()}");
                        },
                        expandedText: true,
                        prefix: Image.asset(
                          ic_location,
                          width: 20,
                          height: 20,
                        ),
                        text: '${widget.providerData.address.validate()}',
                      ),
                    ],
                  ),
                8.height,
                TextIcon(
                  spacing: 10,
                  onTap: () {
                    if (!widget.providerIsHandyman) {
                      launchCall(widget.providerData.contactNumber.validate());
                    }
                  },
                  prefix: Image.asset(ic_calling, width: 20, height: 20, color: appStore.isDarkMode ? Colors.white : Colors.black),
                  text: '${widget.providerData.contactNumber.validate()}',
                  expandedText: true,
                ),
              ],
            ),
          // if (widget.providerIsHandyman)
          //   Row(
          //     children: [
          //       if (widget.providerData.contactNumber.validate().isNotEmpty)
          //         AppButton(
          //           child: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               ic_calling.iconImage(size: 18, color: Colors.white),
          //               8.width,
          //               Text(language.lblCall, style: boldTextStyle(color: white)),
          //             ],
          //           ).fit(),
          //           width: context.width(),
          //           color: primaryColor,
          //           elevation: 0,
          //           onTap: () {
          //             launchCall(widget.providerData.contactNumber.validate());
          //           },
          //         ).expand(),
          //       16.width,
          //       AppButton(
          //         child: Row(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             ic_chat.iconImage(size: 18),
          //             8.width,
          //             Text(language.lblChat, style: boldTextStyle()),
          //           ],
          //         ).fit(),
          //         width: context.width(),
          //         elevation: 0,
          //         color: context.scaffoldBackgroundColor,
          //         onTap: () async {
          //           toast(language.pleaseWaitWhileWeLoadChatDetails);
          //           UserData? user = await userService.getUserNull(email: widget.providerData.email.validate());
          //           if (user != null) {
          //             Fluttertoast.cancel();
          //             UserChatScreen(receiverUser: user).launch(context);
          //           } else {
          //             Fluttertoast.cancel();
          //             toast("${widget.providerData.firstName} ${language.isNotAvailableForChat}");
          //           }
          //         },
          //       ).expand(),
          //       16.width,
          //       AppButton(
          //         child: Image.asset(ic_whatsapp, height: 18),
          //         elevation: 0,
          //         color: context.scaffoldBackgroundColor,
          //         onTap: () async {
          //           String phoneNumber = "";
          //           if (widget.providerData.contactNumber.validate().contains('+')) {
          //             phoneNumber = "${widget.providerData.contactNumber.validate().replaceAll('-', '')}";
          //           } else {
          //             phoneNumber = "+${widget.providerData.contactNumber.validate().replaceAll('-', '')}";
          //           }
          //           launchUrl(Uri.parse('${getSocialMediaLink(LinkProvider.WHATSAPP)}$phoneNumber'), mode: LaunchMode.externalApplication);
          //         },
          //       ),
          //     ],
          //   ).paddingTop(8),
        ],
      ),
    );
  }
}
