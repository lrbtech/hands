import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/component/custom_confirmation_dialog.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/get_my_post_job_list_response.dart';
import 'package:hands_user_app/model/post_job_detail_response.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/booking/provider_info_screen.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/jobRequest/book_post_job_request_screen.dart';
import 'package:hands_user_app/screens/payment/payment_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/extensions/num_extenstions.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/disabled_rating_bar_widget.dart';
import '../../../component/price_widget.dart';

class BidderItemComponent extends StatefulWidget {
  final bool fromRealTime;
  final BidderData data;
  final int? postRequestId;
  final PostJobData postJobData;
  final PostJobDetailResponse? postJobDetailResponse;
  final bool fromAvailableProviders;
  final int serviceId;
  final Function afterAccept;
  final bool bestPrice;
  final num bidderPrice;

  BidderItemComponent({
    required this.data,
    required this.postRequestId,
    required this.postJobData,
    this.postJobDetailResponse,
    this.fromAvailableProviders = false,
    required this.serviceId,
    required this.afterAccept,
    this.bestPrice = false,
    required this.fromRealTime,
    required this.bidderPrice,
  });

  @override
  _BidderItemComponentState createState() => _BidderItemComponentState();
}

class _BidderItemComponentState extends State<BidderItemComponent> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController counterOfferPriceController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> savePostJobReq() async {
    print('Address : ${widget.postJobData.toJson()}');
    showCustomConfirmDialog(
      context,
      negativeText: language.lblNo,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      title:
          '${language.doYouWantToAssign} ${widget.data.provider!.displayName.validate()} ${appStore.selectedLanguageCode == 'en' ? '?' : '؟'}',
      subTitle: appStore.selectedLanguageCode == 'en'
          ? otherSettingStore.disclimerText.validate()
          : otherSettingStore.disclimerTextAr.validate(),
      positiveText: language.lblYes,
      onAccept: (c) async {
        List<int> serviceList = [];

        if (widget.postJobData.service.validate().isNotEmpty) {
          widget.postJobData.service.validate().forEach((element) {
            serviceList.add(element.id.validate());
          });
        }

        Map request = {
          CommonKeys.id: widget.postRequestId.validate(),
          PostJob.providerId: widget.data.providerId.validate(),
          PostJob.jobPrice: widget.data.price.validate(),
          PostJob.status: JOB_REQUEST_STATUS_ASSIGNED,
          PostJob.serviceId: widget.serviceId,
          PostJob.addressId: widget.postJobData.addressId.validate(),
        };
        Map bookingRequest = {
          CommonKeys.id: "",
          CommonKeys.serviceId: widget.serviceId.toString(),
          CommonKeys.providerId: widget.data.provider!.id.validate().toString(),
          CommonKeys.customerId: appStore.userId.toString().toString(),
          BookingServiceKeys.description:
              widget.postJobData.description.validate(),
          CommonKeys.address:
              widget.postJobData.address!.address.validate().toString(),
          CommonKeys.date: widget.postJobData.date.validate(),
          BookService.amount: widget.data.price,
          BookService.quantity: 1,
          BookingServiceKeys.totalAmount: widget.data.price
              .validate()
              .toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS)),
          BookService.bookingAddressId: widget.postJobData.addressId,
          BookingServiceKeys.type: BOOKING_TYPE_USER_POST_JOB,
          "status": BOOKING_STATUS_ACCEPT,
          CouponKeys.discount: null,
          BookingServiceKeys.couponId: null,
          BookingServiceKeys.bookingPackage: null,
          BookingServiceKeys.serviceAddonId: null,
        };

        appStore.setLoading(true);

        await savePostJob(request).then((value) {
          bookingRequest.putIfAbsent(
              "post_request_id", () => widget.postRequestId);
          saveBooking(bookingRequest).then((value2) {
            appStore.setLoading(false);
            toast(value.message.validate());
            widget.afterAccept.call();
            DashboardScreen(
              redirectToBooking: true,
              bookingId: value2.bookingDetail?.id.validate(),
            ).launch(context, isNewTask: true);
          });

          // finish(context);
          // widget.postJobDetailResponse?.postRequestDetail?.jobPrice = widget.data.price.validate();
          // LiveStream().emit(LIVESTREAM_UPDATE_BIDER);
          // PaymentScreen(bookings: bookings).launch(context);
          // BookPostJobRequestScreen(
          //   postJobDetailResponse: widget.postJobDetailResponse!,
          //   providerId: widget.data.providerId.validate(),
          //   jobPrice: widget.data.price.validate(),
          // ).launch(context);
        }).catchError((e) {
          appStore.setLoading(false);
          log(e.toString());
        });
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ProviderInfoScreen(
        //   providerId: widget.data.provider!.id,
        // ).launch(context);
        if (widget.postJobData.providerId == null) {
          savePostJobReq();
        } else {
          ProviderInfoScreen(
            providerId: widget.data.provider!.id,
          ).launch(context);
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        // // padding: EdgeInsets.all(16),
        // decoration: boxDecorationWithRoundedCorners(
        //     backgroundColor: context.cardColor,
        //     borderRadius: BorderRadius.all(Radius.circular(16)),
        //     border: Border.all(
        //       width: 1,
        //       color:
        //     )),

        child: 1 == 1
            ? Container(
                decoration: boxDecorationRoundedWithShadow(12,
                    backgroundColor: context.cardColor),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CachedImageWidget(
                              url:
                                  widget.data.provider!.profileImage.validate(),
                              height: 65,
                              radius: 65,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: -12,
                              right: 0,
                              left: 0,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.scaffoldBackgroundColor,
                                ),
                                // padding: EdgeInsets.all(8),
                                child: Icon(
                                  widget.data.provider?.providerType
                                              ?.toLowerCase() ==
                                          'company'
                                      ? CupertinoIcons.bag_fill
                                      : widget.data.provider?.gender == 'male'
                                          ? Icons.man
                                          : widget.data.provider?.gender ==
                                                  'female'
                                              ? Icons.woman
                                              : Icons.circle,
                                  size: 18,
                                  color: widget.data.provider?.providerType
                                              ?.toLowerCase() ==
                                          'company'
                                      ? black
                                      : widget.data.provider?.gender == 'male'
                                          ? Color(0xFF518EF8)
                                          : widget.data.provider?.gender ==
                                                  'female'
                                              ? Color(0xFFF14336)
                                              : transparentColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        10.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              widget.data.provider?.displayName.validate() ??
                                  "",
                              style: boldTextStyle(),
                            ),
                            Text(
                              widget.data.provider?.providerType
                                          ?.toLowerCase() ==
                                      'individual'
                                  ? (appStore.selectedLanguageCode == 'en'
                                      ? 'Individual'
                                      : 'فردي')
                                  : widget.data.provider?.providerType
                                              ?.toLowerCase() ==
                                          'company'
                                      ? (appStore.selectedLanguageCode == 'en'
                                          ? 'Company'
                                          : 'شركة')
                                      : '',
                              style: secondaryTextStyle(size: 14),
                            ),
                            5.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // DisabledRatingBarWidget(
                                //   rating: widget.data.provider!.providersServiceRating.validate(),
                                //   size: 14,
                                // ),
                                Icon(
                                  Iconsax.star1,
                                  color: greenColor,
                                  size: 22,
                                ),
                                5.width,
                                Text(
                                  widget.data.provider!.providersServiceRating
                                      .toString(),
                                  style: boldTextStyle(),
                                ),
                                5.width,
                                Text(
                                  ' (${widget.data.provider!.totalServiceRating.toString()})',
                                  style: secondaryTextStyle(),
                                )
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Tooltip(
                              message: appStore.selectedLanguageCode == 'en'
                                  ? 'Profile'
                                  : 'الملف الشخصي',
                              child: Icon(Iconsax.info_circle).onTap(() {
                                ProviderInfoScreen(
                                  canCustomerContact: false,
                                  providerId: widget.data.provider?.id,
                                ).launch(context);
                              }),
                            ),
                            15.height,
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/bid.png',
                                  width: 15,
                                  height: 25,
                                  color: appStore.isDarkMode
                                      ? white
                                      : context.primaryColor,
                                ),
                                5.width,
                                PriceWidget(
                                  price: widget.data.price.validate(),
                                  color: widget.fromRealTime
                                      ? (widget.bestPrice
                                          ? Color(0xFF2AB749)
                                          : Color(0xFF961D1D))
                                      : (appStore.isDarkMode
                                          ? white
                                          : context.primaryColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (1 != 1)
                      if (widget.postJobData.providerId == null) 10.height,
                    if (1 != 1)
                      if (widget.postJobData.providerId == null)
                        Row(
                          children: [
                            // Accept offer
                            Expanded(
                              child: AppButton(
                                padding: EdgeInsets.zero,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.thumb_up_alt_outlined,
                                        color: white, size: 16),
                                    4.width,
                                    Text(language.acceptOffer,
                                        style: boldTextStyle(
                                            color: white, size: 12)),
                                  ],
                                ),
                                color: greenColor,
                                onTap: () {
                                  if (widget.postJobData.providerId == null) {
                                    savePostJobReq();
                                  } else {
                                    ProviderInfoScreen(
                                      providerId: widget.data.provider!.id,
                                    ).launch(context);
                                  }
                                },
                              ),
                            ),

                            if (widget.postJobData.price.validate() !=
                                widget.bidderPrice.validate())
                              10.width,

                            // Counter offer
                            if (widget.postJobData.price.validate() !=
                                widget.bidderPrice.validate())
                              Expanded(
                                child: AppButton(
                                  padding: EdgeInsets.zero,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/bid.png',
                                        width: 15,
                                        height: 15,
                                        color: appStore.isDarkMode
                                            ? context.primaryColor
                                            : white,
                                      ),
                                      4.width,
                                      Text(
                                        language.counterOffer,
                                        style: boldTextStyle(
                                            color: !appStore.isDarkMode
                                                ? white
                                                : context.primaryColor,
                                            size: 12),
                                      ),
                                    ],
                                  ),
                                  color: appStore.isDarkMode
                                      ? white
                                      : context.primaryColor,
                                  onTap: () {
                                    counterOfferPriceController.clear();

                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        scrollable: true,
                                        backgroundColor: context.cardColor,
                                        elevation: 0,
                                        content: Form(
                                          key: formKey,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    language.counterOffer,
                                                    style: boldTextStyle(
                                                      size: 18,
                                                    ),
                                                  ).expand(),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: appStore.isDarkMode
                                                          ? white
                                                          : context
                                                              .primaryColor,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              ),

                                              Text(
                                                language
                                                    .counterOfferDescription,
                                                style: primaryTextStyle(
                                                  size: 12,
                                                ),
                                              ),

                                              10.height,
                                              Row(
                                                children: [
                                                  Text(
                                                    language.providerPrice,
                                                    style: primaryTextStyle(
                                                      size: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${widget.data.price.validate().toPriceFormat()}',
                                                    style: boldTextStyle(
                                                      size: 14,
                                                      color: greenColor,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              10.height,

                                              // Price Field.
                                              TextFormField(
                                                controller:
                                                    counterOfferPriceController,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  FilteringTextInputFormatter
                                                      .deny(RegExp(r'^0')),
                                                ],
                                                validator: (newPrice) {
                                                  if (newPrice == null ||
                                                      newPrice.isEmpty) {
                                                    return language
                                                        .requiredText;
                                                  }
                                                  return null;
                                                },
                                                style: primaryTextStyle(
                                                  color: appStore.isDarkMode
                                                      ? white
                                                      : context.primaryColor,
                                                ),
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10),
                                                  prefixIcon: Container(
                                                    height: 15,
                                                    width: 15,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14.0),
                                                    child: Image.asset(
                                                      'assets/images/bid.png',
                                                      color: !appStore
                                                              .isDarkMode
                                                          ? context.primaryColor
                                                          : white,
                                                    ),
                                                  ),
                                                  hintText: language
                                                      .counterOfferPrice,
                                                  hintStyle:
                                                      secondaryTextStyle(),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide:
                                                        BorderSide(color: gray),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide: BorderSide(
                                                        color: greenColor),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color: errorColor),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    borderSide: BorderSide(
                                                        color: appStore
                                                                .isDarkMode
                                                            ? white
                                                            : context
                                                                .primaryColor),
                                                  ),
                                                ),
                                              ),

                                              10.height,

                                              SizedBox(
                                                width: double.maxFinite,
                                                child: AppButton(
                                                  padding: EdgeInsets.zero,
                                                  child: Text(
                                                      language
                                                          .counterOfferTitle,
                                                      style: boldTextStyle(
                                                          color: white,
                                                          size: 12)),
                                                  color: greenColor,
                                                  onTap: () {
                                                    if (formKey.currentState!
                                                        .validate()) {
                                                      Navigator.of(context)
                                                          .pop();
                                                      print('Success');
                                                    }
                                                  },
                                                ),
                                              ),

                                              10.height,

                                              // Warning
                                              if (widget.fromRealTime)
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.warning_amber,
                                                      color: Colors.amber,
                                                    ),
                                                    10.width,
                                                    Expanded(
                                                      child: Text(
                                                        language
                                                            .counterOfferWarning,
                                                        style:
                                                            secondaryTextStyle(
                                                          size: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                    //               DashboardScreen(
                                    //           postJobId: widget.postJobData.id!.toInt(),
                                    //         ).launch(context, isNewTask: true))
                                    //     .catchError((e) {
                                    //   print(e.toString());
                                    //   DashboardScreen(
                                    //     postJobId: widget.postJobData.id!.toInt(),
                                    //   ).launch(context, isNewTask: true);
                                    // });
                                  },
                                ),
                              ),
                          ],
                        ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    child: CachedImageWidget(
                      url: widget.data.provider!.profileImage.validate(),
                      fit: BoxFit.cover,
                      height: 130,
                      width: double.infinity,
                    ),
                  ),
                  8.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Marquee(
                          directionMarguee: DirectionMarguee.oneDirection,
                          child: Text(
                              widget.data.provider?.displayName.validate() ??
                                  "",
                              style: boldTextStyle()),
                        ),
                      ),
                      // 4.height,
                      // if (widget.data.provider!.designation.validate().isNotEmpty)
                      //   Marquee(
                      //     directionMarguee: DirectionMarguee.oneDirection,
                      //     child: Text(widget.data.provider!.designation.validate(), style: primaryTextStyle(size: 12)),
                      //   ).center(),
                      4.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // DisabledRatingBarWidget(
                          //   rating: widget.data.provider!.providersServiceRating.validate(),
                          //   size: 14,
                          // ),
                          Icon(
                            Iconsax.star1,
                            color: greenColor,
                            size: 22,
                          ),
                          5.width,
                          Text(
                            widget.data.provider!.providersServiceRating
                                .toString(),
                            style: boldTextStyle(),
                          )
                        ],
                      ),
                      4.height,
                      Center(
                        child: Marquee(
                          directionMarguee: DirectionMarguee.oneDirection,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${language.bidPrice}: ',
                                  style: secondaryTextStyle()),
                              PriceWidget(
                                price: widget.data.price.validate(),
                                isHourlyService: false,
                                color: textPrimaryColorGlobal,
                                isFreeService: false,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                      8.width,
                      if (widget.postJobData.providerId == null)
                        AppButton(
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: white, size: 16),
                              4.width,
                              Text(language.accept,
                                  style: boldTextStyle(color: white, size: 12)),
                            ],
                          ),
                          color: context.primaryColor,
                          onTap: () {
                            savePostJobReq();
                          },
                        ).paddingSymmetric(horizontal: 10),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
