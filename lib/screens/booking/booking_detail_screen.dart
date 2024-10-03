import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hands_user_app/component/add_review_dialog.dart';
import 'package:hands_user_app/component/app_common_dialog.dart';
import 'package:hands_user_app/component/back_widget.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/component/price_widget.dart';
import 'package:hands_user_app/component/view_all_label_component.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/booking_data_model.dart';
import 'package:hands_user_app/model/booking_detail_model.dart';
import 'package:hands_user_app/model/extra_charges_model.dart';
import 'package:hands_user_app/model/package_data_model.dart';
import 'package:hands_user_app/model/service_data_model.dart';
import 'package:hands_user_app/model/service_detail_response.dart';
import 'package:hands_user_app/model/user_data_model.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/booking/booking_history_component.dart';
import 'package:hands_user_app/screens/booking/component/booking_detail_handyman_widget.dart';
import 'package:hands_user_app/screens/booking/component/booking_detail_provider_widget.dart';
import 'package:hands_user_app/screens/booking/component/booking_item_component.dart';
import 'package:hands_user_app/screens/booking/component/countdown_component.dart';
import 'package:hands_user_app/screens/booking/component/invoice_request_dialog_component.dart';
import 'package:hands_user_app/screens/booking/component/price_common_widget.dart';
import 'package:hands_user_app/screens/booking/component/reason_dialog.dart';
import 'package:hands_user_app/screens/booking/component/service_proof_list_widget.dart';
import 'package:hands_user_app/screens/booking/component/view_invoice_screen.dart';
import 'package:hands_user_app/screens/booking/handyman_info_screen.dart';
import 'package:hands_user_app/screens/booking/order_tracking_scvreen.dart';
import 'package:hands_user_app/screens/booking/provider_info_screen.dart';
import 'package:hands_user_app/screens/booking/shimmer/booking_detail_shimmer.dart';
import 'package:hands_user_app/screens/booking/tip_screen.dart';
import 'package:hands_user_app/screens/payment/payment_screen.dart';
import 'package:hands_user_app/screens/review/components/review_widget.dart';
import 'package:hands_user_app/screens/review/rating_view_all_screen.dart';
import 'package:hands_user_app/screens/service/service_detail_screen.dart';
import 'package:hands_user_app/screens/wallet/user_wallet_balance_screen.dart';
import 'package:hands_user_app/utils/booking_calculations_logic.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/map_utils.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hands_user_app/component/custom_confirmation_dialog.dart';

import '../../component/empty_error_state_widget.dart';
import '../../model/booking_amount_model.dart';
import '../service/addons/service_addons_component.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  BookingDetailScreen({required this.bookingId});

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Future<BookingDetailResponse>? future;

  bool isSentInvoiceOnEmail = false;

  @override
  void initState() {
    super.initState();
    init(isLoading: false);
  }

  void init({isLoading = true}) async {
    appStore.setLoading(isLoading);
    future = getBookingDetail(
      {
        CommonKeys.bookingId: widget.bookingId.toString(),
        CommonKeys.customerId: appStore.userId
      },
    );
  }

  //region Widgets
  Widget _buildReasonWidget({required BookingDetailResponse snap}) {
    if ((([
          BookingStatusKeys.cancelled,
          BookingStatusKeys.rejected,
          BookingStatusKeys.failed
        ].contains(snap.bookingDetail!.status)) &&
        (snap.bookingDetail!.reason != null &&
            snap.bookingDetail!.reason!.isNotEmpty)))
      return Container(
        padding: EdgeInsets.all(16),
        color: redColor.withOpacity(0.05),
        width: context.width(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.reasonOfRejection, style: secondaryTextStyle()),
            Text(snap.bookingDetail!.reason.validate(),
                style: primaryTextStyle(color: redColor)),
          ],
        ),
      );

    return SizedBox();
  }

  Future<void> sentMail() async {
    hideKeyboard(context);

    if (1 == 1) {
      // formKey.currentState!.save();
      appStore.setLoading(true);

      Map req = {
        UserKeys.email: appStore.userEmail.validate(),
        CommonKeys.bookingId: widget.bookingId.validate(),
      };

      sentInvoiceOnMail(req).then((res) async {
        // toast(res.message.validate());
        if (res.pdf != null) {
          if (res.pdf!.isNotEmpty) {
            if (Platform.isIOS) {
              final storageStatus = await Permission.storage.request();

              if (storageStatus == PermissionStatus.granted) {
                // Proceed with downloading the PDF (rest of your download logic)
                downloadPDF(res.pdf!);
              } else if (storageStatus == PermissionStatus.permanentlyDenied) {
                // User has permanently denied permission
                openAppSettings(); // Open app settings for user to change permissions
              }
            } else {
              final storageStatus =
                  await Permission.manageExternalStorage.request();

              if (storageStatus == PermissionStatus.granted) {
                // Proceed with downloading the PDF (rest of your download logic)
                downloadPDF(res.pdf!);
              } else if (storageStatus == PermissionStatus.permanentlyDenied) {
                // User has permanently denied permission
                openAppSettings(); // Open app settings for user to change permissions
              } else {}
            }
          }
        }
      }).catchError((e) {
        toast(e.toString(), print: true);
      }).whenComplete(() => appStore.setLoading(false));
    }
  }

  Future<void> downloadPDF(String url) async {
    if (Platform.isIOS) {
      final storageStatus = await Permission.storage.request();

      if (storageStatus == PermissionStatus.granted) {
        try {
          final response = await get(Uri.parse(url));

          if (response.statusCode == 200) {
            final temporaryDirectory = await getTemporaryDirectory();
            final fileName = url.split('/').last; // Extract filename from URL
            final file = File('${temporaryDirectory.path}/$fileName');

            await file.writeAsBytes(response.bodyBytes);

            final fileUri = Uri.parse(file.path);

            print('File path is ${fileUri.toString()}');

            // Proceed with opening the downloaded PDF (use your ViewInvoiceScreen)
            try {
              ViewInvoiceScreen(
                path: fileUri.toString(),
              ).launch(context).then((value) => setState(() {}));
            } catch (e) {
              print('Navigation error is ${e.toString()}');
            }
          } else {
            appStore.setLoading(false);
            // Handle non-200 status code error
            print(
                'Download failed: Status code ${response.statusCode} and -> ${response.body}');
          }
        } on Exception catch (e) {
          // Handle other download errors
          print('Failed to download PDF: ${e.toString()}');
          appStore.setLoading(false);
        }
      } else if (storageStatus == PermissionStatus.permanentlyDenied) {
        // User has permanently denied permission
        openAppSettings(); // Open app settings for user to change permissions
      }
    } else {
      try {
        final response = await get(Uri.parse(url));

        if (response.statusCode == 200) {
          final dir = await getExternalStorageDirectory();

          final fileName = url.split('/').last; // Extract filename from URL
          final file = File('${dir?.absolute.path}/$fileName');

          await file.writeAsBytes(response.bodyBytes);

          final fileUri = Uri.parse(file.path);

          print('File path is ${fileUri.toString()}');

          // finish(context);

          appStore.setLoading(false);
          // finish(context, true);

          try {
            ViewInvoiceScreen(
              path: fileUri.toString(),
            ).launch(context).then((value) => setState(() {}));
          } catch (e) {
            print('Navigation error is ${e.toString()}');
          }
        } else {
          // Handle non-200 status code error
          print(
              'Download failed: Status code ${response.statusCode} and -> ${response.body}');
          // toast(language.downloadInvoiceFailed);
          appStore.setLoading(false);
          // finish(context, true);
        }
      } on Exception catch (e) {
        // Handle other download errors
        // print(e.toString());
        print('Failed to download PDF: ${e.toString()}');
        // toast(language.downloadInvoiceFailed);
        appStore.setLoading(false);
        // finish(context, true);
      }
    }
  }

  Widget _pendingMessage({required BookingDetailResponse snap}) {
    if (snap.bookingDetail!.status == BookingStatusKeys.pending)
      return Container(
        padding: EdgeInsets.all(16),
        color: redColor.withOpacity(0.08),
        width: context.width(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (snap.bookingDetail!.status ==
                    BookingStatusKeys.waitingAdvancedPayment &&
                (snap.service != null && snap.service!.isAdvancePayment) &&
                (snap.bookingDetail!.paymentStatus == null ||
                    snap.bookingDetail!.paymentStatus != PAYMENT_STATUS_PAID))
              Text(language.advancePaymentMessage,
                  style: primaryTextStyle(color: redColor))
            else
              Text(language.lblWaitingForProviderApproval,
                  style: primaryTextStyle(color: redColor)),
          ],
        ),
      );

    return SizedBox();
  }

  Widget bookingIdWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          language.lblBookingID,
          style: boldTextStyle(
            size: LABEL_TEXT_SIZE,
          ),
        ),
        Text('#' + widget.bookingId.validate().toString(),
            style: boldTextStyle(
                color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),//appStore.isDarkMode ? white : primaryColor,
                size: LABEL_TEXT_SIZE)),
      ],
    );
  }

  Widget buildTimeWidget({required BookingData bookingDetail}) {
    // if (bookingDetail.bookingSlot == null) {
    //   return Text(formatDate(bookingDetail.date.validate(), isTime: true), style: boldTextStyle(size: 12)).expand();
    // }
    return Text(
      "${bookingDetail.bookingSlot.validate()}",
      // formatDate(getSlotWithDate(date: bookingDetail.date.validate(), slotTime: bookingDetail.bookingSlot.validate()), isTime: true),
      style: boldTextStyle(size: 12),
    );
  }

  Widget serviceDetailWidget(
      {required BookingData bookingDetail,
      required ServiceData serviceDetail}) {
    return GestureDetector(
      onTap: () {
        if (bookingDetail.isPostJob || bookingDetail.isPackageBooking) {
          //
        } else {
          ServiceDetailScreen(serviceId: bookingDetail.serviceId.validate())
              .launch(context);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingDetail.isPackageBooking)
                Text(bookingDetail.bookingPackage!.name.validate(),
                    style: boldTextStyle(size: LABEL_TEXT_SIZE))
              else
                Text(bookingDetail.serviceName.validate(),
                    style: boldTextStyle(size: LABEL_TEXT_SIZE)),
              12.height,
              Row(
                children: [
                  Text("${language.lblDate}: ", style: secondaryTextStyle()),
                  if (bookingDetail.date.validate().isNotEmpty)
                    Text(formatDate(bookingDetail.date.validate()),
                            style: boldTextStyle(size: 12))
                        .expand(),
                ],
              ).visible(bookingDetail.date.validate().isNotEmpty),
              8.height,
              if (bookingDetail.bookingSlot.validate().isNotEmpty)
                Row(
                  children: [
                    Text("${language.lblTime}: ", style: secondaryTextStyle()),
                    if (bookingDetail.date.validate().isNotEmpty)
                      buildTimeWidget(bookingDetail: bookingDetail),
                  ],
                ).visible(bookingDetail.date.validate().isNotEmpty),
            ],
          ).expand(),
          if (serviceDetail.attachments!.isNotEmpty &&
              !bookingDetail.isPackageBooking)
            CachedImageWidget(
              url: serviceDetail.attachments!.first,
              height: 90,
              width: 90,
              fit: BoxFit.cover,
              radius: 8,
            )
          else
            CachedImageWidget(
              url: bookingDetail.bookingPackage != null
                  ? bookingDetail.bookingPackage!.imageAttachments
                          .validate()
                          .isNotEmpty
                      ? bookingDetail.bookingPackage!.imageAttachments
                              .validate()
                              .first
                              .validate()
                              .isNotEmpty
                          ? bookingDetail.bookingPackage!.imageAttachments
                              .validate()
                              .first
                              .validate()
                          : ''
                      : ''
                  : '',
              height: 90,
              width: 90,
              fit: BoxFit.cover,
              radius: 8,
            )
        ],
      ),
    );
  }

  Widget counterWidget({required BookingDetailResponse value}) {
    if (value.bookingDetail!.isHourlyService &&
        (value.bookingDetail!.status == BookingStatusKeys.inProgress ||
            value.bookingDetail!.status == BookingStatusKeys.hold ||
            value.bookingDetail!.status == BookingStatusKeys.complete ||
            value.bookingDetail!.status == BookingStatusKeys.onGoing))
      return Column(
        children: [
          16.height,
          CountdownWidget(bookingDetailResponse: value),
        ],
      );
    else
      return Offstage();
  }

  Widget serviceProofListWidget({required List<ServiceProof> list}) {
    if (list.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language.lblServiceProof,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: ListView.separated(
            itemBuilder: (context, index) =>
                ServiceProofListWidget(data: list[index]),
            itemCount: list.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 0, color: context.dividerColor);
            },
          ),
        ),
      ],
    );
  }

  Widget handymanWidget(
      {required List<UserData> handymanList,
      required BookingDetailResponse res,
      required ServiceData serviceDetail,
      required BookingData bookingDetail}) {
    if (handymanList.isEmpty) return Offstage();

    if (res.providerData!.id != handymanList.first.id)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          24.height,
          Text(language.lblAboutHandyman,
              style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          16.height,
          Column(
            children: handymanList.map((e) {
              return BookingDetailHandymanWidget(
                handymanData: e,
                serviceDetail: serviceDetail,
                bookingDetail: bookingDetail,
                onUpdate: () {
                  init();
                  setState(() {});
                },
              ).onTap(
                () {
                  HandymanInfoScreen(handymanId: e.id)
                      .launch(context)
                      .then((value) => null);
                },
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              );
            }).toList(),
          ),
        ],
      );
    else
      return Offstage();
  }

  Widget providerWidget({required BookingDetailResponse res}) {
    if (res.providerData == null) return Offstage();
    bool canCustomerContact = res.bookingDetail!.canCustomerContact;
    bool providerIsHandyman = res.handymanData.validate().isNotEmpty &&
        (res.providerData!.id == res.handymanData!.first.id.validate());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.lblAboutProvider,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        BookingDetailProviderWidget(
                providerData: res.providerData!,
                canCustomerContact: canCustomerContact,
                providerIsHandyman: providerIsHandyman)
            .onTap(
          () {
            ProviderInfoScreen(
                    providerId: res.providerData!.id.validate(),
                    canCustomerContact: canCustomerContact)
                .launch(context)
                .then((value) {
              setStatusBarColor(context.primaryColor);
            });
          },
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
      ],
    );
  }

  Widget extraChargesWidget(
      {required List<ExtraChargesModel> extraChargesList}) {
    if (extraChargesList.isEmpty) return Offstage();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.extraCharges,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor, borderRadius: radius()),
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: extraChargesList.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              ExtraChargesModel data = extraChargesList[i];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(data.title.validate(),
                              style: secondaryTextStyle(size: 14))
                          .expand(),
                      16.width,
                      Row(
                        children: [
                          Text('${data.qty} * ${data.price.validate()} = ',
                              style: secondaryTextStyle()),
                          4.width,
                          PriceWidget(
                              price:
                                  '${data.price.validate() * data.qty.validate()}'
                                      .toDouble(),
                              color: textPrimaryColorGlobal,
                              isBoldText: true),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget paymentDetailCard(BookingData bookingData) {
    if (bookingData.paymentId != null && bookingData.paymentStatus != null)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          ViewAllLabel(label: language.paymentDetail, list: []),
          8.height,
          Container(
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.lblID.toUpperCase(),
                        style:
                            boldTextStyle(size: 14, color: Color(0xFF6D7698))),
                    Text("#" + bookingData.paymentId.toString(),
                        style: boldTextStyle()),
                  ],
                ),
                4.height,
                Divider(color: context.dividerColor),
                4.height,
                if (bookingData.paymentMethod.validate().isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.lblMethod,
                          style: boldTextStyle(
                              size: 14, color: Color(0xFF6D7698))),
                      Text(
                        // (bookingData.paymentMethod != null ? bookingData.paymentMethod.toString() : language.notAvailable).capitalizeFirstLetter(),
                        language.paidViaBankCards,
                        style: boldTextStyle(),
                      ),
                    ],
                  ),
                4.height,
                Divider(color: context.dividerColor)
                    .visible(bookingData.paymentMethod != null),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.lblStatus,
                        style:
                            boldTextStyle(size: 14, color: Color(0xFF6D7698))),
                    Text(
                      getPaymentStatusText(
                          bookingData.paymentStatus, bookingData.paymentMethod),
                      style: boldTextStyle(),
                    ),
                  ],
                ),
                if (bookingData.txnId.validate().isNotEmpty &&
                    (bookingData.paymentMethod != PAYMENT_METHOD_COD ||
                        bookingData.paymentMethod !=
                            PAYMENT_METHOD_FROM_WALLET))
                  Column(
                    children: [
                      8.height,
                      Divider(color: context.dividerColor),
                      8.height,
                      Row(
                        children: [
                          Text(language.transactionId,
                              style: boldTextStyle(
                                  size: 14, color: Color(0xFF6D7698))),
                          8.width,
                          Row(
                            children: [
                              Text(bookingData.txnId.validate(),
                                      textAlign: TextAlign.right,
                                      style: boldTextStyle(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)
                                  .expand(),
                              4.width,
                              InkWell(
                                onTap: () async {
                                  await Clipboard.setData(ClipboardData(
                                      text: bookingData.txnId.validate()));
                                  toast(language.copied);
                                },
                                child: SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: Icon(Icons.copy, size: 18)),
                              ),
                            ],
                          ).expand(),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      );

    return Offstage();
  }

  Widget customerReviewWidget(
      {required List<RatingData> ratingList,
      required RatingData? customerReview,
      required BookingData bookingDetail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bookingDetail.status == BookingStatusKeys.complete)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              24.height,
              if (customerReview == null)
                Text(language.lblNotRatedYet,
                    style: boldTextStyle(size: LABEL_TEXT_SIZE))
              else
                Row(
                  children: [
                    16.height,
                    Text(language.yourReview,
                            style: boldTextStyle(size: LABEL_TEXT_SIZE))
                        .expand(),
                    ic_edit_square.iconImage(size: 16).paddingAll(8).onTap(() {
                      showInDialog(
                        context,
                        contentPadding: EdgeInsets.zero,
                        builder: (p0) {
                          return AddReviewDialog(
                              customerReview: customerReview);
                        },
                      ).then((value) {
                        if (value ?? false) {
                          init();
                          setState(() {});
                        }
                      }).catchError((e) {
                        toast(e.toString());
                      });
                    }),
                    ic_delete.iconImage(size: 16).paddingAll(8).onTap(() {
                      showCustomConfirmDialog(
                        context,
                        title: language.lblDeleteReview,
                        subTitle: language.lblConfirmReviewSubTitle,
                        positiveText: language.lblYes,
                        negativeText: language.lblNo,
                        dialogType: DialogType.DELETE,
                        onAccept: (p0) async {
                          appStore.setLoading(true);

                          await deleteReview(id: customerReview.id.validate())
                              .then((value) {
                            toast(value.message);
                          }).catchError((e) {
                            toast(e.toString());
                          });

                          init();
                          setState(() {});
                        },
                      );
                      return;
                    }),
                  ],
                ),
              16.height,
              if (customerReview == null)
                AppButton(
                  color: context.primaryColor,
                  onTap: () {
                    showInDialog(
                      context,
                      contentPadding: EdgeInsets.zero,
                      builder: (p0) {
                        return AddReviewDialog(
                            serviceId: bookingDetail.serviceId.validate(),
                            bookingId: bookingDetail.id.validate());
                      },
                    ).then((value) {
                      if (value) {
                        init();
                        setState(() {});
                      }
                    }).catchError((e) {
                      log(e.toString());
                    });
                  },
                  text: language.btnRate,
                  textColor: Colors.white,
                ).withWidth(context.width())
              else
                ReviewWidget(data: customerReview),
            ],
          ),
        16.height,
        if (ratingList.isNotEmpty)
          ViewAllLabel(
            label: '${language.review} (${bookingDetail.totalReview})',
            list: ratingList,
            onTap: () {
              RatingViewAllScreen(
                      ratingData: ratingList,
                      serviceId: bookingDetail.serviceId)
                  .launch(context);
            },
          ),
        8.height,
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: ratingList.length,
          itemBuilder: (context, index) =>
              ReviewWidget(data: ratingList[index]),
        ),
      ],
    );
  }

  Widget descriptionWidget({required BookingDetailResponse value}) {
    if (value.bookingDetail!.description.validate().isNotEmpty)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Text("${language.hintDescription}",
              style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          8.height,
          ReadMoreText(
            value.bookingDetail!.description.validate(),
            style: secondaryTextStyle(),
            colorClickableText: context.primaryColor,
          )
        ],
      );
    else
      return Offstage();
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

  Widget addressDetailWidget({required BookingDetailResponse data}) {
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
          backgroundColor: context.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.bookingDetail!.addressDetails!.address.validate().isNotEmpty)
            titleWidget(
              title: language.addressTitle,
              detail: data.bookingDetail!.addressDetails!.address.validate(),
              detailTextStyle: boldTextStyle(),
            ),
          // Row(
          //   children: [
          //     if (data.bookingDetail!.description.validate().isNotEmpty)
          //       titleWidget(
          //         title: appStore.selectedLanguageCode == 'en' ? 'Address Title' : 'اسم العنوان',
          //         detail: data.bookingDetail!.addressDetails!.name.validate().capitalizeFirstLetter(),
          //         detailTextStyle: primaryTextStyle(),
          //         isReadMore: false,
          //       ),
          //     if (data.bookingDetail!.addressDetails!.villaNumber.validate().isNotEmpty)
          //       Container(
          //         width: 1,
          //         height: 50,
          //         color: grey.withOpacity(.2),
          //       ).paddingSymmetric(horizontal: 10),
          //     if (data.bookingDetail!.addressDetails!.villaNumber.validate().isNotEmpty)
          //       titleWidget(
          //         title: appStore.selectedLanguageCode == 'en' ? 'Building name / Villa number' : 'اسم المبنى / رقم الفيلا',
          //         detail: data.bookingDetail!.addressDetails!.villaNumber.validate(),
          //         detailTextStyle: primaryTextStyle(),
          //         isReadMore: false,
          //       ),
          //   ],
          // ),

          if (data.bookingDetail!.addressDetails!.latitude != null &&
              data.bookingDetail!.addressDetails!.longitude != null)
            AppButton(
              width: context.width(),
              color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.map,
                    color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ,
                  ),
                  10.width,
                  Text(
                    appStore.selectedLanguageCode == 'en'
                        ? 'Show location on map'
                        : 'عرض الموقع على الخريطة',
                    style: boldTextStyle(color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ),
                  )
                ],
              ),
              onTap: () {
                MapUtils.openMap(
                    data.bookingDetail!.addressDetails!.latitude.toDouble(),
                    data.bookingDetail!.addressDetails!.longitude.toDouble());
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

  Widget packageWidget({required BookingPackage? package}) {
    if (package == null) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language.includedInThisPackage, style: boldTextStyle()),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: package.serviceList!.length,
          padding: EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (_, i) {
            ServiceData data = package.serviceList![i];

            return Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: radius(),
                backgroundColor: context.cardColor,
                border: appStore.isDarkMode
                    ? Border.all(color: context.dividerColor)
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedImageWidget(
                    url: data.attachments!.isNotEmpty
                        ? data.attachments!.first.validate()
                        : "",
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    radius: 8,
                  ),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.name.validate(),
                          style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                      4.height,
                      if (data.subCategoryName.validate().isNotEmpty)
                        Marquee(
                          child: Row(
                            children: [
                              Text('${data.categoryName}',
                                  style: boldTextStyle(
                                      color: textSecondaryColorGlobal)),
                              Text('  >  ',
                                  style: boldTextStyle(
                                      color: textSecondaryColorGlobal)),
                              Text('${data.subCategoryName}',
                                  style: boldTextStyle(
                                      color: context.primaryColor)),
                            ],
                          ),
                        )
                      else
                        Text('${data.categoryName}',
                            style: secondaryTextStyle()),
                      4.height,
                      PriceWidget(
                        price: data.price.validate(),
                        hourlyTextColor: Colors.white,
                      ),
                    ],
                  ).flexible()
                ],
              ),
            ).onTap(
              () {
                ServiceDetailScreen(serviceId: data.id!).launch(context);
              },
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
            );
          },
        )
      ],
    );
  }

  Widget myServiceList({required List<ServiceData> serviceList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.myServices, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        8.height,
        AnimatedListView(
          itemCount: serviceList.length,
          shrinkWrap: true,
          listAnimationType: ListAnimationType.FadeIn,
          itemBuilder: (_, i) {
            ServiceData data = serviceList[i];

            return Container(
              width: context.width(),
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(8),
              decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.cardColor,
                  borderRadius:
                      BorderRadius.all(Radius.circular(defaultRadius))),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: data.attachments.validate().isNotEmpty
                        ? data.attachments!.first.validate()
                        : "",
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                    radius: defaultRadius,
                  ),
                  16.width,
                  Text(data.name.validate(),
                          style: primaryTextStyle(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis)
                      .expand(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _handlePendingApproval({
    required BookingDetailResponse val,
    bool isAddExtraCharges = false,
    bool isEditExtraCharges = false,
  }) async {
    appStore.setLoading(true);

    Map req = {
      CommonKeys.id: val.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: val.bookingDetail!.startAt.toString(),
      BookingUpdateKeys.endAt: val.bookingDetail!.endAt.toString(),
      CommonKeys.status: BookingStatusKeys.complete,
      BookingUpdateKeys.durationDiff: 0,
      BookingUpdateKeys.paymentStatus:
          val.bookingDetail!.paymentStatus.validate(),
    };

    await updateBooking(req).then((res) async {
      //
      init();
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  Widget _action({required BookingDetailResponse bookingResponse}) {
    if ((bookingResponse.service != null &&
            bookingResponse.service!.isAdvancePayment &&
            bookingResponse.bookingDetail!.bookingPackage == null) &&
        (bookingResponse.bookingDetail!.paymentStatus == null ||
            (bookingResponse.bookingDetail!.paymentStatus ==
                    SERVICE_PAYMENT_STATUS_ADVANCE_PAID &&
                bookingResponse.bookingDetail!.status ==
                    BookingStatusKeys.complete))) {
      return AppButton(
        text: bookingResponse.bookingDetail!.paymentStatus ==
                    SERVICE_PAYMENT_STATUS_ADVANCE_PAID &&
                bookingResponse.bookingDetail!.status ==
                    BookingStatusKeys.complete
            ? language.lblPayNow
            : language.payAdvance,
        textColor: Colors.white,
        color: Colors.green,
        onTap: () {
          PaymentScreen(bookings: bookingResponse, isForAdvancePayment: true)
              .launch(context);
        },
      ).paddingOnly(left: 16, right: 16, bottom: 16);
    } else if (bookingResponse.bookingDetail!.status ==
            BookingStatusKeys.accept &&
        bookingResponse.bookingDetail!.paymentId == null) {
      return AppButton(
        text: language.lblPayNow,
        textColor: Colors.white,
        color: Colors.green,
        onTap: () {
          PaymentScreen(bookings: bookingResponse, isForAdvancePayment: false)
              .launch(
            context,
            duration: Duration.zero,
          );
        },
      ).paddingOnly(left: 16, right: 16, bottom: 16);
    } else if (bookingResponse.bookingDetail!.status ==
        BookingStatusKeys.pending) {
      return AppButton(
        text: language.lblCancelBooking,
        textColor: Colors.white,
        color: primaryColor,
        onTap: () {
          _handleCancelClick(status: bookingResponse);
        },
      ).paddingOnly(left: 16, right: 16, bottom: 16);
    } else if (bookingResponse.bookingDetail!.status ==
        BookingStatusKeys.onGoing) {
      return Column(
        children: [
          AppButton(
            width: context.width(),
            text: appStore.isArabic ? 'تتبع الطلب' : 'Track Order',
            textColor: Colors.white,
            color: primaryColor,
            onTap: () {
              print(
                  'Location latitude is ${bookingResponse.bookingDetail!.addressDetails!.latitude.validate().toDouble()}');
              print(
                  'Location longitude is ${bookingResponse.bookingDetail!.addressDetails!.longitude.validate().toDouble()}');
              print(
                  'providerName is ${bookingResponse.bookingDetail?.providerName}');

              OrderTrackingScreen(
                bookingId: bookingResponse.bookingDetail!.id!,
                userLocation: LatLng(
                  bookingResponse.bookingDetail!.addressDetails!.latitude
                      .validate()
                      .toDouble(),
                  bookingResponse.bookingDetail!.addressDetails!.longitude
                      .validate()
                      .toDouble(),
                ),
                driverName: bookingResponse.bookingDetail?.providerName,
              ).launch(context);
            },
          ).paddingOnly(left: 16, right: 16, bottom: 8),
          AppButton(
            width: context.width(),
            text: language.lblStart,
            textColor: Colors.white,
            color: Colors.green,
            onTap: () {
              _handleStartClick(status: bookingResponse);
            },
          ).paddingOnly(left: 16, right: 16, bottom: 16),
        ],
      );
    } else if (bookingResponse.bookingDetail!.status ==
        BookingStatusKeys.inProgress) {
      return 1 == 1
          ? Container(
              width: context.width(),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: context.cardColor),
              child: Text(
                      appStore.selectedLanguageCode == 'en'
                          ? 'Waiting until the service provider completes the work ...'
                          : 'في انتظار العمل حتى يكتمل',
                      style: boldTextStyle(),
                      textAlign: TextAlign.center)
                  .center(),
            )
          : Row(
              children: [
                if (!bookingResponse.service!.isOnlineService.validate())
                  AppButton(
                    text: language.lblHold,
                    textColor: Colors.white,
                    color: hold,
                    onTap: () {
                      _handleHoldClick(status: bookingResponse);
                    },
                  ).expand(),
                if (!bookingResponse.service!.isOnlineService.validate())
                  16.width,
                AppButton(
                  text: language.done,
                  textColor: Colors.white,
                  color: primaryColor,
                  onTap: () {
                    _handleDoneClick(status: bookingResponse);
                  },
                ).expand(),
              ],
            ).paddingOnly(left: 16, right: 16, bottom: 16);
    } else if (bookingResponse.bookingDetail!.status ==
        BookingStatusKeys.hold) {
      return Row(
        children: [
          AppButton(
            text: language.lblResume,
            textColor: Colors.white,
            color: primaryColor,
            onTap: () {
              _handleResumeClick(status: bookingResponse);
            },
          ).expand(),
          16.width,
          AppButton(
            text: language.lblCancel,
            textColor: Colors.white,
            color: cancelled,
            onTap: () {
              _handleCancelClick(status: bookingResponse);
            },
          ).expand(),
        ],
      ).paddingOnly(left: 16, right: 16, bottom: 16);
    } else if (bookingResponse.bookingDetail!.status ==
        BookingStatusKeys.rejected) {
      return (1 == 1)
          ? Container(
              color: white,
              child: Center(
                child: Text(
                  language.messageWhenRejected,
                  style: boldTextStyle(),
                ),
              ),
            )
          : Column(
              children: [
                AppButton(
                  text: appStore.isArabic ? 'موافقة' : 'Approve',
                  textStyle: boldTextStyle(color: white),
                  color: forestGreen,
                  width: context.width(),
                  onTap: () {
                    bool isAnyServiceAddonUnCompleted = bookingResponse
                        .bookingDetail!.serviceaddon
                        .validate()
                        .any((element) => element.status.getBoolInt() == false);
                    showCustomConfirmDialog(
                      context,
                      onAccept: (_) {
                        _handlePendingApproval(
                            val: bookingResponse, isAddExtraCharges: false);
                      },
                      primaryColor: context.primaryColor,
                      positiveText: language.lblYes,
                      negativeText: language.lblNo,
                      subTitle: isAnyServiceAddonUnCompleted
                          ? language.pleaseNoteThatAllServiceMarkedCompleted
                          : null,
                      title: language.confirmationRequestTxt,
                    );
                  },
                ).paddingOnly(left: 16, right: 16, bottom: 8),
                AppButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.message_question,
                        color: white,
                      ),
                      10.width,
                      Text(
                        appStore.selectedLanguageCode == 'en'
                            ? 'Do you need help with this job ?'
                            : 'هل تريد المساعدة في هذا العمل؟',
                        style: boldTextStyle(color: white),
                      )
                    ],
                  ),
                  // text: appStore.selectedLanguageCode == 'en' ? 'Do you need help with this job ?' : 'هل تريد المساعدة في هذا العمل؟',
                  textStyle: boldTextStyle(color: white),
                  color: primaryColor,
                  width: context.width(),
                  onTap: () async {
                    String jobId = "#${bookingResponse.bookingDetail!.id}";
                    String contact = appStore.helplineNumber.validate();
                    String androidUrl =
                        "whatsapp://send?phone=$contact&text=${(appStore.selectedLanguageCode == 'en' ? whatsappString : whatsappStringAr)}${Uri.encodeComponent(jobId)}";
                    String iosUrl =
                        "whatsapp://wa.me/$contact/?text=${(appStore.selectedLanguageCode == 'en' ? whatsappString : whatsappStringAr)}${Uri.encodeComponent(jobId)}";

                    try {
                      if (Platform.isIOS) {
                        await launchUrl(Uri.parse(iosUrl));
                      } else {
                        await launchUrl(Uri.parse(androidUrl));
                      }
                    } on Exception {
                      toast(appStore.selectedLanguageCode == 'en'
                          ? 'WhatsApp Is Not Installed'
                          : 'الواتساب غير متوفر');
                    }
                    // String phoneNumber = "";
                    // if (appStore.helplineNumber.validate().contains('+')) {
                    //   phoneNumber = "${appStore.helplineNumber.validate().replaceAll('-', '')}";
                    // } else {
                    //   phoneNumber = "+${appStore.helplineNumber.validate().replaceAll('-', '')}";
                    // }
                    // launchUrl(Uri.parse('${getSocialMediaLink(LinkProvide r.WHATSAPP)}$phoneNumber'), mode: LaunchMode.externalApplication);
                  },
                ).paddingOnly(left: 16, right: 16, bottom: 16),
              ],
            );
    } else if (bookingResponse.bookingDetail!.status ==
        BookingStatusKeys.pendingApproval) {
      return Container(
        // height: 200,
        width: double.infinity,

        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              language.descriptionWhenPendingApproval,
              style: boldTextStyle(color: black),
            ),
            5.height,
            Text(
              language.doYouConfirm,
              style: boldTextStyle(color: black),
            ),
            10.height,
            Row(
              children: [
                AppButton(
                    text: appStore.isArabic ? 'رفض' : 'Reject',
                    textStyle: boldTextStyle(color: white),
                    color: Colors.redAccent.shade700,
                    onTap: () {
                      // bool isAnyServiceAddonUnCompleted = bookingResponse.bookingDetail!.serviceaddon.validate().any((element) => element.status.getBoolInt() == false);
                      showInDialog(
                        context,
                        contentPadding: EdgeInsets.zero,
                        backgroundColor: context.scaffoldBackgroundColor,
                        builder: (context) {
                          return AppCommonDialog(
                            title: language.confirmRefuse,
                            child: ReasonDialog(
                              status: bookingResponse,
                              currentStatus: BookingStatusKeys.rejected,
                              showLoading: false,
                            ),
                          );
                        },
                      ).then((value) async {
                        if (value != null) {
                          // Navigator.of(context).pop();
                          init();
                          setState(() {});
                        }
                      });
                    }
                    //   showCustomConfirmDialog(
                    //     context,
                    //     onAccept: (_) async {
                    //       // _handlePendingApproval(val: bookingResponse, isAddExtraCharges: false);
                    //       Map req = {
                    //         CommonKeys.id: bookingResponse.bookingDetail!.id.validate(),
                    //         BookingUpdateKeys.durationDiff: 0,
                    //         CommonKeys.status: BookingStatusKeys.rejected,
                    //         BookingUpdateKeys.reason: 'REJECT REASON',
                    //       };
                    //       appStore.setLoading(true);
                    //       await updateBooking(req).then((value) {
                    //         init();
                    //         setState(() {});
                    //       }).catchError((e) {
                    //         print(e.toString());
                    //       });
                    //     },
                    //     primaryColor: context.primaryColor,
                    //     positiveText: language.lblYes,
                    //     negativeText: language.lblNo,
                    //     subTitle: isAnyServiceAddonUnCompleted ? language.pleaseNoteThatAllServiceMarkedCompleted : null,
                    //     title: language.confirmationRequestTxt,
                    //   );
                    // },
                    ).expand(),
                10.width,
                AppButton(
                  text: appStore.isArabic ? 'موافقة' : 'Approve',
                  textStyle: boldTextStyle(color: white),
                  color: forestGreen,
                  onTap: () {
                    bool isAnyServiceAddonUnCompleted = bookingResponse
                        .bookingDetail!.serviceaddon
                        .validate()
                        .any((element) => element.status.getBoolInt() == false);
                    showCustomConfirmDialog(
                      context,
                      onAccept: (_) {
                        _handlePendingApproval(
                            val: bookingResponse, isAddExtraCharges: false);
                      },
                      primaryColor: context.primaryColor,
                      positiveText: language.lblYes,
                      negativeText: language.lblNo,
                      subTitle: isAnyServiceAddonUnCompleted
                          ? language.pleaseNoteThatAllServiceMarkedCompleted
                          : null,
                      title: language.confirmAccept,
                    );
                  },
                ).expand(),
              ],
            ),
          ],
        ),
      ).paddingOnly(left: 16, right: 16, bottom: 16);
      // return Container(
      //   width: context.width(),
      //   padding: EdgeInsets.all(16),
      //   decoration: BoxDecoration(color: context.cardColor),
      //   child: Text(language.lblWaitingForResponse, style: boldTextStyle()).center(),
      // );
    } else if (!bookingResponse.bookingDetail!.isFreeService &&
        bookingResponse.bookingDetail!.status == BookingStatusKeys.complete &&
        !isSentInvoiceOnEmail) {
      return Column(
        children: [
          AppButton(
            text: language.requestInvoice,
            textColor: Colors.white,
            color: context.primaryColor,
            width: context.width(),
            onTap: () async {
              sentMail();

              // bool? res = await showInDialog(
              //   context,
              //   contentPadding: EdgeInsets.zero,
              //   dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
              //   barrierDismissible: false,
              //   builder: (_) => InvoiceRequestDialogComponent(bookingId: bookingResponse.bookingDetail!.id.validate()),
              // );

              // if (res ?? false) {
              //   isSentInvoiceOnEmail = res.validate();

              //   init();
              //   setState(() {});
              // }
            },
          ).paddingOnly(left: 16, right: 16, bottom: 8),
          if (bookingResponse.bookingDetail!.tipAmount.validate() == 0)
            AppButton(
              text: language.addTip,
              textColor: Colors.white,
              color: greenColor,
              width: context.width(),
              onTap: () async {
                TipScreen(
                  bookingId: bookingResponse.bookingDetail!.id!,
                  afterPayment: init,
                ).launch(context);
              },
            ).paddingOnly(left: 16, right: 16, bottom: 16),
        ],
      );
    } else if (bookingResponse.bookingDetail!.status ==
        'pending_approval_again') {
      return AppButton(
        text: appStore.isArabic ? 'موافقة' : 'Approve',
        textStyle: boldTextStyle(color: white),
        color: forestGreen,
        width: context.width(),
        onTap: () {
          bool isAnyServiceAddonUnCompleted = bookingResponse
              .bookingDetail!.serviceaddon
              .validate()
              .any((element) => element.status.getBoolInt() == false);
          showCustomConfirmDialog(
            context,
            onAccept: (_) {
              _handlePendingApproval(
                  val: bookingResponse, isAddExtraCharges: false);
            },
            primaryColor: context.primaryColor,
            positiveText: language.lblYes,
            negativeText: language.lblNo,
            subTitle: isAnyServiceAddonUnCompleted
                ? language.pleaseNoteThatAllServiceMarkedCompleted
                : null,
            title: language.confirmationRequestTxt,
          );
        },
      ).paddingOnly(left: 16, right: 16, bottom: 8);
    } else if (bookingResponse.bookingDetail!.status ==
            BookingStatusKeys.complete &&
        isSentInvoiceOnEmail) {
      return Container(
        width: context.width(),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: context.cardColor),
        child: Text(language.sentInvoiceText,
                style: boldTextStyle(), textAlign: TextAlign.center)
            .center(),
      );
    }

    return Offstage();
  }

  //endregion

  //region ActionMethods
  //region Cancel
  void _handleCancelClick({required BookingDetailResponse status}) {
    if (status.bookingDetail!.status == BookingStatusKeys.pending ||
        status.bookingDetail!.status == BookingStatusKeys.accept ||
        status.bookingDetail!.status == BookingStatusKeys.hold) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        builder: (context) {
          return AppCommonDialog(
            title: language.lblCancelReason,
            child: ReasonDialog(status: status),
          );
        },
      ).then((value) {
        if (value != null) {
          init();
          setState(() {});
        }
      });
    }
  }

  //endregion

  //region Hold Click
  void _handleHoldClick({required BookingDetailResponse status}) {
    if (status.bookingDetail!.status == BookingStatusKeys.inProgress) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        backgroundColor: context.scaffoldBackgroundColor,
        builder: (context) {
          return AppCommonDialog(
            title: language.lblConfirmService,
            child: ReasonDialog(
                status: status, currentStatus: BookingStatusKeys.hold),
          );
        },
      ).then((value) async {
        if (value != null) {
          init();
          setState(() {});
        }
      });
    }
  }

  //endregion

  //region Resume Service
  void _handleResumeClick({required BookingDetailResponse status}) {
    showCustomConfirmDialog(
      context,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      negativeText: language.lblNo,
      positiveText: language.lblYes,
      title: language.lblConFirmResumeService,
      onAccept: (c) {
        resumeClick(status: status);
      },
    );
  }

  void resumeClick({required BookingDetailResponse status}) async {
    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: formatBookingDate(DateTime.now().toString(),
          format: BOOKING_SAVE_FORMAT, isLanguageNeeded: false),
      BookingUpdateKeys.endAt: status.bookingDetail!.endAt.validate(),
      BookingUpdateKeys.durationDiff:
          status.bookingDetail!.durationDiff.validate(),
      BookingUpdateKeys.reason: "",
      CommonKeys.status: BookingStatusKeys.inProgress,
      BookingUpdateKeys.paymentStatus:
          status.bookingDetail!.isAdvancePaymentDone
              ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
              : status.bookingDetail!.paymentStatus.validate(),
    };

    appStore.setLoading(true);

    await updateBooking(request).then((res) async {
      toast(language.bookingUpdatedSuccessfully);

      commonStartTimer(
          isHourlyService: status.bookingDetail!.isHourlyService,
          status: BookingStatusKeys.inProgress,
          timeInSec: status.bookingDetail!.durationDiff.validate().toInt());

      init();
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
  }

  //endregion

  //region Start Service
  void startClick({required BookingDetailResponse status}) async {
    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: formatBookingDate(DateTime.now().toString(),
          format: BOOKING_SAVE_FORMAT, isLanguageNeeded: false),
      BookingUpdateKeys.endAt: status.bookingDetail!.endAt.validate(),
      BookingUpdateKeys.durationDiff: 0,
      BookingUpdateKeys.reason: "",
      CommonKeys.status: BookingStatusKeys.inProgress,
      BookingUpdateKeys.paymentStatus:
          status.bookingDetail!.isAdvancePaymentDone
              ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
              : status.bookingDetail!.paymentStatus.validate(),
    };

    appStore.setLoading(true);

    await updateBooking(request).then((res) async {
      // toast(res.message!);
      toast(language.bookingUpdatedSuccessfully);

      commonStartTimer(
          isHourlyService: status.bookingDetail!.isHourlyService,
          status: BookingStatusKeys.inProgress,
          timeInSec: status.bookingDetail!.durationDiff.validate().toInt());

      init();
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  void _handleStartClick({required BookingDetailResponse status}) {
    showCustomConfirmDialog(
      context,
      title: language.startWorkConfirmation,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      negativeText: language.lblNo,
      positiveText: language.lblYes,
      onAccept: (c) {
        startClick(status: status);
      },
    );
  }

  //endregion

  //region Done Service
  void _handleDoneClick({required BookingDetailResponse status}) {
    bool isAnyServiceAddonUnCompleted = status.bookingDetail!.serviceaddon
        .validate()
        .any((element) => element.status.getBoolInt() == false);
    showCustomConfirmDialog(
      context,
      negativeText: language.lblNo,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      title: isAnyServiceAddonUnCompleted
          ? language.confirmation
          : language.lblEndServicesMsg,
      subTitle: isAnyServiceAddonUnCompleted
          ? language.pleaseNoteThatAllServiceMarkedCompleted
          : null,
      positiveText: language.lblYes,
      onAccept: (c) async {
        String endDateTime =
            DateFormat(BOOKING_SAVE_FORMAT).format(DateTime.now());

        log('STATUS.BOOKINGDETAIL!.STARTAT: ${status.bookingDetail!.startAt}');
        num durationDiff = DateTime.parse(endDateTime.validate())
            .difference(
                DateTime.parse(status.bookingDetail!.startAt.validate()))
            .inSeconds;

        Map request = {
          CommonKeys.id: status.bookingDetail!.id.validate(),
          BookingUpdateKeys.startAt: status.bookingDetail!.startAt.validate(),
          BookingUpdateKeys.endAt: endDateTime,
          BookingUpdateKeys.durationDiff: durationDiff,
          BookingUpdateKeys.reason: DONE,
          CommonKeys.status: BookingStatusKeys.pendingApproval,
          BookingUpdateKeys.paymentStatus:
              status.bookingDetail!.isAdvancePaymentDone
                  ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID
                  : status.bookingDetail!.paymentStatus.validate(),
        };

        //TO Complete all service addon on booking
        if (status.bookingDetail!.serviceaddon.validate().isNotEmpty) {
          request.putIfAbsent(
              BookingUpdateKeys.serviceAddon,
              () => status.bookingDetail!.serviceaddon
                  .validate()
                  .map((e) => e.id)
                  .toList());
        }

        /// Perform new calculations if service hourly
        if (status.bookingDetail!.isHourlyService) {
          BookingAmountModel bookingAmountModel = finalCalculations(
            servicePrice: status.bookingDetail!.amount.validate(),
            appliedCouponData: status.couponData,
            discount: status.service!.discount.validate(),
            serviceAddons: serviceAddonStore.selectedServiceAddon,
            taxes: status.bookingDetail!.taxes,
            quantity: status.bookingDetail!.quantity.validate(),
            selectedPackage: status.bookingDetail!.bookingPackage,
            extraCharges: status.bookingDetail!.extraCharges,
            serviceType: status.service!.type!,
            bookingType: status.bookingDetail!.bookingType!,
            durationDiff: durationDiff.toInt(),
          );

          request.addAll(bookingAmountModel.toBookingUpdateJson());
        }

        appStore.setLoading(true);

        log('RES: ${jsonEncode(request)}');
        await updateBooking(request).then((res) async {
          // toast(res.message!);
          toast(language.bookingUpdatedSuccessfully);
          commonStartTimer(
              isHourlyService: status.bookingDetail!.isHourlyService,
              status: BookingStatusKeys.complete,
              timeInSec: status.bookingDetail!.durationDiff.validate().toInt());

          appStore.setLoading(false);
          init();
          setState(() {});
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });
      },
    );
  }

  //region Done Service
  void _handleAddonDoneClick(
      {required BookingDetailResponse status,
      required Serviceaddon serviceAddon}) async {
    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.serviceAddon: [serviceAddon.id],
      BookingUpdateKeys.type: BookingUpdateKeys.serviceAddon,
    };

    appStore.setLoading(true);
    await updateBooking(request).then((res) async {
      // toast(res.message!);
      toast(language.bookingUpdatedSuccessfully);
      appStore.setLoading(false);
      init();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  //endregion

  //region Methods
  void commonStartTimer(
      {required bool isHourlyService,
      required String status,
      required int timeInSec}) {
    if (isHourlyService) {
      Map<String, dynamic> liveStreamRequest = {
        "inSeconds": timeInSec,
        "status": status,
      };
      LiveStream().emit(LIVESTREAM_START_TIMER, liveStreamRequest);
    }
  }

  //endregion

  //region Body
  Widget buildBodyWidget(AsyncSnapshot<BookingDetailResponse> snap) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Stack(
          children: [
            AnimatedScrollView(
              padding: EdgeInsets.only(bottom: 60),
              physics: AlwaysScrollableScrollPhysics(),
              listAnimationType: ListAnimationType.FadeIn,
              children: [
                (snap.data!.bookingDetail!.status == BookingStatusKeys.accept &&
                        snap.data!.bookingDetail?.paymentId == null)
                    ? Container(
                        // height: 100,
                        padding: EdgeInsets.all(16),
                        color: redColor.withOpacity(0.05),
                        width: context.width(),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              color: redColor,
                            ),
                            5.width,
                            Text(
                              appStore.selectedLanguageCode == 'en'
                                  ? 'The request will be on hold until you pay !'
                                  : 'هذا الطلب سيكون مجمد حتى يتم الدفع',
                              style: boldTextStyle(color: redColor),
                            ),
                          ],
                        ),
                      )
                    : Offstage(),
                _buildReasonWidget(snap: snap.data!),
                _pendingMessage(snap: snap.data!),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      8.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            language.lblCategory,
                            style: boldTextStyle(
                              size: LABEL_TEXT_SIZE,
                            ),
                          ),
                          Text(
                              '${getCategoryName(snap.data!.postRequestDetail!.category)}',
                              style: boldTextStyle(
                                  color: appStore.isDarkMode
                                      ? white
                                      : primaryColor,
                                  size: LABEL_TEXT_SIZE)),
                        ],
                      ),

                      8.height,
                      bookingIdWidget(),

                      if (snap.data!.postRequestDetail!.isUrgent == 1)
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
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

                      Divider(height: 32, color: context.dividerColor),

                      /// Service Details
                      serviceDetailWidget(
                          bookingDetail: snap.data!.bookingDetail!,
                          serviceDetail: snap.data!.service!),
                      16.height,
                      Divider(height: 0, color: context.dividerColor),

                      /// Service Counter Time Widget
                      counterWidget(value: snap.data!),

                      /// My Service List
                      // if (snap.data!.postRequestDetail != null && snap.data!.postRequestDetail!.service != null) myServiceList(serviceList: snap.data!.postRequestDetail!.service!),

                      /// Package Info if User selected any Package
                      packageWidget(
                          package: snap.data!.bookingDetail!.bookingPackage),

                      /// Description
                      descriptionWidget(value: snap.data!),

                      // 20.height,

                      Divider(height: 32, color: context.dividerColor),
                      Text("${language.addressTitle}",
                          style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                      8.height,
                      addressDetailWidget(data: snap.data!),
                      Divider(height: 32, color: context.dividerColor),

                      /// Service Proof
                      serviceProofListWidget(
                          list: snap.data!.serviceProof.validate()),

                      /// About Handyman Card
                      handymanWidget(
                        handymanList: snap.data!.handymanData.validate(),
                        res: snap.data!,
                        serviceDetail: snap.data!.service!,
                        bookingDetail: snap.data!.bookingDetail!,
                      ),

                      Text(
                        language.haveAnIssue,
                        style: boldTextStyle(),
                      ),
                      10.height,
                      GestureDetector(
                        onTap: () async {
                          String message =
                              "${language.contactUsOnWhatsAppMessage}${snap.data!.bookingDetail!.id!}.. ";

                          String androidUrl =
                              "whatsapp://send?phone=${appStore.helplineNumber.validate()}&text=$message";
                          String iosUrl =
                              "whatsapp://wa.me/${appStore.helplineNumber.validate()}/?text=$message";

                          print('message = ${message}');

                          print("Android is ${Uri.parse(androidUrl)}");
                          print("iOS is ${Uri.parse(iosUrl)}");

                          try {
                            if (Platform.isIOS) {
                              await launchUrl(Uri.parse(iosUrl));
                            } else {
                              await launchUrl(Uri.parse(androidUrl));
                            }
                          } on Exception {
                            toast(
                                appStore.isArabic
                                    ? 'تطبيق الواتس آب غير مُثبَت على هذا الموبايل'
                                    : 'WhatsApp is not installed on this device.',
                                bgColor: redColor);
                          }
                        },
                        child: SizedBox(
                          height: 50,
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  margin: EdgeInsetsDirectional.only(start: 15),
                                  width: context.width(),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ,
                                  ),
                                  child: Center(
                                    child: Text(
                                      language.contactUsOnWhatsApp,
                                      style: boldTextStyle(
                                        color: appStore.isDarkMode ?  Color(0xFF000C2C) : Color(0xFFFAF9F6)  ,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: greenColor,
                                radius: 30,
                                child: Center(
                                  child: Image.asset(
                                    ic_whatsapp,
                                    height: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// About Provider Card
                      providerWidget(res: snap.data!),

                      ///Add-ons
                      if (snap.data!.bookingDetail!.serviceaddon
                          .validate()
                          .isNotEmpty)
                        AddonComponent(
                          isFromBookingDetails: true,
                          showDoneBtn: snap.data!.bookingDetail!.status ==
                              BookingStatusKeys.inProgress,
                          serviceAddon:
                              snap.data!.bookingDetail!.serviceaddon.validate(),
                          onDoneClick: (p0) {
                            showCustomConfirmDialog(
                              context,
                              onAccept: (_) {
                                _handleAddonDoneClick(
                                    status: snap.data!, serviceAddon: p0);
                              },
                              primaryColor: context.primaryColor,
                              positiveText: language.lblYes,
                              negativeText: language.lblNo,
                              title: language.confirmationRequestTxt,
                            );
                          },
                        ),

                      /// Price Details
                      PriceCommonWidget(
                        bookingDetail: snap.data!.bookingDetail!,
                        serviceDetail: snap.data!.service!,
                        taxes: snap.data!.bookingDetail!.taxes.validate(),
                        couponData: snap.data!.couponData,
                        bookingPackage:
                            snap.data!.bookingDetail!.bookingPackage != null
                                ? snap.data!.bookingDetail!.bookingPackage
                                : null,
                      ),

                      /// Extra charges
                      extraChargesWidget(
                          extraChargesList: snap
                              .data!.bookingDetail!.extraCharges
                              .validate()),

                      /// Payment Detail Card
                      if (snap.data!.service!.type.validate() !=
                          SERVICE_TYPE_FREE)
                        paymentDetailCard(snap.data!.bookingDetail!),

                      /// Customer Review widget
                      customerReviewWidget(
                          ratingList: snap.data!.ratingData.validate(),
                          customerReview: snap.data!.customerReview,
                          bookingDetail: snap.data!.bookingDetail!),
                      if (snap.data!.bookingDetail!.status ==
                          BookingStatusKeys.rejected)
                        40.height,

                      // _action(bookingResponse: snap.data!),
                    ],
                  ),
                ),
                100.height,
              ],
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: snap.data!.bookingDetail!.status ==
                          BookingStatusKeys.pendingApproval
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(bottom: 16),
                  child: _action(bookingResponse: snap.data!),
                )),
          ],
        ),
      ],
    );
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<BookingDetailResponse>(
          future: future,
          initialData: cachedBookingDetailList
              .firstWhere(
                  (element) => element?.$1 == widget.bookingId.validate(),
                  orElse: () => null)
              ?.$2,
          builder: (context, snap) {
            if (snap.hasData) {
              return RefreshIndicator(
                onRefresh: () async {
                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                child: Scaffold(
                  appBar: appBarWidget(
                    snap.hasData
                        ? snap.data!.bookingDetail!.status
                            .validate()
                            .toBookingStatus()
                        : "",
                    color: context.primaryColor,
                    textColor: Colors.white,
                    showBack: true,
                    backWidget: BackWidget(),
                    actions: [
                      if (snap.hasData)
                        TextButton(
                          child: Text(language.lblCheckStatus,
                              style: primaryTextStyle(color: Colors.white)),
                          onPressed: () {
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
                                  minChildSize: 0.2,
                                  maxChildSize: 1,
                                  builder: (context, scrollController) =>
                                      BookingHistoryComponent(
                                          data: snap
                                              .data!.bookingActivity!.reversed
                                              .toList(),
                                          scrollController: scrollController),
                                );
                              },
                            );
                          },
                        ).paddingRight(16)
                    ],
                  ),
                  body: buildBodyWidget(snap),
                ),
              );
            }

            return Scaffold(
              body: snapWidgetHelper(
                snap,
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    imageWidget: ErrorStateWidget(),
                    retryText: language.reload,
                    onRetry: () {
                      init();
                      setState(() {});
                    },
                  );
                },
                loadingWidget: BookingDetailShimmer(),
              ),
            );
          },
        ),
        Observer(
            builder: (context) => LoaderWidget().visible(appStore.isLoading)),
      ],
    );
  }
}
