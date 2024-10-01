import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/components/cached_image_widget.dart';
import 'package:hands_user_app/provider/fragment/booking_fragment.dart';
import 'package:hands_user_app/provider/fragment/notification_fragment.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/fragments/explore_jobs.dart';
import 'package:hands_user_app/provider/fragments/provider_home_fragment.dart';
import 'package:hands_user_app/provider/fragments/provider_payment_fragment.dart';
import 'package:hands_user_app/provider/fragments/provider_profile_fragment.dart';
import 'package:hands_user_app/provider/jobRequest/bid_list_screen.dart';
import 'package:hands_user_app/provider/jobRequest/guest_job_list_screen.dart';
import 'package:hands_user_app/provider/jobRequest/job_list_screen.dart';
import 'package:hands_user_app/provider/screens/chat/user_chat_list_screen.dart';
import 'package:hands_user_app/provider/utils/colors.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/extensions/string_extension.dart';
import 'package:hands_user_app/provider/utils/firebase_messaging_utils.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final int? index;

  ProviderDashboardScreen({this.index});

  @override
  ProviderDashboardScreenState createState() => ProviderDashboardScreenState();
}

class ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  // Filter
  String selectedFilterValue = '';
  List<String> filters = [
    languages.activeJobsOnTop,
    languages.urgentJobsOnTop,
    languages.priceHighToLow,
    languages.latestJobs,
  ];

  void changeSelectedFilter({required int index}) {
    selectedFilterValue = filters[index];
  }

  int currentIndex = 0;

  DateTime? currentBackPressTime;

  late List<Widget> fragmentList;

  List<String> screenName = [];

  @override
  void initState() {
    super.initState();

    fragmentList = [
      ProviderHomeFragment(),
      ProviderProfileFragment(),
      guest && getBoolAsync(HAS_IN_REVIEW)
          ? GuestJobListScreen()
          : JobListScreen(),
    ];

    init().whenComplete(() {
      // afterBuildCreated(() {
      //When the app is in the background and opened directly from the push notification.
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        //Handle onClick Notification
        if (message != null) {
          log("data 2 ==> ${message.data}");
          handleNotificationClick(message);
          print(
              'From FirebaseMessaging.instance.getInitialMessage, ${message.notification?.title}, ${message.notification?.body}');
        }
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
  }

  Future<void> init() async {
    afterBuildCreated(
      () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStorePro
              .setDarkMode(context.platformBrightness() == Brightness.dark);
        }

        window.onPlatformBrightnessChanged = () async {
          if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
            appStorePro
                .setDarkMode(context.platformBrightness() == Brightness.light);
          }
        };
      },
    );

    LiveStream().on(LIVESTREAM_PROVIDER_ALL_BOOKING, (index) {
      BookingFragment().launch(context);
      setState(() {});
    });

    // await 3.seconds.delay;
    if (getIntAsync(FORCE_UPDATE_PROVIDER_APP).getBoolInt()) {
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
    LiveStream().dispose(LIVESTREAM_PROVIDER_ALL_BOOKING);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();

        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          toast(languages.lblCloseAppMsg);
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: currentIndex != 2
            ? appBarWidget(
                [
                  languages.providerHome,
                  // languages.lblBooking,
                  // languages.lblPayment,
                  languages.lblProfile,
                  languages.exploreJobs,
                  // (1 == 1 ? languages.bidList : languages.jobRequestList),
                ][currentIndex],
                color: primaryColor,
                textColor: Colors.white,
                showBack: false,
                titleWidget: currentIndex == 0
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: boxDecorationDefault(
                                border: Border.all(color: white, width: 3),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                decoration: boxDecorationDefault(
                                  border: Border.all(color: white, width: 4),
                                  shape: BoxShape.circle,
                                ),
                                child: CachedImageWidget(
                                  url: appStore.userProfileImage.validate(),
                                  height: 20,
                                  fit: BoxFit.cover,
                                  circle: true,
                                ),
                              ),
                            ),
                            10.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 16.height,
                                Text(
                                    "${languages.lblHello}, ${appStore.userFullName}",
                                    style: boldTextStyle(
                                      size: 13,
                                      color: white,
                                    )).paddingLeft(16),
                                // 8.height,
                                Text(languages.lblWelcomeBack,
                                        style: secondaryTextStyle(size: 11))
                                    .paddingLeft(16),
                                16.height,
                              ],
                            ),
                          ],
                        ),
                      )
                    : null,
                actions: [
                  if (currentIndex == 2)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            insetPadding: EdgeInsets.all(20),
                            backgroundColor: white,
                            titlePadding: EdgeInsets.all(20),
                            contentPadding: EdgeInsets.all(20),
                            elevation: 0,
                            actions: [],
                            content: StatefulBuilder(
                              builder: (BuildContext context,
                                      void Function(void Function())
                                          setState2) =>
                                  SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                // height: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Title
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          languages.filterByTitle,
                                          style: boldTextStyle(),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: CircleAvatar(
                                            radius: 15,
                                            backgroundColor: black,
                                            child: Icon(
                                              Icons.close,
                                              color: white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    20.height,

                                    // Buttons
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) =>
                                          FilterButton(
                                        onPressed: () {},
                                        title: filters[index],
                                        selectedValue: selectedFilterValue,
                                        onChanged: (selected) {
                                          changeSelectedFilter(index: index);
                                          setState2(() {});
                                          // Navigator.of(context).pop();
                                        },
                                      ),
                                      separatorBuilder: (context, index) =>
                                          20.height,
                                      itemCount: filters.length,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        // width: 100,
                        height: 25,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: filter.iconImage(
                            color: black, size: 20, fit: BoxFit.fitHeight),
                      ),
                    ),
                  // IconButton(
                  //   icon: filter.iconImage(color: white, size: 20),
                  //   onPressed: () async {
                  //     ChatListScreen().launch(context);
                  //   },
                  // ),
                  IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ic_notification.iconImage(color: white, size: 20),
                        Positioned(
                          top: -14,
                          right: -6,
                          child: Observer(
                            builder: (context) {
                              if (appStorePro.notificationCount.validate() > 0)
                                return Container(
                                  padding: EdgeInsets.all(4),
                                  child: FittedBox(
                                    child: Text(
                                        appStorePro.notificationCount
                                            .toString(),
                                        style: primaryTextStyle(
                                            size: 12, color: Colors.white)),
                                  ),
                                  decoration: boxDecorationDefault(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                );

                              return Offstage();
                            },
                          ),
                        )
                      ],
                    ),
                    onPressed: () async {
                      NotificationFragment().launch(context);
                    },
                  ),
                ],
              )
            : null,
        body: fragmentList[currentIndex],
        floatingActionButton: GestureDetector(
          onTap: () {
            currentIndex = 2;

            setState(() {});
          },
          child: Container(
            height: 90,
            width: 90,
            // margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              // mar,
              color: currentIndex == 2 ? Color(0xFFF5F8FE) : white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.3),
                  offset: Offset(0, 3),
                  spreadRadius: 0.7,
                  blurRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                currentIndex == 2
                    ? ic_explore_jobs_active.iconImage(
                        color: appTextSecondaryColor)
                    : ic_explore_jobs.iconImage(color: appTextSecondaryColor),
                const SizedBox(height: 7),
                Center(
                  child: Text(
                    languages.exploreJobs,
                    style: currentIndex == 2
                        ? boldTextStyle(size: 10, color: black)
                        : primaryTextStyle(size: 10, color: black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: Blur(
          blur: 30,
          child: BottomAppBar(
            color: appStorePro.isDarkMode
                ? context.primaryColor
                : context.cardColor,
            // height: 60,
            elevation: 0.0,
            shape: const CircularNotchedRectangle(),

            // color: ColorsResources.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: Container(
                    alignment: AlignmentDirectional.centerStart,
                    color: transparentColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        40.width,
                        Column(
                          children: [
                            currentIndex == 0
                                ? ic_fill_home.iconImage(
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : context.primaryColor)
                                : ic_home.iconImage(
                                    color: appTextSecondaryColor),
                            Text(languages.home,
                                style: primaryTextStyle(
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : context.primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      currentIndex = 0;
                    });
                  },
                ).expand(),
                GestureDetector(
                  child: Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    color: transparentColor,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            currentIndex == 1
                                ? ic_fill_profile.iconImage(
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : context.primaryColor)
                                : profile.iconImage(
                                    color: appTextSecondaryColor),
                            Text(languages.lblProfile,
                                style: primaryTextStyle(
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : context.primaryColor)),
                          ],
                        ),
                        40.width,
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  },
                ).expand(),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: Blur(
        //   blur: 30,
        //   child: Stack(
        //     children: [
        //       Container(
        //         height: 50,
        //         width: double.infinity,
        //         color: appStorePro.isDarkMode ? context.primaryColor : white,
        //       ),
        //       Container(
        //         height: 50,
        //         padding: EdgeInsets.symmetric(horizontal: 20),
        //         child: BottomNavyBar(
        //           showElevation: true,
        //           backgroundColor:
        //               appStorePro.isDarkMode ? context.primaryColor : white,
        //           selectedIndex: currentIndex,
        //           items: [
        //             BottomNavyBarItem(
        //               icon: currentIndex == 0
        //                   ? ic_fill_home.iconImage(
        //                       color: appStorePro.isDarkMode
        //                           ? white
        //                           : context.primaryColor)
        //                   : ic_home.iconImage(color: appTextSecondaryColor),
        //               title: Text(
        //                 languages.home,
        //                 style: primaryTextStyle(
        //                     color: appStorePro.isDarkMode
        //                         ? white
        //                         : context.primaryColor),
        //               ),
        //               activeColor:
        //                   !appStorePro.isDarkMode ? white : context.primaryColor,
        //             ),
        //             BottomNavyBarItem(
        //               icon: currentIndex == 1
        //                   ? ic_fill_profile.iconImage(
        //                       color: appStorePro.isDarkMode
        //                           ? white
        //                           : context.primaryColor)
        //                   : profile.iconImage(color: appTextSecondaryColor),
        //               title: Text(
        //                 languages.lblProfile,
        //                 style: primaryTextStyle(
        //                   color: appStorePro.isDarkMode
        //                       ? white
        //                       : context.primaryColor,
        //                 ),
        //               ),
        //             ),
        //           ],
        //           onItemSelected: (int value) {
        //             currentIndex = value;
        //             setState(() {});
        //           },
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        /// dasdasdas
        // bottomNavigationBar: Blur(
        //   blur: 30,
        //   borderRadius: radius(0),
        //   child: NavigationBarTheme(
        //     data: NavigationBarThemeData(
        //       backgroundColor: context.primaryColor.withOpacity(0.02),
        //       indicatorColor: context.primaryColor.withOpacity(0.1),
        //       labelTextStyle:
        //           MaterialStateProperty.all(primaryTextStyle(size: 12)),
        //       surfaceTintColor: Colors.transparent,
        //       shadowColor: Colors.transparent,
        //     ),
        //     child: NavigationBar(
        //       selectedIndex: currentIndex,
        //       destinations: [
        //         NavigationDestination(
        //           icon: ic_home.iconImage(color: appTextSecondaryColor),
        //           selectedIcon: ic_fill_home.iconImage(
        //               color:
        //                   appStorePro.isDarkMode ? white : context.primaryColor),
        //           label: languages.home,
        //         ),
        //         NavigationDestination(
        //           icon: total_booking.iconImage(color: appTextSecondaryColor),
        //           selectedIcon: fill_ticket.iconImage(
        //               color:
        //                   appStorePro.isDarkMode ? white : context.primaryColor),
        //           label: languages.lblBooking,
        //         ),
        //         NavigationDestination(
        //           icon: un_fill_wallet.iconImage(color: appTextSecondaryColor),
        //           selectedIcon: ic_fill_wallet.iconImage(
        //               color:
        //                   appStorePro.isDarkMode ? white : context.primaryColor),
        //           label: languages.lblPayment,
        //         ),
        //         NavigationDestination(
        //           icon: profile.iconImage(color: appTextSecondaryColor),
        //           selectedIcon: ic_fill_profile.iconImage(
        //               color:
        //                   appStorePro.isDarkMode ? white : context.primaryColor),
        //           label: languages.lblProfile,
        //         ),
        //       ],
        //       onDestinationSelected: (index) {
        //         currentIndex = index;
        //         setState(() {});
        //       },
        //     ),
        //   ),
        // ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String title;
  final String selectedValue;
  final void Function(String?)? onChanged;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.title,
    required this.selectedValue,
    required this.onChanged,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        unselectedWidgetColor:
            appStorePro.isDarkMode ? white : context.primaryColor,
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: title == selectedValue
                ? white
                : Color(0xFFCED1DD).withOpacity(0.36),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 4),
                color: black.withOpacity(title == selectedValue ? 0.1 : 0.05),
                blurRadius: 3,
                spreadRadius: 3,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Radio(
                  value: title,
                  groupValue: selectedValue,
                  onChanged: onChanged,
                  activeColor: greenColor,
                ),
                Text(
                  title,
                  style: primaryTextStyle(
                    color: context.primaryColor,
                  ),
                ),
              ],
            ),
            // child: RadioListTile(
            //   // selectedTileColor: greenColor,
            //   value: title,
            //   groupValue: selectedValue,
            //   activeColor: greenColor,

            //   title: Text(
            //     title,
            //     style: primaryTextStyle(
            //       color: context.primaryColor,
            //     ),
            //   ),

            //   onChanged: onChanged,
            // ),
          ),
        ),
      ),
    );
  }
}
