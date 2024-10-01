import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:hands_user_app/auth/sign_in_screen.dart';
import 'package:hands_user_app/components/cached_image_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/dashboard_response.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/components/chart_component.dart';
import 'package:hands_user_app/provider/components/handyman_list_component.dart';
import 'package:hands_user_app/provider/components/handyman_recently_online_component.dart';
import 'package:hands_user_app/provider/components/job_list_component.dart';
import 'package:hands_user_app/provider/components/services_list_component.dart';
import 'package:hands_user_app/provider/components/total_component.dart';
import 'package:hands_user_app/provider/fragments/shimmer/provider_dashboard_shimmer.dart';
import 'package:hands_user_app/provider/subscription/pricing_plan_screen.dart';
import 'package:hands_user_app/provider/screens/booking_detail_screen.dart';
import 'package:hands_user_app/provider/screens/cash_management/component/today_cash_component.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_widgets.dart';
import '../../components/empty_error_state_widget.dart';
import '../components/upcoming_booking_component.dart';

class ProviderHomeFragment extends StatefulWidget {
  @override
  _ProviderHomeFragmentState createState() => _ProviderHomeFragmentState();
}

class _ProviderHomeFragmentState extends State<ProviderHomeFragment> {
  int page = 1;

  int currentIndex = 0;

  late Future<DashboardResponses> future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = providerDashboard().whenComplete(() {
      setState(() {});
    });
  }

  Widget _buildHeaderWidget(DashboardResponses data) {
    return Row(
      children: [
        SizedBox(width: 20),
        Container(
          decoration: boxDecorationDefault(
            border: Border.all(color: primaryColor, width: 3),
            shape: BoxShape.circle,
          ),
          child: Container(
            decoration: boxDecorationDefault(
              border:
                  Border.all(color: context.scaffoldBackgroundColor, width: 4),
              shape: BoxShape.circle,
            ),
            child: CachedImageWidget(
              url: appStorePro.userProfileImage.validate(),
              height: 35,
              fit: BoxFit.cover,
              circle: true,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              Text("${languages.lblHello}, ${appStorePro.userFullName}",
                      style: boldTextStyle(size: 16))
                  .paddingLeft(16),
              8.height,
              Text(languages.lblWelcomeBack,
                      style: secondaryTextStyle(size: 14))
                  .paddingLeft(16),
              16.height,
            ],
          ),
        ),
      ],
    );
  }

  Widget planBanner(DashboardResponses data) {
    if (data.isPlanExpired.validate()) {
      return subSubscriptionPlanWidget(
        planBgColor:
            appStorePro.isDarkMode ? context.cardColor : Colors.red.shade50,
        planTitle: languages.lblPlanExpired,
        planSubtitle: languages.lblPlanSubTitle,
        planButtonTxt: languages.btnTxtBuyNow,
        btnColor: Colors.red,
        onTap: () {
          PricingPlanScreen().launch(context);
        },
      );
    } else if (data.userNeverPurchasedPlan.validate()) {
      return subSubscriptionPlanWidget(
        planBgColor:
            appStorePro.isDarkMode ? context.cardColor : Colors.red.shade50,
        planTitle: languages.lblChooseYourPlan,
        planSubtitle: languages.lblRenewSubTitle,
        planButtonTxt: languages.btnTxtBuyNow,
        btnColor: Colors.red,
        onTap: () {
          PricingPlanScreen().launch(context);
        },
      );
    } else if (data.isPlanAboutToExpire.validate()) {
      int days = getRemainingPlanDays();

      if (days != 0 && days <= PLAN_REMAINING_DAYS) {
        return subSubscriptionPlanWidget(
          planBgColor: appStorePro.isDarkMode
              ? context.cardColor
              : Colors.orange.shade50,
          planTitle: languages.lblReminder,
          planSubtitle: languages.planAboutToExpire(days),
          planButtonTxt: languages.lblRenew,
          btnColor: Colors.orange,
          onTap: () {
            PricingPlanScreen().launch(context);
          },
        );
      } else {
        return SizedBox();
      }
    } else {
      return SizedBox();
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<DashboardResponses>(
            initialData: cachedProviderDashboardResponse,
            future: future,
            builder: (context, snap) {
              if (snap.hasData) {
                return AnimatedScrollView(
                  padding: EdgeInsets.only(bottom: 16),
                  physics: AlwaysScrollableScrollPhysics(),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  children: [
                    20.height,
                    if (appStorePro.isLocationTracked &&
                        appStorePro.trackingJobId != null)
                      Observer(
                        builder: (context) => GestureDetector(
                          onTap: () {
                            BookingDetailScreen(
                              bookingId: appStorePro.trackingJobId!,
                            ).launch(context);
                          },
                          child: Container(
                            width: context.width(),
                            // height: 80,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F8FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/lottie/tracking.json',
                                  width: 80,
                                ),
                                5.width,
                                Expanded(
                                  child: Text(
                                    'Your Location is being tracked by order ${appStorePro.trackingJobId}',
                                    style:
                                        boldTextStyle(size: 12, color: black),
                                  ),
                                ),
                                5.width,
                                Lottie.asset('assets/lottie/live.json',
                                    width: 30, height: 30),
                                5.width,
                              ],
                            ),
                          ).paddingSymmetric(horizontal: 10, vertical: 5),
                        ),
                      ),
                    if ((getStringAsync(EARNING_TYPE) ==
                        EARNING_TYPE_SUBSCRIPTION))
                      planBanner(snap.data!),
                    if (appStorePro.isLocationTracked &&
                        appStorePro.trackingJobId != null)
                      SizedBox(height: 20),
                    TodayCashComponent(
                        todayCashAmount: snap.data!.todayCashAmount.validate()),
                    TotalComponent(snap: snap.data!),
                    ChartComponent(),
                    // HandymanRecentlyOnlineComponent(images: snap.data!.onlineHandyman.validate()),
                    // HandymanListComponent(list: snap.data!.handyman.validate()),
                    UpcomingBookingComponent(
                        bookingData: snap.data!.upcomingBookings.validate()),
                    100.height,
                    // JobListComponent(list: snap.data!.myPostJobData.validate()).paddingOnly(left: 16, right: 16, top: 8),
                    // ServiceListComponent(list: snap.data!.service.validate()),
                  ],
                  onSwipeRefresh: () async {
                    page = 1;
                    appStorePro.setLoading(true);

                    init();
                    setState(() {});

                    return await 2.seconds.delay;
                  },
                );
              }

              return guest && getBoolAsync(HAS_IN_REVIEW)
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            languages.loginToContinue,
                            style: boldTextStyle(
                              size: 18,
                            ),
                          ),
                          SizedBox(height: 20),
                          AppButton(
                            width: MediaQuery.of(context).size.width - 100,
                            color: appStorePro.isDarkMode
                                ? white
                                : context.primaryColor,
                            onTap: () {
                              // SignInScreen().launch(context);
                            },
                            text: languages.signIn,
                            textColor: !appStorePro.isDarkMode
                                ? white
                                : context.primaryColor,
                          ),
                        ],
                      ),
                    )
                  : snapWidgetHelper(
                      snap,
                      loadingWidget: ProviderDashboardShimmer(),
                      errorBuilder: (error) {
                        return NoDataWidget(
                          title: error,
                          imageWidget: ErrorStateWidget(),
                          retryText: languages.reload,
                          onRetry: () {
                            page = 1;
                            appStorePro.setLoading(true);

                            init();
                            setState(() {});
                          },
                        );
                      },
                    );
            },
          ),
          Observer(
              builder: (context) =>
                  LoaderWidget().visible(appStorePro.isLoading))
        ],
      ),
    );
  }
}
