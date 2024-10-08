import 'package:flutter/material.dart';
import 'package:hands_user_app/components/disabled_rating_bar_widget.dart';
import 'package:hands_user_app/components/handyman_name_widget.dart';
import 'package:hands_user_app/components/image_border_component.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/booking_list_response.dart';
import 'package:hands_user_app/models/service_model.dart';
import 'package:hands_user_app/models/user_data.dart';
import 'package:hands_user_app/screens/chat/user_chat_screen.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/extensions/string_extension.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/booking_detail_response.dart';

class BasicInfoComponent extends StatefulWidget {
  final UserDatas? handymanData;
  final UserDatas? customerData;
  final UserDatas? providerData;
  final ServiceData? service;
  final BookingDetailResponses? bookingInfo;

  /// flag == 0 = customer
  /// flag == 1 = handyman
  /// else provider
  final int flag;
  final BookingDatas? bookingDetail;

  BasicInfoComponent(this.flag,
      {this.customerData,
      this.handymanData,
      this.providerData,
      this.service,
      this.bookingDetail,
      this.bookingInfo});

  @override
  BasicInfoComponentState createState() => BasicInfoComponentState();
}

class BasicInfoComponentState extends State<BasicInfoComponent> {
  UserDatas customer = UserDatas();
  UserDatas provider = UserDatas();
  UserDatas userDatas = UserDatas();
  ServiceData service = ServiceData();

  String? googleUrl;
  String? address;
  String? name;
  String? contactNumber;
  String? profileUrl;
  int? profileId;
  int? handymanRating;

  int? flag;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (widget.flag == 0) {
      profileId = widget.customerData!.id.validate();
      name = widget.customerData!.displayName.validate();
      profileUrl = widget.customerData!.profileImage.validate();
      contactNumber = widget.customerData!.contactNumber.validate();
      address = widget.customerData!.address.validate();

      userDatas = widget.customerData!;
      await userService
          .getUser(email: widget.customerData!.email.validate())
          .then((value) {
        widget.customerData!.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
    } else if (widget.flag == 1) {
      profileId = widget.handymanData!.id.validate();
      name = widget.handymanData!.displayName.validate();
      profileUrl = widget.handymanData!.profileImage.validate();
      contactNumber = widget.handymanData!.contactNumber.validate();
      address = widget.handymanData!.address.validate();

      userDatas = widget.handymanData!;
      await userService
          .getUser(email: widget.handymanData!.email.validate())
          .then((value) {
        widget.handymanData!.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
    } else {
      profileId = widget.providerData!.id.validate();
      name = widget.providerData!.displayName.validate();
      profileUrl = widget.providerData!.profileImage.validate();
      contactNumber = widget.providerData!.contactNumber.validate();
      address = widget.providerData!.address.validate();
      provider = widget.providerData!;
    }
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (profileUrl.validate().isNotEmpty)
                    ImageBorder(src: profileUrl.validate(), height: 65),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          HandymanNameWidget(name: name.validate(), size: 14)
                              .flexible(),
                          if (widget.flag == 1)
                            Row(
                              children: [
                                16.width,
                                ic_info.iconImage(size: 15),
                              ],
                            ),
                        ],
                      ),
                      10.height,
                      if (userDatas.email.validate().isNotEmpty &&
                          widget.flag == 0 &&
                          widget.bookingDetail!.canCustomerContact)
                        Row(
                          children: [
                            ic_message.iconImage(
                                size: 16, color: textSecondaryColorGlobal),
                            6.width,
                            Text(userDatas.email.validate(),
                                    style: secondaryTextStyle())
                                .flexible(),
                          ],
                        ).onTap(() {
                          launchMail(userDatas.email.validate());
                        }),
                      if (widget.bookingDetail != null &&
                          widget.flag == 0 &&
                          widget.bookingDetail!.canCustomerContact)
                        Column(
                          children: [
                            8.height,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                servicesAddress.iconImage(
                                    size: 18, color: textSecondaryColorGlobal),
                                3.width,
                                Text(widget.bookingDetail!.address.validate(),
                                        style: secondaryTextStyle())
                                    .flexible(),
                              ],
                            ),
                          ],
                        )
                            .visible(widget.bookingDetail!.address
                                .validate()
                                .isNotEmpty)
                            .onTap(() {
                          commonLaunchUrl(
                              '$GOOGLE_MAP_PREFIX${Uri.encodeFull(widget.bookingDetail!.address.validate())}',
                              launchMode: LaunchMode.externalApplication);
                        }),
                      if (widget.flag == 1)
                        DisabledRatingBarWidget(
                            rating:
                                userDatas.handymanRating.validate().toDouble(),
                            size: 14),
                    ],
                  ).expand()
                ],
              ),
              if (userDatas.userType.validate() == IS_USER ||
                  widget.bookingInfo != null &&
                      (widget.bookingInfo!.providerData!.id.validate() !=
                          widget.handymanData!.id.validate()))
                if (widget.bookingDetail!.canCustomerContact)
                  Column(
                    children: [
                      // 8.height,
                      // Divider(color: context.dividerColor),
                      8.height,
                      Row(
                        children: [
                          if (contactNumber.validate().isNotEmpty)
                            AppButton(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(calling,
                                      color: white, height: 18, width: 18),
                                  16.width,
                                  Text(languages.lblCall,
                                      style: boldTextStyle(color: white)),
                                ],
                              ),
                              width: context.width(),
                              color: primaryColor,
                              elevation: 0,
                              onTap: () {
                                launchCall(contactNumber.validate());
                              },
                            ).expand(),
                          // if (contactNumber.validate().isNotEmpty) 24.width,
                          // AppButton(
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Image.asset(chat, color: context.iconColor, height: 18, width: 18),
                          //       16.width,
                          //       Text(languages.lblChat, style: boldTextStyle()),
                          //     ],
                          //   ),
                          //   width: context.width(),
                          //   elevation: 0,
                          //   color: context.scaffoldBackgroundColor,
                          //   onTap: () async {
                          //     toast(languages.pleaseWaitWhileWeLoadChatDetails);
                          //     UserData? user = await userService.getUserNull(email: userData.email.validate());
                          //     if (user != null) {
                          //       Fluttertoast.cancel();
                          //       UserChatScreen(receiverUser: user).launch(context);
                          //     } else {
                          //       Fluttertoast.cancel();
                          //       toast("${userData.firstName} ${languages.isNotAvailableForChat}");
                          //     }
                          //   },
                          // ).expand(),
                        ],
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
