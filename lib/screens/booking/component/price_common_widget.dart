import 'package:hands_user_app/component/price_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/booking_data_model.dart';
import 'package:hands_user_app/model/package_data_model.dart';
import 'package:hands_user_app/model/service_data_model.dart';
import 'package:hands_user_app/model/service_detail_response.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../payment/component/payment_info_component.dart';
import 'applied_tax_list_bottom_sheet.dart';

class PriceCommonWidget extends StatelessWidget {
  final BookingData bookingDetail;
  final ServiceData serviceDetail;
  final List<TaxData> taxes;
  final CouponData? couponData;
  final BookingPackage? bookingPackage;

  const PriceCommonWidget({
    Key? key,
    required this.bookingDetail,
    required this.serviceDetail,
    required this.taxes,
    required this.couponData,
    required this.bookingPackage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (bookingDetail.isFreeService && bookingDetail.bookingType.validate() == BOOKING_TYPE_SERVICE) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language.priceDetail, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        if (bookingPackage != null)
          Container(
            padding: EdgeInsets.all(16),
            width: context.width(),
            decoration: boxDecorationDefault(color: context.cardColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(language.price, style: secondaryTextStyle(size: 14)).expand(),
                    16.width,
                    PriceWidget(price: bookingPackage!.price.validate(), color: textPrimaryColorGlobal, isBoldText: true),
                  ],
                ),
                if (bookingDetail.totalExtraChargeAmount != 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(height: 26, color: context.dividerColor),
                      Row(
                        children: [
                          Text(language.lblTotalExtraCharges, style: secondaryTextStyle(size: 14)).expand(),
                          PriceWidget(price: bookingDetail.totalExtraChargeAmount, color: textPrimaryColorGlobal),
                        ],
                      ),
                    ],
                  ),
                if (bookingDetail.finalTotalTax.validate() != 0)
                  Column(
                    children: [
                      Divider(height: 26, color: context.dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.lblTax, style: secondaryTextStyle(size: 14)),
                          16.width,
                          PriceWidget(price: bookingDetail.finalTotalTax.validate(), color: Colors.red, isBoldText: true),
                        ],
                      ),
                    ],
                  ),
                Column(
                  children: [
                    Divider(height: 26, color: context.dividerColor),
                    Row(
                      children: [
                        Text(language.totalAmount, style: secondaryTextStyle(size: 14)).expand(),
                        PriceWidget(
                          price: bookingDetail.totalAmount.validate(),
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(16),
            width: context.width(),
            decoration: boxDecorationDefault(color: context.cardColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bookingDetail.bookingType.validate() == BOOKING_TYPE_SERVICE)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(language.lblPrice, style: secondaryTextStyle(size: 14)).expand(),
                          16.width,
                          if (bookingDetail.isFixedService)
                            Marquee(
                              child: Row(
                                children: [
                                  PriceWidget(price: bookingDetail.amount.validate(), size: 12, isBoldText: false, color: appTextSecondaryColor),
                                  Text(' * ${bookingDetail.quantity != 0 ? bookingDetail.quantity : 1}  = ', style: secondaryTextStyle()),
                                  PriceWidget(price: bookingDetail.finalTotalServicePrice.validate(), isBoldText: true, color: textPrimaryColorGlobal),
                                ],
                              ),
                            )
                          else
                            PriceWidget(price: bookingDetail.finalTotalServicePrice.validate(), color: textPrimaryColorGlobal, isBoldText: true),
                        ],
                      ),
                      Divider(height: 26, color: context.dividerColor),
                    ],
                  ),
                if (bookingDetail.finalDiscountAmount != 0 && bookingDetail.bookingType.validate() == BOOKING_TYPE_SERVICE)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: language.lblDiscount, style: secondaryTextStyle(size: 14)),
                                TextSpan(
                                  text: " (${bookingDetail.discount.validate()}% ${language.lblOff.toLowerCase()}) ",
                                  style: boldTextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ).expand(),
                          16.width,
                          PriceWidget(
                            price: bookingDetail.finalDiscountAmount.validate(),
                            color: Colors.green,
                            isBoldText: true,
                            isDiscountedPrice: true,
                          ),
                        ],
                      ),
                      Divider(height: 26, color: context.dividerColor),
                    ],
                  ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(language.jobPrice, style: secondaryTextStyle(size: 14)),
                        16.width,
                        PriceWidget(price: bookingDetail.amount.validate(), color: appStore.isDarkMode ? white : primaryColor, isBoldText: true),
                      ],
                    ),
                    Divider(height: 26, color: context.dividerColor),
                  ],
                ),

                if (couponData != null)
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(language.lblCoupon, style: secondaryTextStyle(size: 14)),
                          Text(" (${couponData!.code})", style: boldTextStyle(size: 14, color: primaryColor)).expand(),
                          Text(
                            '${getCouponPrice(
                              coupon: couponData!,
                              price: bookingDetail.amount!,
                            ).toStringAsFixed(2)}${appStore.currencySymbol}',
                            style: boldTextStyle(
                              size: 16,
                              color: greenColor,
                            ),
                          ),
                          // PriceWidget(
                          //     price: getCouponPrice(
                          //       coupon: couponData!,
                          //       price: bookingDetail.amount!,
                          //     ),
                          //     color: Colors.green,
                          //     isBoldText: true,
                          //     isDiscountedPrice: true),

                          // couponData?.discount.validate()
                        ],
                      ),
                      Divider(height: 26, color: context.dividerColor),
                    ],
                  ),

                /// Show Service Add-on Price
                if (bookingDetail.serviceaddon.validate().isNotEmpty)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(language.serviceAddOns, style: secondaryTextStyle(size: 14)).flexible(fit: FlexFit.loose), 16.width, PriceWidget(price: bookingDetail.serviceaddon.validate().sumByDouble((p0) => p0.price), color: textPrimaryColorGlobal)],
                      ),
                      Divider(height: 26, color: context.dividerColor),
                    ],
                  ),

                if ((bookingDetail.isHourlyService || bookingDetail.isFixedService) && bookingDetail.bookingType.validate() == BOOKING_TYPE_SERVICE)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.lblSubTotal, style: secondaryTextStyle(size: 14)).flexible(fit: FlexFit.loose),
                          PriceWidget(price: bookingDetail.finalSubTotal.validate(), color: textPrimaryColorGlobal, isBoldText: true),
                        ],
                      ),
                      Divider(height: 26, color: context.dividerColor),
                    ],
                  ),
                if (bookingDetail.totalExtraChargeAmount != 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(language.lblTotalExtraCharges, style: secondaryTextStyle(size: 14)).expand(),
                          PriceWidget(price: bookingDetail.totalExtraChargeAmount, color: textPrimaryColorGlobal),
                        ],
                      ),
                      Divider(height: 26, color: context.dividerColor),
                    ],
                  ),

                if (bookingDetail.finalTotalTax.validate() != 0)
                  Column(
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Row(
                      //       children: [
                      //         Text(language.lblTax, style: secondaryTextStyle(size: 14)).expand(),
                      //         16.width,
                      //         // Icon(Icons.info_outline_rounded, size: 20, color: appStore.isDarkMode ? white : context.primaryColor).onTap(
                      //         //   () {
                      //         //     showModalBottomSheet(
                      //         //       context: context,
                      //         //       builder: (_) {
                      //         //         return AppliedTaxListBottomSheet(taxes: bookingDetail.taxes.validate(), subTotal: bookingDetail.finalSubTotal.validate() + bookingDetail.totalExtraChargeAmount);
                      //         //       },
                      //         //     );
                      //         //   },
                      //         // ),
                      //       ],
                      //     ).expand(),
                      //     //Text(language.lblTax, style: secondaryTextStyle(size: 14)),
                      //     16.width,
                      //     PriceWidget(price: bookingDetail.finalTotalTax.validate(), color: Colors.red, isBoldText: true),
                      //   ],
                      // ),
                      AppliedTaxListBottomSheet(
                        taxes: bookingDetail.taxes.validate(),
                        subTotal: bookingDetail.finalSubTotal.validate() + bookingDetail.totalExtraChargeAmount,
                      ),
                      Divider(height: 26, color: context.dividerColor),
                    ],
                  ),

                if (bookingDetail.tipAmount.validate() != 0)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.tip, style: secondaryTextStyle(size: 14)),
                          16.width,
                          Text(
                            '${bookingDetail.tipAmount.validate().toStringAsFixed(2)}${appStore.currencySymbol}',
                            style: boldTextStyle(
                              size: 16,
                              color: appStore.isDarkMode ? white : primaryColor,
                            ),
                          ),
                          // PriceWidget(price: bookingDetail.tipAmount.validate(), color: Colors.green, isBoldText: true),
                        ],
                      ),
                      Divider(height: 26, color: context.dividerColor),
                    ],
                  ),

                /// Final Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextIcon(
                      text: '${language.totalAmount}',
                      textStyle: secondaryTextStyle(size: 14),
                      edgeInsets: EdgeInsets.zero,
                      expandedText: true,
                      maxLine: 2,
                    ).expand(flex: 2),
                    Marquee(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 16.width,
                          if (bookingDetail.isHourlyService)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('(', style: secondaryTextStyle()),
                                PriceWidget(price: bookingDetail.amount.validate(), color: appTextSecondaryColor, size: 14, isBoldText: false),
                                Text('/${language.lblHr})', style: secondaryTextStyle()),
                              ],
                            ),
                          if (couponData != null) 8.width,
                          if (couponData != null)
                            Text(
                              '${(bookingDetail.totalAmount! - getCouponPrice(
                                    coupon: couponData!,
                                    price: bookingDetail.amount!,
                                  ) + (bookingDetail.tipAmount.validate() != 0 ? bookingDetail.tipAmount.validate() : 0)).toStringAsFixed(2)}${appStore.currencySymbol}',
                              style: boldTextStyle(
                                size: 16,
                                color: appStore.isDarkMode ? white : primaryColor,
                              ),
                            ),
                          // PriceWidget(
                          //   price: (bookingDetail.totalAmount! -
                          //       getCouponPrice(
                          //         coupon: couponData!,
                          //         price: bookingDetail.amount!,
                          //       ) +
                          //       (bookingDetail.tipAmount.validate() != 0 ? bookingDetail.tipAmount.validate() : 0)),
                          //   color: appStore.isDarkMode ? white : primaryColor,
                          // ),
                          if (couponData == null)
                            Text(
                              '${(bookingDetail.totalAmount.validate() + (bookingDetail.tipAmount.validate() != 0 ? bookingDetail.tipAmount.validate() : 0)).toStringAsFixed(2)}${appStore.currencySymbol}',
                              style: boldTextStyle(
                                size: 16,
                                color: appStore.isDarkMode ? white : primaryColor,
                              ),
                            ),
                          // PriceWidget(
                          //   price: (bookingDetail.totalAmount.validate() + (bookingDetail.tipAmount.validate() != 0 ? bookingDetail.tipAmount.validate() : 0)),
                          //   color: appStore.isDarkMode ? white : primaryColor,
                          // ),
                        ],
                      ),
                    ).flexible(flex: 3),
                  ],
                ),

                /// Advance Payment Detail
                if (serviceDetail.isAdvancePayment)
                  Column(
                    children: [
                      Divider(height: 26, color: context.dividerColor),
                      Row(
                        children: [
                          Text.rich(TextSpan(children: [
                            TextSpan(text: bookingDetail.paidAmount.validate() != 0 ? language.advancePaid : language.advancePayment, style: secondaryTextStyle(size: 14)),
                            TextSpan(
                              text: " (${serviceDetail.advancePaymentPercentage.validate().toString()}%)  ",
                              style: boldTextStyle(color: Colors.green),
                            ),
                          ])).expand(),
                          PriceWidget(price: getAdvancePaymentAmount, color: primaryColor),
                        ],
                      ),
                    ],
                  ),

                /// Remaining Amount if Advance Payment
                if (serviceDetail.isAdvancePayment && bookingDetail.paidAmount.validate() != 0)
                  Column(
                    children: [
                      Divider(height: 26, color: context.dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextIcon(
                            text: '${language.remainingAmount}',
                            textStyle: secondaryTextStyle(size: 14),
                            edgeInsets: EdgeInsets.zero,
                            suffix: Icon(Icons.info_outline_rounded, size: 20, color: context.primaryColor),
                            expandedText: true,
                            maxLine: 3,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) {
                                  return PaymentInfoComponent(bookingDetail.id!);
                                },
                              );
                            },
                          ).expand(),
                          8.width,
                          bookingDetail.status == BookingStatusKeys.complete && bookingDetail.paymentStatus == SERVICE_PAYMENT_STATUS_PAID ? PriceWidget(price: 0, color: primaryColor) : PriceWidget(price: getRemainingAmount, color: primaryColor),
                        ],
                      ),
                    ],
                  ),

                /// Hourly Service Detail
                if (bookingDetail.isHourlyService && bookingDetail.status == BookingStatusKeys.complete)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      children: [
                        Divider(height: 26, color: context.dividerColor),
                        6.height,
                        Text(
                          "${language.lblOnBase} ${calculateTimer(bookingDetail.durationDiff.validate().toInt())} ${getMinHour(durationDiff: bookingDetail.durationDiff.validate())}",
                          style: secondaryTextStyle(),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
      ],
    );
  }

  num get getAdvancePaymentAmount {
    if (bookingDetail.paidAmount.validate() != 0) {
      return bookingDetail.paidAmount!;
    } else {
      return bookingDetail.totalAmount.validate() * serviceDetail.advancePaymentPercentage.validate() / 100;
    }
  }

  num get getRemainingAmount {
    if (bookingDetail.paidAmount.validate() == 0) {
      return bookingDetail.totalAmount.validate();
    } else {
      return bookingDetail.totalAmount.validate() - getAdvancePaymentAmount;
    }
  }

  String getMinHour({required String durationDiff}) {
    String totalTime = calculateTimer(durationDiff.toInt());
    List<String> totalHours = totalTime.split(":");
    if (totalHours.first == "00") {
      return language.min;
    } else {
      return language.hour;
    }
  }
}

double getCouponPrice({
  required CouponData coupon,
  required num price,
}) {
  if (coupon.discountType == 'percentage') {
    return price.toDouble() * (coupon.discount!.toDouble() / 100.toDouble());
  } else {
    return coupon.discount!.toDouble();
  }
}
