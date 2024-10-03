import 'package:geolocator/geolocator.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/booking_data_model.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/booking/booking_detail_screen.dart';
import 'package:hands_user_app/screens/booking/component/booking_item_component.dart';
import 'package:hands_user_app/screens/booking/shimmer/booking_shimmer.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../booking/component/booking_status_filter_bottom_sheet.dart';

class BookingFragment extends StatefulWidget {
  @override
  _BookingFragmentState createState() => _BookingFragmentState();
}

class _BookingFragmentState extends State<BookingFragment> {
  UniqueKey keyForList = UniqueKey();

  ScrollController scrollController = ScrollController();

  Future<List<BookingData>>? future;
  List<BookingData> bookings = [];

  int page = 1;
  bool isLastPage = false;

  String selectedValue = BOOKING_TYPE_ALL;

  @override
  void initState() {
    super.initState();
    init();

    afterBuildCreated(() {
      if (appStore.isLoggedIn) {
        setStatusBarColor(context.primaryColor);
      }
    });
    finish(context);
    LiveStream().on(LIVESTREAM_UPDATE_BOOKING_LIST, (p0) {
      page = 1;
      appStore.setLoading(true);
      init();
      setState(() {});
    });
    cachedBookingStatusDropdown.validate().forEach((element) {
      element.isSelected = false;
    });
  }

  void init({String status = ''}) async {
    future = getBookingList(page, status: status, bookings: bookings,
        lastPageCallback: (b) {
      isLastPage = b;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKING_LIST);
    //scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.booking,
        // textColor: white,
        showBack: false,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 0.0,
        color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),//appStore.isDarkMode ? context.primaryColor : white,
      ),
      body: SizedBox(
        width: context.width(),
        height: context.height(),
        child: Stack(
          children: [
            Column(
              children: [
                20.height,
                AppButton(
                  color: Theme.of(context).cardColor,
                  height: 48,
                  width: MediaQuery.sizeOf(context).width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: cachedBookingStatusDropdown == null ||
                                  (cachedBookingStatusDropdown
                                          ?.where(
                                              (element) => element.isSelected)
                                          .isEmpty ??
                                      false)
                              ? Text(
                                  language.lblAll,
                                  style: boldTextStyle(),
                                )
                              : Text(
                                  cachedBookingStatusDropdown
                                      .validate()
                                      .where((element) => element.isSelected)
                                      .map((e) => e.label)
                                      .join(' , '),
                                  style: boldTextStyle(size: 12),
                                )),
                      RotatedBox(
                        quarterTurns: 1,
                        child: trailing,
                      )
                    ],
                  ),
                  onTap: () async {
                    String? res = await showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      isScrollControlled: true,
                      isDismissible: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: radiusOnly(
                              topLeft: defaultRadius, topRight: defaultRadius)),
                      builder: (_) {
                        return BookingStatusFilterBottomSheet();
                      },
                    );

                    if (res.validate().isNotEmpty) {
                      page = 1;
                      appStore.setLoading(true);

                      selectedValue = res!;
                      init(status: res);

                      if (bookings.isNotEmpty) {
                        scrollController.animateTo(0,
                            duration: 1.seconds, curve: Curves.easeOutQuart);
                      } else {
                        scrollController = ScrollController();
                        keyForList = UniqueKey();
                      }

                      setState(() {});
                    }
                  },
                ).paddingSymmetric(horizontal: 16),
                Expanded(
                  child: SnapHelperWidget<List<BookingData>>(
                    initialData: cachedBookingList,
                    future: future,
                    errorBuilder: (error) {
                      return NoDataWidget(
                        title: error,
                        imageWidget: ErrorStateWidget(),
                        retryText: language.reload,
                        onRetry: () {
                          page = 1;
                          appStore.setLoading(true);

                          init();
                          setState(() {});
                        },
                      );
                    },
                    loadingWidget: BookingShimmer(),
                    onSuccess: (list) {
                      return Stack(
                        children: [
                          AnimatedListView(
                            key: keyForList,
                            controller: scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                                bottom: 60, top: 16, right: 16, left: 16),
                            itemCount: list.length,
                            shrinkWrap: true,
                            disposeScrollController: true,
                            listAnimationType: ListAnimationType.FadeIn,
                            fadeInConfiguration:
                                FadeInConfiguration(duration: 2.seconds),
                            slideConfiguration:
                                SlideConfiguration(verticalOffset: 400),
                            itemBuilder: (_, index) {
                              BookingData? data = list[index];

                              return GestureDetector(
                                onTap: () {
                                  BookingDetailScreen(
                                          bookingId: data.id.validate())
                                      .launch(context);
                                },
                                child: BookingItemComponent(bookingData: data),
                              );
                            },
                            onNextPage: () {
                              if (!isLastPage) {
                                page++;
                                appStore.setLoading(true);

                                init();
                                setState(() {});
                              }
                            },
                            onSwipeRefresh: () async {
                              page = 1;
                              appStore.setLoading(true);

                              init(status: selectedValue);
                              setState(() {});

                              return await 1.seconds.delay;
                            },
                          ),
                          if (list.isEmpty)
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    NoDataWidget(
                                      titleTextStyle: boldTextStyle(size: 18),
                                      subTitleTextStyle:
                                          primaryTextStyle(size: 14),
                                      // fit: BoxFit.fill,
                                      title: language.lblNoBookingsFound,
                                      subTitle: language.noBookingSubTitle,
                                      imageWidget: EmptyStateWidget(),
                                    ),
                                    SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                50.height
              ],
            ),
            Observer(
                builder: (_) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
