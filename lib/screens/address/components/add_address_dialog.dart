import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/address_model.dart';
import 'package:hands_user_app/screens/address/repository/addresses_repo.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

class AddressDialog extends StatefulWidget {
  const AddressDialog({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.street,
    this.buildingName,
    this.flat,
    this.addressModel,
  });
  final String address;
  final double latitude;
  final double longitude;
  final String? street;
  final String? buildingName;
  final String? flat;
  final AddressModel? addressModel;

  @override
  State<AddressDialog> createState() => _AddressDialogState();
}

class _AddressDialogState extends State<AddressDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController streetCont;
  late TextEditingController villaNumberCont;
  late TextEditingController floorNumberCont;
  late TextEditingController addressCont;

  bool _isHome = false;

  _initControllers() {
    addressCont = TextEditingController();
    streetCont = TextEditingController();
    villaNumberCont = TextEditingController();
    floorNumberCont = TextEditingController();
  }

  _disposeControllers() {
    addressCont.dispose();
    streetCont.dispose();
    villaNumberCont.dispose();
    floorNumberCont.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initControllers();

    addressCont.text = widget.address;
    streetCont.text = widget.street.validate();

    if (widget.addressModel != null) {
      villaNumberCont.text = widget.addressModel!.villaNumber.validate();
      floorNumberCont.text = widget.addressModel!.flatNumber.validate();
      _isHome = widget.addressModel!.name.validate().toLowerCase() == 'home';
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _disposeControllers();
  }

  _saveAddress() async {
    hideKeyboard(context);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      appStore.setLoading(true);
      Map request = {
        "id": widget.addressModel?.id,
        "latitude": widget.latitude,
        "longitude": widget.longitude,
        "name": _isHome ? "home" : "other",
        "address": widget.address,
        "street": widget.street,
        "villa_number": villaNumberCont.text.trim(),
        "flat_number": floorNumberCont.text.trim(),
      };

      Map<String, dynamic> response = await saveAddress(request);
      LiveStream().emit('address_list');
      appStore.setLoading(false);
      finish(context);
      finish(context);
      toast(response['message']);
      // Navigator.of(context).pop();
      print(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                width: context.width(),
                decoration: boxDecorationDefault(
                  color: white,
                  borderRadius: radiusOnly(
                      topRight: defaultRadius, topLeft: defaultRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.lblEnterYourAddress,
                        style: boldTextStyle(color: primaryColor)),
                    IconButton(
                      onPressed: () {
                        finish(context);
                      },
                      icon: Icon(Icons.clear, color: primaryColor, size: 20),
                    )
                  ],
                ),
              ),
              Container(
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: context.primaryColor,
                ),
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      10.height,
                      Row(
                        children: [
                          10.width,
                          AnimatedContainer(
                            duration: 200.milliseconds,
                            curve: Curves.ease,
                            width: 80,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: boxDecorationWithRoundedCorners(
                                borderRadius: radius(50),
                                backgroundColor: context.cardColor,
                                border: Border.all(
                                  color: _isHome ? white : transparentColor,
                                  width: 1,
                                )),
                            child: Center(
                              child: Text(
                                language.homeAddress,
                                style: boldTextStyle(),
                              ),
                            ),
                          ).onTap(() {
                            _isHome = true;
                            setState(() {});
                          }).expand(),
                          10.width,
                          AnimatedContainer(
                            duration: 200.milliseconds,
                            curve: Curves.ease,
                            width: 80,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: boxDecorationWithRoundedCorners(
                                borderRadius: radius(50),
                                backgroundColor: context.cardColor,
                                border: Border.all(
                                  color: !_isHome ? white : transparentColor,
                                  width: 1,
                                )),
                            child: Center(
                                child: Text(
                              appStore.selectedLanguageCode == 'en'
                                  ? 'Other'
                                  : 'عنوان آخر',
                              style: boldTextStyle(),
                            )),
                          ).onTap(() {
                            _isHome = false;
                            setState(() {});
                          }).expand(),
                          10.width,
                        ],
                      ),
                      20.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: villaNumberCont,
                        isValidationRequired: true,
                        // maxLines: 2,
                        decoration: inputDecoration(
                          context,
                          labelText: language.addressBuildingNumber,
                        ).copyWith(
                          prefixIcon: Icon(Iconsax.house).paddingAll(14),
                          labelStyle: primaryTextStyle(size: 10),

                          // : primaryTextStyle(size: 14),
                        ),
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.NUMBER,
                        controller: floorNumberCont,
                        isValidationRequired: false,
                        decoration: inputDecoration(
                          context,
                          labelText: language.addressFlatNumber,
                        ).copyWith(
                            prefixIcon:
                                Icon(CupertinoIcons.number).paddingAll(14),
                            labelStyle: primaryTextStyle(size: 10)),
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: streetCont,
                        textStyle: secondaryTextStyle(),
                        decoration: inputDecoration(
                          context,
                          labelText: language.addressStreet,
                        ).copyWith(
                          prefixIcon: Icon(Iconsax.map).paddingAll(14),
                          labelStyle: primaryTextStyle(size: 10),
                        ),
                      ),
                      16.height,
                      AppTextField(
                        textFieldType: TextFieldType.MULTILINE,
                        controller: addressCont,
                        enabled: false,
                        textStyle: secondaryTextStyle(),
                        decoration: inputDecoration(
                          context,
                          labelText: language.addressTextFieldTitle,
                        ).copyWith(
                          prefixIcon:
                              Icon(CupertinoIcons.number).paddingAll(14),
                          labelStyle: primaryTextStyle(size: 10),
                        ),
                      ),
                      20.height,
                      Row(
                        children: [
                          AppButton(
                            text: language.save,
                            color: white,
                            textColor: primaryColor,
                            onTap: () => _saveAddress(),
                          ).expand(),
                        ],
                      ),
                      30.height,
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Observer(
            builder: (context) => LoaderWidget()
                .visible(appStore.isLoading)
                .withSize(height: 80, width: 80))
      ],
    );
  }
}
