import 'package:hands_user_app/app_theme.dart';
import 'package:hands_user_app/locale/app_localizations.dart';
import 'package:hands_user_app/locale/language_en.dart';
import 'package:hands_user_app/locale/languages.dart';
import 'package:hands_user_app/model/address_model.dart';
import 'package:hands_user_app/model/booking_detail_model.dart';
import 'package:hands_user_app/model/get_my_post_job_list_response.dart';
import 'package:hands_user_app/model/material_you_model.dart';
import 'package:hands_user_app/model/notification_model';
// import 'package:hands_user_app/model/notification_model.dart';
// import 'package:hands_user_app/models/notification_model';
import 'package:hands_user_app/model/provider_info_response.dart';
import 'package:hands_user_app/model/remote_config_data_model.dart';
import 'package:hands_user_app/model/service_data_model.dart';
import 'package:hands_user_app/model/service_detail_response.dart';
import 'package:hands_user_app/model/user_data_model.dart';
import 'package:hands_user_app/model/user_wallet_history.dart';
import 'package:hands_user_app/models/booking_detail_response.dart';
import 'package:hands_user_app/models/booking_list_response.dart';
import 'package:hands_user_app/models/booking_status_response.dart';
import 'package:hands_user_app/models/dashboard_response.dart';
import 'package:hands_user_app/models/extra_charges_model.dart';
import 'package:hands_user_app/models/handyman_dashboard_response.dart';
import 'package:hands_user_app/models/payment_list_reasponse.dart';
import 'package:hands_user_app/models/provider_notification_model.dart';
import 'package:hands_user_app/models/ratings_model.dart';
import 'package:hands_user_app/models/remote_config_data_model.dart';
import 'package:hands_user_app/models/revenue_chart_data.dart';
import 'package:hands_user_app/models/service_detail_response.dart';
import 'package:hands_user_app/models/total_earning_response.dart';
import 'package:hands_user_app/models/wallet_history_list_response.dart';
import 'package:hands_user_app/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:hands_user_app/provider/locale/base_language.dart';
import 'package:hands_user_app/provider/locale/language_en.dart';
import 'package:hands_user_app/provider/networks/firebase_services/auth_services.dart';
import 'package:hands_user_app/provider/networks/firebase_services/chat_messages_service.dart';
import 'package:hands_user_app/provider/networks/firebase_services/user_services.dart';
import 'package:hands_user_app/provider/store/AppStore.dart';
import 'package:hands_user_app/provider/store/other_setting_store.dart';
import 'package:hands_user_app/provider/timeSlots/timeSlotStore/time_slot_store.dart';
import 'package:hands_user_app/screens/blog/model/blog_detail_response.dart';
import 'package:hands_user_app/screens/blog/model/blog_response_model.dart';
import 'package:hands_user_app/screens/splash_screen.dart';
import 'package:hands_user_app/services/auth_services.dart';
import 'package:hands_user_app/services/chat_services.dart';
import 'package:hands_user_app/services/user_services.dart';
import 'package:hands_user_app/store/app_store.dart';
import 'package:hands_user_app/store/filter_store.dart';
import 'package:hands_user_app/store/other_setting_store.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/firebase_messaging_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import 'model/booking_data_model.dart';
import 'model/booking_status_model.dart';
import 'model/category_model.dart';
import 'model/coupon_list_model.dart';
import 'model/dashboard_model.dart';

//region Mobx Stores
AppStore appStore = AppStore();
FilterStore filterStore = FilterStore();
OtherSettingStore otherSettingStore = OtherSettingStore();

//endregion
//region Mobx Stores
AppStorePro appStorePro = AppStorePro();
TimeSlotStore timeSlotStore = TimeSlotStore();
OtherSettingStorePro otherSettingStorePro = OtherSettingStorePro();
//region Global Variables
BaseLanguage language = LanguageEn();
//region Global Variables
Languages languages = LanguageEng();
List<RevenueChartData> chartData = [];
//endregion

//region Services
UserService userService = UserService();
ProviderService providerService = ProviderService();
// UserServices userServices = UserServices();
AuthService authService = AuthService();
AuthServices authServices = AuthServices();
ChatServices chatServices = ChatServices();
ProviderChatServices providerChatServices = ProviderChatServices();
RemoteConfigDataModel remoteConfigDataModel = RemoteConfigDataModel();
RemoteConfigDataModels remoteConfigDataModels = RemoteConfigDataModels();
List<WalletHistory>? cachedWalletList;
List<NotificationModel>? cachedNotifications;
List<NotificationModelProvider>? cachedNotification;
DashboardResponses? cachedProviderDashboardResponse;
List<PaymentData>? cachedPaymentList;
HandymanDashBoardResponse? cachedHandymanDashboardResponse;
List<UserData>? cachedHandymanList;
List<BookingDetailResponses> cachedBookingDetailLists = [];
List<TotalData>? cachedTotalDataList;

List<ExtraChargesModel> chargesList = [];

//endregion
//region Cached Response Variables for Dashboard Tabs
DashboardResponse? cachedDashboardResponse;
List<BookingData>? cachedBookingList;
List<BookingDatas>? cachedBookingLists;
List<CategoryData>? cachedCategoryList;
List<BookingStatusResponse>? cachedBookingStatusDropdown;
List<BookingStatusResponses>? cachedBookingStatusDropdowns;
List<PostJobData>? cachedPostJobList;
List<(int postJobId, PostJobDetailResponse)?> cachedPostJobLists = [];
List<WalletDataElement>? cachedWalletHistoryList;
List<Rating>? cachedRatingsList;

List<ServiceData>? cachedServiceFavList;
List<UserData>? cachedProviderFavList;
List<BlogData>? cachedBlogList;
List<AddressModel>? cachedAddressList;
List<RatingData>? cachedRatingList;
List<NotificationModel>? cachedNotificationList;
CouponListResponse? cachedCouponListResponse;
List<(int blogId, BlogDetailResponse list)?> cachedBlogDetail = [];
List<(int serviceId, ServiceDetailResponse list)?> listOfCachedData = [];
List<(int serviceId, ServiceDetailResponses list)?> listOfCachedDatas = [];
List<(int providerId, ProviderInfoResponse list)?> cachedProviderList = [];
List<(int categoryId, List<CategoryData> list)?> cachedSubcategoryList = [];
List<(int bookingId, BookingDetailResponse list)?> cachedBookingDetailList = [];

//endregion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  passwordLengthGlobal = 6;
  appButtonBackgroundColorGlobal = primaryColor;
  defaultAppButtonTextColorGlobal = Colors.white;
  defaultRadius = 12;
  defaultBlurRadius = 0;
  defaultSpreadRadius = 0;
  textSecondaryColorGlobal = appTextPrimaryColor;
  textPrimaryColorGlobal = appTextSecondaryColor;
  defaultAppButtonElevation = 0;
  pageRouteTransitionDurationGlobal = 400.milliseconds;
  textBoldSizeGlobal = 14;
  textPrimarySizeGlobal = 14;
  textSecondarySizeGlobal = 12;

  await initialize();
  localeLanguageList = languageList();

  Firebase.initializeApp().then((value) {
    /// Firebase Notification
    // initFirebaseMessaging();

    if (kReleaseMode) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    setupFirebaseRemoteConfig();
  });

  await appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN), isInitializing: true);

  int themeModeIndex =
      getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_LIGHT);
  if (themeModeIndex == THEME_MODE_LIGHT) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == THEME_MODE_DARK) {
    appStore.setDarkMode(true);
  }

  await appStore.setUseMaterialYouTheme(getBoolAsync(USE_MATERIAL_YOU_THEME),
      isInitializing: true);

  if (appStore.isLoggedIn) {
    await appStore.setUserId(getIntAsync(USER_ID), isInitializing: true);
    await appStore.setFirstName(getStringAsync(FIRST_NAME),
        isInitializing: true);
    await appStore.setLastName(getStringAsync(LAST_NAME), isInitializing: true);
    await appStore.setUserEmail(getStringAsync(USER_EMAIL),
        isInitializing: true);
    await appStore.setUserName(getStringAsync(USERNAME), isInitializing: true);
    await appStore.setContactNumber(getStringAsync(CONTACT_NUMBER),
        isInitializing: true);
    await appStore.setUserProfile(getStringAsync(PROFILE_IMAGE),
        isInitializing: true);
    await appStore.setCountryId(getIntAsync(COUNTRY_ID), isInitializing: true);
    await appStore.setStateId(getIntAsync(STATE_ID), isInitializing: true);
    await appStore.setCityId(getIntAsync(COUNTRY_ID), isInitializing: true);
    await appStore.setUId(getStringAsync(UID), isInitializing: true);
    await appStore.setToken(getStringAsync(TOKEN), isInitializing: true);
    await appStore.setAddress(getStringAsync(ADDRESS), isInitializing: true);
    await appStore.setCurrencyCode(getStringAsync(CURRENCY_COUNTRY_CODE),
        isInitializing: true);
    await appStore.setCurrencyCountryId(getStringAsync(CURRENCY_COUNTRY_ID),
        isInitializing: true);
    await appStore.setCurrencySymbol(getStringAsync(CURRENCY_COUNTRY_SYMBOL),
        isInitializing: true);
    await appStore.setPrivacyPolicy(getStringAsync(PRIVACY_POLICY),
        isInitializing: true);
    await appStore.setLoginType(getStringAsync(LOGIN_TYPE),
        isInitializing: true);
    await appStore.setUserType(getStringAsync(USER_TYPE), isInitializing: true);
    await appStore.setPlayerId(getStringAsync(PLAYERID), isInitializing: true);
    await appStore.setTermConditions(getStringAsync(TERM_CONDITIONS),
        isInitializing: true);
    await appStore.setInquiryEmail(getStringAsync(INQUIRY_EMAIL),
        isInitializing: true);
    await appStore.setHelplineNumber(getStringAsync(HELPLINE_NUMBER),
        isInitializing: true);
    await appStore.setEnableUserWallet(getBoolAsync(ENABLE_USER_WALLET),
        isInitializing: true);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: Observer(
        builder: (_) => FutureBuilder<Color>(
          future: getMaterialYouData(),
          builder: (_, snap) {
            return Observer(
              builder: (_) => MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                home: SplashScreen(),
                theme: AppTheme.lightTheme(color: snap.data),
                darkTheme: AppTheme.darkTheme(color: snap.data),
                themeMode:
                    appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                title: APP_NAME,
                supportedLocales: LanguageDataModel.languageLocales(),
                localizationsDelegates: [
                  AppLocalizations(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                localeResolutionCallback: (locale, supportedLocales) => locale,
                locale: Locale(appStore.selectedLanguageCode),
              ),
            );
          },
        ),
      ),
    );
  }
}
