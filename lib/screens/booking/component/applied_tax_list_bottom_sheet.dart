import 'package:hands_user_app/component/price_widget.dart';
import 'package:hands_user_app/model/service_detail_response.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';

class AppliedTaxListBottomSheet extends StatelessWidget {
  final List<TaxData> taxes;
  final num subTotal;

  const AppliedTaxListBottomSheet({super.key, required this.taxes, required this.subTotal});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(language.appliedTaxes, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          // 8.height,
          AnimatedListView(
            itemCount: taxes.length,
            shrinkWrap: true,
            listAnimationType: ListAnimationType.FadeIn,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              TaxData data = taxes[index];

              if (data.type == TAX_TYPE_PERCENT) {
                data.totalCalculatedValue = subTotal * data.value.validate() / 100;
              } else {
                data.totalCalculatedValue = data.value.validate();
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  data.type == TAX_TYPE_PERCENT
                      ? Row(
                          children: [
                            // Text('• ', style: secondaryTextStyle(size: 14)),
                            Text(data.title.validate(), style: secondaryTextStyle(size: 14)),
                            4.width,
                            Text("(${data.value.validate()}%)", style: secondaryTextStyle(color: context.primaryColor, size: 14)),
                          ],
                        ).expand()
                      : Row(
                          children: [
                            // Text('• ', style: secondaryTextStyle(size: 14)),
                            Text(appStore.isArabic ? data.titleAR.validate() : data.title.validate(), style: secondaryTextStyle(size: 14)),
                          ],
                        ),
                  PriceWidget(
                    price: data.totalCalculatedValue.validate(),
                    // isBoldText: false,
                    // size: 14,
                    // color: redColor,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
