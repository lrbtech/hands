import 'package:hands_user_app/component/back_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pinput/pinput.dart' as pinput;
import 'package:pinput/pinput.dart';

import '../../utils/constant.dart';

class OtpDialogComponent extends StatefulWidget {
  final Function(String? otpCode) onTap;

  OtpDialogComponent({required this.onTap});

  @override
  State<OtpDialogComponent> createState() => _OtpDialogComponentState();
}

class _OtpDialogComponentState extends State<OtpDialogComponent> {
  late pinput.PinTheme defaultPinTheme;
  late pinput.PinTheme focusedPinTheme;
  late pinput.PinTheme submittedPinTheme;

  String otpCode = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    defaultPinTheme = pinput.PinTheme(
      width: 60,
      height: 60,
      constraints: BoxConstraints(
          maxHeight: 60, minHeight: 60, maxWidth: 60, minWidth: 60),
      textStyle: TextStyle(
          fontSize: 20, color: primaryColor, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: appStore.isDarkMode ? cardColor : Colors.grey.shade200,
        border: 1 == 2
            ? null
            : Border.all(
                color: const Color.fromRGBO(234, 239, 243, 1), width: 1),
        borderRadius: BorderRadius.circular(50),
      ),
    );

    focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: cardColor,
      border: Border.all(color: primaryColor),
      borderRadius: BorderRadius.circular(50),
    );

    submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: primaryColor.withOpacity(.10),
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }

  void submitOtp() {
    if (otpCode.validate().isNotEmpty) {
      if (otpCode.trim().validate().length == 5) {
        hideKeyboard(context);
        appStore.setLoading(true);
        widget.onTap.call(otpCode);
      } else {
        // toast('${otpCode} ${otpCode.length}');
        toast(language.pleaseEnterValidOTP);
      }
    } else {
      toast(language.pleaseEnterValidOTP);
      // toast('${otpCode} ${otpCode.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.confirmOTP,
        backWidget: BackWidget(iconColor: primaryColor),
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 0,
        color: context.scaffoldBackgroundColor,
        systemUiOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness:
                appStore.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarColor: context.scaffoldBackgroundColor),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                32.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        appStore.selectedLanguageCode == 'en'
                            ? 'Enter your 5 digit code'
                            : 'أدخل الرمز الخاص بك المكون من 5 أرقام',
                        style: boldTextStyle(
                            size: 28,
                            color:
                                appStore.isDarkMode ? null : Color(0xFF0C1B54)),
                      ),
                    ),
                  ],
                ),
                6.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        appStore.selectedLanguageCode == 'en'
                            ? 'Please Check your messages and enter your 5 digit code'
                            : 'يرجى التحقق من رسائلك وإدخال الرمز المكون من 5 أرقام',
                        style: primaryTextStyle(size: 15),
                      ),
                    ),
                  ],
                ),
                20.height,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  decoration: boxDecorationDefault(color: white),
                  child: 1 == 1
                      ? Center(
                          child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: pinput.Pinput(
                                autofocus: true,
                                defaultPinTheme: defaultPinTheme,
                                focusedPinTheme: focusedPinTheme,
                                submittedPinTheme: submittedPinTheme,
                                // validator: (value) {
                                //   return value == authController.otpResponse?.otp ? null : null;
                                // },
                                androidSmsAutofillMethod: pinput
                                    .AndroidSmsAutofillMethod.smsRetrieverApi,
                                pinputAutovalidateMode:
                                    PinputAutovalidateMode.disabled,
                                showCursor: true,
                                onChanged: (value) => setState(() {
                                  otpCode = value;
                                }),

                                onCompleted: (pin) => setState(() {
                                  otpCode = pin;
                                  // submitOtp();
                                }),
                                length: 5,
                                onSubmitted: (value) => setState(() {
                                  otpCode = value;
                                }),
                              )),
                        )
                      : OTPTextField(
                          pinLength: 5,
                          textStyle: primaryTextStyle(),
                          boxDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100)),
                          fieldWidth: 45,
                          cursorColor: primaryColor,
                          decoration: inputDecoration(
                            context,
                            borderRadius: 100,
                          ).copyWith(
                            counter: Offstage(),
                            fillColor: context.scaffoldBackgroundColor,
                          ),
                          onChanged: (s) {
                            otpCode = s;
                            log(otpCode);
                          },
                          onCompleted: (pin) {
                            otpCode = pin;
                            submitOtp();
                          },
                        ).fit(),
                ),
                30.height,
                AppButton(
                  onTap: () {
                    submitOtp();
                  },
                  text: language.confirm,
                  color: white,
                  textColor: primaryColor,
                  width: context.width(),
                ),
              ],
            ),
          ),
          Observer(builder: (context) {
            return LoaderWidget().visible(appStore.isLoading);
          }),
        ],
      ),
    );
  }
}
