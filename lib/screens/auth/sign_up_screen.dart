import 'package:flutter/widgets.dart';
import 'package:hands_user_app/component/back_widget.dart';
import 'package:hands_user_app/component/html_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/component/selected_item_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/user_data_model.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/auth/auth_user_services.dart';
import 'package:hands_user_app/screens/auth/sign_in_screen.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/map/map_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? countryCode;
  final bool isOTPLogin;
  final String? uid;

  SignUpScreen(
      {Key? key,
      this.phoneNumber,
      this.isOTPLogin = false,
      this.countryCode,
      this.uid})
      : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Country selectedCountry = defaultCountry();

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isAcceptedTc = false;

  bool isFirstTimeValidation = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (widget.phoneNumber != null) {
      selectedCountry = Country.parse(
          widget.countryCode.validate(value: selectedCountry.countryCode));
      print(
          'SelectedCioiuuntry : ${selectedCountry.countryCode} , ${selectedCountry.displayName}');
      mobileCont.text = widget.phoneNumber != null
          ? widget.phoneNumber.toString().replaceFirst('971', '')
          : "";
      // passwordCont.text = widget.phoneNumber != null ? widget.phoneNumber.toString() : "";
      userNameCont.text =
          widget.phoneNumber != null ? widget.phoneNumber.toString() : "";
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  //region Logic
  String buildMobileNumber() {
    return '${selectedCountry.phoneCode}-${mobileCont.text.trim()}';
  }

  Future<void> registerWithOTP() async {
    hideKeyboard(context);

    if (appStore.isLoading) return;

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      UserData userResponse = UserData()
        ..username = widget.phoneNumber.validate().trim()
        ..loginType = LOGIN_TYPE_OTP
        ..contactNumber = buildMobileNumber()
        ..email = emailCont.text.trim()
        ..firstName = fNameCont.text.trim()
        ..lastName = lNameCont.text.trim()
        ..playerId = getStringAsync(PLAYERID)
        ..userType = USER_TYPE_USER
        ..uid = widget.uid.validate()
        ..password = passwordCont.text.trim();

      await createUsers(tempRegisterData: userResponse);
    }
  }

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
        setState(() {});
      },
    );
  }

  void registerUser() async {
    hideKeyboard(context);

    if (appStore.isLoading) return;

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      /// If Terms and condition is Accepted then only the user will be registered
      if (isAcceptedTc) {
        appStore.setLoading(true);

        /// Create a temporary request to send
        UserData tempRegisterData = UserData()
          ..contactNumber = buildMobileNumber()
          ..firstName = fNameCont.text.trim()
          ..lastName = lNameCont.text.trim()
          ..userType = USER_TYPE_USER
          ..username = userNameCont.text.trim()
          ..email = emailCont.text.trim()
          ..password = passwordCont.text.trim();

        createUsers(tempRegisterData: tempRegisterData);
      }
    } else {
      isFirstTimeValidation = false;
      setState(() {});
    }
  }

  Future<void> createUsers({required UserData tempRegisterData}) async {
    await createUser(tempRegisterData.toJson()).then((registerResponse) async {
      registerResponse.userData!.password = passwordCont.text.trim();
      var request;

      /// After successful entry in the mysql database it will login into firebase.

      if (widget.isOTPLogin) {
        request = {
          'username': widget.phoneNumber.validate(),
          'password': passwordCont.text.trim(),
          'player_id': getStringAsync(PLAYERID, defaultValue: ""),
          'login_type': LOGIN_TYPE_OTP,
          "uid": widget.uid.validate(),
        };
      } else {
        request = {
          "email": registerResponse.userData!.email.validate(),
          'password': passwordCont.text.trim().validate(),
          'player_id': getStringAsync(PLAYERID),
        };
      }

      appStore.setLoading(false);

      if (registerResponse.message
          .validate()
          .contains('Your account is already exists')) {
        toast(registerResponse.message.validate());
        return;
      }

      if (registerResponse.message
          .validate()
          .contains('Email Verification link has been sent to your email')) {
        toast(registerResponse.message.validate());
      }
      await loginCurrentUsers(context,
              req: request, isSocialLogin: widget.isOTPLogin)
          .then((res) async {
        saveDataToPreference(context,
            userData: res.userData!,
            isSocialLogin: widget.isOTPLogin, onRedirectionClick: () {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return DashboardScreen();
              },
            ),
            (_) => false,
          );
          // DashboardScreen().launch(context, isNewTask: true);
        });
      }).catchError((e) {
        toast(language.lblLoginAgain);
        appStore.setLoading(false);
        SignInScreen().launch(context, isNewTask: true);
      });

      /// Calling Login API
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  //endregion

  //region Widget
  Widget _buildTopWidget() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          padding: EdgeInsets.all(16),
          child: ic_profile2.iconImage(color: Colors.white),
          decoration:
              boxDecorationDefault(shape: BoxShape.circle, color: primaryColor),
        ),
        16.height,
        Text(language.lblHelloUser, style: boldTextStyle(size: 22)).center(),
        16.height,
        Text(language.lblSignUpSubTitle,
                style: secondaryTextStyle(size: 14),
                textAlign: TextAlign.center)
            .center()
            .paddingSymmetric(horizontal: 32),
      ],
    );
  }

  Widget _buildFormWidget() {
    setState(() {});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        6.height,
        Text(
          language.hintFirstNameTxt,
          style: boldTextStyle(),
        ).paddingBottom(8),
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: fNameCont,
          focus: fNameFocus,
          nextFocus: lNameFocus,
          errorThisFieldRequired: language.requiredText,
          textStyle: primaryTextStyle(color: primaryColor),
          decoration: inputDecoration(context).copyWith(
              hintText: 'Enter First Name',
              hintStyle: primaryTextStyle(color: Colors.grey),
              fillColor: white),
          // decoration: inputDecoration(
          //   context,
          //   fillColor: white
          // ),
          suffix: ic_profile2
              .iconImage(size: 10, color: primaryColor)
              .paddingAll(14),
        ),
        16.height,
        Text(
          language.hintLastNameTxt,
          style: boldTextStyle(),
        ).paddingBottom(8),
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: lNameCont,
          focus: lNameFocus,
          nextFocus: userNameFocus,
          errorThisFieldRequired: language.requiredText,
          textStyle: primaryTextStyle(color: primaryColor),
          decoration: inputDecoration(context).copyWith(
              hintText: 'Enter Last Name',
              hintStyle: primaryTextStyle(color: Colors.grey),
              fillColor: white),
          suffix: ic_profile2
              .iconImage(size: 10, color: primaryColor)
              .paddingAll(14),
        ),
        16.height,
        Text(
          language.hintUserNameTxt,
          style: boldTextStyle(),
        ).paddingBottom(8),
        AppTextField(
          textFieldType: TextFieldType.USERNAME,
          controller: userNameCont,
          focus: userNameFocus,
          nextFocus: emailFocus,
          readOnly: widget.isOTPLogin.validate() ? widget.isOTPLogin : false,
          errorThisFieldRequired: language.requiredText,
          textStyle: primaryTextStyle(color: primaryColor),
          decoration: inputDecoration(context).copyWith(
              hintText: 'Enter UserName',
              hintStyle: primaryTextStyle(color: Colors.grey),
              fillColor: white),
          suffix: ic_profile2
              .iconImage(size: 10, color: primaryColor)
              .paddingAll(14),
        ),
        16.height,
        Text(
          language.email,
          style: boldTextStyle(),
        ).paddingBottom(8),
        AppTextField(
          textFieldType: TextFieldType.EMAIL_ENHANCED,
          controller: emailCont,
          focus: emailFocus,
          errorThisFieldRequired: language.requiredText,
          nextFocus: mobileFocus,
          textStyle: primaryTextStyle(color: primaryColor),
          decoration: inputDecoration(context).copyWith(
              hintText: 'Enter Email',
              hintStyle: primaryTextStyle(color: Colors.grey),
              fillColor: white),
          suffix: ic_message
              .iconImage(size: 10, color: primaryColor)
              .paddingAll(14),
        ),
        16.height,
        Text(
          language.hintContactNumberTxt,
          style: boldTextStyle(),
        ).paddingBottom(8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  textFieldType:
                      isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
                  controller: mobileCont,
                  focus: mobileFocus,
                  // buildCounter: (_, {required int currentLength, required bool isFocused, required int? maxLength}) {
                  //   return TextButton(
                  //     child: Text(language.lblChangeCountry, style: primaryTextStyle(size: 12)),
                  //     onPressed: () {
                  //       changeCountry();
                  //     },
                  //   );
                  // },
                  readOnly:
                      widget.isOTPLogin.validate() ? widget.isOTPLogin : false,

                  errorThisFieldRequired: language.requiredText,
                  nextFocus: passwordFocus,
                  decoration: inputDecoration(
                    context,
                  ).copyWith(
                      // prefixStyle: boldTextStyle(),
                      // prefixText: '+${selectedCountry.phoneCode} ',
                      hintText:
                          '${language.lblExample}: ${selectedCountry.example}',
                      hintStyle: secondaryTextStyle(),
                      //  hintStyle: primaryTextStyle(color: Colors.grey),
                      fillColor: white),
                  textStyle: primaryTextStyle(color: primaryColor),
                  maxLength: 9,
                  suffix: ic_calling
                      .iconImage(size: 10, color: primaryColor)
                      .paddingAll(14),
                ),
              ),
            ],
          ),
        ),
        4.height,
        Text(
          language.password,
          style: boldTextStyle(),
        ).paddingBottom(8),
        AppTextField(
          textFieldType: TextFieldType.PASSWORD,
          controller: passwordCont,
          focus: passwordFocus,
          textStyle: primaryTextStyle(color: primaryColor),
          decoration: inputDecoration(context).copyWith(
              hintText: 'Enter Password',
              hintStyle: primaryTextStyle(color: Colors.grey),
              fillColor: white),
          // readOnly: widget.isOTPLogin.validate() ? widget.isOTPLogin : false,
          suffixPasswordVisibleWidget:
              ic_show.iconImage(size: 10, color: primaryColor).paddingAll(14),
          suffixPasswordInvisibleWidget:
              ic_hide.iconImage(size: 10, color: primaryColor).paddingAll(14),
          errorThisFieldRequired: language.requiredText,
          // decoration: inputDecoration(context),
          onFieldSubmitted: (s) {
            // if (widget.isOTPLogin) {
            //   registerWithOTP();
            // } else {
            //   registerUser();
            // }
          },
        ),
        20.height,
        _buildTcAcceptWidget(),
        8.height,
        AppButton(
          text: language.signUp,
          color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ,
          textColor: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
          width: context.width(),
          onTap: () {
            if (widget.isOTPLogin) {
              registerWithOTP();
            } else {
              registerUser();
            }
          },
        ),
        _buildFooterWidget(),
        80.height
      ],
    );
  }

  Widget _buildTcAcceptWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SelectedItemWidget(isSelected: isAcceptedTc).onTap(() async {
          isAcceptedTc = !isAcceptedTc;
          setState(() {});
        }),
        16.width,
        RichTextWidget(
          list: [
            TextSpan(
                text: '${language.lblAgree} ',
                style: secondaryTextStyle(
                    fontFamily:
                        Theme.of(context).textTheme.bodyLarge?.fontFamily)),
            TextSpan(
              text: language.lblTermsOfService,
              style: boldTextStyle(
                  color: appStore.isDarkMode ? white : primaryColor,
                  size: 14,
                  fontFamily:
                      Theme.of(context).textTheme.bodyLarge?.fontFamily),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (appStore.selectedLanguageCode == 'en') {
                    appStore.setTermConditions(cachedDashboardResponse
                            ?.termConditions?.value
                            .validate() ??
                        TERMS_CONDITION_URL);
                  } else {
                    appStore.setTermConditions(cachedDashboardResponse
                            ?.termConditions?.valueAr
                            .validate() ??
                        TERMS_CONDITION_URL);
                  }
                  checkIfLink(context, appStore.termConditions.validate(),
                      title: language.termsCondition);

                  // HtmlWidget(
                  //   title: language.termsCondition,
                  //   postContent: appStore.termConditions.validate(),
                  // ).launch(context);
                  // commonLaunchUrl(TERMS_CONDITION_URL, launchMode: LaunchMode.externalApplication);
                },
            ),
            TextSpan(text: ' & ', style: secondaryTextStyle()),
            TextSpan(
              text: language.privacyPolicy,
              style: boldTextStyle(
                  color: appStore.isDarkMode ? white : primaryColor,
                  size: 14,
                  fontFamily:
                      Theme.of(context).textTheme.bodyLarge?.fontFamily),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (appStore.selectedLanguageCode == 'en') {
                    appStore.setPrivacyPolicy(cachedDashboardResponse
                            ?.privacyPolicy?.value
                            .validate() ??
                        PRIVACY_POLICY_URL);
                  } else {
                    appStore.setPrivacyPolicy(cachedDashboardResponse
                            ?.privacyPolicy?.valueAr
                            .validate() ??
                        PRIVACY_POLICY_URL);
                  }
                  checkIfLink(context, appStore.privacyPolicy.validate(),
                      title: language.privacyPolicy);

                  // HtmlWidget(
                  //   title: language.privacyPolicy,
                  //   postContent: appStore.privacyPolicy.validate(),
                  // ).launch(context);
                  // commonLaunchUrl(PRIVACY_POLICY_URL, launchMode: LaunchMode.externalApplication);
                },
            ),
          ],
        ).flexible(flex: 2),
      ],
    ).paddingSymmetric(vertical: 16);
  }

  Widget _buildFooterWidget() {
    return Column(
      children: [
        16.height,
        RichTextWidget(
          list: [
            TextSpan(
                text: "${language.alreadyHaveAccountTxt} ? ",
                style: secondaryTextStyle(
                    fontFamily:
                        Theme.of(context).textTheme.bodyLarge?.fontFamily)),
            TextSpan(
              text: language.signIn,
              style: boldTextStyle(
                  color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ,
                  size: 14,
                  fontFamily:
                      Theme.of(context).textTheme.bodyLarge?.fontFamily),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // finish(context);
                },
            ),
          ],
        ),
        30.height,
      ],
    );
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isOTPLogin
          ? AppBar(
              elevation: 0,
              backgroundColor: context.scaffoldBackgroundColor,
              leading: 1 == 1 ? null : BackWidget(iconColor: context.iconColor),
              scrolledUnderElevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness:
                      appStore.isDarkMode ? Brightness.light : Brightness.dark,
                  statusBarColor: context.scaffoldBackgroundColor),
            )
          : null,
      body: SizedBox(
        width: context.width(),
        child: Stack(
          children: [
            Form(
              key: formKey,
              autovalidateMode: isFirstTimeValidation
                  ? AutovalidateMode.disabled
                  : AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(widget.isOTPLogin ? 18.0 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    20.height,
                    // _buildTopWidget(),
                    Text(language.lblSignUpSubTitle,
                        style: boldTextStyle(size: 22)),
                    20.height,
                    _buildFormWidget(),
                    30.height,

                    // _buildFooterWidget(),
                  ],
                ),
              ),
            ),
            Observer(
                builder: (_) =>
                    LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
