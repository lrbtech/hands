import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
// import 'package:hands_user_app/auth/sign_in_screen.dart';
// import 'package:hands_user_app/handyman/handyman_dashboard_screen.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/provider_dashboard_screen.dart';
import 'package:hands_user_app/screens/maintenance_mode_screen.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/firebase_messaging_utils.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constant.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late Timer timer;

  @override
  void initState() {
    super.initState();

    initFirebaseMessaging();

    timer = Timer(Duration(seconds: 2), () {
      init();
    });
  }

  Future<void> init() async {
    // initFirebaseMessaging();

    afterBuildCreated(() async {
      appStorePro.setLanguage(
          getStringAsync(SELECTED_LANGUAGE_CODE,
              defaultValue: DEFAULT_LANGUAGE),
          context: context);
      setStatusBarColor(Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness:
              appStorePro.isDarkMode ? Brightness.light : Brightness.dark);

      int themeModeIndex =
          getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
      if (themeModeIndex == THEME_MODE_SYSTEM) {
        appStorePro.setDarkMode(
            MediaQuery.of(context).platformBrightness == Brightness.dark);
      }
    });

    if (!await isAndroid12Above()) await 500.milliseconds.delay;

    if (otherSettingStore.maintenanceModeEnable.getBoolInt()) {
      MaintenanceModeScreen()
          .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
    } else {
      if (!appStorePro.isLoggedIn) {
        // SignInScreen().launch(context, isNewTask: true);
      } else {
        if (isUserTypeProvider) {
          setStatusBarColor(primaryColor);
          ProviderDashboardScreen(index: 0).launch(context,
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else if (isUserTypeHandyman) {
          setStatusBarColor(primaryColor);
          // HandymanDashboardScreen(index: 0).launch(context,
          //     isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          // SignInScreen().launch(context, isNewTask: true);
        }
      }
    }

    timer.cancel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            appStorePro.isDarkMode
                ? splash_background
                : splash_light_background,
            height: context.height(),
            width: context.width(),
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BounceInUp(
                  child: Image.asset(splashLogo, height: 220, width: 220)),
              32.height,
              BounceInDown(
                  child: Text(APP_NAME, style: boldTextStyle(size: 26))),
            ],
          ),
        ],
      ),
    );
  }
}
