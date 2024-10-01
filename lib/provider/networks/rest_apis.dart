import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:hands_user_app/auth/sign_in_screen.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/Package_response.dart';
import 'package:hands_user_app/models/base_response.dart';
import 'package:hands_user_app/models/booking_detail_response.dart';
import 'package:hands_user_app/models/booking_list_response.dart';
import 'package:hands_user_app/models/booking_status_response.dart';
import 'package:hands_user_app/models/caregory_response.dart';
import 'package:hands_user_app/models/city_list_response.dart';
import 'package:hands_user_app/models/country_list_response.dart';
import 'package:hands_user_app/models/dashboard_response.dart';
import 'package:hands_user_app/models/document_list_response.dart';
import 'package:hands_user_app/models/handyman_dashboard_response.dart';
import 'package:hands_user_app/models/login_response.dart';
import 'package:hands_user_app/models/notification_list_response.dart';
import 'package:hands_user_app/models/payment_list_reasponse.dart';
import 'package:hands_user_app/models/plan_list_response.dart';
import 'package:hands_user_app/models/plan_request_model.dart';
import 'package:hands_user_app/models/profile_update_response.dart';
import 'package:hands_user_app/models/provider_document_list_response.dart';
import 'package:hands_user_app/models/provider_info_model.dart';
import 'package:hands_user_app/models/provider_notification_model.dart';
import 'package:hands_user_app/models/provider_subscription_model.dart';
import 'package:hands_user_app/models/ratings_model.dart';
import 'package:hands_user_app/models/register_response.dart';
import 'package:hands_user_app/models/search_list_response.dart';
import 'package:hands_user_app/models/service_address_response.dart';
import 'package:hands_user_app/models/service_detail_response.dart';
import 'package:hands_user_app/models/service_model.dart';
import 'package:hands_user_app/models/service_response.dart';
import 'package:hands_user_app/models/service_review_response.dart';
import 'package:hands_user_app/models/sign_up_categories_model.dart';
import 'package:hands_user_app/models/state_list_response.dart';
import 'package:hands_user_app/models/subscription_history_model.dart';
import 'package:hands_user_app/models/tax_list_response.dart';
import 'package:hands_user_app/models/total_earning_response.dart';
import 'package:hands_user_app/models/user_data.dart';
import 'package:hands_user_app/models/user_info_response.dart';
import 'package:hands_user_app/models/user_list_response.dart';
import 'package:hands_user_app/models/user_type_response.dart';
import 'package:hands_user_app/models/verify_transaction_response.dart';
import 'package:hands_user_app/provider/networks/network_utils.dart';
import 'package:hands_user_app/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:hands_user_app/provider/jobRequest/models/post_job_response.dart';
import 'package:hands_user_app/provider/provider_dashboard_screen.dart';
import 'package:hands_user_app/provider/timeSlots/models/slot_data.dart';
import 'package:hands_user_app/provider/utils/app_config_model.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:hands_user_app/provider/utils/model_keys.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../models/addons_service_response.dart';
import '../../models/configuration_response.dart';
import '../../models/google_places_model.dart';
import '../../models/my_bid_response.dart';
import '../../models/wallet_history_list_response.dart';
import '../../provider/jobRequest/models/bidder_data.dart';
import '../../provider/jobRequest/models/post_job_data.dart';
import '../../provider/utils/firebase_messaging_utils.dart';
import '../../provider/utils/one_signal_utils.dart';

//region Auth API

Future<void> logout(BuildContext context) async {
  showConfirmDialogCustom(context,
      title: languages.logout,
      subTitle: languages.lblDeleteSubTitle,
      positiveText: appStorePro.selectedLanguageCode == 'en' ? "Yes" : 'نعم',
      negativeText: appStorePro.selectedLanguageCode == 'en' ? "No" : 'لا',
      primaryColor: Color(0xFFe04f5f),
      customCenterWidget: Container(
        color: redColor.withOpacity(.2),
        child: Center(
          child: Image.asset(
            'assets/icons/logout.png',
            width: 80,
          ),
        ),
      ), onAccept: (BuildContext) async {
    if (await isNetworkAvailable()) {
      appStorePro.setLoading(true);
      await logoutApi().then((value) async {}).catchError((e) {
        appStorePro.setLoading(false);
        toast(e.toString());
      });

      await clearPreferences();

      appStorePro.setLoading(false);

      // SignInScreen().launch(context,
      //     isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    } else {
      toast(errorInternetNotAvailable);
    }
  });
  // showInDialog(
  //   context,
  //   contentPadding: EdgeInsets.zero,
  //   builder: (_) {
  //     return Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Image.asset('assets/icons/logout.png', width: 250),
  //             32.height,
  //             Text(languages.lblDeleteTitle, style: boldTextStyle(size: 18)),
  //             16.height,
  //             Text(languages.lblDeleteSubTitle, style: secondaryTextStyle()),
  //             28.height,
  //             Row(
  //               children: [
  //                 AppButton(
  //                   child: Text(languages.lblNo, style: boldTextStyle()),
  //                   color: appStorePro.isDarkMode ? context.scaffoldBackgroundColor : context.cardColor,
  //                   elevation: 0,
  //                   onTap: () {
  //                     finish(context);
  //                   },
  //                 ).expand(),
  //                 16.width,
  //                 AppButton(
  //                   child: Text(languages.lblYes, style: boldTextStyle(color: white)),
  //                   color: primaryColor,
  //                   elevation: 0,
  //                   onTap: () async {},
  //                 ).expand(),
  //               ],
  //             ),
  //           ],
  //         ).paddingSymmetric(horizontal: 16, vertical: 24),
  //         Observer(builder: (_) => LoaderWidget().withSize(width: 60, height: 60).visible(appStorePro.isLoading)),
  //       ],
  //     );
  //   },
  // );
}

Future<void> clearPreferences() async {
  await unsubscribeFirebaseTopic();
  cachedProviderDashboardResponse = null;
  // cachedHandymanDashboardResponse = null;
  cachedBookingList = null;
  cachedPaymentList = null;
  cachedNotifications = null;
  cachedBookingStatusDropdown = null;

  await appStorePro.setFirstName('');
  await appStorePro.setLastName('');
  if (!getBoolAsync(IS_REMEMBERED)) await appStorePro.setUserEmail('');
  await appStorePro.setUserName('');
  await appStorePro.setContactNumber('');
  await appStorePro.setCountryId(0);
  await appStorePro.setStateId(0);
  await appStorePro.setCityId(0);
  await appStorePro.setUId('');
  await appStorePro.setToken('');
  await appStorePro.setCurrencySymbol('');
  await appStorePro.setLoggedIn(false);
  await appStorePro.setPlanSubscribeStatus(false);
  await appStorePro.setPlanTitle('');
  await appStorePro.setIdentifier('');
  await appStorePro.setPlanEndDate('');
  await appStorePro.setTester(false);
  await appStorePro.setPrivacyPolicy('');
  await appStorePro.setTermConditions('');
  await appStorePro.setInquiryEmail('');
  await appStorePro.setHelplineNumber('');

  OneSignal.Notifications.clearAll();
  OneSignal.logout();

  /// Firebase Notification
}

Future<void> logoutApi() async {
  String playerId = appStorePro.playerId.isNotEmpty
      ? '?player_id=${appStorePro.playerId}'
      : '';
  return await handleResponse(
      await buildHttpResponse('logout$playerId', method: HttpMethodType.GET));
}

Future<RegisterResponse> registerUser(Map request) async {
  return RegisterResponse.fromJson(await (handleResponse(
      await buildHttpResponse('register',
          request: request, method: HttpMethodType.POST))));
}

Future<LoginResponse> loginUser(Map request) async {
  LoginResponse res = LoginResponse.fromJson(await (handleResponse(
      await buildHttpResponse('login',
          request: request, method: HttpMethodType.POST))));

  return res;
}

Future<void> saveUserDatass(UserDatas data) async {
  if (data.status == 1) {
    // if (data.apiToken != null) await appStorePro.setToken(data.apiToken.validate());

    await appStorePro.setUserId(data.id.validate());
    await appStorePro.setCategoriesIDs(data.categoriesIds.validate());
    // print('appStorePro.setCategoriesIDs = ${data.categoriesIds.validate().toString()}');
    await appStorePro.setFirstName(data.firstName.validate());
    await appStorePro.setUserType(data.userType.validate());
    await appStorePro.setLastName(data.lastName.validate());
    await appStorePro.setUserEmail(data.email.validate());
    await appStorePro.setUserName(data.username.validate());
    await appStorePro.setContactNumber('${data.contactNumber.validate()}');
    await appStorePro.setUserProfile(data.profileImage.validate());
    await appStorePro.setCountryId(data.countryId.validate());
    await appStorePro.setStateId(data.stateId.validate());
    await appStorePro.setDesignation(data.designation.validate());
    await appStorePro.setProviderId(data.providerId.validate());
    await appStorePro.setAddress(
        data.address.validate().isNotEmpty ? data.address.validate() : '');

    await appStorePro.setCityId(data.cityId.validate());
    await appStorePro.setProviderId(data.providerId.validate());
    if (data.playerId.validate().isNotEmpty) {
      appStorePro.setPlayerId(data.playerId.validate());
    }
    if (data.serviceAddressId != null)
      await appStorePro.setServiceAddressId(data.serviceAddressId!);

    await appStorePro.setCreatedAt(data.createdAt.validate());

    if (data.subscription != null) {
      await setSaveSubscription(
        isSubscribe: data.isSubscribe,
        title: data.subscription!.title.validate(),
        identifier: data.subscription!.identifier.validate(),
        endAt: data.subscription!.endAt.validate(),
      );
    }

    await appStorePro.setLoggedIn(true);
  }
}

Future<BaseResponseModel> changeUserPassword(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('change-password',
          request: request, method: HttpMethodType.POST)));
}

Future<UserInfoResponse> getUserDetail(int id) async {
  appStorePro.setLoading(true);
  UserInfoResponse res = UserInfoResponse.fromJson(await handleResponse(
      await buildHttpResponse('user-detail?id=$id',
          method: HttpMethodType.GET)));
  appStorePro.setLoading(false);
  return res;
}

Future<HandymanInfoResponse> getProviderDetail(int id) async {
  return HandymanInfoResponse.fromJson(await handleResponse(
      await buildHttpResponse('user-detail?id=$id',
          method: HttpMethodType.GET)));
}

Future<List<Rating>> getUserRatings(
  int page,
  List<Rating> list,
  Function(bool)? lastPageCallback,
) async {
  try {
    var res = RatingsModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          'get-provider-ratings?page=$page',
          method: HttpMethodType.GET,
        ),
      ),
    );

    if (page == 1) list.clear();
    var myList = res.providerReviews!.ratings!.toList();
    list.addAll(myList.validate());

    cachedRatingsList = list;

    appStorePro.setLoading(false);

    lastPageCallback?.call(
        res.providerReviews!.ratings!.validate().length != PER_PAGE_ITEM);

    return list;
  } catch (e) {
    appStorePro.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<double?> getRatingInProfile() async {
  var res = RatingsModel.fromJson(
    await handleResponse(
      await buildHttpResponse(
        'get-provider-ratings',
        method: HttpMethodType.GET,
      ),
    ),
  );

  return res.providerRating?.rate;
}

// Future<RatingsModel> getUserRatings(int page) async {
//   return RatingsModel.fromJson(
//     await handleResponse(
//       await buildHttpResponse(
//         'get-provider-ratings?page=$page',
//         method: HttpMethodType.GET,
//       ),
//     ),
//   );
// }

Future<BaseResponseModel> forgotPassword(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('forgot-password',
          request: request, method: HttpMethodType.POST)));
}

Future<CommonResponseModel> updateProfile(Map request) async {
  return CommonResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('update-profile',
          request: request, method: HttpMethodType.POST)));
}

Future<AppConfigModel> getSellerAgreement() async {
  return AppConfigModel.fromJson(
    await handleResponse(
      await buildHttpResponse('configurations', method: HttpMethodType.GET),
    ),
  );
}

Future<VerificationModel> verifyUserEmail(String userEmail) async {
  Map<String, dynamic> request = {'email': userEmail};
  return VerificationModel.fromJson(await handleResponse(
      await buildHttpResponse('user-email-verify',
          request: request, method: HttpMethodType.POST)));
}

//endregion

//region Country API
Future<List<CountryListResponse>> getCountryList() async {
  Iterable res = await (handleResponse(
      await buildHttpResponse('country-list', method: HttpMethodType.POST)));
  return res.map((e) => CountryListResponse.fromJson(e)).toList();
}

Future<List<StateListResponse>> getStateList(Map request) async {
  Iterable res = await (handleResponse(await buildHttpResponse('state-list',
      request: request, method: HttpMethodType.POST)));
  return res.map((e) => StateListResponse.fromJson(e)).toList();
}

Future<List<CityListResponse>> getCityList(Map request) async {
  Iterable res = await (handleResponse(await buildHttpResponse('city-list',
      request: request, method: HttpMethodType.POST)));
  return res.map((e) => CityListResponse.fromJson(e)).toList();
}
//endregion

Future<SignUpCategoriesModel> getSignUpCategoryList(
    {String perPage = ''}) async {
  return SignUpCategoriesModel.fromJson(await handleResponse(
      await buildHttpResponse('category-list?per_page=$perPage',
          method: HttpMethodType.GET)));
}

//region Category API
Future<CategoryResponse> getCategoryList({String perPage = ''}) async {
  return CategoryResponse.fromJson(await handleResponse(await buildHttpResponse(
      'category-list?per_page=$perPage',
      method: HttpMethodType.GET)));
}
//endregion

//region SubCategory Api
Future<CategoryResponse> getSubCategoryList({required int catId}) async {
  String categoryId = catId != -1 ? "category_id=$catId" : "";
  String perPage = catId != -1 ? '&per_page=all' : '?per_page=all';
  return CategoryResponse.fromJson(await handleResponse(await buildHttpResponse(
      'subcategory-list?$categoryId$perPage',
      method: HttpMethodType.GET)));
}
//endregion

//region Configuration API
Future<ConfigurationResponse> configurationDashboard() async {
  ConfigurationResponse data = ConfigurationResponse.fromJson(
      await handleResponse(await buildHttpResponse(
          'configurations?is_authenticated=${appStorePro.isLoggedIn.getIntBool()}',
          method: HttpMethodType.GET)));

  if (data.otherSettings != null) {
    final otherSetting = data.otherSettings!;

    compareValuesInSharedPreference(
        FORCE_UPDATE_PROVIDER_APP, otherSetting.forceUpdateProviderApp);
    compareValuesInSharedPreference(
        PROVIDER_APP_MINIMUM_VERSION, otherSetting.providerAppMinimumVersion);
    compareValuesInSharedPreference(
        PROVIDER_APP_LATEST_VERSION, otherSetting.providerAppLatestVersion);
    otherSettingStorePro
        .setMaintenanceModeEnable(otherSetting.maintenanceMode.validate());
    otherSettingStorePro
        .setChatGptEnable(otherSetting.enableChatGpt.validate());
    otherSettingStorePro
        .setTestWithoutKey(otherSetting.testWithoutKey.validate());
    otherSettingStorePro
        .setEnableAutoAssign(otherSetting.enableAutoAssign.validate());
    otherSettingStorePro.setChatGptKey(otherSetting.chatGptKey.validate());
    otherSettingStorePro.setFirebaseKey(otherSetting.firebaseKey.validate());
    await setValue(FIREBASE_NOTIFICATION_STATUS,
        otherSetting.firebaseNotification.validate().getBoolInt());

    /// Place ChatGPT Key Here
    if (otherSetting.chatGptKey.validate().isNotEmpty) {
      chatGPTAPIkey = otherSetting.chatGptKey.validate();
    }
  }

  data.configurations.validate().forEach((data) async {
    if (data.value.validate().isNotEmpty &&
        data.key == ONESIGNAL_APP_ID_PROVIDER) {
      await setValue(ONESIGNAL_APP_ID_PROVIDER, data.value);
    } else if (data.value.validate().isNotEmpty &&
        data.key == ONESIGNAL_REST_API_KEY_PROVIDER) {
      await setValue(ONESIGNAL_REST_API_KEY_PROVIDER, data.value);
    } else if (data.value.validate().isNotEmpty &&
        data.key == ONESIGNAL_CHANNEL_KEY_PROVIDER) {
      await setValue(ONESIGNAL_CHANNEL_KEY_PROVIDER, data.value);
    } else if (data.value.validate().isNotEmpty &&
        data.key == ONESIGNAL_APP_ID_USER) {
      await setValue(ONESIGNAL_APP_ID_USER, data.value);
    } else if (data.value.validate().isNotEmpty &&
        data.key == ONESIGNAL_REST_API_KEY_USER) {
      await setValue(ONESIGNAL_REST_API_KEY_USER, data.value);
    } else if (data.value.validate().isNotEmpty &&
        data.key == ONESIGNAL_CHANNEL_KEY_USER) {
      await setValue(ONESIGNAL_CHANNEL_KEY_USER, data.value);
    }
    if (data.value.validate().isNotEmpty && data.key == siteSetupKey) {
      setConfigData(SiteConfig.fromJson(data.value.validate()));
    }
    if (data.value.validate().isNotEmpty &&
        data.key == serviceConfigurationsKey) {
      serviceConfig(ServiceConfig.fromJson(json.decode(data.value.validate())));
    }

    if (data.value.validate().isNotEmpty && data.key == earningType) {
      setValue(EARNING_TYPE, data.value);
    }
  });

  if (data.countryList != null && data.countryList.validate().isNotEmpty) {
    if (data.countryList.validate().first.currencyCode.validate() !=
        appStorePro.currencyCode)
      appStorePro.setCurrencyCode(
          data.countryList.validate().first.currencyCode.validate());
    if (data.countryList.validate().first.countryId.validate().toString() !=
        appStorePro.countryId.toString())
      appStorePro.setCurrencyCountryId(
          data.countryList.validate().first.countryId.validate().toString());
    if (data.countryList.validate().first.currencySymbol.validate() !=
        appStorePro.currencySymbol)
      appStorePro.setCurrencySymbol(
          data.countryList.validate().first.currencySymbol.validate());
  }

  if (!data.otherSettings!.firebaseNotification.validate().getBoolInt()) {
    initializeOneSignal();
  }

  /// Subscribe Firebase Topic
  subscribeToFirebaseTopic();

  return data;
}
//endregion

//region Provider API
Future<DashboardResponses> providerDashboard() async {
  final completer = Completer<DashboardResponses>();

  try {
    final data = DashboardResponses.fromJson(await handleResponse(
        await buildHttpResponse('provider-dashboard',
            method: HttpMethodType.GET)));

    completer.complete(data);
    // Perform additional code or post-processing
    await _performAdditionalProcessingProvider(data);
  } catch (e) {
    appStorePro.setLoading(false);
    completer.completeError(e);
  }

  return completer.future;
}

Future<void> _performAdditionalProcessingProvider(
    DashboardResponses data) async {
  cachedProviderDashboardResponse = data;

  setValue(IS_EMAIL_VERIFIED, data.isEmailVerified.getBoolInt());

  if (data.commission != null) {
    compareValuesInSharedPreference(
        DASHBOARD_COMMISSION, jsonEncode(data.commission));
  }

  if (data.appDownload != null) {
    compareValuesInSharedPreference(PROVIDER_PLAY_STORE_URL,
        data.appDownload!.providerPlayStoreUrl.validate());
    compareValuesInSharedPreference(PROVIDER_APPSTORE_URL,
        data.appDownload!.providerAppstoreUrl.validate());
  }

  appStorePro.setNotificationCount(data.notificationUnreadCount.validate());
  appStorePro.setPrivacyPolicy(
      data.privacyPolicy?.value.validate() ?? PRIVACY_POLICY_URL);
  appStorePro.setTermConditions(
      data.termConditions?.value.validate() ?? TERMS_CONDITION_URL);
  appStorePro.setInquiryEmail(
      data.inquiryEmail.validate(value: INQUIRY_SUPPORT_EMAIL));
  appStorePro.setHelplineNumber(data.helplineNumber.validate());

  if (data.languageOption != null) {
    compareValuesInSharedPreference(
        SERVER_LANGUAGES, jsonEncode(data.languageOption!.toList()));
  }

  setValue(IS_ADVANCE_PAYMENT_ALLOWED,
      data.isAdvancePaymentAllowed.validate().getBoolInt());

  appStorePro.setEarningType(data.earningType.validate());

  if (data.subscription != null) {
    await setSaveSubscription(
      isSubscribe: data.isSubscribed,
      title: data.subscription!.title.validate(),
      identifier: data.subscription!.identifier.validate(),
      endAt: data.subscription!.endAt.validate(),
    );
  }

  /*if (appStorePro.isLoggedIn) {
    configurationDashboard();
  }*/

  await configurationDashboard();

  appStorePro.setLoading(false);
}

Future<ProviderDocumentListResponse> getProviderDoc() async {
  return ProviderDocumentListResponse.fromJson(await handleResponse(
      await buildHttpResponse('provider-document-list',
          method: HttpMethodType.GET)));
}

Future<CommonResponseModel> deleteProviderDoc(int? id) async {
  return CommonResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('provider-document-delete/$id',
          method: HttpMethodType.POST)));
}
//endregion

//region Handyman API
Future<HandymanDashBoardResponse> handymanDashboard() async {
  final completer = Completer<HandymanDashBoardResponse>();

  try {
    final response = await buildHttpResponse('handyman-dashboard',
        method: HttpMethodType.GET);
    final data =
        HandymanDashBoardResponse.fromJson(await handleResponse(response));

    // Perform additional code or post-processing
    await _performAdditionalProcessingHandyman(data);

    completer.complete(data);
  } catch (e) {
    completer.completeError(e);
  }

  return completer.future;
}

Future<void> _performAdditionalProcessingHandyman(
    HandymanDashBoardResponse data) async {
  cachedHandymanDashboardResponse = data;

  setValue(IS_EMAIL_VERIFIED, data.isEmailVerified.getBoolInt());

  appStorePro.setCompletedBooking(data.completedBooking.validate().toInt());
  appStorePro.setHandymanAvailability(data.isHandymanAvailable.validate());

  if (data.appDownload != null) {
    compareValuesInSharedPreference(PROVIDER_PLAY_STORE_URL,
        data.appDownload!.providerPlayStoreUrl.validate());
    compareValuesInSharedPreference(PROVIDER_APPSTORE_URL,
        data.appDownload!.providerAppstoreUrl.validate());
  }

  setValue(IS_ADVANCE_PAYMENT_ALLOWED,
      data.isAdvancePaymentAllowed.validate().getBoolInt());

  appStorePro.setNotificationCount(data.notificationUnreadCount.validate());
  appStorePro.setPrivacyPolicy(
      data.privacyPolicy?.value.validate() ?? PRIVACY_POLICY_URL);
  appStorePro.setTermConditions(
      data.termConditions?.value.validate() ?? TERMS_CONDITION_URL);

  if (data.commission != null) {
    compareValuesInSharedPreference(
        DASHBOARD_COMMISSION, jsonEncode(data.commission));
  }

  appStorePro.setInquiryEmail(
      data.inquiryEmail.validate(value: INQUIRY_SUPPORT_EMAIL));
  appStorePro.setHelplineNumber(data.helplineNumber.validate());

  if (data.languageOption != null) {
    compareValuesInSharedPreference(
        SERVER_LANGUAGES, jsonEncode(data.languageOption!.toList()));
  }

  /*if (appStorePro.isLoggedIn) {
    configurationDashboard();
  }*/

  await configurationDashboard();

  appStorePro.setLoading(false);
}

Future<BaseResponseModel> updateHandymanStatus(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('user-update-status',
          request: request, method: HttpMethodType.POST)));
}

Future<List<UserDatas>> getHandyman(
    {int? page,
    int? providerId,
    String? userTypeHandyman = "handyman",
    required List<UserDatas> list,
    Function(bool)? lastPageCallback}) async {
  try {
    var res = UserListResponse.fromJson(
      await handleResponse(await buildHttpResponse(
          'user-list?user_type=$userTypeHandyman&provider_id=$providerId&per_page=$PER_PAGE_ITEM&page=$page',
          method: HttpMethodType.GET)),
    );

    if (page == 1) list.clear();

    list.addAll(res.data.validate());

    lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

    // cachedHandymanList = res.data;

    appStorePro.setLoading(false);
  } catch (e) {
    appStorePro.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
  return list;
}

Future<List<UserDatas>> getAllHandyman(
    {int? page,
    int? serviceAddressId,
    required List<UserDatas> UserDatas,
    Function(bool)? lastPageCallback}) async {
  try {
    UserListResponse res = UserListResponse.fromJson(
      await handleResponse(await buildHttpResponse(
          'user-list?user_type=handyman&provider_id=${appStorePro.userId}&per_page=$PER_PAGE_ITEM&page=$page',
          method: HttpMethodType.GET)),
    );

    if (page == 1) UserDatas.clear();

    UserDatas.addAll(res.data.validate());

    lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);
    appStorePro.setLoading(false);
  } catch (e) {
    appStorePro.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }

  return UserDatas;
}

Future<UserDatas> deleteHandyman(int id) async {
  return UserDatas.fromJson(await handleResponse(await buildHttpResponse(
      'handyman-delete/$id',
      method: HttpMethodType.POST)));
}

Future<BaseResponseModel> restoreHandyman(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('handyman-action',
          request: request, method: HttpMethodType.POST)));
}

//endregion

//region Service API
Future<ServiceResponse> getServiceList(int page, int providerId,
    {String? searchTxt,
    bool isSearch = false,
    int? categoryId,
    bool isCategoryWise = false}) async {
  if (isCategoryWise) {
    return ServiceResponse.fromJson(await handleResponse(await buildHttpResponse(
        'service-list?per_page=$PER_PAGE_ITEM&category_id=$categoryId&page=$page&provider_id=$providerId',
        method: HttpMethodType.GET)));
  } else if (isSearch) {
    return ServiceResponse.fromJson(await handleResponse(await buildHttpResponse(
        'service-list?per_page=$PER_PAGE_ITEM&page=$page&search=$searchTxt&provider_id=$providerId',
        method: HttpMethodType.GET)));
  } else {
    return ServiceResponse.fromJson(await handleResponse(await buildHttpResponse(
        'service-list?per_page=$PER_PAGE_ITEM&page=$page&provider_id=$providerId',
        method: HttpMethodType.GET)));
  }
}

Future<ServiceDetailResponses> getServiceDetail(Map request) async {
  ServiceDetailResponses res = ServiceDetailResponses.fromJson(
      await handleResponse(await buildHttpResponse('service-detail',
          request: request, method: HttpMethodType.POST)));
  if (!listOfCachedData
      .any((element) => element?.$1 == request['service_id'])) {
    listOfCachedDatas.add((request['service_id'], res));
  } else {
    int index = listOfCachedData
        .indexWhere((element) => element?.$1 == request['service_id']);
    listOfCachedDatas[index] = (request['service_id'], res);
  }

  return res;
}

Future<CommonResponseModel> deleteService(int id) async {
  return CommonResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('service-delete/$id',
          method: HttpMethodType.POST)));
}

Future<BaseResponseModel> deleteImage(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('remove-file',
          request: request, method: HttpMethodType.POST)));
}

Future<void> addServiceMultiPart(
    {required Map<String, dynamic> value,
    List<int>? serviceAddressList,
    List<File>? imageFile}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('service-save');

  multiPartRequest.fields.addAll(await getMultipartFields(val: value));

  if (serviceAddressList.validate().isNotEmpty) {
    for (int i = 0; i < serviceAddressList!.length; i++) {
      multiPartRequest.fields[AddServiceKey.providerAddressId + '[$i]'] =
          serviceAddressList[i].toString().validate();
    }
  }

  if (imageFile.validate().isNotEmpty) {
    multiPartRequest.files.addAll(await getMultipartImages(
        files: imageFile.validate(), name: AddServiceKey.serviceAttachment));
    multiPartRequest.fields[AddServiceKey.attachmentCount] =
        imageFile.validate().length.toString();
  }

  log("${multiPartRequest.fields}");

  multiPartRequest.headers.addAll(buildHeaderTokens());

  log("Multi Part Request : ${jsonEncode(multiPartRequest.fields)} ${multiPartRequest.files.map((e) => e.field + ": " + e.filename.validate())}");

  appStorePro.setLoading(true);

  await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
    appStorePro.setLoading(false);

    log("Response: ${jsonDecode(temp)}");

    toast(jsonDecode(temp)['message'], print: true);
    finish(getContext, true);
  }, onError: (error) {
    toast(error.toString(), print: true);
    appStorePro.setLoading(false);
  }).catchError((e) {
    appStorePro.setLoading(false);
    toast(e.toString());
  });
}
//endregion

//region Booking API
Future<List<BookingStatusResponses>> bookingStatus(
    {required List<BookingStatusResponses> list}) async {
  Iterable res = await (handleResponse(
      await buildHttpResponse('booking-status', method: HttpMethodType.GET)));
  list = res.map((e) => BookingStatusResponses.fromJson(e)).toList();
  cachedBookingStatusDropdowns = list;
  return list;
}

Future<List<BookingDatas>> getBookingList(int page,
    {var perPage = PER_PAGE_ITEM,
    String status = '',
    String searchText = '',
    required List<BookingDatas> bookings,
    Function(bool)? lastPageCallback}) async {
  try {
    BookingListResponse res;
    String searchParam = searchText.isNotEmpty ? '&search=$searchText' : '';

    if (status == BOOKING_PAYMENT_STATUS_ALL) {
      res = BookingListResponse.fromJson(await handleResponse(
          await buildHttpResponse(
              'booking-list?per_page=$perPage&page=$page$searchParam',
              method: HttpMethodType.GET)));
    } else {
      res = BookingListResponse.fromJson(await handleResponse(
          await buildHttpResponse(
              'booking-list?status=$status&per_page=$perPage&page=$page$searchParam',
              method: HttpMethodType.GET)));
    }

    if (page == 1) bookings.clear();
    bookings.addAll(res.data.validate());
    lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

    cachedBookingLists = bookings;

    appStorePro.setLoading(false);

    return bookings;
  } catch (e) {
    appStorePro.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<SearchListResponse> getServicesList(int page,
    {var perPage = PER_PAGE_ITEM,
    int? categoryId = -1,
    int? subCategoryId = -1,
    int? providerId,
    String? search,
    String? type}) async {
  String? req;
  String categoryIds = categoryId != -1 ? 'category_id=$categoryId&' : '';
  String searchPara = search.validate().isNotEmpty ? 'search=$search&' : '';
  String subCategorys =
      subCategoryId != -1 ? 'subcategory_id=$subCategoryId&' : '';
  String pages = 'page=$page&';
  String perPages = 'per_page=$PER_PAGE_ITEM';
  String providerIds =
      appStorePro.isLoggedIn ? 'provider_id=${appStorePro.userId}&' : '';
  String serviceType = type.validate().isNotEmpty ? 'type=$type&' : "";

  req =
      '?$categoryIds$providerIds$subCategorys$serviceType$searchPara$pages$perPages';
  return SearchListResponse.fromJson(await handleResponse(
      await buildHttpResponse('search-list$req', method: HttpMethodType.GET)));
}

Future<List<ServiceData>> getSearchList(
  int page, {
  var perPage = PER_PAGE_ITEM,
  int? categoryId = -1,
  int? subCategoryId = -1,
  int? providerId,
  String? search,
  String? type,
  required List<ServiceData> services,
  Function(bool)? lastPageCallback,
}) async {
  try {
    SearchListResponse res;

    String? req;
    String categoryIds = categoryId != -1 ? 'category_id=$categoryId&' : '';
    String searchPara = search.validate().isNotEmpty ? 'search=$search&' : '';
    String subCategorys =
        subCategoryId != -1 ? 'subcategory_id=$subCategoryId&' : '';
    String pages = 'page=$page&';
    String perPages = 'per_page=$perPage';
    String providerIds =
        appStorePro.isLoggedIn ? 'provider_id=${appStorePro.userId}&' : '';
    String serviceType = type.validate().isNotEmpty ? 'type=$type&' : "";

    req =
        '?$categoryIds$providerIds$subCategorys$serviceType$searchPara$pages$perPages';
    res = SearchListResponse.fromJson(await handleResponse(
        await buildHttpResponse('search-list$req',
            method: HttpMethodType.GET)));

    if (page == 1) services.clear();
    services.addAll(res.data.validate());
    lastPageCallback?.call(res.data.validate().length != perPage);

    appStorePro.setLoading(false);

    return services;
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<BookingDetailResponses> bookingDetail(Map request) async {
  BookingDetailResponses bookingDetailResponse =
      BookingDetailResponses.fromJson(
    await handleResponse(await buildHttpResponse('booking-detail',
        request: request, method: HttpMethodType.POST)),
  );

  appStorePro.setLoading(false);

  if (cachedBookingDetailLists.any((element) =>
      element.bookingDetail!.id == bookingDetailResponse.bookingDetail!.id)) {
    cachedBookingDetailLists.removeWhere((element) =>
        element.bookingDetail!.id == bookingDetailResponse.bookingDetail!.id);
  }
  cachedBookingDetailLists.add(bookingDetailResponse);

  return bookingDetailResponse;
}

Future<BaseResponseModel> bookingUpdate(Map request) async {
  var res = BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('booking-update',
          request: request, method: HttpMethodType.POST)));
  LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);

  return res;
}

Future<BaseResponseModel> assignBooking(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('booking-assigned',
          request: request, method: HttpMethodType.POST)));
}
//endregion

//region Address API
Future<ServiceAddressesResponse> getAddresses({int? providerId}) async {
  return ServiceAddressesResponse.fromJson(await handleResponse(
      await buildHttpResponse('provideraddress-list?provider_id=$providerId',
          method: HttpMethodType.GET)));
}

Future<List<AddressResponse>> getAddressesWithPagination({
  int? page,
  int? perPage = PER_PAGE_ITEM,
  required List<AddressResponse> addressList,
  required int providerId,
  Function(bool)? lastPageCallback,
}) async {
  try {
    ServiceAddressesResponse res = ServiceAddressesResponse.fromJson(
        await handleResponse(await buildHttpResponse(
            'provideraddress-list?provider_id=$providerId&per_page=$perPage&page=$page',
            method: HttpMethodType.GET)));

    if (page == 1) addressList.clear();

    addressList.addAll(res.addressResponse.validate());

    lastPageCallback
        ?.call(res.addressResponse.validate().length != PER_PAGE_ITEM);

    appStorePro.setLoading(false);
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
  return addressList;
}

Future<BaseResponseModel> addAddresses(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('save-provideraddress',
          request: request, method: HttpMethodType.POST)));
}

Future<BaseResponseModel> removeAddress(int? id) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('provideraddress-delete/$id',
          method: HttpMethodType.POST)));
}
//endregion

//region Reviews API
Future<List<RatingDatas>> serviceReviews(Map request) async {
  ServiceReviewResponse res = ServiceReviewResponse.fromJson(
      await handleResponse(await buildHttpResponse(
          'service-reviews?per_page=all',
          request: request,
          method: HttpMethodType.POST)));

  return res.data.validate();
}

Future<List<RatingDatas>> handymanReviews(Map request) async {
  ServiceReviewResponse res = ServiceReviewResponse.fromJson(
      await handleResponse(await buildHttpResponse(
          'handyman-reviews?per_page=all',
          request: request,
          method: HttpMethodType.POST)));
  return res.data.validate();
}
//endregion

//region Subscription API
Future<List<ProviderSubscriptionModel>> getPricingPlanList() async {
  try {
    PlanListResponse res = PlanListResponse.fromJson(await handleResponse(
        await buildHttpResponse('plan-list', method: HttpMethodType.GET)));

    appStorePro.setLoading(false);

    return res.data.validate();
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<ProviderSubscriptionModel> saveSubscription(Map request) async {
  return ProviderSubscriptionModel.fromJson(await handleResponse(
      await buildHttpResponse('save-subscription',
          request: request, method: HttpMethodType.POST)));
}

Future<List<ProviderSubscriptionModel>> getSubscriptionHistory({
  int? page,
  int? perPage = PER_PAGE_ITEM,
  required List<ProviderSubscriptionModel> providerSubscriptionList,
  Function(bool)? lastPageCallback,
}) async {
  try {
    SubscriptionHistoryResponse res = SubscriptionHistoryResponse.fromJson(
        await handleResponse(await buildHttpResponse(
      'subscription-history?per_page=$perPage&page=$page&orderby=desc',
      method: HttpMethodType.GET,
    )));

    if (page == 1) providerSubscriptionList.clear();

    providerSubscriptionList.addAll(res.data.validate());

    lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

    appStorePro.setLoading(false);

    return providerSubscriptionList;
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<void> cancelSubscription(Map request) async {
  return await handleResponse(await buildHttpResponse('cancel-subscription',
      request: request, method: HttpMethodType.POST));
}

Future<void> savePayment({
  ProviderSubscriptionModel? data,
  String? paymentStatus = BOOKING_PAYMENT_STATUS_ALL,
  String? paymentMethod,
  String? txnId,
}) async {
  if (data != null) {
    PlanRequestModel planRequestModel = PlanRequestModel()
      ..amount = data.amount
      ..description = data.description
      ..duration = data.duration
      ..identifier = data.identifier
      ..otherTransactionDetail = ''
      ..paymentStatus = paymentStatus.validate()
      ..paymentType = paymentMethod.validate()
      ..planId = data.id
      ..planLimitation = data.planLimitation
      ..planType = data.planType
      ..title = data.title
      ..txnId = txnId
      ..type = data.type
      ..userId = appStorePro.userId;

    appStorePro.setLoading(true);
    log('Request : $planRequestModel');

    await saveSubscription(planRequestModel.toJson()).then((value) {
      toast("${data.title.validate()}  ${languages.successfullyActivated}");
      // toast("${data.title.validate()} ${languages.lblIsSuccessFullyActivated}");
      push(ProviderDashboardScreen(index: 0),
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((e) {
      log(e.toString());
    }).whenComplete(() => appStorePro.setLoading(false));
  }
}

Future<List<WalletHistory>> getWalletHistory({
  int? page,
  var perPage = PER_PAGE_ITEM,
  required List<WalletHistory> list,
  Function(bool)? lastPageCallback,
}) async {
  try {
    WalletHistoryListResponse res = WalletHistoryListResponse.fromJson(
      await handleResponse(await buildHttpResponse(
          'wallet-history?per_page=$perPage&page=$page&orderby=desc',
          method: HttpMethodType.GET)),
    );

    if (page == 1) list.clear();
    list.addAll(res.data.validate());

    cachedWalletList = list;

    appStorePro.setLoading(false);

    lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

    return list;
  } catch (e) {
    appStorePro.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<BaseResponseModel> updateHandymanAvailabilityApi(
    {required Map request}) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('handyman-update-available-status',
          request: request, method: HttpMethodType.POST)));
}

//endregion

//region Payment API
Future<PaymentListResponse> getPaymentList(int page,
    {var perPage = PER_PAGE_ITEM}) async {
  return PaymentListResponse.fromJson(await handleResponse(
      await buildHttpResponse('payment-list?per_page=$perPage&page=$page',
          method: HttpMethodType.GET)));
}

Future<List<PaymentData>> getPaymentAPI(
    int page, List<PaymentData> list, Function(bool)? lastPageCallback,
    {var perPage = PER_PAGE_ITEM}) async {
  try {
    var res = PaymentListResponse.fromJson(await handleResponse(
        await buildHttpResponse('payment-list?per_page=$perPage&page=$page',
            method: HttpMethodType.GET)));

    if (page == 1) list.clear();
    list.addAll(res.data.validate());

    cachedPaymentList = list;

    appStorePro.setLoading(false);

    lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

    return list;
  } catch (e) {
    appStorePro.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<List<PaymentData>> getUserPaymentList(int page, int id,
    List<PaymentData> list, Function(bool)? lastPageCallback) async {
  appStorePro.setLoading(true);
  var res = PaymentListResponse.fromJson(await handleResponse(
      await buildHttpResponse('payment-list?booking_id=$id&page=$page',
          method: HttpMethodType.GET)));

  if (page == 1) list.clear();
  list.addAll(res.data.validate());

  appStorePro.setLoading(false);

  lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

  return list;
}

//endregion

//region Common API
Future<List<TaxData>> getTaxList({
  int? page,
  required List<TaxData> list,
  Function(bool)? lastPageCallback,
}) async {
  try {
    TaxListResponse res = TaxListResponse.fromJson(
      await (handleResponse(
          await buildHttpResponse('tax-list', method: HttpMethodType.GET))),
    );

    if (page == 1) list.clear();
    list.addAll(res.taxData.validate());

    lastPageCallback?.call(res.taxData.validate().length != PER_PAGE_ITEM);

    appStorePro.setLoading(false);
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
  return list;
}

Future<List<NotificationModelProvider>> getAdminNotifications() async {
  var headers = buildHeaderTokens();

  var request = Request(
    'GET',
    buildBaseUrl('push-notification-list'),
  );

  request.headers.addAll(headers);

  StreamedResponse response = await request.send();

  List<NotificationModelProvider> notifications = [];

  final data = await Response.fromStream(response);
  print('notifi = ${data.body}');

  if (response.statusCode == 200) {
    jsonDecode(data.body).forEach((notification) {
      notifications.add(NotificationModelProvider.fromJson(notification));
    });
    cachedNotification = notifications;

    return notifications;
  } else {
    return <NotificationModelProvider>[];
  }
}

Future<List<NotificationData>> getNotification(Map request,
    {int? page = 1,
    required List<NotificationData> notificationList,
    var perPage = PER_PAGE_ITEM,
    Function(bool)? lastPageCallback}) async {
  try {
    var res = NotificationListResponse.fromJson(await handleResponse(
        await buildHttpResponse(
            'notification-list?per_page=$perPage&page=$page',
            request: request,
            method: HttpMethodType.POST)));

    if (page == 1) {
      notificationList.clear();
    }

    lastPageCallback
        ?.call(res.notificationData.validate().length != PER_PAGE_ITEM);

    notificationList.addAll(res.notificationData.validate());
    // cachedNotifications = notificationList;

    appStorePro.setLoading(false);
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }

  return notificationList;
}

Future<DocumentListResponse> getDocList() async {
  return DocumentListResponse.fromJson(await handleResponse(
      await buildHttpResponse('document-list', method: HttpMethodType.GET)));
}

Future<List<TotalData>> getTotalEarningList(
    int page, List<TotalData> list, Function(bool)? lastPageCallback,
    {var perPage = PER_PAGE_ITEM}) async {
  try {
    var res = TotalEarningResponse.fromJson(
      await handleResponse(await buildHttpResponse(
          '${isUserTypeProvider ? 'provider-payout-list' : 'handyman-payout-list'}?per_page="$perPage"&page=$page',
          method: HttpMethodType.GET)),
    );

    if (page == 1) list.clear();
    list.addAll(res.data.validate());

    appStorePro.setLoading(false);

    lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);
    cachedTotalDataList = list;
    return list;
  } catch (e) {
    appStorePro.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<UserTypeResponse> getUserType({String type = USER_TYPE_PROVIDER}) async {
  return UserTypeResponse.fromJson(
      await handleResponse(await buildHttpResponse('type-list?type=$type')));
}

Future<BaseResponseModel> deleteAccountCompletely() async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('delete-account',
          request: {}, method: HttpMethodType.POST)));
}
//endregion

//region Post Job Request
Future<List<PostJobData>> getPostJobList(
  int page, {
  var perPage = PER_PAGE_ITEM,
  required List<PostJobData> postJobList,
  Function(bool)? lastPageCallback,
  String? filter,
  String? category,
}) async {
  try {
    print('Current page is ${page}');
    var res = PostJobResponse.fromJson(await handleResponse(await buildHttpResponse(
        'get-post-job?per_page=$perPage&page=$page${filter != null ? '&filter=$filter' : ''}${category != null ? '&category=$category' : ''}',
        method: HttpMethodType.GET)));

    if (page == 1) {
      postJobList.clear();
    }

    lastPageCallback?.call(res.postJobData.validate().length != PER_PAGE_ITEM);

    postJobList.addAll(res.postJobData.validate());
    appStorePro.setLoading(false);
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }

  return postJobList;
}

Future<List<PostJobData>> guestGetPostJobList(
  int page, {
  var perPage = PER_PAGE_ITEM,
  required List<PostJobData> postJobList,
  Function(bool)? lastPageCallback,
  String? filter,
  String? category,
}) async {
  try {
    print('Current page is ${page}');
    var res = PostJobResponse.fromJson(await handleResponse(await buildHttpResponse(
        'guest-get-post-job?per_page=$perPage&page=$page${filter != null ? '&filter=$filter' : ''}${category != null ? '&category=$category' : ''}',
        method: HttpMethodType.GET)));

    if (page == 1) {
      postJobList.clear();
    }

    lastPageCallback?.call(res.postJobData.validate().length != PER_PAGE_ITEM);

    postJobList.addAll(res.postJobData.validate());
    appStorePro.setLoading(false);
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }

  return postJobList;
}

Future<PostJobDetailResponse> getPostJobDetail(Map request) async {
  try {
    var res = PostJobDetailResponse.fromJson(await handleResponse(
        await buildHttpResponse('get-post-job-detail',
            request: request, method: HttpMethodType.POST)));
    appStore.setLoading(false);

    if (!cachedPostJobLists
        .any((element) => element?.$1 == request[PostJob.postRequestId])) {
      cachedPostJobLists.add(
          (request[PostJob.postRequestId].toString().toInt().validate(), res));
    } else {
      int index = cachedPostJobLists.indexWhere((element) =>
          element?.$1 ==
          request[PostJob.postRequestId].toString().toInt().validate());
      cachedPostJobLists[index] =
          (request[PostJob.postRequestId].toString().toInt().validate(), res);
    }

    log(cachedPostJobLists.map((e) => e));

    return res;
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<PostJobDetailResponse> guestGetPostJobDetail(Map request) async {
  try {
    var res = PostJobDetailResponse.fromJson(await handleResponse(
        await buildHttpResponse('guest-get-post-job-detail',
            request: request, method: HttpMethodType.POST)));
    appStorePro.setLoading(false);

    if (!cachedPostJobLists
        .any((element) => element?.$1 == request[PostJob.postRequestId])) {
      cachedPostJobLists.add(
          (request[PostJob.postRequestId].toString().toInt().validate(), res));
    } else {
      int index = cachedPostJobLists.indexWhere((element) =>
          element?.$1 ==
          request[PostJob.postRequestId].toString().toInt().validate());
      cachedPostJobLists[index] =
          (request[PostJob.postRequestId].toString().toInt().validate(), res);
    }

    log(cachedPostJobLists.map((e) => e));

    return res;
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<BidderData> saveBid(Map request) async {
  return BidderData.fromJson(await handleResponse(await buildHttpResponse(
      'save-bid',
      request: request,
      method: HttpMethodType.POST)));
}

Future<List<BidderData>> getBidList(
    {int page = 1,
    var perPage = PER_PAGE_ITEM,
    required List<BidderData> bidList,
    Function(bool)? lastPageCallback}) async {
  print('current page from Bid list is $page');
  try {
    var res = MyBidResponse.fromJson(await handleResponse(
        await buildHttpResponse(
            'get-bid-list?orderby=desc&per_page=$perPage&page=$page',
            method: HttpMethodType.GET)));

    if (page == 1) {
      bidList.clear();
    }

    lastPageCallback?.call(res.bidData.validate().length != PER_PAGE_ITEM);

    bidList.addAll(res.bidData.validate());
    appStorePro.setLoading(false);
  } catch (e) {
    appStorePro.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
  return bidList;
}
//endregion

// region Addons service API
Future<List<ServiceAddon>> getAddonsServiceList(
    {int? page,
    required List<ServiceAddon> addonServiceData,
    Function(bool)? lastPageCallback}) async {
  try {
    AddonsServiceResponse res = AddonsServiceResponse.fromJson(
      await handleResponse(await buildHttpResponse(
          'service-addon-list?per_page=$PER_PAGE_ITEM&page=$page',
          method: HttpMethodType.GET)),
    );

    if (page == 1) addonServiceData.clear();

    addonServiceData.addAll(res.addonsServiceList.validate());

    lastPageCallback
        ?.call(res.addonsServiceList.validate().length != PER_PAGE_ITEM);

    appStorePro.setLoading(false);

    return addonServiceData;
  } catch (e) {
    appStorePro.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<void> addAddonMultiPart(
    {required Map<String, dynamic> value, File? imageFile}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('service-addon-save');

  multiPartRequest.fields.addAll(await getMultipartFields(val: value));

  if (imageFile != null) {
    multiPartRequest.files.add(await MultipartFile.fromPath(
        AddonServiceKey.serviceAddonImage, imageFile.path));
  }

  log("${multiPartRequest.fields}");

  multiPartRequest.headers.addAll(buildHeaderTokens());

  log("MultiPart Request : ${jsonEncode(multiPartRequest.fields)} ${multiPartRequest.files.map((e) => e.field + ": " + e.filename.validate())}");

  appStorePro.setLoading(true);

  await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
    appStorePro.setLoading(false);

    appStorePro.selectedServiceList.clear();
    log("Response: ${jsonDecode(temp)}");

    toast(jsonDecode(temp)['message'], print: true);
    finish(getContext, true);
  }, onError: (error) {
    toast(error.toString(), print: true);
    appStorePro.setLoading(false);
  }).catchError((e) {
    appStorePro.setLoading(false);
    toast(e.toString());
  });
}

Future<CommonResponseModel> deleteAddonService(int id) async {
  return CommonResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('service-addon-delete/$id',
          method: HttpMethodType.POST)));
}
//endregion

// region Package service API
Future<List<PackageData>> getAllPackageList(
    {int? page,
    required List<PackageData> packageData,
    Function(bool)? lastPageCallback}) async {
  try {
    PackageResponse res = PackageResponse.fromJson(
      await handleResponse(await buildHttpResponse(
          'package-list?per_page=$PER_PAGE_ITEM&page=$page',
          method: HttpMethodType.GET)),
    );

    if (page == 1) packageData.clear();

    packageData.addAll(res.packageList.validate());

    lastPageCallback?.call(res.packageList.validate().length != PER_PAGE_ITEM);

    appStorePro.setLoading(false);

    return packageData;
  } catch (e) {
    appStorePro.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<void> addPackageMultiPart(
    {required Map<String, dynamic> value, List<File>? imageFile}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('package-save');

  multiPartRequest.fields.addAll(await getMultipartFields(val: value));

  if (imageFile.validate().isNotEmpty) {
    multiPartRequest.files.addAll(await getMultipartImages(
        files: imageFile.validate(), name: PackageKey.packageAttachment));
    multiPartRequest.fields[AddServiceKey.attachmentCount] =
        imageFile.validate().length.toString();
  }

  log("${multiPartRequest.fields}");

  multiPartRequest.headers.addAll(buildHeaderTokens());

  log("MultiPart Request : ${jsonEncode(multiPartRequest.fields)} ${multiPartRequest.files.map((e) => e.field + ": " + e.filename.validate())}");

  appStorePro.setLoading(true);

  await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
    appStorePro.setLoading(false);

    appStorePro.selectedServiceList.clear();
    log("Response: ${jsonDecode(temp)}");

    toast(jsonDecode(temp)['message'], print: true);
    finish(getContext, true);
  }, onError: (error) {
    toast(error.toString(), print: true);
    appStorePro.setLoading(false);
  }).catchError((e) {
    appStorePro.setLoading(false);
    toast(e.toString());
  });
}

Future<CommonResponseModel> deletePackage(int id) async {
  return CommonResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('package-delete/$id',
          method: HttpMethodType.POST)));
}
//endregion

//region FlutterWave Verify Transaction API
Future<VerifyTransactionResponse> verifyPayment(
    {required String transactionId,
    required String flutterWaveSecretKey}) async {
  return VerifyTransactionResponse.fromJson(
    await handleResponse(await buildHttpResponse(
        "https://api.flutterwave.com/v3/transactions/$transactionId/verify",
        extraKeys: {
          'isFlutterWave': true,
          'flutterWaveSecretKey': flutterWaveSecretKey,
        })),
  );
}
//endregion

//region TimeSlots
Future<BaseResponseModel> updateAllServicesApi({required Map request}) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('provider-all-services-timeslots',
          request: request, method: HttpMethodType.POST)));
}

Future<List<SlotData>> getProviderSlot({int? val}) async {
  String providerId = val != null ? "?provider_id=$val" : '';
  Iterable res = await handleResponse(await buildHttpResponse(
      'get-provider-slot$providerId',
      method: HttpMethodType.GET));
  return res.map((e) => SlotData.fromJson(e)).toList();
}

Future<List<SlotData>> getProviderServiceSlot(
    {int? providerId, int? serviceId}) async {
  String pId = providerId != null ? "?provider_id=$providerId" : '';
  String sId = serviceId != null ? "&service_id=$serviceId" : '';
  Iterable res = await handleResponse(await buildHttpResponse(
      'get-service-slot$pId$sId',
      method: HttpMethodType.GET));
  return res.map((e) => SlotData.fromJson(e)).toList();
}

Future<BaseResponseModel> saveProviderSlot(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('save-provider-slot',
          request: request, method: HttpMethodType.POST)));
}

Future<BaseResponseModel> saveServiceSlot(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('save-service-slot',
          request: request, method: HttpMethodType.POST)));
}

//endregion

//region CommonFunctions
Future<Map<String, String>> getMultipartFields(
    {required Map<String, dynamic> val}) async {
  Map<String, String> data = {};

  val.forEach((key, value) {
    data[key] = '$value';
  });

  return data;
}

Future<List<MultipartFile>> getMultipartImages(
    {required List<File> files, required String name}) async {
  List<MultipartFile> multiPartRequest = [];

  await Future.forEach<File>(files, (element) async {
    int i = files.indexOf(element);

    multiPartRequest.add(await MultipartFile.fromPath(
        '${'$name' + i.toString()}', element.path));
  });

  return multiPartRequest;
}
//endregion

//region Sadad Payment Api
Future<String> sadadLogin(Map request) async {
  var res = await handleResponse(
    await buildHttpResponse('$SADAD_API_URL/api/userbusinesses/login',
        method: HttpMethodType.POST,
        request: request,
        extraKeys: {
          'isSadadPayment': true,
        }),
    avoidTokenError: false,
    isSadadPayment: true,
  );
  return res['accessToken'];
}

Future sadadCreateInvoice(
    {required Map<String, dynamic> request, required String sadadToken}) async {
  return handleResponse(
    await buildHttpResponse('$SADAD_API_URL/api/invoices/createInvoice',
        method: HttpMethodType.POST,
        request: request,
        extraKeys: {
          'sadadToken': true,
          'isSadadPayment': true,
        }),
    avoidTokenError: false,
    isSadadPayment: true,
  );
}
//endregion

//region Google Maps
Future<List<GooglePlacesModel>> getSuggestion(String input) async {
  String baseURL =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  String request =
      '$baseURL?input=$input&key=$GOOGLE_MAPS_API_KEY&sessiontoken=${appStorePro.token}';

  var response = await buildHttpResponse(request);

  if (response.statusCode == 200) {
    Iterable it = jsonDecode(response.body)['predictions'];
    return it.map((e) => GooglePlacesModel.fromJson(e)).toList().validate();
  } else {
    throw Exception('${languages.lblFailedToLoadPredictions}');
  }
}
//endregion
