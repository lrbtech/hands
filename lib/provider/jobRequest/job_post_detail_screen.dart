import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/cached_image_widget.dart';
import 'package:hands_user_app/components/price_widget.dart';
import 'package:hands_user_app/provider/firebase/firebase_database_service.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/service_model.dart';
import 'package:hands_user_app/models/user_data.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/jobRequest/components/bid_price_dialog.dart';
import 'package:hands_user_app/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:hands_user_app/screens/zoom_image_screen.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/extensions/string_extension.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:hands_user_app/provider/utils/map_utils.dart';
import 'package:hands_user_app/provider/utils/model_keys.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import 'models/bidder_data.dart';
import 'models/post_job_data.dart';

class JobPostDetailScreen extends StatefulWidget {
  final int postJobDataId;
  final String? postJobDataTitle;

  JobPostDetailScreen(
      {required this.postJobDataId, this.postJobDataTitle = ""});

  @override
  _JobPostDetailScreenState createState() => _JobPostDetailScreenState();
}

class _JobPostDetailScreenState extends State<JobPostDetailScreen> {
  late Future<PostJobDetailResponse> future;

  int page = 1;

  @override
  void initState() {
    super.initState();
    print(widget.postJobDataId);
    print(widget.postJobDataId.runtimeType);
    init();
  }

  void init() async {
    future = getPostJobDetail(
        {PostJob.postRequestId: widget.postJobDataId.validate()});
  }

  Widget titleWidget(
      {required String title,
      required String detail,
      bool isReadMore = false,
      required TextStyle detailTextStyle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.validate(), style: secondaryTextStyle()),
        8.height,
        if (isReadMore)
          ReadMoreText(
            detail,
            style: detailTextStyle,
            colorClickableText: context.primaryColor,
          )
        else
          Text(detail.validate(), style: detailTextStyle),
        16.height,
      ],
    );
  }

  Widget postJobDetailWidget({required PostJobData data}) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget(
            title:
                appStorePro.selectedLanguageCode == 'en' ? 'Category' : 'فئة',
            detail: getCategoryName(data.category) ?? '',
            detailTextStyle: primaryTextStyle(),
            isReadMore: true,
          ),
          if (data.title.validate().isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleWidget(
                  title: languages.postJobTitle,
                  detail: data.title.validate(),
                  detailTextStyle: boldTextStyle(),
                ).expand(),
                data.isUrgent == 1
                    ? Column(
                        children: [
                          Image.asset(
                            ic_urgent,
                            height: 30,
                          ),
                          Text(
                            appStorePro.selectedLanguageCode == 'en'
                                ? 'Urgent'
                                : 'عاجل',
                            style: boldTextStyle(
                              color: redColor,
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
              ],
            ),
          if (data.description.validate().isNotEmpty)
            titleWidget(
              title: languages.postJobDescription,
              detail: data.description.validate(),
              detailTextStyle: primaryTextStyle(),
              isReadMore: true,
            ),
          GestureDetector(
            onTap: () async {
              await MapUtils.openMap(
                double.parse(data.addressModel!.latitude!),
                double.parse(data.addressModel!.longitude!),
              );
            },
            child: titleWidget(
              title: languages.lblAddress,
              detail: data.address!.address.validate(),
              detailTextStyle: primaryTextStyle(),
            ),
          ),
          titleWidget(
            title: languages.lblDate,
            detail: getDateFromString(data.date ?? ''),
            detailTextStyle: primaryTextStyle(),
          ),
          if (data.timeslot != null)
            titleWidget(
              title: languages.lblTime,
              detail: appStorePro.selectedLanguageCode == 'en'
                  ? (data.timeslot ?? '')
                  : (data.timeslotAr ?? ''),
              detailTextStyle: primaryTextStyle(),
            ),
        ],
      ),
    );
  }

  Widget postJobServiceWidget({required List<ServiceData> serviceList}) {
    if (serviceList.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        if (serviceList.first.imageAttachments.validate().isNotEmpty)
          Text(languages.serviceImages,
                  style: boldTextStyle(size: LABEL_TEXT_SIZE))
              .paddingOnly(left: 16, right: 16),
        AnimatedListView(
          itemCount: serviceList.length,
          padding: EdgeInsets.all(8),
          shrinkWrap: true,
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];

            return Container(
              width: context.width(),
              // margin: EdgeInsets.all(8),
              // padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...data.imageAttachments!
                        .map(
                          (e) => GestureDetector(
                            onTap: () {
                              ZoomImageScreen(
                                galleryImages: data.imageAttachments!,
                                index: data.imageAttachments!.indexOf(e),
                              ).launch(context);
                            },
                            child: CachedImageWidget(
                              url: e.validate(),
                              fit: BoxFit.cover,
                              height: 120,
                              width: 120,
                              radius: defaultRadius,
                            ).paddingSymmetric(horizontal: 5),
                          ),
                        )
                        .toList(),
                    // 16.width,
                    // Text(data.name.validate(), style: primaryTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget providerWidget(List<BidderData> bidderList) {
    try {
      if (bidderList
          .any((element) => element.providerId == appStorePro.userId)) {
        BidderData? bidderData = bidderList
            .firstWhere((element) => element.providerId == appStorePro.userId);
        UserDatas? user = bidderData.provider;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Text(languages.myBid, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
            16.height,
            Container(
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: user!.profileImage.validate(),
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                    circle: true,
                  ),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Marquee(
                        directionMarguee: DirectionMarguee.oneDirection,
                        child: Text(
                          user.displayName.validate(),
                          style: boldTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      4.height,
                      PriceWidget(price: bidderData.price.validate()),
                    ],
                  ).expand(),
                ],
              ),
            ),
            16.height,
          ],
        ).paddingOnly(left: 16, right: 16);
      }
    } catch (e) {
      print(e);
    }

    return Offstage();
  }

  Widget customerWidget(PostJobData? postJobData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(languages.lblAboutCustomer,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Row(
            children: [
              CachedImageWidget(
                url: postJobData!.customerProfile.validate(),
                fit: BoxFit.cover,
                height: 60,
                width: 60,
                circle: true,
              ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Marquee(
                    directionMarguee: DirectionMarguee.oneDirection,
                    child: Text(
                      postJobData.customerName.validate(),
                      style: boldTextStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  4.height,
                  Text(
                      postJobData.status.validate() ==
                              JOB_REQUEST_STATUS_ACCEPTED
                          ? languages.jobPrice
                          : languages.estimatedPrice,
                      style: secondaryTextStyle()),
                  4.height,
                  PriceWidget(price: postJobData.price.validate()),
                ],
              ).expand(),
            ],
          ),
        ),
        16.height,
      ],
    ).paddingOnly(left: 16, right: 16);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: '${widget.postJobDataTitle}',
      body: Stack(
        children: [
          SnapHelperWidget<PostJobDetailResponse>(
            future: future,
            initialData: cachedPostJobLists
                .firstWhere(
                    (element) => element?.$1 == widget.postJobDataId.validate(),
                    orElse: () => null)
                ?.$2,
            onSuccess: (data) {
              return Stack(
                children: [
                  AnimatedScrollView(
                    padding: EdgeInsets.only(bottom: 60),
                    physics: AlwaysScrollableScrollPhysics(),
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    onSwipeRefresh: () async {
                      page = 1;

                      init();
                      setState(() {});

                      return await 2.seconds.delay;
                    },
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          postJobDetailWidget(data: data.postRequestDetail!)
                              .paddingAll(16),
                          customerWidget(data.postRequestDetail!),
                          providerWidget(data.bidderData.validate()),
                          if (data.postRequestDetail!.service
                              .validate()
                              .isNotEmpty)
                            postJobServiceWidget(
                              serviceList:
                                  data.postRequestDetail!.service.validate(),
                            ),
                          130.height,
                        ],
                      ),
                    ],
                  ),
                  // if (data.postRequestDetail!.providerId == appStorePro.userId && data.postRequestDetail!.status == 'assigned')
                  //   Positioned(
                  //     bottom: 16,
                  //     left: 16,
                  //     right: 16,
                  //     child: AppButton(
                  //       child: Text(languages.confirm, style: boldTextStyle(color: white)),
                  //       color: context.primaryColor,
                  //       width: context.width(),
                  //       onTap: () async {},
                  //     ),
                  //   ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (data.postRequestDetail!.canBid.validate())
                            AppButton(
                              child: Text(languages.bid,
                                  style: boldTextStyle(color: white)),
                              color: context.primaryColor,
                              width: context.width(),
                              onTap: () async {
                                bool? res = await showInDialog(
                                  context,
                                  contentPadding: EdgeInsets.zero,
                                  hideSoftKeyboard: true,
                                  backgroundColor: context.cardColor,
                                  builder: (_) => BidPriceDialog(
                                      data: data.postRequestDetail!),
                                );

                                if (res ?? false) {
                                  init();
                                  setState(() {});
                                }
                              },
                            ).paddingSymmetric(horizontal: 16, vertical: 10),
                          if (data.postRequestDetail!.canBid.validate() &&
                              data.postRequestDetail!.price.validate() >= 1)
                            AppButton(
                              child: Text(languages.accept,
                                  style: boldTextStyle(color: white)),
                              color: greenColor,
                              width: context.width(),
                              onTap: () async {
                                showConfirmDialogCustom(
                                  context,
                                  dialogType: DialogType.ACCEPT,
                                  customCenterWidget: Container(
                                    color: greenColor.withOpacity(.3),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/icons/bid.png',
                                        width: 80,
                                      ),
                                    ),
                                  ),
                                  title: languages.confirmAcceptBid,
                                  positiveText: languages.lblYes,
                                  negativeText: languages.lblNo,
                                  primaryColor: greenColor.withOpacity(.8),
                                  onAccept: (context) async {
                                    appStorePro.setLoading(true);

                                    Map request = {
                                      SaveBidding.postRequestId:
                                          data.postRequestDetail!.id.validate(),
                                      SaveBidding.providerId:
                                          appStorePro.userId.validate(),
                                      SaveBidding.price: data
                                          .postRequestDetail!.price
                                          .validate(),
                                    };

                                    try {
                                      BidderData value = await saveBid(request);
                                      await firebaseDbService.firebaseJobBid(
                                          bidderData: value,
                                          postJobId: data.postRequestDetail!.id
                                              .toString());
                                      appStorePro.setLoading(false);
                                      init();
                                      setState(() {});
                                      // toast(value.message.validate());
                                      finish(context, true);
                                    } catch (e) {
                                      appStorePro.setLoading(false);
                                      print(e.toString());
                                    }
                                  },
                                );
                              },
                            ).paddingSymmetric(horizontal: 16, vertical: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: languages.reload,
                onRetry: () {
                  page = 1;
                  appStorePro.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
            loadingWidget: LoaderWidget(),
          ),
          Observer(
              builder: (context) =>
                  LoaderWidget().visible(appStorePro.isLoading))
        ],
      ),
    );
  }
}

String? getCategoryName(Category? category) {
  if (appStorePro.selectedLanguageCode != 'en') {
    return category?.nameAr ?? 'لا يوجد';
  }

  return category?.name ?? 'No category';
}
