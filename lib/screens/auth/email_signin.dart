import 'package:firebase_auth/firebase_auth.dart';
import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/auth/auth_user_services.dart';
import 'package:hands_user_app/screens/auth/forgot_password_screen.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/map/map_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class EmailSinginScreen extends StatefulWidget {
  final bool? isFromDashboard;
  final bool? isFromServiceBooking;
  final bool returnExpected;
  final bool isRegeneratingToken;
  const EmailSinginScreen(
      {super.key,
      this.isFromDashboard,
      this.isFromServiceBooking,
      this.returnExpected = false,
      this.isRegeneratingToken = false});

  @override
  State<EmailSinginScreen> createState() => _EmailSinginScreenState();
}

class _EmailSinginScreenState extends State<EmailSinginScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> formKeys = GlobalKey<FormState>();
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  bool isRemember = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    if (await isIqonicProduct) {
      emailCont.text = DEFAULT_EMAIL;
      passwordCont.text = DEFAULT_PASS;
    }

    isRemember = getBoolAsync(IS_REMEMBERED, defaultValue: true);
    if (isRemember) {
      emailCont.text = getStringAsync(USER_EMAIL, defaultValue: DEFAULT_EMAIL);
      passwordCont.text =
          getStringAsync(USER_PASSWORD, defaultValue: DEFAULT_PASS);
    }

    if (widget.isRegeneratingToken) {
      if (isLoginTypeUser) {
        emailCont.text = appStore.userEmail;
        passwordCont.text = getStringAsync(USER_PASSWORD);

        _handleLogin(isDirectLogin: true);
      }

      await clearPreferences();
    }
  }

  void _handleLogin({bool isDirectLogin = false}) {
    if (isDirectLogin) {
      _handleLoginUsers();
    } else {
      hideKeyboard(context);
      if (formKeys.currentState!.validate()) {
        formKeys.currentState!.save();
        _handleLoginUsers();
      }
    }
  }

  void _handleLoginUsers() async {
    hideKeyboard(context);
    Map<String, dynamic> request = {
      'email': emailCont.text.trim(),
      'password': passwordCont.text.trim(),
      'player_id': getStringAsync(PLAYERID),
    };

    log(request);

    await loginCurrentUsers(context, req: request).then((value) async {
      if (isRemember) {
        setValue(USER_EMAIL, emailCont.text);
        setValue(USER_PASSWORD, passwordCont.text);
        await setValue(IS_REMEMBERED, isRemember);
      }

      FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: request['email'],
        password: request['password'],
      )
          .then((value) {
        print('User has been successfully signed in ${value.user?.email}');
      });

      saveDataToPreference(context, userData: value.userData!,
          onRedirectionClick: () {
        onLoginSuccessRedirection();
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Widget _buildRememberWidget() {
    return Column(
      children: [
        8.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RoundedCheckBox(
              borderColor: white,
              checkedColor: !appStore.isDarkMode ? white : context.primaryColor,
              isChecked: isRemember,
              text: language.rememberMe,
              textStyle: secondaryTextStyle(),
              size: 20,
              onTap: (value) async {
                await setValue(IS_REMEMBERED, isRemember);
                isRemember = !isRemember;
                setState(() {});
              },
            ),
            TextButton(
              onPressed: () {
                showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                  builder: (_) => ForgotPasswordScreen(),
                );
              },
              child: Text(
                language.forgotPassword,
                style: secondaryTextStyle(color: Colors.green),
                textAlign: TextAlign.right,
              ),
            ).flexible(),
          ],
        ),
        14.height,
        AppButton(
          text: language.signIn,
          color: white,
          textColor: primaryColor,
          width: context.width(),
          onTap: () {
            _handleLogin();
          },
        ),
        // 16.height,
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text(language.doNotHaveAccount, style: secondaryTextStyle()),
        //     TextButton(
        //       onPressed: () {
        //         hideKeyboard(context);
        //         SignUpScreen().launch(context);
        //       },
        //       child: Text(
        //         language.signUp,
        //         style: boldTextStyle(
        //           color: primaryColor,
        //           decoration: TextDecoration.underline,
        //           fontStyle: FontStyle.italic,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        // TextButton(
        //   onPressed: () {
        //     if (isAndroid) {
        //       if (getStringAsync(PROVIDER_PLAY_STORE_URL).isNotEmpty) {
        //         launchUrl(Uri.parse(getStringAsync(PROVIDER_PLAY_STORE_URL)), mode: LaunchMode.externalApplication);
        //       } else {
        //         launchUrl(Uri.parse('${getSocialMediaLink(LinkProvider.PLAY_STORE)}$PROVIDER_PACKAGE_NAME'), mode: LaunchMode.externalApplication);
        //       }
        //     } else if (isIOS) {
        //       if (getStringAsync(PROVIDER_APPSTORE_URL).isNotEmpty) {
        //         commonLaunchUrl(getStringAsync(PROVIDER_APPSTORE_URL));
        //       } else {
        //         commonLaunchUrl(IOS_LINK_FOR_PARTNER);
        //       }
        //     }
        //   },
        //   child: Text(language.lblRegisterAsPartner, style: boldTextStyle(color: primaryColor)),
        // )
      ],
    );
  }

  void onLoginSuccessRedirection() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return DashboardScreen();
        },
      ),
      (_) => false,
    );
    // DashboardScreen().launch(context,
    //     isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);

    appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // appBarTitle: language.signIn,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: formKeys,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Observer(builder: (context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 20.height,
                      // Text(language.lblWelcome + ' !', style: boldTextStyle(size: 22)),
                      20.height,
                      AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.email,
                              style: boldTextStyle(),
                            ).paddingBottom(8),
                            AppTextField(
                              textFieldType: TextFieldType.EMAIL_ENHANCED,
                              controller: emailCont,
                              focus: emailFocus,
                              nextFocus: passwordFocus,
                              errorThisFieldRequired: language.requiredText,
                              // decoration: inputDecoration(
                              //   context,
                              //   prefixIcon: ic_message
                              //       .iconImage(size: 10)
                              //       .paddingAll(14),
                              // ),
                              decoration: inputDecoration(context).copyWith(
                                  hintText: 'Enter Email',
                                  prefixIcon: ic_message
                                      .iconImage(size: 10, color: primaryColor)
                                      .paddingAll(14),
                                  hintStyle:
                                      primaryTextStyle(color: Colors.grey),
                                  fillColor: white),
                              textStyle: primaryTextStyle(color: primaryColor),
                              autoFillHints: [AutofillHints.email],
                            ),
                            16.height,
                            Text(
                              language.password,
                              style: boldTextStyle(),
                            ).paddingBottom(8),
                            AppTextField(
                              textFieldType: TextFieldType.PASSWORD,
                              controller: passwordCont,
                              focus: passwordFocus,
                              suffixPasswordVisibleWidget: ic_show
                                  .iconImage(size: 10, color: primaryColor)
                                  .paddingAll(14),
                              suffixPasswordInvisibleWidget: ic_hide
                                  .iconImage(size: 10, color: primaryColor)
                                  .paddingAll(14),
                              // decoration: inputDecoration(
                              //   context,
                              // ),
                              textStyle: primaryTextStyle(color: primaryColor),
                              decoration: inputDecoration(context).copyWith(
                                  hintText: 'Enter Password',
                                  hintStyle:
                                      primaryTextStyle(color: Colors.grey),
                                  fillColor: white),
                              autoFillHints: [AutofillHints.password],
                              onFieldSubmitted: (s) {
                                _handleLogin();
                              },
                            ),
                          ],
                        ),
                      ),
                      _buildRememberWidget(),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
