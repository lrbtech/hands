import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/jobRequest/job_list_screen.dart';
import 'package:hands_user_app/screens/auth/sign_in_screen.dart';
import 'package:hands_user_app/screens/booking/booking_detail_screen.dart';
import 'package:hands_user_app/screens/category/category_screen.dart';
import 'package:hands_user_app/screens/dashboard/Custom_BottomNav.dart';
import 'package:hands_user_app/screens/dashboard/fragment/booking_fragment.dart';
import 'package:hands_user_app/screens/dashboard/fragment/dashboard_fragment.dart';
import 'package:hands_user_app/screens/dashboard/fragment/profile_fragment.dart';
import 'package:hands_user_app/screens/jobRequest/my_post_detail_screen.dart';
import 'package:hands_user_app/screens/setting_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../utils/firebase_messaging_utils.dart';

class DashboardScreen extends StatefulWidget {
  final bool? redirectToBooking;
  final int? postJobId;
  final int? bookingId;

  DashboardScreen({this.redirectToBooking, this.postJobId, this.bookingId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  GlobalKey homeTabKey = GlobalKey();
  GlobalKey bookingsTabKey = GlobalKey();
  GlobalKey categoriesTabKey = GlobalKey();
  GlobalKey profileTabKey = GlobalKey();

  // List<double> destinationsPositions = [];
  // bool isLoaded = false;
  late PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();

    init().whenComplete(() {
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        // afterBuildCreated(() {
        //When the app is in the background and opened directly from the push notification.

        //Handle onClick Notification
        if (message != null) {
          log("data 2 ==> ${message.data}");
          handleNotificationClick(message);
          print(
              'From FirebaseMessaging.instance.getInitialMessage, ${message.notification?.title}, ${message.notification?.body}');
        }

        // });
        //     //When the app is in the background and opened directly from the push notification.
        // FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        //   //Handle onClick Notification
        //   log("data 1 ==> ${message.data}");
        //   handleNotificationClick(message);
        // });

        // FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        //   //Handle onClick Notification
        //   if (message != null) {
        //     log("data 2 ==> ${message.data}");
        //     handleNotificationClick(message);
        //   }
        // });
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        //Handle onClick Notification
        log("data 1 ==> ${message.data}");
        handleNotificationClick(message);
        print(
            'From onMessageOpenedApp, ${message.notification?.title}, ${message.notification?.body}');
      });
    });
    ;
  }

  // void load() {
  //   for (var i = 0; i < 4; i++) {
  //     if (i == 0) {
  //       RenderBox box = homeTabKey.currentContext?.findRenderObject() as RenderBox;
  //       Offset position = box.localToGlobal(Offset.zero); //this is global position
  //       destinationsPositions.add(position.dx);
  //     } else if (i == 1) {
  //       RenderBox box = bookingsTabKey.currentContext?.findRenderObject() as RenderBox;
  //       Offset position = box.localToGlobal(Offset.zero); //this is global position
  //       destinationsPositions.add(position.dx);
  //     } else if (i == 2) {
  //       RenderBox box = categoriesTabKey.currentContext?.findRenderObject() as RenderBox;
  //       Offset position = box.localToGlobal(Offset.zero); //this is global position
  //       destinationsPositions.add(position.dx);
  //     } else if (i == 3) {
  //       RenderBox box = profileTabKey.currentContext?.findRenderObject() as RenderBox;
  //       Offset position = box.localToGlobal(Offset.zero); //this is global position
  //       destinationsPositions.add(position.dx);
  //     }
  //   }
  //   print('********************************************************************************************');
  //   print(destinationsPositions);
  // }

  Future<void> init() async {
    afterBuildCreated(() async {
      if (widget.redirectToBooking.validate()) {
        currentIndex = 1;

        if (widget.bookingId != null) {
          BookingDetailScreen(bookingId: widget.bookingId!).launch(context);
        }
      }
      _controller = PersistentTabController(initialIndex: currentIndex);

      /// Changes System theme when changed
      ///
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: context.cardColor,
          systemNavigationBarContrastEnforced: true,
        ),
      );
      if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
      }

      View.of(context).platformDispatcher.onPlatformBrightnessChanged =
          () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(
              MediaQuery.of(context).platformBrightness == Brightness.light);
        }
      };
      if (widget.postJobId != null) {
        MyPostDetailScreen(
          postRequestId: widget.postJobId!,
          callback: () {},
        ).launch(context);
      }
    });

    /// Handle Firebase Notification click and redirect to that Service & BookDetail screen
    // LiveStream().on(LIVESTREAM_FIREBASE, (value) {
    //   if (value == 3) {
    //     currentIndex = 3;
    //     setState(() {});
    //   }
    // });

    if (isMobile && appStore.isLoggedIn) {
      /// Handle Notification click and redirect to that Service & BookDetail screen
      // OneSignal.Notifications.addClickListener((notification) async {
      //   if (notification.notification.additionalData == null) return;

      //   if (notification.notification.additionalData!.containsKey('id')) {
      //     String? notId = notification.notification.additionalData!["id"].toString();
      //     if (notId.validate().isNotEmpty) {
      //       BookingDetailScreen(bookingId: notId.toString().toInt()).launch(context);
      //     }
      //   } else if (notification.notification.additionalData!.containsKey('service_id')) {
      //     String? notId = notification.notification.additionalData!["service_id"];
      //     if (notId.validate().isNotEmpty) {
      //       ServiceDetailScreen(serviceId: notId.toInt()).launch(context);
      //     }
      //   } else if (notification.notification.additionalData!.containsKey('sender_uid')) {
      //     String? notId = notification.notification.additionalData!["sender_uid"];
      //     if (notId.validate().isNotEmpty) {
      //       currentIndex = 3;
      //       setState(() {});
      //     }
      //   }
      // });
    }

    await 1.seconds.delay;
    if (getIntAsync(FORCE_UPDATE_USER_APP).getBoolInt()) {
      showForceUpdateDialog(context);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    LiveStream().dispose(LIVESTREAM_FIREBASE);
  }

  List<PersistentTabConfig> _navBarsItems() {
    return [
      PersistentTabConfig(
        screen: DashboardFragment(),
        item: ItemConfig(
          icon: Icon(Iconsax.home),
          title: language.home,
          activeForegroundColor: Colors.white,
          inactiveForegroundColor: grey,
        ),
      ),
      PersistentTabConfig(
        screen: Observer(
            builder: (context) => appStore.isLoggedIn
                ? appStore.userType == "provider"
                    ? JobListScreen()
                    : BookingFragment()
                : SignInScreen(isFromDashboard: true)),
        item: ItemConfig(
          icon: Icon(
            Icons.abc,
            color: primaryColor,
          ),
          // icon: Image.asset(
          //   'assets/ic_logo.png',
          // ),
          //title: language.booking,
          title: " ",
          activeForegroundColor: primaryColor,
          inactiveForegroundColor: grey,
        ),
      ),
      PersistentTabConfig(
          screen: ProfileFragment(),
          item: ItemConfig(
            icon: Icon(Iconsax.user),
            title: language.profile,
            activeForegroundColor: Colors.white,
            inactiveForegroundColor: grey,
          )),
      // PersistentBottomNavBarItem(
      //   icon: Icon(Iconsax.document),
      //   title: language.booking,
      //   activeColorPrimary: primaryColor,
      //   inactiveColorPrimary: grey,
      // ),
      // PersistentBottomNavBarItem(
      //   icon: Icon(Iconsax.category),
      //   title: language.category,
      //   activeColorPrimary: primaryColor,
      //   inactiveColorPrimary: grey,
      // ),
      // PersistentTabConfig(
      //   icon: Icon(Iconsax.user),
      //   title: language.profile,
      //   activeColorPrimary: primaryColor,
      //   inactiveColorPrimary: grey,
      // ),
    ];
  }

  List<Widget> _buildScreens() {
    return [
      DashboardFragment(),
      Observer(
          builder: (context) => appStore.isLoggedIn
              ? BookingFragment()
              : SignInScreen(isFromDashboard: true)),
      CategoryScreen(),
      // Observer(builder: (context) => appStore.isLoggedIn ? ChatListScreen() : SignInScreen(isFromDashboard: true)),
      ProfileFragment(),
    ];
  }

  // @override
  // Widget build(BuildContext context) {
  //   return DoublePressBackWidget(
  //     message: language.lblBackPressMsg,
  //     child: Scaffold(
  //         body: [
  //           DashboardFragment(),
  //           Observer(
  //               builder: (context) => appStore.isLoggedIn
  //                   ? BookingFragment()
  //                   : SignInScreen(isFromDashboard: true)),
  //           // CategoryScreen(
  //           //   showBackButton: false,
  //           // ),
  //           // Observer(builder: (context) => appStore.isLoggedIn ? ChatListScreen() : SignInScreen(isFromDashboard: true)),
  //           ProfileFragment(),
  //           // SettingScreen(
  //           //   showBack: false,
  //           // )
  //         ][currentIndex],
  //         floatingActionButtonLocation:
  //             FloatingActionButtonLocation.centerDocked,
  //         floatingActionButton: ClipRRect(
  //             borderRadius: BorderRadius.circular(18),
  //             child: Container(
  //               decoration:
  //                   BoxDecoration(color: Color(0xFF0C0C0C).withOpacity(.84)),
  //               child: Blur(
  //                 color: context.scaffoldBackgroundColor.withOpacity(.7),
  //                 blur: 30,
  //                 borderRadius: radius(18),
  //                 child: NavigationBarTheme(
  //                   data: NavigationBarThemeData(
  //                     backgroundColor:
  //                         context.scaffoldBackgroundColor.withOpacity(.4),
  //                     indicatorColor: context.primaryColor.withOpacity(0.1),
  //                     labelTextStyle:
  //                         MaterialStateProperty.all(primaryTextStyle(size: 12)),
  //                     surfaceTintColor: Colors.transparent,
  //                     shadowColor: Colors.transparent,
  //                   ),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(18),
  //                     child: NavigationBar(
  //                       selectedIndex: currentIndex,
  //                       height: 70,
  //                       destinations: [
  //                         NavigationDestination(
  //                           icon:
  //                               ic_home.iconImage(color: appTextSecondaryColor),
  //                           selectedIcon: ic_home_active.iconImage(
  //                               color: appStore.isDarkMode
  //                                   ? white
  //                                   : context.primaryColor),
  //                           label: language.home,
  //                         ),
  //                         NavigationDestination(
  //                           icon: ic_ticket.iconImage(
  //                               color: appTextSecondaryColor),
  //                           selectedIcon: ic_ticket_active.iconImage(
  //                               color: appStore.isDarkMode
  //                                   ? white
  //                                   : context.primaryColor),
  //                           label: language.booking,
  //                         ),
  //                         // NavigationDestination(
  //                         //   icon: ic_category.iconImage(color: appTextSecondaryColor),
  //                         //   selectedIcon: ic_category_active.iconImage(color: context.primaryColor),
  //                         //   label: language.category,
  //                         // ),
  //                         NavigationDestination(
  //                           icon: ic_profile2.iconImage(
  //                               color: appTextSecondaryColor),
  //                           selectedIcon: ic_profile2_active.iconImage(
  //                               color: appStore.isDarkMode
  //                                   ? white
  //                                   : context.primaryColor),
  //                           label: language.profile,
  //                         ),
  //                         // NavigationDestination(
  //                         //   icon: Icon(Iconsax.call, color: appTextSecondaryColor),
  //                         //   selectedIcon: Icon(Iconsax.call5, color: context.primaryColor),
  //                         //   label: appStore.selectedLanguageCode == 'en' ? 'Contact' : 'راسلنا',
  //                         // ),
  //                       ],
  //                       onDestinationSelected: (index) {
  //                         currentIndex = index;
  //                         setState(() {});
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             )).paddingSymmetric(horizontal: 16, vertical: isAndroid ? 10 : 0)
  //         // bottomNavigationBar: AnimatedBottomNavigationBar(
  //         //   icons: [
  //         //     Iconsax.home,
  //         //     Iconsax.document,
  //         //     Iconsax.category,
  //         //     Iconsax.user,
  //         //     // Iconsax.user,
  //         //   ],
  //         //   gapLocation: GapLocation.center,
  //         //   notchSmoothness: NotchSmoothness.defaultEdge,
  //         //   activeIndex: currentIndex,
  //         //   height: 55,
  //         //   splashRadius: 32,
  //         //   leftCornerRadius: 32,
  //         //   rightCornerRadius: 32,
  //         //   blurEffect: true,
  //         //   gapWidth: 10,
  //         //   inactiveColor: grey.withOpacity(.7),
  //         //   activeColor: primaryColor,
  //         //   backgroundColor: context.cardColor,
  //         //   onTap: (index) => setState(() => currentIndex = index),
  //         //   safeAreaValues: SafeAreaValues(bottom: false),
  //         //   //other params
  //         // ),
  //         ),
  //   );
  // }
  DateTime? _currentBackPressTime;
  @override
  Widget build(BuildContext context) => PersistentTabView(
        navBarHeight: 70,
        onWillPop: (BuildContext) {
          DateTime now = DateTime.now();

          if (_currentBackPressTime == null ||
              now.difference(_currentBackPressTime!) > Duration(seconds: 2)) {
            _currentBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Press back again to exit'),
              ),
            );

            return Future.value(false);
          }
          SystemNavigator.pop();
          return Future.value(true);
        },
        navBarOverlap: const NavBarOverlap.custom(overlap: 35.0),
        controller: _controller,
        stateManagement: false,
        backgroundColor: context.scaffoldBackgroundColor.withOpacity(.4),
        // backgroundColor: primaryColor,
        // resizeToAvoidBottomInset: true,
        tabs: _navBarsItems(),
        navBarBuilder: (navBarConfig) => Style15BottomNavBar(
            navBarConfig: navBarConfig,
            navBarDecoration: NavBarDecoration(
              color: primaryColor,
              // border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 191, 185, 185),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
              // padding: EdgeInsets.all(10)
            )),
        onTabChanged: (value) {
          if (value == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Observer(
                        builder: (context) => appStore.isLoggedIn
                            ? BookingFragment()
                            : SignInScreen(isFromDashboard: true))));
          }
        },
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: customFloatingActionButton(context),
      );
}
