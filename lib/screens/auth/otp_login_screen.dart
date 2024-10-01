import 'dart:convert';

import 'package:hands_user_app/component/back_widget.dart';
import 'package:hands_user_app/component/base_scaffold_body.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/configs.dart';

class OTPLoginScreen extends StatefulWidget {
  const OTPLoginScreen({Key? key, this.showBackButton = true})
      : super(key: key);
  final bool showBackButton;

  @override
  State<OTPLoginScreen> createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController numberController = TextEditingController();

  Country selectedCountry = defaultCountry();

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() => init());
  }

  Future<void> init() async {
    appStore.setLoading(false);
  }

  //region Methods
  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
        searchTextStyle: primaryTextStyle(),
        inputDecoration: InputDecoration(
          labelText: language.search,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      showPhoneCode:
          true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountry = country;
        log(jsonEncode(selectedCountry.toJson()));
        setState(() {});
      },
    );
  }

  Future<void> sendOTP() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      appStore.setLoading(true);

      toast(language.sendingOTP);

      await authService
          .loginWithOTP(context,
              phoneNumber: numberController.text.trim(),
              countryCode: selectedCountry.phoneCode,
              countryISOCode: selectedCountry.countryCode)
          .then((value) {
        //
      }).catchError(
        (e) {
          appStore.setLoading(false);

          toast(e.toString(), print: true);
        },
      );
    }
  }

  // endregion

  Widget _buildMainWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        30.height,
        Text(language.lblEnterPhnNumber, style: boldTextStyle()),
        16.height,
        Form(
          key: formKey,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: ,
                children: [
                  Container(
                    padding: EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        color: white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/arabic_two.png',
                          width: 20,
                        ),
                        5.width,
                        Text(
                          '+971',
                          style: boldTextStyle(color: primaryColor),
                        )
                      ],
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: AppTextField(
                      controller: numberController,
                      textFieldType: TextFieldType.PHONE,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp("^[\u0000-\u007F]+\$"))
                      ],
                      decoration: inputDecoration(context).copyWith(
                          hintText: 'ex : 580000000',
                          hintStyle: primaryTextStyle(color: Colors.grey),
                          fillColor: white),
                      textStyle: primaryTextStyle(color: primaryColor),
                      maxLength: 9,

                      // autoFocus: true,
                      onFieldSubmitted: (s) {
                        sendOTP();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        30.height,
        AppButton(
          onTap: () {
            sendOTP();
          },
          text: language.btnSendOtp,
          color: white,
          textColor: primaryColor,
          width: context.width(),
        ),
        16.height,
        // AppButton(
        //   onTap: () {
        //     changeCountry();
        //   },
        //   text: language.lblChangeCountry,
        //   textStyle: boldTextStyle(),
        //   width: context.width(),
        // ),
      ],
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBarWidget(
      //   '', showBack: false,
      //   // elevation: 0,
      //   // backgroundColor: context.scaffoldBackgroundColor,
      //   // leading: !widget.showBackButton
      //   //     ? null
      //   //     : Navigator.of(context).canPop()
      //   //         ? BackWidget(iconColor: context.iconColor)
      //   //         : null,
      //   // scrolledUnderElevation: 0,
      //   // systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark, statusBarColor: context.scaffoldBackgroundColor),
      // ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: _buildMainWidget(),
      ),
    );
  }
}
