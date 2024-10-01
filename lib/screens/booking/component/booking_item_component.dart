import 'package:hands_user_app/component/app_common_dialog.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/component/price_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/booking_data_model.dart';
import 'package:hands_user_app/screens/booking/component/edit_booking_service_dialog.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/extensions/num_extenstions.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/service_detail_response.dart';
import '../../../network/rest_apis.dart';
import 'booking_slots.dart';

class BookingItemComponent extends StatefulWidget {
  final BookingData bookingData;

  BookingItemComponent({required this.bookingData});

  @override
  State<BookingItemComponent> createState() => _BookingItemComponentState();
}

class _BookingItemComponentState extends State<BookingItemComponent> {
  Widget _buildEditBookingWidget() {
    // if (bookingData.isSlotBooking) return Offstage();
    if (widget.bookingData.status == BookingStatusKeys.pending &&
        isDateTimeAfterNow) {
      return IconButton(
        icon: ic_edit_square.iconImage(size: 18),
        visualDensity: VisualDensity.compact,
        onPressed: () async {
          ServiceDetailResponse res = await getServiceDetails(
              serviceId: widget.bookingData.serviceId.validate(),
              customerId: appStore.userId,
              fromBooking: true);
          if (widget.bookingData.isSlotBooking) {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              shape: RoundedRectangleBorder(
                  borderRadius: radiusOnly(
                      topLeft: defaultRadius, topRight: defaultRadius)),
              builder: (_) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.65,
                  minChildSize: 0.65,
                  maxChildSize: 1,
                  builder: (context, scrollController) => BookingSlotsComponent(
                    data: res,
                    bookingData: widget.bookingData,
                    showAppbar: true,
                    scrollController: scrollController,
                    onApplyClick: () {
                      setState(() {});
                    },
                  ),
                );
              },
            );
          } else {
            showInDialog(
              context,
              contentPadding: EdgeInsets.zero,
              hideSoftKeyboard: true,
              backgroundColor: context.cardColor,
              builder: (p0) {
                return AppCommonDialog(
                  title: language.lblUpdateDateAndTime,
                  child: EditBookingServiceDialog(data: widget.bookingData),
                );
              },
            );
          }
        },
      );
    }
    return Offstage();
  }

  @override
  Widget build(BuildContext context) {
    String buildTimeWidget({required BookingData bookingDetail}) {
      if (bookingDetail.bookingSlot == null) {
        return formatDate(bookingDetail.date.validate(), isTime: true);
      }
      return formatDate(
          getSlotWithDate(
              date: bookingDetail.date.validate(),
              slotTime: bookingDetail.bookingSlot.validate()),
          isTime: true);
    }

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor, borderRadius: radius(24)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.bookingData.isPackageBooking)
                CachedImageWidget(
                  url: widget.bookingData.bookingPackage!.imageAttachments
                          .validate()
                          .isNotEmpty
                      ? widget.bookingData.bookingPackage!.imageAttachments
                          .validate()
                          .first
                          .validate()
                      : "",
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  radius: defaultRadius,
                )
              else
                CachedImageWidget(
                  url: widget.bookingData.serviceAttachments
                          .validate()
                          .isNotEmpty
                      ? widget.bookingData.serviceAttachments!.first.validate()
                      : '',
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                  radius: defaultRadius,
                ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Marquee(
                            child: Text(
                              widget.bookingData.isPackageBooking
                                  ? '${widget.bookingData.bookingPackage!.name.validate()}'
                                  : '${widget.bookingData.serviceName.validate()}',
                              style: boldTextStyle(size: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ).expand(),

                          // if (widget.bookingData.isPostJob)
                          //   Container(
                          //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //     margin: EdgeInsets.only(left: 4),
                          //     decoration: BoxDecoration(
                          //       color: context.primaryColor.withOpacity(0.1),
                          //       borderRadius: radius(8),
                          //     ),
                          //     child: Text(
                          //       language.postJob,
                          //       style: boldTextStyle(color: context.primaryColor, size: 12),
                          //     ),
                          //   ),
                          // if (widget.bookingData.isPackageBooking)
                          //   Container(
                          //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //     margin: EdgeInsets.only(left: 4),
                          //     decoration: BoxDecoration(
                          //       color: context.primaryColor.withOpacity(0.1),
                          //       borderRadius: radius(8),
                          //     ),
                          //     child: Text(
                          //       language.package,
                          //       style: boldTextStyle(color: context.primaryColor, size: 12),
                          //     ),
                          //   ),
                          if (widget.bookingData.isUrgent == 1)
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    'assets/icons/urgent.png',
                                    width: 25,
                                  ),
                                  4.width,
                                  Text(
                                    appStore.isArabic ? 'عاجل' : 'Urgent',
                                    style: boldTextStyle(
                                      color: redColor,
                                      size: 14,
                                    ),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ).expand(),
                    ],
                  ),
                  8.height,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: white,
                    ),
                    child: Text(
                      '${getCategoryName(widget.bookingData.category)}',

                      /// here
                      style: boldTextStyle(color: black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  4.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.bookingData.status
                              .validate()
                              .getPaymentStatusBackgroundColor
                              .withOpacity(0.1),
                          borderRadius: radius(8),
                        ),
                        child: Marquee(
                          child: Text(
                            widget.bookingData.status
                                .validate()
                                .toBookingStatus(),
                            style: boldTextStyle(
                                color: widget.bookingData.status
                                    .validate()
                                    .getPaymentStatusBackgroundColor,
                                size: 12),
                          ),
                        ),
                      ),
                      if (widget.bookingData.status != BookingStatusKeys.refund)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.bookingData.isPaid
                                  ? language.paid
                                  : (appStore.isArabic
                                      ? 'غير مدفوع'
                                      : 'Unpaid'),
                              style: boldTextStyle(
                                color: widget.bookingData.isPaid
                                    ? Colors.green
                                    : Color(0xFFe04f5f),
                              ),
                            ).paddingBottom(6),
                            6.width,
                            Image.asset(
                              widget.bookingData.isPaid
                                  ? 'assets/icons/paid.png'
                                  : 'assets/icons/unpaid.png',
                              width: 30,
                              color: greenColor,
                            ),
                          ],
                        )
                    ],
                  ),
                  10.height,
                  Row(
                    children: [
                      _buildEditBookingWidget(),
                      Text(
                          '${language.lblBookingID} #${widget.bookingData.id.validate()}',
                          style: boldTextStyle(
                              color:
                                  appStore.isDarkMode ? white : primaryColor)),
                    ],
                  ),
                  if (widget.bookingData.bookingPackage != null)
                    PriceWidget(
                      price: widget.bookingData.totalAmount.validate(),
                      color: appStore.isDarkMode ? white : primaryColor,
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PriceWidget(
                          isFreeService:
                              widget.bookingData.type == SERVICE_TYPE_FREE,
                          // price: widget.bookingData.totalAmount.validate(),
                          price: widget.bookingData.finalCouponDiscountAmount !=
                                  null
                              ? (widget.bookingData.totalAmount! -
                                  widget.bookingData.finalCouponDiscountAmount!)
                              : widget.bookingData.totalAmount.validate(),
                          // price: widget.bookingData.finalCouponDiscountAmount.validate(),
                          color: appStore.isDarkMode ? white : primaryColor,
                        ),
                        if (widget.bookingData.isHourlyService)
                          Row(
                            children: [
                              4.width,
                              Text(
                                  '${widget.bookingData.amount.validate().toPriceFormat()}/${language.lblHr}',
                                  style: secondaryTextStyle()),
                            ],
                          ),
                        if (widget.bookingData.discount.validate() != 0)
                          Row(
                            children: [
                              4.width,
                              Text('(${widget.bookingData.discount!}%',
                                  style: boldTextStyle(
                                      size: 12, color: Colors.green)),
                              Text(' ${language.lblOff})',
                                  style: boldTextStyle(
                                      size: 12, color: Colors.green)),
                            ],
                          ),
                      ],
                    ),
                ],
              ).expand(),
            ],
          ).paddingAll(8),
          Container(
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.scaffoldBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${language.lblDate} & ${language.lblTime}',
                        style: boldTextStyle(color: Color(0xFF6D7698))),
                    8.width,
                    Text(
                      "${formatDate(widget.bookingData.date.validate())} ${widget.bookingData.bookingSlot != null ? language.at : ''} ${widget.bookingData.bookingSlot.validate()}", // + buildTimeWidget(bookingDetail: widget.bookingData),
                      style: boldTextStyle(size: 12),
                      maxLines: 2,
                      textAlign: TextAlign.right,
                    ).expand(),
                  ],
                ).paddingAll(8),
                if (widget.bookingData.providerName.validate().isNotEmpty)
                  Column(
                    children: [
                      Divider(height: 0, color: context.dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(language.textProvider,
                              style: boldTextStyle(color: Color(0xFF6D7698))),
                          8.width,
                          Text(widget.bookingData.providerName.validate(),
                                  style: boldTextStyle(size: 12),
                                  textAlign: TextAlign.right)
                              .flexible(),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
                if (widget.bookingData.handyman.validate().isNotEmpty &&
                    widget.bookingData.providerId !=
                        widget.bookingData.handyman!.first.handymanId! &&
                    widget.bookingData.handyman!.first.handyman != null)
                  Column(
                    children: [
                      Divider(height: 0, color: context.dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.textHandyman,
                              style: boldTextStyle(color: Color(0xFF6D7698))),
                          Text(
                                  widget.bookingData.handyman!
                                      .validate()
                                      .first
                                      .handyman!
                                      .displayName
                                      .validate(),
                                  style: boldTextStyle(size: 12))
                              .flexible(),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
                if (widget.bookingData.paymentStatus != null &&
                    (widget.bookingData.status == BookingStatusKeys.complete ||
                        widget.bookingData.paymentStatus ==
                            SERVICE_PAYMENT_STATUS_ADVANCE_PAID ||
                        widget.bookingData.paymentStatus ==
                            SERVICE_PAYMENT_STATUS_PAID))
                  Column(
                    children: [
                      Divider(height: 0, color: context.dividerColor),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.paymentStatus,
                                  style:
                                      boldTextStyle(color: Color(0xFF6D7698)))
                              .expand(),
                          Text(
                            language.paidViaBankCards,
                            // buildPaymentStatusWithMethod(widget.bookingData.paymentStatus.validate(), widget.bookingData.paymentMethod.validate()),
                            style: boldTextStyle(
                                size: 12,
                                color: widget.bookingData.paymentStatus ==
                                            SERVICE_PAYMENT_STATUS_ADVANCE_PAID ||
                                        (widget.bookingData.paymentStatus ==
                                                SERVICE_PAYMENT_STATUS_PAID ||
                                            widget.bookingData.paymentStatus ==
                                                PENDING_BY_ADMIN)
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
              ],
            ).paddingAll(8),
          ),
        ],
      ),
    );
  }

  bool get isDateTimeAfterNow {
    try {
      if (widget.bookingData.bookingSlot != null) {
        final bookingDateTimeForTimeSlots =
            widget.bookingData.date.validate().split(" ").isNotEmpty
                ? widget.bookingData.date.validate().split(" ").first
                : "";
        final bookingTimeForTimeSlots =
            widget.bookingData.bookingSlot.validate();
        return DateTime.parse(
                bookingDateTimeForTimeSlots + " " + bookingTimeForTimeSlots)
            .isAfter(DateTime.now());
      } else {
        return DateTime.parse(widget.bookingData.date.validate())
            .isAfter(DateTime.now());
      }
    } catch (e) {
      log('E: $e');
    }
    return false;
  }
}

String? getCategoryName(Category? category) {
  if (appStore.isArabic) {
    return category?.nameAr ?? 'لا يوجد';
  }

  return category?.name ?? 'No category';
}
