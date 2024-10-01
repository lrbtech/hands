import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../common.dart';
import '../constant.dart';

extension NumExtension on num {
  String toPriceFormat() {
    return "${isCurrencyPositionLeft ? appStore.currencySymbol : ''}${this.toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS)).formatNumberWithComma()}${isCurrencyPositionRight ? appStore.currencySymbol : ''}";
  }
}
