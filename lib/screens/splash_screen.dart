import 'package:flutter/widgets.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/maintenance_mode_screen.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/firebase_messaging_utils.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:video_player/video_player.dart';

import '../network/rest_apis.dart';
import 'walk_through_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  late VoidCallback _listener;
  late Future<void> _initVideoFuture;
  bool open = false;
  bool videoCompleted = false;

  _videoDisplay() {
    initFirebaseMessaging();
    _videoController = VideoPlayerController.asset(
        "assets/images/splash_video.MP4",
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    videoCompleted = false;

    _initVideoFuture = _videoController.initialize().then((value) {
      setState(() {});
    });
    _listener = () async {
      if (_videoController.value.hasError && !open) {
        open = true;
        videoCompleted = true;
        log("video Error Stop");
        init();
      } else {
        if (_videoController.value.isInitialized &&
            !_videoController.value.isPlaying &&
            !open) {
          open = true;
          videoCompleted = true;
          // Future.delayed(Duration(seconds: 6), () async {
          log("Video Complete");
          init();
          // });
        } else {
          await 4.seconds;
          init();
        }
      }
    };
    _videoController.addListener(_listener);
    _videoController.play();
  }

  @override
  void initState() {
    super.initState();
    _videoDisplay();
  }

  Future<void> init() async {
    // initFirebaseMessaging();

    afterBuildCreated(() async {
      setStatusBarColor(Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness:
              appStore.isDarkMode ? Brightness.light : Brightness.dark);

      ///Set app configurations
      await getAppConfigurations().then((value) {}).catchError((e) {
        log(e);
      });

      await appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE,
          defaultValue: DEFAULT_LANGUAGE));

      int themeModeIndex =
          getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
      if (themeModeIndex == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(
            MediaQuery.of(context).platformBrightness == Brightness.dark);
      }

      await 500.milliseconds.delay;

      if (otherSettingStore.maintenanceModeEnable.getBoolInt()) {
        MaintenanceModeScreen().launch(context,
            isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else {
        if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
          WalkThroughScreen().launch(context,
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          DashboardScreen().launch(context,
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initVideoFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasError &&
              snapshot.connectionState == ConnectionState.done) {
            return FittedBox(
              fit: BoxFit.contain,
              child: Container(
                color: Colors.white,
                // color: ColorResources.videoBG,
                // margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    // Video
                    VideoPlayer(_videoController),

                    // Logo
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(),
                          Image.asset(
                            "assets/logo_large.png",
                            height: 200,
                          ),
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                language.splashSlogan,
                                textStyle: boldTextStyle(
                                  color: Color(0xFF000C2C),
                                  size: 24,
                                ),
                                speed: 100.milliseconds,
                              ),
                            ],
                            totalRepeatCount: 4,
                            pause: const Duration(milliseconds: 1000),
                            displayFullTextOnTap: true,
                            stopPauseOnTap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(color: Colors.white);
          }
        },
      ),

      //  Stack(
      //   fit: StackFit.expand,
      //   children: [
      //     Image.asset(
      //       appStore.isDarkMode ? splash_background : splash_light_background,
      //       height: context.height(),
      //       width: context.width(),
      //       fit: BoxFit.cover,
      //     ),
      //     Column(
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Image.asset(appLogo, height: 120, width: 120),
      //         32.height,
      //         Text(APP_NAME, style: boldTextStyle(size: 26)),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }
}
