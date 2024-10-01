import 'package:flutter/widgets.dart';
import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/component/disabled_rating_bar_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/component/price_widget.dart';
import 'package:hands_user_app/component/view_all_label_component.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/get_my_post_job_list_response.dart';
import 'package:hands_user_app/model/post_job_detail_response.dart';
import 'package:hands_user_app/model/service_data_model.dart';
import 'package:hands_user_app/model/user_data_model.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/booking/component/booking_item_component.dart';
import 'package:hands_user_app/screens/booking/provider_info_screen.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/gallery/gallery_component.dart';
import 'package:hands_user_app/screens/gallery/gallery_screen.dart';
import 'package:hands_user_app/screens/jobRequest/book_post_job_request_screen.dart';
import 'package:hands_user_app/screens/jobRequest/components/bidder_item_component.dart';
import 'package:hands_user_app/screens/payment/payment_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/map_utils.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';

class MyPostDetailScreen extends StatefulWidget {
  final int postRequestId;
  final PostJobData? postJobData;
  final VoidCallback callback;

  MyPostDetailScreen(
      {required this.postRequestId, this.postJobData, required this.callback});

  @override
  _MyPostDetailScreenState createState() => _MyPostDetailScreenState();
}

// postJobDetailResponse.postRequestDetail;
class _MyPostDetailScreenState extends State<MyPostDetailScreen> {
  Future<PostJobDetailResponse>? future;

  int page = 1;
  bool isLastPage = false;
  num? serviceId;

  @override
  void initState() {
    super.initState();
    LiveStream().on(LIVESTREAM_UPDATE_BIDER, (p0) {
      init();
      setState(() {});
    });

    init();
  }

  void init() async {
    future = getPostJobDetail(
        {PostJob.postRequestId: widget.postRequestId.validate()});
  }

  Widget titleWidget(
      {required String title,
      required String detail,
      bool isUrgent = false,
      bool isReadMore = false,
      required TextStyle detailTextStyle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text('${widget.postJobData?.address}'),

        4.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title.validate(), style: secondaryTextStyle()),
            if (isUrgent)
              Container(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/urgent.png',
                      width: 30,
                    ),
                    6.width,
                    Text(
                      appStore.isArabic ? 'عاجل' : 'Urgent',
                      style: boldTextStyle(color: redColor),
                    )
                  ],
                ),
              ).paddingSymmetric(horizontal: 3),
          ],
        ),
        4.height,
        if (isReadMore)
          ReadMoreText(
            detail,
            style: detailTextStyle,
            colorClickableText: context.primaryColor,
          )
        else
          Text(detail.validate(), style: boldTextStyle(size: 12)),
        20.height,
      ],
    );
  }

  Widget postJobDetailWidget({required PostJobData data}) {
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.lblCategory, style: secondaryTextStyle()),
          Text('${getCategoryName(data.category)}',
              style: boldTextStyle(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (data.title.validate().isNotEmpty)
            titleWidget(
                title: language.postJobTitle,
                detail: data.title.validate(),
                detailTextStyle: boldTextStyle(),
                isUrgent: data.isUrgentRequest),
          if (data.description.validate().isNotEmpty)
            titleWidget(
              title: language.postJobDescription,
              detail: data.description.validate(),
              detailTextStyle: boldTextStyle(),
              isReadMore: true,
            ),
          Row(
            children: [
              if (data.date.validate().isNotEmpty)
                titleWidget(
                  title: language.lblDateAndTime,
                  detail: data.date.validate().substring(0, 11),
                  detailTextStyle: boldTextStyle(),
                  isReadMore: false,
                ),
              if (data.timeSlot.validate().isNotEmpty)
                Container(
                  width: 1,
                  height: 50,
                  color: grey.withOpacity(.2),
                ).paddingSymmetric(horizontal: 20),
              if (data.timeSlot.validate().isNotEmpty)
                titleWidget(
                  title: language.lblTime,
                  detail: appStore.selectedLanguageCode == 'en'
                      ? data.timeSlot.validate()
                      : data.timeSlotAr.validate(),
                  detailTextStyle: boldTextStyle(),
                  isReadMore: false,
                ),
            ],
          ),
          Row(
            children: [],
          ),
          Text(
              data.status.validate() == JOB_REQUEST_STATUS_ASSIGNED
                  ? language.jobPrice
                  : language.estimatedPrice,
              style: secondaryTextStyle()),
          4.height,
          // [null, 0].contains(data.jobPrice)
          //     ? Text(
          //         '-',
          //         style: boldTextStyle(),
          //       )
          //     :
          PriceWidget(
            price: data.status.validate() == JOB_REQUEST_STATUS_ASSIGNED
                ? data.jobPrice.validate()
                : data.price.validate(),
            isHourlyService: false,
            color: textPrimaryColorGlobal,
            isFreeService: false,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget addressDetailWidget({required PostJobData data}) {
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.address!.address.validate().isNotEmpty)
            titleWidget(
              title: language.addressTitle,
              detail: data.address!.address.validate(),
              detailTextStyle: boldTextStyle(),
            ),
          Row(
            children: [
              if (data.description.validate().isNotEmpty)
                titleWidget(
                  title: appStore.selectedLanguageCode == 'en'
                      ? 'Address Title'
                      : 'اسم العنوان',
                  detail: data.address!.name.validate().capitalizeFirstLetter(),
                  detailTextStyle: primaryTextStyle(),
                  isReadMore: false,
                ),
              if (data.address!.villaNumber.validate().isNotEmpty)
                Container(
                  width: 1,
                  height: 50,
                  color: grey.withOpacity(.2),
                ).paddingSymmetric(horizontal: 10),
              if (data.address!.villaNumber.validate().isNotEmpty)
                titleWidget(
                  title: appStore.selectedLanguageCode == 'en'
                      ? 'Building name / Villa number'
                      : 'اسم المبنى / رقم الفيلا',
                  detail: data.address!.villaNumber.validate(),
                  detailTextStyle: primaryTextStyle(),
                  isReadMore: false,
                ),
            ],
          ),
          if (data.address!.latitude != null && data.address!.longitude != null)
            AppButton(
              width: context.width(),
              color: primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.map,
                    color: white,
                  ),
                  10.width,
                  Text(
                    appStore.selectedLanguageCode == 'en'
                        ? 'Show location on map'
                        : 'عرض الموقع على الخريطة',
                    style: boldTextStyle(color: white),
                  )
                ],
              ),
              onTap: () {
                MapUtils.openMap(data.address!.latitude.toDouble(),
                    data.address!.longitude.toDouble());
              },
            )
          // Text(data.status.validate() == JOB_REQUEST_STATUS_ASSIGNED ? language.jobPrice : language.estimatedPrice, style: secondaryTextStyle()),
          // 4.height,
          // PriceWidget(
          //   price: data.status.validate() == JOB_REQUEST_STATUS_ASSIGNED ? data.jobPrice.validate() : data.price.validate(),
          //   isHourlyService: false,
          //   color: textPrimaryColorGlobal,
          //   isFreeService: false,
          //   size: 14,
          // ),
        ],
      ),
    );
  }

  Widget postJobServiceWidget({required List<ServiceData> serviceList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(language., style: boldTextStyle(size: LABEL_TEXT_SIZE)).paddingOnly(left: 16, right: 16),
        // 8.height,
        AnimatedListView(
          itemCount: serviceList.length,
          padding: EdgeInsets.all(8),
          shrinkWrap: true,
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];
            return Container(
              width: context.width(),
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                children: [
                  HorizontalList(
                    itemCount: data.attachments.validate().length,
                    itemBuilder: (context, index) {
                      return 1 == 1
                          ? GalleryComponent(
                              images: data.attachmentsArray!
                                  .map((e) => e.url!)
                                  .toList(),
                              index: index)
                          : CachedImageWidget(
                              url: data.attachments.validate().isNotEmpty
                                  ? data.attachments![index].validate()
                                  : "",
                              fit: BoxFit.cover,
                              height: 50,
                              width: 50,
                              radius: defaultRadius,
                            ).onTap(() {});
                    },
                  ),
                  // 16.width,
                  // Text(data.name.validate(), style: primaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget bidderWidget(List<BidderData> bidderList,
      {required PostJobDetailResponse postJobDetailResponse}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: language.bidder,
          list: bidderList,
          onTap: () {
            //
          },
        ).paddingSymmetric(horizontal: 16),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: bidderList.length > 4
              ? bidderList.take(4).length
              : bidderList.length,
          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .74),
          itemBuilder: (context, index) {
            return BidderItemComponent(
              fromRealTime: false,
              data: bidderList[index],
              postRequestId: widget.postRequestId.validate(),
              postJobData: postJobDetailResponse.postRequestDetail!,
              postJobDetailResponse: postJobDetailResponse,
              serviceId:
                  postJobDetailResponse.postRequestDetail!.serviceId.validate(),
              afterAccept: () {},
              bidderPrice: bidderList[index].price.validate(),
            );
          },
        ),
        // AnimatedListView(
        //   itemCount: bidderList.length > 4 ? bidderList.take(4).length : bidderList.length,
        //   padding: EdgeInsets.zero,
        //   shrinkWrap: true,
        //   physics: NeverScrollableScrollPhysics(),
        //   listAnimationType: ListAnimationType.FadeIn,
        //   fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        //   itemBuilder: (_, i) {
        //     return BidderItemComponent(
        //       data: bidderList[i],
        //       postRequestId: widget.postRequestId.validate(),
        //       postJobData: postJobDetailResponse.postRequestDetail!,
        //       postJobDetailResponse: postJobDetailResponse,
        //     );
        //   },
        // ),
      ],
    );
  }

  Widget providerWidget(List<BidderData> bidderList, num? providerId) {
    try {
      BidderData? bidderData =
          bidderList.firstWhere((element) => element.providerId == providerId);
      UserData? user = bidderData.provider;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Text(language.assignedProvider,
              style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          16.height,
          InkWell(
            onTap: () {
              ProviderInfoScreen(providerId: user.id.validate())
                  .launch(context);
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CachedImageWidget(
                        url: user!.profileImage.validate(),
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
                        circle: true,
                      ),
                      8.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Marquee(
                                directionMarguee: DirectionMarguee.oneDirection,
                                child: Text(
                                  user.displayName.validate(),
                                  style: boldTextStyle(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ).expand(),
                            ],
                          ),
                          4.height,
                          if (user.email.validate().isNotEmpty)
                            Marquee(
                              directionMarguee: DirectionMarguee.oneDirection,
                              child: Text(
                                user.email.validate(),
                                style: primaryTextStyle(size: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          6.height,
                          if (user.providersServiceRating != null)
                            DisabledRatingBarWidget(
                                rating: user.providersServiceRating.validate(),
                                size: 14),
                        ],
                      ).expand(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ).paddingOnly(left: 16, right: 16);
    } catch (e) {
      log(e);
      return Offstage();
    }
  }

  void bookServices({required PostJobDetailResponse postJobDetailResponse}) {
    if (postJobDetailResponse.postRequestDetail != null &&
        postJobDetailResponse.postRequestDetail!.service
            .validate()
            .isNotEmpty) {
      serviceId =
          postJobDetailResponse.postRequestDetail!.service!.first.id.validate();
    }

    log(postJobDetailResponse.postRequestDetail!.toJson());

    Map request = {
      CommonKeys.id: "",
      PostJob.postRequestId:
          postJobDetailResponse.postRequestDetail!.id.validate(),
      CommonKeys.serviceId: serviceId,
      CommonKeys.providerId:
          postJobDetailResponse.postRequestDetail!.providerId.toString(),
      CommonKeys.customerId: appStore.userId.toString().toString(),
      CommonKeys.status: BookingStatusKeys.accept,
      CommonKeys.address:
          postJobDetailResponse.postRequestDetail!.address!.address.validate(),
      CommonKeys.date: postJobDetailResponse.postRequestDetail!.date.validate(),
      BookService.amount:
          postJobDetailResponse.postRequestDetail!.jobPrice.validate(),
      BookingServiceKeys.totalAmount:
          postJobDetailResponse.postRequestDetail!.jobPrice.validate(),
      BookingServiceKeys.type: BOOKING_TYPE_USER_POST_JOB,
      BookingServiceKeys.couponId: '',
      BookingServiceKeys.description:
          postJobDetailResponse.postRequestDetail!.description.validate(),
    };
    appStore.setLoading(true);

    saveBooking(request).then((value) {
      appStore.setLoading(false);
      init();
      setState(() {});
      PaymentScreen(
        bookings: value,
      ).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
      // DashboardScreen(redirectToBooking: true).launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_BIDER);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.myPostDetail,
      child: SnapHelperWidget<PostJobDetailResponse>(
        future: future,
        onSuccess: (data) {
          return Stack(
            children: [
              AnimatedScrollView(
                padding: EdgeInsets.only(bottom: 60),
                physics: AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  postJobDetailWidget(data: data.postRequestDetail!)
                      .paddingAll(10),
                  if (data.postRequestDetail!.addressDetails != null)
                    addressDetailWidget(data: data.postRequestDetail!)
                        .paddingAll(10),
                  if (data.postRequestDetail!.service != null &&
                      data.postRequestDetail!.service!.isNotEmpty &&
                      data.postRequestDetail!.service!.first != null &&
                      data.postRequestDetail!.service!.first.attachments
                          .validate()
                          .isNotEmpty)
                    postJobServiceWidget(
                        serviceList:
                            data.postRequestDetail!.service.validate()),

                  if (data.postRequestDetail!.providerId != null)
                    providerWidget(
                      data.biderData.validate(),
                      data.postRequestDetail!.providerId.validate(),
                    ),
                  // else
                  bidderWidget(data.biderData.validate(),
                      postJobDetailResponse: data),
                  10.height,
                ],
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
              ),
              // if (data.postRequestDetail!.status.validate() == JOB_REQUEST_STATUS_ASSIGNED && data.postRequestDetail!.paymentId == null)
              //   Positioned(
              //     bottom: 10,
              //     left: 16,
              //     right: 16,
              //     child: AppButton(
              //       child: Text(language.lblPayNow, style: boldTextStyle(color: white)),
              //       color: context.primaryColor,
              //       width: context.width(),
              //       onTap: () async {
              //         bookServices(postJobDetailResponse: data);
              //       },
              //     ),
              //   ),
              // Positioned(
              //   bottom: 16,
              //   left: 16,
              //   right: 16,
              //   child: AppButton(
              //     child: Text(language.bookTheService, style: boldTextStyle(color: white)),
              //     color: context.primaryColor,
              //     width: context.width(),
              //     onTap: () async {
              //       BookPostJobRequestScreen(
              //         postJobDetailResponse: data,
              //         providerId: data.postRequestDetail!.providerId.validate(),
              //         jobPrice: data.postRequestDetail!.jobPrice.validate(),
              //       ).launch(context);
              //     },
              //   ),
              // ),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading))
            ],
          );
        },
        errorBuilder: (error) {
          return NoDataWidget(
            title: error,
            imageWidget: ErrorStateWidget(),
            retryText: language.reload,
            onRetry: () {
              page = 1;
              appStore.setLoading(true);

              init();
              setState(() {});
            },
          );
        },
        loadingWidget: LoaderWidget(),
      ),
    );
  }
}
