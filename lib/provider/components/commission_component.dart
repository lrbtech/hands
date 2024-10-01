import 'package:flutter/material.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/dashboard_response.dart';
import 'package:hands_user_app/models/ratings_model.dart';
import 'package:hands_user_app/provider/fragments/provider_ratings.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:rate_in_stars/rate_in_stars.dart';

class CommissionComponent extends StatelessWidget {
  final Commission commission;
  final double? rating;

  CommissionComponent({required this.commission, required this.rating});

  @override
  Widget build(BuildContext context) {
    return rating != null
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            margin: EdgeInsets.only(top: 8, left: 16, right: 16),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(8),
              backgroundColor: context.cardColor,
            ),
            child: Row(
              children: [
                Row(
                  // textAlign: TextAlign.center,
                  children: [
                    Text('${languages.lblProviderType}: ',
                        style: secondaryTextStyle(size: 10)),
                    Text('${commission.name.validate()}',
                        style: boldTextStyle(size: 10)),
                  ],
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ProviderRatings().launch(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${languages.ratings}',
                            style: secondaryTextStyle(size: 10)),
                        4.width,
                        Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                color: context.scaffoldBackgroundColor,
                                borderRadius: radius(8),
                              ),
                              child: RatingStars(
                                rating: rating!,
                                color: appStore.isDarkMode
                                    ? white
                                    : context.primaryColor,
                                editable: false,
                                iconSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ProviderRatings().launch(context);
                              },
                              child: Container(
                                height: 30,
                                width: 100,
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: radius(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // child: Row(
            //   children: [
            //     // Column(
            //     //   crossAxisAlignment: CrossAxisAlignment.start,
            //     //   children: [
            //     //     RichTextWidget(
            //     //       textAlign: TextAlign.center,
            //     //       list: [
            //     //         TextSpan(text: '${languages.lblProviderType}: ', style: secondaryTextStyle(size: 12)),
            //     //         TextSpan(text: '${commission.name.validate()}', style: boldTextStyle(size: 12)),
            //     //       ],
            //     //     ),
            //     //     // 8.height,
            //     //     // RichTextWidget(
            //     //     //   textAlign: TextAlign.center,
            //     //     //   list: [
            //     //     //     TextSpan(text: '${languages.lblMyCommission}: ', style: secondaryTextStyle(size: 12)),
            //     //     //     TextSpan(
            //     //     //       text: isCommissionTypePercent(commission.type)
            //     //     //           ? '${commission.commission.validate()}%'
            //     //     //           : '${isCurrencyPositionLeft ? appStore.currencySymbol : ""}${commission.commission.validate()}${isCurrencyPositionRight ? appStore.currencySymbol : ""}',
            //     //     //       style: boldTextStyle(size: 12),
            //     //     //     ),
            //     //     //     if (isCommissionTypePercent(commission.type)) TextSpan(text: ' (${languages.lblFixed})', style: secondaryTextStyle(size: 12)),
            //     //     //   ],
            //     //     // ),
            //     //   ],
            //     // ),
            //
            //     Spacer(),
            //     Container(
            //       padding: EdgeInsets.all(8),
            //       decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
            //       child: Image.asset(percent_line, height: 18, width: 18, color: white),
            //     ),
            //   ],
            // ),
          )
        : SizedBox();
  }
}
