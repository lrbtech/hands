import 'package:flutter/material.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/dashboard_response.dart';
import 'package:hands_user_app/provider/components/total_widget.dart';
import 'package:hands_user_app/provider/handyman_list_screen.dart';
import 'package:hands_user_app/provider/services/service_list_screen.dart';
import 'package:hands_user_app/provider/wallet/wallet_history_screen.dart';
import 'package:hands_user_app/provider/screens/total_earning_screen.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalComponent extends StatelessWidget {
  final DashboardResponses snap;

  TotalComponent({required this.snap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // Text('${appStore.categoriesIDs}'),
        TotalWidget(
          // fullWidth: true,
          title: languages.lblTotalBooking,
          total: snap.totalBooking.toString(),
          icon: total_booking,
        ).onTap(
          () {
            LiveStream().emit(LIVESTREAM_PROVIDER_ALL_BOOKING, 1);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        // TotalWidget(
        //   title: languages.lblTotalService,
        //   total: snap.totalService.validate().toString(),
        //   icon: total_services,
        // ).onTap(
        //   () {
        //     ServiceListScreen().launch(context);
        //   },
        //   highlightColor: Colors.transparent,
        //   splashColor: Colors.transparent,
        // ),
        if (getStringAsync(EARNING_TYPE) == EARNING_TYPE_SUBSCRIPTION &&
            isUserTypeProvider)
          TotalWidget(
            title: languages.lblTotalHandyman,
            total: snap.totalHandyman.validate().toString(),
            icon: handyman,
          ).onTap(
            () {
              HandymanListScreen().launch(context);
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
          ),
        TotalWidget(
          // fullWidth: true,
          title: languages.monthlyEarnings,
          total:
              "${isCurrencyPositionLeft ? appStore.currencySymbol : ""}${snap.totalRevenue.validate().toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS)).formatNumberWithComma()}${isCurrencyPositionRight ? appStore.currencySymbol : ""}",
          icon: percent_line,
        ).onTap(
          () {
            TotalEarningScreen().launch(context);
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        // if (snap.earningType == EARNING_TYPE_COMMISSION)
        //   TotalWidget(
        //     title: languages.lblWallet,
        //     total: "${isCurrencyPositionLeft ? appStore.currencySymbol : ""}${snap.providerWallet != null ? snap.providerWallet?.amount.validate().toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS)).formatNumberWithComma() : "0"}${isCurrencyPositionRight ? appStore.currencySymbol : ""}",
        //     icon: un_fill_wallet,
        //   ).onTap(
        //     () {
        //       WalletHistoryScreen().launch(context);
        //     },
        //     highlightColor: Colors.transparent,
        //     splashColor: Colors.transparent,
        //   ),
      ],
    ).paddingAll(16);
  }
}
