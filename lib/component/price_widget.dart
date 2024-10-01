import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class PriceWidget extends StatelessWidget {
  final num price;
  final double? size;
  final Color? color;
  final Color? hourlyTextColor;
  final bool isBoldText;
  final bool isLineThroughEnabled;
  final bool isDiscountedPrice;
  final bool isHourlyService;
  final bool isFreeService;
  final int? decimalPoint;

  PriceWidget({
    required this.price,
    this.size = 16.0,
    this.color,
    this.hourlyTextColor,
    this.isLineThroughEnabled = false,
    this.isBoldText = true,
    this.isDiscountedPrice = false,
    this.isHourlyService = false,
    this.isFreeService = false,
    this.decimalPoint,
  });

  @override
  Widget build(BuildContext context) {
    TextDecoration? textDecoration() => isLineThroughEnabled ? TextDecoration.lineThrough : null;

    TextStyle _textStyle({int? aSize}) {
      return isBoldText
          ? boldTextStyle(
              size: aSize ?? size!.toInt(),
              color: color != null ? color : (appStore.isDarkMode ? white : primaryColor),
              decoration: textDecoration(),
            )
          : secondaryTextStyle(
              size: aSize ?? size!.toInt(),
              color: color != null ? color : (appStore.isDarkMode ? white : primaryColor),
              decoration: textDecoration(),
            );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "${isDiscountedPrice ? ' -' : ''}",
          style: _textStyle(),
        ),
        Row(
          children: [
            if (isFreeService)
              Text(language.lblFree, style: _textStyle())
            else
              Text(
                "${isCurrencyPositionLeft ? appStore.currencySymbol : ''}${price.validate().toStringAsFixed(decimalPoint ?? getIntAsync(PRICE_DECIMAL_POINTS)).formatNumberWithComma()}${isCurrencyPositionRight ? appStore.currencySymbol : ''}",
                style: _textStyle(),
              ),
            if (isHourlyService)
              Text(
                '/${language.lblHr}',
                style: secondaryTextStyle(color: hourlyTextColor, size: 12),
              ),
          ],
        ),
      ],
    );
  }
}
