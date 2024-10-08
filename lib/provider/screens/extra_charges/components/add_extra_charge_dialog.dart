import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/extra_charges_model.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:nb_utils/nb_utils.dart';

// import '../../../models/extra_charges_model.dart';

class AddExtraChargesDialog extends StatefulWidget {
  final ExtraChargesModel? data;
  final int? indexOfextraCharge;

  AddExtraChargesDialog({this.data, this.indexOfextraCharge});

  @override
  _AddExtraChargesDialogState createState() => _AddExtraChargesDialogState();
}

class _AddExtraChargesDialogState extends State<AddExtraChargesDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController titleCont = TextEditingController();
  TextEditingController priceCont = TextEditingController();

  FocusNode priceFocus = FocusNode();

  int qty = 1;

  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isEdit = widget.data != null && widget.indexOfextraCharge != null;
    if (isEdit) {
      titleCont.text = widget.data!.title.validate();
      priceCont.text = widget.data!.price.validate().toString();
      qty = widget.data!.qty.validate().toInt();
      setState(() {});
    }
  }

  void addCharges() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      ExtraChargesModel data = ExtraChargesModel();
      data.title = titleCont.text.validate();
      data.price = priceCont.text.toDouble().validate();
      data.qty = qty.validate();
      if (isEdit) {
        log('ISEDIT: $isEdit');
        chargesList[widget.indexOfextraCharge.validate()] = data;
      } else {
        chargesList.add(data);
      }
      finish(context, true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      color: Colors.transparent,
      child: Container(
        decoration:
            boxDecorationDefault(color: context.scaffoldBackgroundColor),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.width(),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  backgroundColor: primaryColor,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(languages.lblAddExtraChargesDetail,
                            style: boldTextStyle(color: white))
                        .paddingOnly(left: 16),
                    CloseButton(color: Colors.white),
                  ],
                ),
              ),
              16.height,
              Container(
                margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
                padding: EdgeInsets.all(8),
                alignment: Alignment.bottomCenter,
                decoration: boxDecorationRoundedWithShadow(
                    defaultRadius.toInt(),
                    blurRadius: 0,
                    backgroundColor: context.scaffoldBackgroundColor),
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: titleCont,
                        autoFocus: true,
                        nextFocus: priceFocus,
                        validator: (s) {
                          if (s!.isEmpty)
                            return languages.hintRequired;
                          else
                            return null;
                        },
                        errorThisFieldRequired: languages.hintRequired,
                        decoration: inputDecoration(context,
                            hint: languages.lblEnterExtraChargesDetail,
                            fillColor: context.cardColor),
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.PHONE,
                        controller: priceCont,
                        focus: priceFocus,
                        validator: (s) {
                          if (s!.isEmpty) return errorThisFieldRequired;

                          if (s.toDouble() <= 0)
                            return languages.priceAmountValidationMessage;
                          return null;
                        },
                        errorThisFieldRequired: languages.hintRequired,
                        decoration: inputDecoration(context,
                            hint: languages.lblEnterAmount,
                            fillColor: context.cardColor),
                      ),
                      16.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(languages.quantity, style: boldTextStyle()),
                          Container(
                            height: 40,
                            padding: EdgeInsets.all(8),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: context.cardColor),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Feather.minus, size: 24).onTap(() {
                                  if (qty > 1) {
                                    qty = qty - 1;
                                  }
                                  setState(() {});
                                }),
                                16.width,
                                Text(qty.toString(), style: primaryTextStyle()),
                                16.width,
                                Icon(Icons.add, size: 24).onTap(() {
                                  qty = qty + 1;
                                  setState(() {});
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      24.height,
                      AppButton(
                        text:
                            isEdit ? languages.saveChanges : languages.hintAdd,
                        color: primaryColor,
                        textStyle: boldTextStyle(color: white),
                        width: context.width() - context.navigationBarHeight,
                        onTap: () {
                          addCharges();
                        },
                      ),
                      8.height,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
