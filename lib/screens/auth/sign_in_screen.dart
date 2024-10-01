import 'package:flutter_html/flutter_html.dart';
import 'package:hands_user_app/component/back_widget.dart';
import 'package:hands_user_app/component/base_scaffold_body.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/auth/auth_user_services.dart';
import 'package:hands_user_app/screens/auth/email_signin.dart';
import 'package:hands_user_app/screens/auth/forgot_password_screen.dart';
import 'package:hands_user_app/screens/auth/otp_login_screen.dart';
import 'package:hands_user_app/screens/auth/sign_up_screen.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/map/map_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/dashed_rect.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInScreen extends StatefulWidget {
  final bool? isFromDashboard;
  final bool? isFromServiceBooking;
  final bool returnExpected;
  final bool isRegeneratingToken;

  SignInScreen(
      {this.isFromDashboard,
      this.isFromServiceBooking,
      this.returnExpected = false,
      this.isRegeneratingToken = false});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;

  bool isRemember = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _tabIndex,
    );
    // if (await isIqonicProduct) {
    //   emailCont.text = DEFAULT_EMAIL;
    //   passwordCont.text = DEFAULT_PASS;
    // }

    // isRemember = getBoolAsync(IS_REMEMBERED, defaultValue: true);
    // if (isRemember) {
    //   emailCont.text = getStringAsync(USER_EMAIL, defaultValue: DEFAULT_EMAIL);
    //   passwordCont.text = getStringAsync(USER_PASSWORD, defaultValue: DEFAULT_PASS);
    // }

    if (widget.isRegeneratingToken) {
      // if (isLoginTypeUser) {
      //   emailCont.text = appStore.userEmail;
      //   passwordCont.text = getStringAsync(USER_PASSWORD);

      //   _handleLogin(isDirectLogin: true);
      // } else

      if (isLoginTypeGoogle) {
        googleSignIn();
      } else if (isLoginTypeApple) {
        appleSign();
      } else if (isLoginTypeOTP) {
        toast(language.lblLoginAgain);
        logoutApi().then((value) async {
          //
        }).catchError((e) {
          log(e.toString());
        });

        await clearPreferences();
      }
    }
  }

  //region Methods

  void googleSignIn() async {
    print("************************************************************");
    print("Google sign in");
    print("************************************************************");
    appStore.setLoading(true);
    await authService.signInWithGoogle(context).then((value) async {
      print("************************************************************");
      print("Value =$value");
      print("************************************************************");
      appStore.setLoading(false);
      saveDataToPreference(context,
          userData: value!.userData!,
          isSocialLogin: true, onRedirectionClick: () {
        onLoginSuccessRedirection();
      });
    }).catchError((e) {
      appStore.setLoading(false);
      print("************************************************************");
      print("${e.toString()}");
      print("************************************************************");
      toast(e.toString());
    });
  }

  void otpSignIn() async {
    hideKeyboard(context);

    OTPLoginScreen().launch(context);
  }

  void onLoginSuccessRedirection() {
    TextInput.finishAutofillContext();
    if (widget.isFromServiceBooking.validate() ||
        widget.isFromDashboard.validate() ||
        widget.returnExpected.validate()) {
      if (widget.isFromDashboard.validate()) {
        setStatusBarColor(context.primaryColor);
      }

      finish(context, true);
    } else {
      DashboardScreen().launch(context,
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }

    appStore.setLoading(false);
  }

  void appleSign() async {
    appStore.setLoading(true);

    await authService.appleSignIn().then((value) async {
      appStore.setLoading(false);

      onLoginSuccessRedirection();
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

//endregion

//region Widgets
  Widget _buildTopWidget() {
    return Container(
      child: Column(
        children: [
          Text("${language.lblLoginTitle}!", style: boldTextStyle(size: 20))
              .center(),
          16.height,
          Text(language.lblLoginSubTitle,
                  style: primaryTextStyle(size: 14),
                  textAlign: TextAlign.center)
              .center()
              .paddingSymmetric(horizontal: 32),
          32.height,
        ],
      ),
    );
  }

  Widget _buildSocialWidget() {
    if (otherSettingStore.socialLoginEnable.getBoolInt()) {
      return Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Icon(
          //       Icons.mail,
          //     ),
          //     10.width,
          //     Text(
          //       appStore.selectedLanguageCode == 'en'
          //           ? 'Login via email & password.'
          //           : 'تسجيل الدخول عن طريق البريد الالكتروني',
          //       style: primaryTextStyle(),
          //     ),
          //   ],
          // ).paddingSymmetric(horizontal: 20, vertical: 10).onTap(() {
          //   EmailSinginScreen().launch(context);
          // }, borderRadius: BorderRadius.circular(8)),
          20.height,

          if ((otherSettingStore.googleLoginEnable.getBoolInt() ||
                  otherSettingStore.otpLoginEnable.getBoolInt()) ||
              (isIOS && otherSettingStore.appleLoginEnable.getBoolInt()))
            Row(
              children: [
                Divider(color: context.dividerColor, thickness: 2).expand(),
                16.width,
                Text(language.lblOrContinueWith.toUpperCase(),
                    style: secondaryTextStyle()),
                16.width,
                Divider(color: context.dividerColor, thickness: 2).expand(),
              ],
            ),
          24.height,
          // if (otherSettingStore.otpLoginEnable.getBoolInt())
          // AppButton(
          //   text: '',
          //   color: context.cardColor,
          //   padding: EdgeInsets.all(8),
          //   textStyle: boldTextStyle(),
          //   width: context.width() - context.navigationBarHeight,
          //   child: Row(
          //     children: [
          //       Container(
          //         padding: EdgeInsets.all(8),
          //         decoration: boxDecorationWithRoundedCorners(
          //           backgroundColor: primaryColor.withOpacity(0.1),
          //           boxShape: BoxShape.circle,
          //         ),
          //         child: ic_calling.iconImage(size: 18, color: primaryColor).paddingAll(4),
          //       ),
          //       Text(language.lblSignInWithOTP, style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
          //     ],
          //   ),
          //   onTap: otpSignIn,
          // ),
          if (otherSettingStore.otpLoginEnable.getBoolInt()) 10.height,
          Row(
            children: [
              if (otherSettingStore.googleLoginEnable.getBoolInt())
                Expanded(
                  child: AppButton(
                    text: '',
                    color: context.cardColor,
                    padding: EdgeInsets.all(8),
                    textStyle: boldTextStyle(),
                    width: context.width() - context.navigationBarHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: boxDecorationWithRoundedCorners(
                            // backgroundColor: primaryColor.withOpacity(0.1),
                            boxShape: BoxShape.circle,
                          ),
                          child: GoogleLogoWidget(size: 16),
                        ),
                        // Text(language.lblSignInWithGoogle, style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                      ],
                    ),
                    onTap: googleSignIn,
                  ),
                ),
              if (isIOS)
                if (otherSettingStore.appleLoginEnable.getBoolInt()) 10.width,
              if (isIOS)
                if (otherSettingStore.appleLoginEnable.getBoolInt())
                  Expanded(
                    child: AppButton(
                      text: '',
                      color: context.cardColor,
                      padding: EdgeInsets.all(8),
                      textStyle: boldTextStyle(),
                      width: context.width() - context.navigationBarHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: white,
                              boxShape: BoxShape.circle,
                            ),
                            child: Icon(Icons.apple),
                          ),
                          // Text(language.lblSignInWithApple, style: boldTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                        ],
                      ),
                      onTap: appleSign,
                    ),
                  ),
            ],
          ),
        ],
      );
    } else {
      return Offstage();
    }
  }

//endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    if (widget.isFromServiceBooking.validate()) {
      setStatusBarColor(Colors.transparent,
          statusBarIconBrightness: Brightness.dark);
    } else if (widget.isFromDashboard.validate()) {
      setStatusBarColor(Colors.transparent,
          statusBarIconBrightness: Brightness.light);
    } else {
      setStatusBarColor(primaryColor,
          statusBarIconBrightness: Brightness.light);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.scaffoldBackgroundColor,
        leading: Navigator.of(context).canPop()
            ? BackWidget(
                iconColor: appStore.isDarkMode
                    ? context.primaryColor
                    : context.iconColor)
            : null,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness:
                appStore.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarColor: context.scaffoldBackgroundColor),
      ),
      resizeToAvoidBottomInset: true,
      extendBody: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(
                          100,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.white54,
                              offset: Offset(0, 3),
                              spreadRadius: 0.1,
                              blurRadius: 4)
                        ]),
                    padding: EdgeInsets.zero,
                    child: TabBar(
                      isScrollable: false,
                      unselectedLabelColor: appStore.isDarkMode
                          ? textSecondaryColor
                          : primaryColor,
                      unselectedLabelStyle: primaryTextStyle(
                          fontFamily: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.fontFamily),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: black,
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          100,
                        ),
                        color: Colors.white,
                      ),
                      dividerColor: Colors.transparent,
                      labelStyle: boldTextStyle(
                          fontFamily:
                              Theme.of(context).textTheme.bodyLarge?.fontFamily,
                          color: black),
                      tabs: [
                        SizedBox(
                            width: double.infinity,
                            height: 43,
                            child: Tab(text: language.signIn)),
                        SizedBox(
                            width: double.infinity,
                            height: 43,
                            child: Tab(text: language.signUp)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              20.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10, left: 10),
                                    child: Text(language.lblWelcome + ' !',
                                        style: boldTextStyle(size: 22)),
                                  ),
                                ],
                              ),
                              20.height,
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, left: 10),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _onTabSelected(0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Email',
                                            style: TextStyle(
                                              color: _currentIndex == 0
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .surface
                                                  : Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          if (_currentIndex == 0)
                                            Container(
                                              width: 30,
                                              height: 2,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    GestureDetector(
                                      onTap: () => _onTabSelected(1),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Phone',
                                            style: TextStyle(
                                              color: _currentIndex == 1
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .surface
                                                  : Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          if (_currentIndex == 1)
                                            Container(
                                              width: 30,
                                              height: 2,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _currentIndex == 0
                                  ? SizedBox(
                                      height: context.height() * .4,
                                      child: EmailSinginScreen(),
                                    )
                                  : SizedBox(
                                      height: context.height() * .4,
                                      child: OTPLoginScreen(
                                        showBackButton: false,
                                      ),
                                    ),
                              // EmailSinginScreen(),
                              SizedBox(
                                  child: _buildSocialWidget()
                                      .paddingSymmetric(horizontal: 20)),
                              80.height,
                            ],
                          ),
                        ),
                        SignUpScreen().paddingSymmetric(horizontal: 14),
                      ],
                    ),
                  ),
                ],
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
