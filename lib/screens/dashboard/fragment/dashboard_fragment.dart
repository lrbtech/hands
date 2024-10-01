import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/component/view_all_label_component.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/dashboard_model.dart';
import 'package:hands_user_app/model/get_my_post_job_list_response.dart';
import 'package:hands_user_app/models/dashboard_response.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/provider/components/chart_component.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/screens/address/addresses_screen.dart';
import 'package:hands_user_app/screens/auth/sign_in_screen.dart';
import 'package:hands_user_app/screens/dashboard/Custom_BottomNav.dart';
import 'package:hands_user_app/screens/dashboard/component/category_component.dart';
import 'package:hands_user_app/screens/dashboard/component/featured_service_list_component.dart';
import 'package:hands_user_app/screens/dashboard/component/jobs_type_widget.dart';
import 'package:hands_user_app/screens/dashboard/component/service_list_component.dart';
import 'package:hands_user_app/screens/dashboard/component/slider_and_location_component.dart';
import 'package:hands_user_app/screens/dashboard/component/welcome_user.dart';
import 'package:hands_user_app/screens/dashboard/fragment/Custom_TopEarnerMonth.dart';
import 'package:hands_user_app/screens/dashboard/fragment/Custom_TopEarnerWeek.dart';
import 'package:hands_user_app/screens/dashboard/fragment/Custombooking_Container.dart';
import 'package:hands_user_app/screens/dashboard/fragment/Total_Rev_Graph.dart';
import 'package:hands_user_app/screens/dashboard/shimmer/dashboard_shimmer.dart';
import 'package:hands_user_app/screens/jobRequest/components/my_post_request_item_component.dart';
import 'package:hands_user_app/screens/jobRequest/create_post_request_screen.dart';
import 'package:hands_user_app/screens/jobRequest/my_post_request_list_screen.dart';
import 'package:hands_user_app/screens/jobRequest/shimmer/my_post_job_shimmer.dart';
import 'package:hands_user_app/screens/notification/notification_screen.dart';
import 'package:hands_user_app/screens/provider/Dailog_DataMain.dart';
import 'package:hands_user_app/screens/service/search_service_screen.dart';
import 'package:hands_user_app/store/app_store.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';
import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../component/booking_confirmed_component.dart';
import '../component/new_job_request_component.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  Future<DashboardResponse>? future;
  late Future<DashboardResponses> futures;
  // late Future<List<PostJobData>> postFuture;
  List<PostJobData> postJobList = [];

  int page = 1;
  bool isLastPage = false;
  bool isApiCalled = false;

  get commonDecoration => null;
  int? currentState = 0;
  final List list = [
    {
      "image": "slider1.png",
      "title": "NEED HELP ASAP",
      "button": "Urgent Help",
      "color": "red"
    },
    {
      "image": "slider1.png",
      "title": "NEED IT TODAY?\nWE CAN HELP!",
      "button": "Get Help Today",
      "color": "green"
    },
    {
      "image": "slider3.png",
      "title": "LET’S ARRANGE HELP LATER!",
      "button": "Schedule Help",
      "color": "black"
    },
  ];

  @override
  void initState() {
    super.initState();
    init();
    // getLocation();

    setStatusBarColor(primaryColor,
        statusBarIconBrightness: Brightness.light, delayInMilliSeconds: 800);

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) {
      init();
      setState(() {});
    });
  }

  showLoadingDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: primaryColor,
        content: SizedBox(
            height: 100.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: <Widget>[
                  const SizedBox(width: 15.0),
                  Icon(
                    Icons.check_circle,
                    size: 24,
                  ),
                  Expanded(
                    child: Text('Your Document is Under Review!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400)),
                  )
                ]),
                Container(
                  height: 35,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Close",
                        style: GoogleFonts.almarai(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  checkProviderStatus() async {
    appStore.setLoading(true);
    http
        .post(
      Uri.parse("${BASE_URL}user-type-check"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'APP_KEY': "8Shm171pe2oTGvJlql7nxe2Ys/tHJaiiVq6vr5wIu5EJhEEmI3gVi"
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': appStore.userId,
      }),
    )
        .then((response) {
      appStore.setLoading(false);
      Map _user = json.decode(response.body);

      if (_user['provider_status'] == 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const CustomDialogBox();
          },
        );
        appStore.isLoggedIn
            ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const CustomDialogBox();
                },
              )
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Observer(
                        builder: (context) =>
                            SignInScreen(isFromDashboard: true))));
      } else {
        showLoadingDialog(context);
      }
    });
  }

  void init() async {
    future = userDashboard(
        isCurrentLocation: appStore.isCurrentLocation,
        lat: getDoubleAsync(LATITUDE),
        long: getDoubleAsync(LONGITUDE));
    futures = providerDashboard().whenComplete(() {
      setState(() {});
    });
    // postFuture = getPostJobList(page, postJobList: postJobList, lastPageCallBack: (val) {
    //   isLastPage = val;
    // });
  }

  void getLocation() {
    Geolocator.requestPermission().then((value) {
      if (value == LocationPermission.whileInUse ||
          value == LocationPermission.always) {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((value) {
          appStore.setLatitude(value.latitude);
          appStore.setLongitude(value.longitude);
          setState(() {});
        }).catchError(onError);
      }
    });
  }

  bool get _makeMoneyVisibilityCondition {
    if (Platform.isIOS) {
      if (![null, ''].contains(appStore.providerAppstoreUrl)) {
        return true;
      } else {
        return false;
      }
    } else if (Platform.isAndroid) {
      if (![null, ''].contains(appStore.providerPlayStoreUrl)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  String getCurrentOS() {
    if (Platform.isIOS) {
      return 'android';
    } else {
      return 'ios';
    }
  }

  becomeProvider() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, right: 8, left: 8),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.white54, spreadRadius: 0.1, blurRadius: 3)
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textAlign: TextAlign.center,
                "Start Earning Money by Helping People!",
                style: boldTextStyle(
                    color: appStore.isDarkMode ? white : context.primaryColor,
                    size: 14,
                    weight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  if (appStore.isLoggedIn) {
                    checkProviderStatus();
                  } else {
                    SignInScreen().launch(context);
                  }

                  // print(
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 7, bottom: 7, left: 30, right: 30),
                    child: Text("Become a Provider",
                        style: boldTextStyle(
                            color: Colors.black,
                            size: 12,
                            weight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  final AppinioSwiperController controller = AppinioSwiperController();

  ScrollPhysics physics = const AlwaysScrollableScrollPhysics();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            children: [
              SnapHelperWidget<DashboardResponse>(
                initialData: cachedDashboardResponse,
                future: future,
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    imageWidget: ErrorStateWidget(),
                    retryText: language.reload,
                    onRetry: () {
                      appStore.setLoading(true);
                      init();

                      setState(() {});
                    },
                  );
                },
                loadingWidget: DashboardShimmer(),
                onSuccess: (snap) {
                  try {
                    snap.slider?.removeWhere(
                        (element) => element.title == getCurrentOS());
                  } catch (e) {
                    print('no we cant');
                  }
                  return Observer(builder: (context) {
                    return AnimatedScrollView(
                      physics: ScrollPhysics(),
                      listAnimationType: ListAnimationType.FadeIn,
                      fadeInConfiguration:
                          FadeInConfiguration(duration: 2.seconds),
                      onSwipeRefresh: () async {
                        appStore.setLoading(true);

                        init();
                        setState(() {});

                        return await 2.seconds.delay;
                      },
                      children: [
                        // 40.height,
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              color: primaryColor,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.white54,
                                    spreadRadius: 0.1,
                                    blurRadius: 3)
                              ]),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: context.width(),
                              ),
                              // Positioned(
                              //   left: -20,
                              //   child: WhiteCircle(
                              //     size: 80,
                              //   ),
                              // ),
                              // Positioned(
                              //   right: 0,
                              //   left: 0,
                              //   top: 70,
                              //   child: WhiteCircle(
                              //     size: 60,
                              //   ),
                              // ),
                              // Positioned(
                              //   left: 0,
                              //   top: 70,
                              //   bottom: 40,
                              //   child: WhiteCircle(
                              //     size: 60,
                              //   ),
                              // ),
                              // Positioned(
                              //   right: 40,
                              //   top: -5,
                              //   child: WhiteCircle(
                              //     size: 60,
                              //   ),
                              // ),
                              // Positioned(
                              //   left: 40,
                              //   top: 40,
                              //   bottom: 30,
                              //   child: WhiteCircle(
                              //     size: 60,
                              //   ),
                              // ),
                              // Positioned(
                              //   right: 40,
                              //   left: 40,
                              //   bottom: 30,
                              //   child: WhiteCircle(
                              //     size: 90,
                              //   ),
                              // ),
                              Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Column(
                                  children: [
                                    WelcomeUser()
                                        .paddingSymmetric(horizontal: 10),
                                    if (appStore.isLoggedIn)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Row(
                                          children: [
                                            Observer(
                                              builder: (context) {
                                                return AppButton(
                                                  color: Colors.white,
                                                  // width: context.width(),
                                                  shapeBorder:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100)),
                                                  child: Container(
                                                    // padding: EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100)),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          ic_location,
                                                          height: 24,
                                                          width: 24,
                                                        ),
                                                        // ic_location.iconImage(color: redColor),
                                                        8.width,
                                                        Row(
                                                          children: [
                                                            Marquee(
                                                              textDirection: appStore
                                                                          .selectedLanguageCode ==
                                                                      'en'
                                                                  ? TextDirection
                                                                      .ltr
                                                                  : TextDirection
                                                                      .rtl,
                                                              directionMarguee:
                                                                  DirectionMarguee
                                                                      .oneDirection,
                                                              animationDuration:
                                                                  10.seconds,
                                                              backDuration:
                                                                  1.seconds,
                                                              pauseDuration:
                                                                  1.seconds,
                                                              child: Text(
                                                                appStore.tempAddress !=
                                                                        null
                                                                    ? appStore
                                                                        .tempAddress!
                                                                        .address
                                                                        .validate()
                                                                    : language
                                                                        .setAddress,
                                                                style:
                                                                    secondaryTextStyle(),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ).expand(),
                                                          ],
                                                        ).expand(),
                                                        8.width,
                                                        ic_active_location
                                                            .iconImage(
                                                                size: 24,
                                                                color: Color(
                                                                    0xFF6D7698)),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    // locationWiseService(context, () {
                                                    //   appStore.setLoading(true);

                                                    //   init();
                                                    //   setState(() {});
                                                    // });
                                                    AddressesScreen(
                                                      fromSelection: true,
                                                    ).launch(context);
                                                  },
                                                );
                                              },
                                            ).expand(),
                                            // 10.width,
                                            // AppButton(
                                            //   onTap: () {
                                            //     SearchServiceScreen(featuredList: snap.featuredServices.validate()).launch(context);
                                            //   },
                                            //   color: Color(0xFFF95D5D),
                                            //   width: 50,
                                            //   splashColor: Colors.transparent,
                                            //   child: Container(
                                            //     // padding: EdgeInsets.all(16),
                                            //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                                            //     child: Center(child: ic_search.iconImage(color: white)),
                                            //   ),
                                            // ),
                                            // 10.width,
                                          ],
                                        ),
                                      ),
                                    50.height,
                                    // CategoryComponent(categoryList: snap.category.validate()),
                                    // 50.height,
                                  ],
                                ),
                              ),
                              // Positioned(
                              //   bottom: -26,
                              //   left: 10,
                              //   right: 10,
                              //   child: AppButton(
                              //     onTap: () {
                              //       toast('URGENT');
                              //     },
                              //     padding: EdgeInsets.zero,
                              //     child: Container(
                              //       width: context.width(),
                              //       height: 62,
                              //       decoration: BoxDecoration(
                              //         color: context.scaffoldBackgroundColor,
                              //         borderRadius: BorderRadius.circular(10),
                              //         boxShadow: [
                              //           BoxShadow(
                              //             color: grey.withOpacity(.5),
                              //             offset: Offset(0, 10),
                              //             blurRadius: 10,
                              //           ),
                              //         ],
                              //       ),
                              //       child: Row(
                              //         children: [
                              //           30.width,
                              //           Image.asset(
                              //             'assets/icons/urgent.png',
                              //             width: 45,
                              //             height: 45,
                              //           ),
                              //           20.width,
                              //           Expanded(
                              //             child: Column(
                              //               crossAxisAlignment: CrossAxisAlignment.start,
                              //               mainAxisAlignment: MainAxisAlignment.center,
                              //               children: [
                              //                 Text(
                              //                   appStore.selectedLanguageCode == 'en' ? 'Got an urgent job ?' : 'لديك طلب طارئ ؟',
                              //                   style: boldTextStyle(),
                              //                 ),
                              //                 Text(
                              //                   appStore.selectedLanguageCode == 'en' ? 'Request urgently hands Now  !' : 'اطلب بسرعة الان',
                              //                   style: primaryTextStyle(),
                              //                 ),
                              //               ],
                              //             ),
                              //           )
                              //         ],
                              //       ).paddingSymmetric(horizontal: 10),
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        // 10.height,

                        // SizedBox(
                        //   height: 140,
                        //   width: double.infinity,
                        //   child: CarouselSlider(
                        //     items: snap.slider.validate().map((slider) {
                        //       return GestureDetector(
                        //         onTap: () async {
                        //           print('Type = ${slider.title}');
                        //           if (slider.title == 'coupon') {
                        //             await Clipboard.setData(
                        //                 ClipboardData(text: slider.url ?? ''));
                        //             ScaffoldMessenger.of(context).showSnackBar(
                        //               SnackBar(
                        //                 content: Text(appStore.isArabic
                        //                     ? 'تم النسخ الى الحافظة'
                        //                     : 'Copied to clipboard!'),
                        //               ),
                        //             );
                        //           } else {
                        //             String temp =
                        //                 parseHtmlString(slider.url.validate());
                        //             if (temp.startsWith("https") ||
                        //                 temp.startsWith("http")) {
                        //               // launchUrlCustomTab(temp.validate());
                        //               commonLaunchUrl(
                        //                 temp,
                        //                 launchMode:
                        //                     LaunchMode.externalApplication,
                        //               );
                        //             } else {
                        //               toast(language.invalidLink);
                        //             }
                        //           }
                        //         },
                        //         child: Container(
                        //           width: double.maxFinite,
                        //           decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(12),
                        //             // border: Border.all(color: conte),
                        //           ),
                        //           child: Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: ClipRRect(
                        //               borderRadius: BorderRadius.circular(12),
                        //               child: Image.network(
                        //                 slider.sliderImage ?? '',
                        //                 // sliderList[0]!,
                        //                 width: double.maxFinite,

                        //                 fit: BoxFit.fill,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     }).toList(),
                        //     options: CarouselOptions(
                        //       // scrollDirection: Axis.vertical,
                        //       autoPlayInterval: const Duration(seconds: 3),
                        //       scrollPhysics: const BouncingScrollPhysics(),
                        //       autoPlay: true,
                        //       enlargeCenterPage: true,
                        //       enlargeStrategy: CenterPageEnlargeStrategy.scale,
                        //       // enlargeFactor: 1,
                        //       viewportFraction: 0.8,
                        //     ),
                        //   ),
                        // ),

                        // SliderLocationComponent(
                        //   sliderList: snap.slider.validate(),
                        //   featuredList: snap.featuredServices.validate(),
                        //   callback: () async {
                        //     appStore.setLoading(true);

                        //     init();
                        //     setState(() {});
                        //   },
                        // ),
                        // Container(
                        //   height: 500,
                        //   width: 400,
                        //   child: VerticalCardPager(
                        //       titles: titles, // required
                        //       images: images, // required
                        //       textStyle: TextStyle(
                        //           color: Colors.white, fontSize: 10.0, height: 200
                        //           // fontWeight: FontWeight.bold
                        //           ), // optional
                        //       onPageChanged: (page) {
                        //         // optional
                        //       },
                        //       onSelectedItem: (index) {
                        //         // optional
                        //       },
                        //       initialPage: 1, // optional
                        //       align: ALIGN.CENTER, // optional
                        //       physics: ClampingScrollPhysics() // optional
                        //       ),
                        // ),
                        // 10.height,
                        Container(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 0),
                          child: SizedBox(
                            // height: MediaQuery.of(context).size.height -
                            //     MediaQuery.of(context).size.height * 0.3,
                            child: ListView(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              children: [
                                CarouselSlider(
                                  items: list.validate().map((slider) {
                                    int loc_index = list.indexOf(slider);
                                    return GestureDetector(
                                      onTap: () async {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Container(
                                          // padding: EdgeInsets.all(10),
                                          // width: 300,
                                          // height: MediaQuery.of(context)
                                          //         .size
                                          //         .height -
                                          //     MediaQuery.of(context).size.height *
                                          //         0.3,
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.white54,
                                                  spreadRadius: 0.1,
                                                  blurRadius: 3)
                                            ],
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/${slider["image"]}'),
                                                fit: BoxFit.fill,
                                                alignment:
                                                    Alignment.bottomCenter),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 30.0, 0.0, 30.0),
                                            child: Stack(
                                              children: [
                                                currentState == loc_index
                                                    ? SizedBox()
                                                    : Align(
                                                        alignment:
                                                            currentState! >
                                                                    loc_index
                                                                ? Alignment
                                                                    .centerRight
                                                                : Alignment
                                                                    .centerLeft,
                                                        child: Container(
                                                          width: 30,
                                                          height: 100,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: slider[
                                                                        "color"] ==
                                                                    "red"
                                                                ? Colors.red
                                                                : slider["color"] ==
                                                                        "green"
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .black,
                                                            borderRadius:
                                                                currentState! >
                                                                        loc_index
                                                                    ? BorderRadius
                                                                        .only(
                                                                        bottomLeft:
                                                                            Radius.circular(30),
                                                                        topLeft:
                                                                            Radius.circular(30),
                                                                      )
                                                                    : BorderRadius
                                                                        .only(
                                                                        bottomRight:
                                                                            Radius.circular(30),
                                                                        topRight:
                                                                            Radius.circular(30),
                                                                      ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 0,
                                                                    bottom: 0,
                                                                    left: 0,
                                                                    right: 10),
                                                            child: RotatedBox(
                                                              quarterTurns: 1,
                                                              child: Text(
                                                                  "${slider["button"]}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: boldTextStyle(
                                                                      color: slider["color"] ==
                                                                              "black"
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                      size: 10,
                                                                      weight: FontWeight
                                                                          .bold)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                Column(
                                                  // mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Text(
                                                        "${slider['title']}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontFamily: 'Satoshi',
                                                          color: white,
                                                          fontSize: 24.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  16.0,
                                                                  0.0,
                                                                  0.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (loc_index == 0) {
                                                            doIfLoggedIn(
                                                                context, () {
                                                              KeyboardVisibilityProvider(
                                                                child:
                                                                    CreatePostRequestScreen(
                                                                  jobDateType:
                                                                      JobDateType
                                                                          .Today,
                                                                  isUrgent:
                                                                      true,
                                                                ),
                                                              ).launch(context);
                                                            });
                                                          } else if (loc_index ==
                                                              1) {
                                                            doIfLoggedIn(
                                                                context, () {
                                                              KeyboardVisibilityProvider(
                                                                child:
                                                                    CreatePostRequestScreen(
                                                                  jobDateType:
                                                                      JobDateType
                                                                          .Today,
                                                                ),
                                                              ).launch(context);
                                                            });
                                                          } else {
                                                            doIfLoggedIn(
                                                                context, () {
                                                              KeyboardVisibilityProvider(
                                                                child: CreatePostRequestScreen(
                                                                    jobDateType:
                                                                        JobDateType
                                                                            .Scheduled),
                                                              ).launch(context);
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          width: 110.0,
                                                          height: 35.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0),
                                                          ),
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            "${slider['button']}",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 12.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  options: CarouselOptions(
                                    aspectRatio: 1.2,
                                    initialPage: 1,
                                    viewportFraction: 0.7,
                                    disableCenter: true,
                                    enlargeCenterPage: true,
                                    enlargeFactor: 0.35,
                                    enableInfiniteScroll: false,
                                    scrollDirection: Axis.horizontal,
                                    autoPlay: false,
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 800),
                                    autoPlayInterval:
                                        Duration(milliseconds: (800 + 4000)),
                                    autoPlayCurve: Curves.linear,
                                    pauseAutoPlayInFiniteScroll: true,
                                    onPageChanged: (index, _) async {
                                      // print("index ${index}");
                                      setState(() {
                                        currentState = index;
                                      });
                                      // _model.carouselCurrentIndex = index;
                                      // setState(() {
                                      //   FFAppState().introIndex =
                                      //       _model.carouselCurrentIndex;
                                      // });
                                    },
                                  ),
                                ),
                                // CupertinoPageScaffold(
                                //   child:
                                //       // Expanded(child: child),
                                //       Container(
                                //     height:
                                //         MediaQuery.of(context).size.height * .44,
                                //     child: Padding(
                                //       padding: const EdgeInsets.only(
                                //         left: 25,
                                //         right: 25,
                                //         top: 0,
                                //         bottom: 60,
                                //       ),
                                //       child: AppinioSwiper(
                                //         invertAngleOnBottomDrag: true,
                                //         backgroundCardCount: 2,
                                //         swipeOptions: const SwipeOptions.all(),
                                //         controller: controller,
                                //         loop: true,
                                //         onCardPositionChanged: (
                                //           SwiperPosition position,
                                //         ) {
                                //           // int length = list.length;
                                //           // length = length - 1;
                                //           // setState(() {
                                //           //   currentState = position.index;
                                //           // });
                                //           // if (currentState == 3) {
                                //           //   setState(() {
                                //           //     currentState = 0;
                                //           //   });
                                //           // } else {
                                //           //   setState(() {
                                //           //     currentState = position.index + 1;
                                //           //   });
                                //           // }

                                //           // debugPrint(
                                //           //     'position.index :${position.index} - ${currentState}');
                                //           // debugPrint('position1 :${currentState}');
                                //           // debugPrint('${position.toString()}'
                                //           //     '${position.offset.toAxisDirection()}, '
                                //           //     '${position.offset}, '
                                //           //     '${position.angle}');
                                //         },
                                //         onSwipeEnd: (index, num, SwiperActivity) {
                                //           setState(() {
                                //             currentState = num;
                                //           });
                                //           debugPrint(
                                //               'onSwipeEnd :${index} - ${num}');
                                //         },
                                //         // onSwipeEnd: _swipeEnd,
                                //         // onEnd: _onEnd,
                                //         cardCount: list.length,
                                //         cardBuilder:
                                //             (BuildContext context, int index) {
                                //           return Container(
                                //             decoration: BoxDecoration(
                                //               color: primaryColor,
                                //               borderRadius:
                                //                   BorderRadius.circular(30),
                                //               boxShadow: [
                                //                 BoxShadow(
                                //                     color: Colors.white54,
                                //                     spreadRadius: 0.1,
                                //                     blurRadius: 3)
                                //               ],
                                //               image: DecorationImage(
                                //                 image: AssetImage(
                                //                     'assets/images/${currentState == index ? list[index]["image"] : 'empty.png'}'),
                                //                 fit: BoxFit.cover,
                                //               ),
                                //             ),
                                //             child: Container(
                                //               width: MediaQuery.of(context)
                                //                   .size
                                //                   .width,
                                //               child: Stack(
                                //                 alignment:
                                //                     AlignmentDirectional.center,
                                //                 // mainAxisAlignment:
                                //                 //     MainAxisAlignment.spaceAround,
                                //                 // crossAxisAlignment:
                                //                 //     CrossAxisAlignment.center,
                                //                 children: [
                                //                   Align(
                                //                     alignment:
                                //                         Alignment.topCenter,
                                //                     child: Padding(
                                //                       padding:
                                //                           const EdgeInsets.all(
                                //                               20.0),
                                //                       child: Text(
                                //                         textAlign:
                                //                             TextAlign.center,
                                //                         "${list[index]["title"]}",
                                //                         style: boldTextStyle(
                                //                             color: appStore
                                //                                     .isDarkMode
                                //                                 ? white
                                //                                 : context
                                //                                     .primaryColor,
                                //                             size: 22,
                                //                             weight:
                                //                                 FontWeight.bold),
                                //                       ),
                                //                     ),
                                //                   ),
                                //                   GestureDetector(
                                //                     onTap: () {
                                //                       if (index == 0) {
                                //                         doIfLoggedIn(context, () {
                                //                           KeyboardVisibilityProvider(
                                //                             child:
                                //                                 CreatePostRequestScreen(
                                //                               jobDateType:
                                //                                   JobDateType
                                //                                       .Today,
                                //                               isUrgent: true,
                                //                             ),
                                //                           ).launch(context);
                                //                         });
                                //                       } else if (index == 1) {
                                //                         doIfLoggedIn(context, () {
                                //                           KeyboardVisibilityProvider(
                                //                             child:
                                //                                 CreatePostRequestScreen(
                                //                               jobDateType:
                                //                                   JobDateType
                                //                                       .Today,
                                //                             ),
                                //                           ).launch(context);
                                //                         });
                                //                       } else {
                                //                         doIfLoggedIn(context, () {
                                //                           KeyboardVisibilityProvider(
                                //                             child: CreatePostRequestScreen(
                                //                                 jobDateType:
                                //                                     JobDateType
                                //                                         .Scheduled),
                                //                           ).launch(context);
                                //                         });
                                //                       }
                                //                     },
                                //                     child: Container(
                                //                       decoration: BoxDecoration(
                                //                         color: Colors.white,
                                //                         borderRadius:
                                //                             BorderRadius.circular(
                                //                                 15),
                                //                       ),
                                //                       child: Padding(
                                //                         padding:
                                //                             const EdgeInsets.only(
                                //                                 top: 10,
                                //                                 bottom: 10,
                                //                                 left: 30,
                                //                                 right: 30),
                                //                         child: Text(
                                //                             "${list[index]["button"]}",
                                //                             style: boldTextStyle(
                                //                                 color:
                                //                                     Colors.black,
                                //                                 size: 14,
                                //                                 weight: FontWeight
                                //                                     .bold)),
                                //                       ),
                                //                     ),
                                //                   ),
                                //                   currentState != index
                                //                       ? Positioned(
                                //                           bottom: 0,
                                //                           child: Container(
                                //                             decoration:
                                //                                 BoxDecoration(
                                //                               color: list[index][
                                //                                           "color"] ==
                                //                                       "red"
                                //                                   ? Colors.red
                                //                                   : list[index][
                                //                                               "color"] ==
                                //                                           "green"
                                //                                       ? Colors
                                //                                           .green
                                //                                       : Colors
                                //                                           .black,
                                //                               borderRadius:
                                //                                   BorderRadius
                                //                                       .only(
                                //                                 topLeft: Radius
                                //                                     .circular(30),
                                //                                 topRight: Radius
                                //                                     .circular(30),
                                //                               ),
                                //                             ),
                                //                             child: Padding(
                                //                               padding:
                                //                                   const EdgeInsets
                                //                                       .only(
                                //                                       top: 5,
                                //                                       bottom: 5,
                                //                                       left: 30,
                                //                                       right: 30),
                                //                               child: Text(
                                //                                   "${list[index]["button"]}",
                                //                                   style: boldTextStyle(
                                //                                       color: list[index]["color"] ==
                                //                                               "black"
                                //                                           ? Colors
                                //                                               .white
                                //                                           : Colors
                                //                                               .black,
                                //                                       size: 10,
                                //                                       weight: FontWeight
                                //                                           .bold)),
                                //                             ),
                                //                           ),
                                //                         )
                                //                       : SizedBox()
                                //                 ],
                                //               ),
                                //             ),
                                //           );
                                //         },
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                10.height,

                                appStore.userType == "provider"
                                    ? SizedBox()
                                    : becomeProvider(),
                                appStore.userType != "user"
                                    ? appStore.isLoggedIn
                                        ? Column(
                                            children: [
                                              FutureBuilder<DashboardResponses>(
                                                  initialData:
                                                      cachedProviderDashboardResponse,
                                                  future: futures,
                                                  builder: (context, snap) {
                                                    print(
                                                        "cachedProviderDashboardResponse ${snap.data!.totalBooking}");
                                                    return Column(
                                                      children: [
                                                        custombookingContainer(
                                                            context,
                                                            snap.data!
                                                                .totalBooking!,
                                                            snap.data!
                                                                .todayCashAmount!),
                                                        customTopearnerWeek(
                                                            context),
                                                        customTopearnerMonth(
                                                            context),
                                                        ChartComponent(),
                                                        // Padding(
                                                        //   padding:
                                                        //       const EdgeInsets
                                                        //           .all(10.0),
                                                        //   child:
                                                        //       TotalRevenueWidget(),
                                                        // ),
                                                      ],
                                                    );
                                                  })
                                            ],
                                          )
                                        : SizedBox()
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),

                        // Column(
                        //   children: [
                        //     // Urgent jobs
                        //     JobsTypeWidget(
                        //       urgent: true,
                        //       onPressed: () {
                        //         doIfLoggedIn(context, () {
                        //           KeyboardVisibilityProvider(
                        //             child: CreatePostRequestScreen(
                        //               jobDateType: JobDateType.Today,
                        //               isUrgent: true,
                        //             ),
                        //           ).launch(context);
                        //         });
                        //       },
                        //     ).paddingSymmetric(horizontal: 10),
                        //     15.height,

                        //     JobsTypeWidget(
                        //       today: true,
                        //       onPressed: () {
                        //         doIfLoggedIn(context, () {
                        //           KeyboardVisibilityProvider(
                        //             child: CreatePostRequestScreen(
                        //               jobDateType: JobDateType.Today,
                        //             ),
                        //           ).launch(context);
                        //         });
                        //       },
                        //     ).paddingSymmetric(horizontal: 10),

                        //     // InkWell(
                        //     //   borderRadius: BorderRadius.circular(12),
                        //     //   splashColor: context.cardColor,
                        //     //   onTap: () {
                        //     //     doIfLoggedIn(context, () {
                        //     //       KeyboardVisibilityProvider(
                        //     //         child: CreatePostRequestScreen(
                        //     //           jobDateType: JobDateType.Today,
                        //     //         ),
                        //     //       ).launch(context);
                        //     //     });
                        //     //   },
                        //     //   child: Container(
                        //     //     width: context.width(),
                        //     //     height: 60,
                        //     //     decoration: BoxDecoration(
                        //     //       color: primaryColor,
                        //     //       borderRadius: BorderRadius.circular(12),
                        //     //       boxShadow: [
                        //     //         BoxShadow(
                        //     //           color: Colors.black.withOpacity(.1),
                        //     //           spreadRadius: 5,
                        //     //           blurRadius: 10,
                        //     //           offset: Offset(0, 8),
                        //     //         ),
                        //     //       ],
                        //     //     ),
                        //     //     child: Row(
                        //     //       mainAxisAlignment: MainAxisAlignment.center,
                        //     //       children: [
                        //     //         // 20.width,
                        //     //         // Image.asset(
                        //     //         //   'assets/icons/today.png',
                        //     //         // ).paddingAll(5),
                        //     //         // 10.width,
                        //     //         Text(
                        //     //           language.today,
                        //     //           style: boldTextStyle(color: white, size: 20),
                        //     //         )
                        //     //       ],
                        //     //     ).paddingSymmetric(horizontal: 10, vertical: 10),
                        //     //   ),
                        //     // ).paddingSymmetric(horizontal: 10),

                        //     15.height,

                        //     JobsTypeWidget(
                        //       scheduled: true,
                        //       onPressed: () {
                        //         doIfLoggedIn(context, () {
                        //           KeyboardVisibilityProvider(
                        //             child: CreatePostRequestScreen(
                        //                 jobDateType: JobDateType.Scheduled),
                        //           ).launch(context);
                        //         });
                        //       },
                        //     ).paddingSymmetric(horizontal: 10),
                        //     // InkWell(
                        //     //   borderRadius: BorderRadius.circular(12),
                        //     //   onTap: () {
                        //     //     doIfLoggedIn(context, () {
                        //     //       KeyboardVisibilityProvider(
                        //     //         child: CreatePostRequestScreen(jobDateType: JobDateType.Scheduled),
                        //     //       ).launch(context);
                        //     //     });
                        //     //   },
                        //     //   child: Container(
                        //     //     width: context.width(),
                        //     //     height: 60,
                        //     //     decoration: BoxDecoration(
                        //     //       color: primaryColor,
                        //     //       borderRadius: BorderRadius.circular(12),
                        //     //       boxShadow: [
                        //     //         BoxShadow(
                        //     //           color: Colors.black.withOpacity(.1),
                        //     //           spreadRadius: 5,
                        //     //           blurRadius: 10,
                        //     //           offset: Offset(0, 8),
                        //     //         ),
                        //     //       ],
                        //     //     ),
                        //     //     child: Row(
                        //     //       mainAxisAlignment: MainAxisAlignment.center,
                        //     //       children: [
                        //     //         // 20.width,
                        //     //         // Image.asset(
                        //     //         //   'assets/icons/schedule.png',
                        //     //         // ).paddingAll(5),
                        //     //         // 10.width,
                        //     //         Text(
                        //     //           language.scheduled,
                        //     //           style: boldTextStyle(color: white, size: 20),
                        //     //         )
                        //     //       ],
                        //     //     ).paddingSymmetric(horizontal: 10, vertical: 10),
                        //     //   ),
                        //     // ).paddingSymmetric(horizontal: 10),

                        //     // 15.height,
                        //     // InkWell(
                        //     //   borderRadius: BorderRadius.circular(12),
                        //     //   onTap: () {
                        //     //     print('---------------------------------------------------');
                        //     //     print(appStore.appstoreUrl);
                        //     //     print(appStore.providerAppstoreUrl);
                        //     //     print(appStore.playStoreUrl);
                        //     //     print(appStore.providerPlayStoreUrl);

                        //     //     launchUrl(
                        //     //       Uri.parse(Platform.isIOS ? appStore.providerAppstoreUrl : appStore.providerPlayStoreUrl),
                        //     //       mode: LaunchMode.externalApplication,
                        //     //     );
                        //     //   },
                        //     //   child: Container(
                        //     //     width: context.width(),
                        //     //     height: 60,
                        //     //     decoration: BoxDecoration(
                        //     //       color: primaryColor,
                        //     //       borderRadius: BorderRadius.circular(12),
                        //     //       boxShadow: [
                        //     //         BoxShadow(
                        //     //           color: Colors.black.withOpacity(.1),
                        //     //           spreadRadius: 5,
                        //     //           blurRadius: 10,
                        //     //           offset: Offset(0, 8),
                        //     //         ),
                        //     //       ],
                        //     //     ),
                        //     //     child: Row(
                        //     //       children: [
                        //     //         20.width,
                        //     //         Expanded(
                        //     //           flex: 1,
                        //     //           child: Align(
                        //     //             alignment: AlignmentDirectional.centerEnd,
                        //     //             child: Image.asset(
                        //     //               'assets/ic_app_logo.png',
                        //     //             ).paddingAll(0),
                        //     //           ),
                        //     //         ),
                        //     //         10.width,
                        //     //         Expanded(
                        //     //           flex: 4,
                        //     //           child: Align(
                        //     //             alignment: AlignmentDirectional.centerStart,
                        //     //             child: Text(
                        //     //               language.wantToGetMoney,
                        //     //               style: boldTextStyle(
                        //     //                 color: white,
                        //     //                 size: appStore.selectedLanguageCode == "en" ? 15 : 18,
                        //     //               ),
                        //     //               maxLines: 2,
                        //     //               textAlign: TextAlign.center,
                        //     //             ),
                        //     //           ),
                        //     //         )
                        //     //       ],
                        //     //     ).paddingSymmetric(horizontal: 10, vertical: 10),
                        //     //   ),
                        //     // ).paddingSymmetric(horizontal: 10).visible(_makeMoneyVisibilityCondition),
                        //     // 35.height,
                        //   ],
                        // ),
                        // Column(
                        //   children: [
                        //     SliderLocationComponent(
                        //       sliderList: snap.slider.validate(),
                        //       featuredList: snap.featuredServices.validate(),
                        //       callback: () async {
                        //         appStore.setLoading(true);

                        //         init();
                        //         setState(() {});
                        //       },
                        //     ),
                        //   ],
                        // ),
                        // 10.height,

                        // PendingBookingComponent(upcomingData: snap.upcomingData),
                        // 16.height,
                        // FeaturedServiceListComponent(serviceList: snap.featuredServices.validate()),
                        // ServiceListComponent(serviceList: snap.service.validate()),
                        // 16.height,
                        // if (otherSettingStore.postJobRequestEnable.getBoolInt()) NewJobRequestComponent(),
                        // 16.height,
                        // if (appStore.isLoggedIn)
                        //   ViewAllLabel(
                        //     label: language.myPostJobList,
                        //     onTap: () => MyPostRequestListScreen().launch(context),
                        //   ).paddingSymmetric(horizontal: 20),
                        // if (appStore.isLoggedIn)
                        //   SnapHelperWidget<List<PostJobData>>(
                        //     future: postFuture,
                        //     initialData: cachedPostJobList,
                        //     onSuccess: (data) {
                        //       return AnimatedListView(
                        //         itemCount: data.length > 4 ? 4 : data.length,
                        //         physics: NeverScrollableScrollPhysics(),
                        //         shrinkWrap: true,
                        //         padding: EdgeInsets.only(top: 0, bottom: 70),
                        //         listAnimationType: ListAnimationType.FadeIn,
                        //         fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                        //         itemBuilder: (_, i) {
                        //           PostJobData postJob = data[i];

                        //           return MyPostRequestItemComponent(
                        //             data: postJob,
                        //             callback: (v) {
                        //               appStore.setLoading(v);

                        //               if (v) {
                        //                 page = 1;
                        //                 init();
                        //                 setState(() {});
                        //               }
                        //             },
                        //           );
                        //         },
                        //         emptyWidget: NoDataWidget(
                        //           title: language.noPostJobFound,
                        //           subTitle: language.noPostJobFoundSubtitle,
                        //           imageWidget: EmptyStateWidget(),
                        //         ).paddingSymmetric(horizontal: 20),
                        //         onNextPage: () {
                        //           if (!isLastPage) {
                        //             page++;
                        //             appStore.setLoading(true);

                        //             init();
                        //             setState(() {});
                        //           }
                        //         },
                        //         onSwipeRefresh: () async {
                        //           page = 1;

                        //           init();
                        //           setState(() {});

                        //           return await 2.seconds.delay;
                        //         },
                        //       );
                        //     },
                        //     loadingWidget: LoaderWidget(),
                        //     errorBuilder: (error) {
                        //       return NoDataWidget(
                        //         title: error,
                        //         imageWidget: ErrorStateWidget(),
                        //         retryText: language.reload,
                        //         onRetry: () {
                        //           page = 1;
                        //           appStore.setLoading(true);

                        // init();
                        //           setState(() {});
                        //         },
                        //       );
                        //     },
                        //   ),
                        // 20.height,
                      ],
                    );
                  });
                },
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Observer(
            builder: (context) =>
                LoaderWidget().center().visible(appStore.isLoading)));
  }

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    switch (activity) {
      case Swipe():
        log('The card was swiped to the : ${activity.direction}');
        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case Unswipe():
        log('A ${activity.direction.name} swipe was undone.');
        log('previous index: $previousIndex, target index: $targetIndex');
        break;
      case CancelSwipe():
        log('A swipe was cancelled');
        break;
      case DrivenActivity():
        log('Driven Activity');
        break;
    }
  }

  void _onEnd() {
    log('end reached!');
  }

  // Animates the card back and forth to teach the user that it is swipable.
  Future<void> _shakeCard() async {
    const double distance = 30;
    // We can animate back and forth by chaining different animations.
    await controller.animateTo(
      const Offset(-distance, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    await controller.animateTo(
      const Offset(distance, 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    // We need to animate back to the center because `animateTo` does not center
    // the card for us.
    await controller.animateTo(
      const Offset(0, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}

class WhiteCircle extends StatelessWidget {
  const WhiteCircle({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: white.withOpacity(.08)),
    );
  }
}
