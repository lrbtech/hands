import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/provider/firebase/firebase_database_service.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/extensions/context_ext.dart';
import 'package:hands_user_app/provider/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/post_job_data.dart';

class BidPriceDialog extends StatefulWidget {
  final PostJobData data;

  BidPriceDialog({required this.data});

  @override
  _BidPriceDialogState createState() => _BidPriceDialogState();
}

class _BidPriceDialogState extends State<BidPriceDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController servicePrice = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  void _handleSubmitClick() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      Map request = {
        SaveBidding.postRequestId: widget.data.id.validate(),
        SaveBidding.providerId: appStore.userId.validate(),
        SaveBidding.price: servicePrice.text.validate(),
      };

      saveBid(request).then((value) async {
        appStore.setLoading(false);
        await firebaseDbService.firebaseJobBid(
            bidderData: value, postJobId: widget.data.id.toString());

        finish(context, true);
      }).catchError((e) {
        // print("karam ${e.runtimeType}");
        appStore.setLoading(false);
        // toast(e.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: context.width(),
        color: Colors.transparent,
        child: Stack(
          children: [
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: boxDecorationDefault(
                        color: context.scaffoldBackgroundColor),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languages.giveYourEstimatePriceHere,
                            style: boldTextStyle()),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NUMBER,
                          controller: servicePrice,
                          isValidationRequired: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return context.translate.hintRequired;
                            }
                            if (value.toInt() < widget.data.price.validate() ||
                                value.toInt().validate() == 0) {
                              return appStore.selectedLanguageCode == 'ar'
                                  ? "يجب ان لا يكون السعر أقل من ${widget.data.price.validate()} د.إ"
                                  : "Your bid amount must be more than ${widget.data.price.validate()}AED";
                            }
                            /*if (value!.isEmpty) {
                              return languages.hintRequired;
                            } else if (value.toInt() <= 0) {
                              return languages.pleaseEnterValidBidPrice;
                            } else if (widget.data.price.validate() > num.parse(value.validate())) {
                              return "${languages.yourPriceShouldNotBeLessThan} ${widget.data.price.validate()}";
                            }*/
                            return null;
                          },
                          decoration: inputDecoration(context).copyWith(
                            fillColor: context.cardColor,
                            filled: true,
                            hintText: languages.enterBidPrice,
                            hintStyle: secondaryTextStyle(),
                            prefixText: appStore.currencySymbol + " ",
                            prefixStyle: primaryTextStyle(size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Row(
                    children: [
                      AppButton(
                        onTap: () {
                          finish(context);
                        },
                        shapeBorder:
                            RoundedRectangleBorder(borderRadius: radius()),
                        color: context.scaffoldBackgroundColor,
                        text: languages.lblCancel,
                        textColor: context.iconColor,
                      ).expand(),
                      16.width,
                      AppButton(
                        onTap: _handleSubmitClick,
                        color: context.primaryColor,
                        text: languages.confirm,
                      ).expand(),
                    ],
                  ),
                ],
              ),
            ).paddingAll(16),
            Observer(builder: (context) {
              return LoaderWidget().visible(appStore.isLoading);
            })
          ],
        ).center(),
      ),
    );
  }
}
