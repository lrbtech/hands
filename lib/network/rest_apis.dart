import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hands_user_app/model/invoice_response_model';
import 'package:either_dart/either.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/base_response_model.dart';
import 'package:hands_user_app/model/booking_data_model.dart';
import 'package:hands_user_app/model/booking_detail_model.dart';
import 'package:hands_user_app/model/booking_list_model.dart';
import 'package:hands_user_app/model/booking_status_model.dart';
import 'package:hands_user_app/model/category_model.dart';
import 'package:hands_user_app/model/city_list_model.dart';
import 'package:hands_user_app/model/country_list_model.dart';
import 'package:hands_user_app/model/dashboard_model.dart';
import 'package:hands_user_app/model/get_my_post_job_list_response.dart';
import 'package:hands_user_app/model/login_model.dart';
import 'package:hands_user_app/model/notification_model';
import 'package:hands_user_app/model/notification_model.dart';
import 'package:hands_user_app/model/post_job_detail_response.dart';
import 'package:hands_user_app/model/provider_info_response.dart';
import 'package:hands_user_app/model/provider_list_model.dart';
import 'package:hands_user_app/model/service_data_model.dart';
import 'package:hands_user_app/model/service_detail_response.dart';
import 'package:hands_user_app/model/service_response.dart';
import 'package:hands_user_app/model/service_review_response.dart';
import 'package:hands_user_app/model/state_list_model.dart';
import 'package:hands_user_app/model/user_data_model.dart';
import 'package:hands_user_app/model/user_wallet_history.dart';
import 'package:hands_user_app/model/verify_transaction_response.dart';
import 'package:hands_user_app/network/network_utils.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/payment/component/coupon_model.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/configuration_response.dart';
import '../model/coupon_list_model.dart';
import '../model/payment_list_reasponse.dart';
import '../model/wallet_response.dart';
import '../utils/firebase_messaging_utils.dart';

//region Auth Api
Future<LoginResponse> createUser(Map request) async {
  return LoginResponse.fromJson(await (handleResponse(await buildHttpResponse(
      'register',
      request: request,
      method: HttpMethodType.POST))));
}

Future<LoginResponse> loginUser(Map request,
    {bool isSocialLogin = false}) async {
  request.remove("uid");
  appStore.setLoading(true);
  LoginResponse res = LoginResponse.fromJson(await handleResponse(
      await buildHttpResponse(isSocialLogin ? 'social-login' : 'login',
          request: request, method: HttpMethodType.POST)));

  // if (res.userData != null && res.userData!.userType != USER_TYPE_USER) {
  //   throw language.lblNotValidUser;
  // }

  if (!isSocialLogin) await appStore.setLoginType(LOGIN_TYPE_USER);

  return res;
}

Future<UserData> getUserDetail(int id) async {
  return UserData.fromJson(await handleResponse(await buildHttpResponse(
      'user-detail?id=$id',
      method: HttpMethodType.GET)));
}

Future<void> saveUserData(UserData data) async {
  if (data.apiToken.validate().isNotEmpty)
    await appStore.setToken(data.apiToken!);
  appStore.setLoggedIn(true);

  await appStore.setUserId(data.id.validate());
  await appStore.setFirstName(data.firstName.validate());
  await appStore.setLastName(data.lastName.validate());
  await appStore.setUserEmail(data.email.validate());
  await appStore.setUserName(data.username.validate());
  await appStore.setUserType(data.userType.validate());
  await appStore.setCountryId(data.countryId.validate());
  await appStore.setStateId(data.stateId.validate());
  await appStore.setCityId(data.cityId.validate());
  await appStore.setContactNumber(data.contactNumber.validate());
  if (data.loginType.validate().isNotEmpty)
    await appStore.setLoginType(data.loginType.validate());
  await appStore.setAddress(data.address.validate());

  if (data.playerId.validate().isNotEmpty) {
    appStore.setPlayerId(data.playerId.validate());
  }

  if (data.loginType != LOGIN_TYPE_GOOGLE) {
    await appStore.setUserProfile(data.profileImage.validate());
  }
  appStore.setUId(data.uid.validate());

  ///Set app configurations
  getAppConfigurations();
}

Future<void> clearPreferences() async {
  if (!getBoolAsync(IS_REMEMBERED)) {
    await appStore.setUserEmail('');
    await removeKey(IS_EMAIL_VERIFIED);
  }
  await unsubscribeFirebaseTopic();

  /// Firebase Notification

  await appStore.setFirstName('');
  await appStore.setLastName('');
  await appStore.setUserId(0);
  await appStore.setUserName('');
  await appStore.setContactNumber('');
  await appStore.setCountryId(0);
  await appStore.setStateId(0);
  await appStore.setUserProfile('');
  await appStore.setCityId(0);
  await appStore.setUId('');
  await appStore.setLatitude(0.0);
  await appStore.setLongitude(0.0);
  await appStore.setCurrentAddress('');

  await appStore.setCurrentLocation(false);

  await appStore.setToken('');
  await appStore.setPrivacyPolicy('');
  await appStore.setTermConditions('');
  await appStore.setInquiryEmail('');
  await appStore.setHelplineNumber('');

  await appStore.setFirebaseToken('');

  await appStore.setLoggedIn(false);
  await removeKey(LOGIN_TYPE);

  // OneSignal.Notifications.clearAll();
  // OneSignal.logout();
}

Future<void> logout(BuildContext context) async {
  return showInDialog(
    context,
    contentPadding: EdgeInsets.zero,
    builder: (p0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            height: 100,
            "assets/icons/logout_logo.png",
            width: context.width(),
            fit: BoxFit.fitHeight,
          ),
          32.height,
          Text(language.lblLogoutTitle, style: boldTextStyle(size: 18)),
          16.height,
          Text(language.lblLogoutSubTitle, style: secondaryTextStyle()),
          28.height,
          Row(
            children: [
              AppButton(
                child: Text(language.lblNo, style: boldTextStyle()),
                elevation: 0,
                onTap: () {
                  print("navpop");
                  Navigator.of(context, rootNavigator: true).pop();
                  // Navigator.pop(context);
                  // finish(context);
                  // finish(context);
                },
              ).expand(),
              16.width,
              AppButton(
                child:
                    Text(language.lblYes, style: boldTextStyle(color: white)),
                color: primaryColor,
                elevation: 0,
                onTap: () async {
                  //finish(context);
                  Navigator.of(context, rootNavigator: true).pop();
                  if (await isNetworkAvailable()) {
                    appStore.setLoading(true);

                    logoutApi().then((value) async {
                      //
                    }).catchError((e) {
                      log(e.toString());
                    });

                    await clearPreferences();
                    await FirebaseAuth.instance.signOut();

                    appStore.setLoading(false);
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return DashboardScreen();
                        },
                      ),
                      (_) => false,
                    );
                    //DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                  }
                },
              ).expand(),
            ],
          ),
        ],
      ).paddingSymmetric(horizontal: 16, vertical: 24);
    },
  );
}

Future<void> logoutApi() async {
  cachedDashboardResponse = null;
  cachedBookingList = null;
  cachedCategoryList = null;
  cachedBookingStatusDropdown = null;

  String playerId =
      appStore.playerId.isNotEmpty ? '?player_id=${appStore.playerId}' : '';
  String firebaseToken = appStore.firebaseToken.isNotEmpty
      ? '&firebase_token=${appStore.firebaseToken}'
      : '';
  return await handleResponse(await buildHttpResponse(
      'logout$playerId$firebaseToken',
      method: HttpMethodType.GET));
}

Future<BaseResponseModel> changeUserPassword(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('change-password',
          request: request, method: HttpMethodType.POST)));
}

Future<BaseResponseModel> forgotPassword(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('forgot-password',
          request: request, method: HttpMethodType.POST)));
}

Future<BaseResponseModel> deleteAccountCompletely() async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('delete-user-account',
          request: {}, method: HttpMethodType.POST)));
}

Future<VerificationModel> verifyUserEmail(String userEmail) async {
  Map<String, dynamic> request = {'email': userEmail};
  return VerificationModel.fromJson(await handleResponse(
      await buildHttpResponse('user-email-verify',
          request: request, method: HttpMethodType.POST)));
}

//endregion

//region Country Api
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

//region Configurations Api
Future<ConfigurationResponse> getAppConfigurations(
    {bool isCurrentLocation = false, double? lat, double? long}) async {
  try {
    ConfigurationResponse? data = ConfigurationResponse.fromJson(
        await handleResponse(await buildHttpResponse(
            'configurations?is_authenticated=${appStore.isLoggedIn.getIntBool()}',
            method: HttpMethodType.GET)));
    // configs = data;

    data.configurations.validate().forEach((data) {
      if (data.value.validate().isNotEmpty &&
          data.key == ONESIGNAL_APP_ID_PROVIDER) {
        compareValuesInSharedPreference(ONESIGNAL_APP_ID_PROVIDER, data.value);
      } else if (data.value.validate().isNotEmpty &&
          data.key == ONESIGNAL_REST_API_KEY_PROVIDER) {
        compareValuesInSharedPreference(
            ONESIGNAL_REST_API_KEY_PROVIDER, data.value);
      } else if (data.value.validate().isNotEmpty &&
          data.key == ONESIGNAL_CHANNEL_KEY_PROVIDER) {
        compareValuesInSharedPreference(
            ONESIGNAL_CHANNEL_KEY_PROVIDER, data.value);
      } else if (data.value.validate().isNotEmpty &&
          data.key == ONESIGNAL_API_KEY) {
        compareValuesInSharedPreference(ONESIGNAL_API_KEY, data.value);
      } else if (data.value.validate().isNotEmpty &&
          data.key == ONESIGNAL_REST_API_KEY) {
        compareValuesInSharedPreference(ONESIGNAL_REST_API_KEY, data.value);
      } else if (data.value.validate().isNotEmpty &&
          data.key == ONESIGNAL_CHANNEL_KEY) {
        compareValuesInSharedPreference(ONESIGNAL_CHANNEL_KEY, data.value);
      }

      if (data.value.validate().isNotEmpty && data.key == siteSetupKey) {
        setConfigData(SiteConfig.fromJson(data.value.validate()));
      }

      if (data.value.validate().isNotEmpty && data.key == generalSettingKey) {
        setGeneralSetting(
            GeneralSettingModel.fromJson(jsonDecode(data.value.validate())));
      }

      if (data.key.validate().isNotEmpty && data.key == socialMediaKey) {
        setSocialMedia(SocialMedia.fromJson(jsonDecode(data.value.validate())));
      }
    });

    if (data.generalSetting != null) {
      appStore.setHelplineNumber(data.generalSetting!.helplineNumber.validate(),
          isInitializing: true);
      appStore.setInquiryEmail(data.generalSetting!.inquriyEmail.validate(),
          isInitializing: true);
    }

    if (data.otherSettings != null) {
      final otherSetting = data.otherSettings!;
      otherSettingStore
          .setSocialLoginEnable(otherSetting.socialLogin.validate());
      otherSettingStore
          .setGoogleLoginEnable(otherSetting.googleLogin.validate());
      otherSettingStore.setAppleLoginEnable(otherSetting.appleLogin.validate());
      otherSettingStore.setOTPLoginEnable(otherSetting.otpLogin.validate());
      otherSettingStore.setBlogEnable(otherSetting.blog.validate());
      otherSettingStore
          .setMaintenanceModeEnable(otherSetting.maintenanceMode.validate());
      otherSettingStore.setChatGptEnable(otherSetting.enableChatGpt.validate());
      otherSettingStore
          .setTestWithoutKey(otherSetting.testWithoutKey.validate());
      otherSettingStore.setChatGptKey(otherSetting.chatGptKey.validate());
      otherSettingStore.setFirebaseKey(otherSetting.firebaseKey.validate());
      await setValue(FIREBASE_NOTIFICATION_STATUS,
          otherSetting.firebaseNotification.validate().getBoolInt());
      otherSettingStore.setDisclimerText(
          data.otherSettings!.disclaimerText.validate(),
          data.otherSettings!.disclaimerTextAr.validate());

      /// Place ChatGPT Key Here
      if (otherSetting.chatGptKey.validate().isNotEmpty) {
        chatGPTAPIkey = otherSetting.chatGptKey.validate();
      }

      compareValuesInSharedPreference(
          FORCE_UPDATE_USER_APP, otherSetting.forceUpdateUserApp);
      compareValuesInSharedPreference(
          USER_APP_MINIMUM_VERSION, otherSetting.userAppMinimumVersion);
      compareValuesInSharedPreference(
          USER_APP_LATEST_VERSION, otherSetting.userAppLatestVersion);
      appStore.setEnableUserWallet(otherSetting.enableUserWallet.validate());
    }

    if (data.radarTime != null) {
      appStore.setRadarTime(val: data.radarTime!);
    }

    if (data.countryList != null && data.countryList.validate().isNotEmpty) {
      if (data.countryList.validate().first.currencyCode.validate() !=
          appStore.currencyCode)
        appStore.setCurrencyCode(
            data.countryList.validate().first.currencyCode.validate());
      if (data.countryList.validate().first.countryId.validate().toString() !=
          appStore.countryId.toString())
        appStore.setCurrencyCountryId(
            data.countryList.validate().first.countryId.validate().toString());
      if (data.countryList.validate().first.currencySymbol.validate() !=
          appStore.currencySymbol)
        appStore.setCurrencySymbol(
            data.countryList.validate().first.currencySymbol.validate());
    }

    otherSettingStore.setPostJobRequestEnable(data.postJobRequest.validate());
    setValue(IS_ADVANCE_PAYMENT_ALLOWED,
        data.isAllowAdvancePayment.validate().getBoolInt());

    // if (appStore.isLoggedIn && !getBoolAsync(FIREBASE_NOTIFICATION_STATUS)) {
    //   initializeOneSignal();
    // }

    /// Subscribe Firebase Topic
    subscribeToFirebaseTopic();

    if (data.paymentSettings != null) {
      compareValuesInSharedPreference(
          PAYMENT_LIST, PaymentSetting.encode(data.paymentSettings.validate()));
    }

    return data;
  } catch (e) {
    log(e);
    throw errorSomethingWentWrong;
  }
}
//endregion

//region User Api
Future<DashboardResponse> userDashboard(
    {bool isCurrentLocation = false, double? lat, double? long}) async {
  Completer<DashboardResponse> completer = Completer();

  String endPoint = 'dashboard-detail';

  if (isCurrentLocation &&
      appStore.isLoggedIn &&
      appStore.userId.validate() != 0) {
    endPoint =
        "$endPoint?latitude=$lat&longitude=$long&?customer_id=${appStore.userId.validate()}}";
  } else if (isCurrentLocation) {
    endPoint = "$endPoint?latitude=$lat&longitude=$long";
  } else if (appStore.isLoggedIn && appStore.userId.validate() != 0) {
    endPoint = "$endPoint?customer_id=${appStore.userId.validate()}";
  }

  try {
    final response =
        await buildHttpResponse(endPoint, method: HttpMethodType.GET);
    final dashboardResponse =
        DashboardResponse.fromJson(await handleResponse(response));

    setValue(SITE_DESCRIPTION_AR,
        dashboardResponse.generalSetting?.siteDescriptionAR);
    setValue(
        SITE_DESCRIPTION, dashboardResponse.generalSetting?.siteDescription);

    appStore.setLoading(false);

    completer.complete(dashboardResponse);
    // Perform additional code or post-processing
    _performAdditionalProcessing(dashboardResponse);
    appStore.setStoresUrls(
        config: SiteConfig(
      playstoreUrl: dashboardResponse.appDownload?.playstore_url,
      providerPlaystoreUrl:
          dashboardResponse.appDownload?.provider_playstore_url,
      appstoreUrl: dashboardResponse.appDownload?.appstore_url,
      providerAppstoreUrl: dashboardResponse.appDownload?.provider_appstore_url,
    ));
  } catch (e) {
    appStore.setLoading(false);
    completer.completeError(e);
  }

  return completer.future;
}

void _performAdditionalProcessing(DashboardResponse dashboardResponse) async {
  cachedDashboardResponse = dashboardResponse;
  appStore.setLoading(false);

  appStore.setPrivacyPolicy(
      dashboardResponse.privacyPolicy?.value.validate() ?? PRIVACY_POLICY_URL);
  appStore.setTermConditions(
      dashboardResponse.termConditions?.value.validate() ??
          TERMS_CONDITION_URL);

  setValue(IS_EMAIL_VERIFIED, dashboardResponse.isEmailVerified.getBoolInt());

  // if (dashboardResponse.appDownload != null) {
  //   compareValuesInSharedPreference(APPSTORE_URL, dashboardResponse.appDownload!.appstore_url.validate());
  //   compareValuesInSharedPreference(PLAY_STORE_URL, dashboardResponse.appDownload!.playstore_url.validate());
  //   compareValuesInSharedPreference(PROVIDER_PLAY_STORE_URL, dashboardResponse.appDownload!.provider_playstore_url.validate());
  //   compareValuesInSharedPreference(PROVIDER_APPSTORE_URL, dashboardResponse.appDownload!.provider_appstore_url.validate());
  // }

  if (dashboardResponse.languageOption != null) {
    compareValuesInSharedPreference(SERVER_LANGUAGES,
        jsonEncode(dashboardResponse.languageOption!.toList()));
  }

  if (dashboardResponse.generalSetting != null) {
    final generalSetting = dashboardResponse.generalSetting!;
  }

  if (dashboardResponse.configurations.validate().isNotEmpty) {
    dashboardResponse.configurations.validate().forEach((data) {
      if (data.value.validate().isNotEmpty && data.key == siteSetupKey) {
        setConfigData(SiteConfig.fromJson(data.value.validate()));
      }

      if (data.value.validate().isNotEmpty && data.key == generalSettingKey) {}
      if (data.value.validate().isNotEmpty && data.key == socialMediaKey) {
        setSocialMedia(SocialMedia.fromJson(jsonDecode(data.value.validate())));
      }
    });
  }

  if (dashboardResponse.countryList != null &&
      dashboardResponse.countryList.validate().isNotEmpty) {
    if (dashboardResponse.countryList
            .validate()
            .first
            .currencyCode
            .validate() !=
        appStore.currencyCode)
      appStore.setCurrencyCode(dashboardResponse.countryList
          .validate()
          .first
          .currencyCode
          .validate());
    if (dashboardResponse.countryList
            .validate()
            .first
            .countryId
            .validate()
            .toString() !=
        appStore.countryId.toString())
      appStore.setCurrencyCountryId(dashboardResponse.countryList
          .validate()
          .first
          .countryId
          .validate()
          .toString());
    if (dashboardResponse.countryList
            .validate()
            .first
            .currencySymbol
            .validate() !=
        appStore.currencySymbol)
      appStore.setCurrencySymbol(dashboardResponse.countryList
          .validate()
          .first
          .currencySymbol
          .validate());
  }

  appStore.setUnreadCount(dashboardResponse.notificationUnreadCount.validate());

  ///Set app configurations
  await getAppConfigurations();
}

Future<num> getUserWalletBalance() async {
  try {
    var res = WalletResponse.fromJson(await handleResponse(
        await buildHttpResponse('user-wallet-balance',
            method: HttpMethodType.GET)));

    return res.balance.validate();
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    return appStore.userWalletAmount;
  }
}

Future<List<WalletDataElement>> getUserWalletHistory(int page,
    {var perPage = PER_PAGE_ITEM,
    required List<WalletDataElement> walletDataList,
    Function(bool)? lastPageCallBack}) async {
  appStore.setLoading(true);
  try {
    var res = UserWalletHistoryResponse.fromJson(await handleResponse(
        await buildHttpResponse(
            'wallet-history?per_page=$perPage&page=$page&orderby=desc',
            method: HttpMethodType.GET)));

    if (page == 1) walletDataList.clear();
    walletDataList.addAll(res.data.validate());

    lastPageCallBack?.call(res.data.validate().length != PER_PAGE_ITEM);
    cachedWalletHistoryList = walletDataList;
    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }

  return walletDataList;
}

Future<BaseResponseModel> walletTopUp(Map req) async {
  appStore.setLoading(true);
  try {
    var res = BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse('wallet-top-up',
            method: HttpMethodType.POST, request: req)));

    toast(language.yourWalletIsUpdated);
    appStore.setUserWalletAmount();
    appStore.setLoading(false);

    return res;
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<bool?> tipProvider(Map req) async {
  appStore.setLoading(true);
  try {
    var res = BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse('tip-provider',
            method: HttpMethodType.POST, request: req)));

    toast(language.thanksForTipping);
    appStore.setLoading(false);

    return true;
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}
//endregion

//region Service Api
Future<ServiceDetailResponse> getServiceDetails(
    {required int serviceId, int? customerId, bool fromBooking = false}) async {
  if (fromBooking) {
    toast(language.pleaseWait);
  }
  Map request = {
    CommonKeys.serviceId: serviceId,
    if (appStore.isLoggedIn) CommonKeys.customerId: customerId
  };
  try {
    var res = ServiceDetailResponse.fromJson(await handleResponse(
        await buildHttpResponse('service-detail',
            request: request, method: HttpMethodType.POST)));

    appStore.setLoading(false);
    return res;
  } catch (e) {
    appStore.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

@Deprecated('Do not use this')
Future<ServiceResponse> getSearchListServices({
  String categoryId = '',
  String providerId = '',
  String handymanId = '',
  String isPriceMin = '',
  String isPriceMax = '',
  String search = '',
  String latitude = '',
  String longitude = '',
  String isFeatured = '',
  String subCategory = '',
  int page = 1,
}) async {
  String categoryIds = categoryId.isNotEmpty ? 'category_id=$categoryId&' : '';
  String searchPara = search.isNotEmpty ? 'search=$search&' : '';
  String providerIds = providerId.isNotEmpty ? 'provider_id=$providerId&' : '';
  String isPriceMinPara =
      isPriceMin.isNotEmpty ? 'is_price_min=$isPriceMin&' : '';
  String isPriceMaxPara =
      isPriceMax.isNotEmpty ? 'is_price_max=$isPriceMax&' : '';
  String latitudes = latitude.isNotEmpty ? 'latitude=$latitude&' : '';
  String longitudes = longitude.isNotEmpty ? 'longitude=$longitude&' : '';
  String isFeatures = isFeatured.isNotEmpty ? 'is_featured=$isFeatured&' : '';
  String subCategorys = subCategory.validate().isNotEmpty
      ? subCategory != "-1"
          ? 'subcategory_id=$subCategory&'
          : ''
      : '';
  String pages = 'page=$page&';
  String perPages = 'per_page=$PER_PAGE_ITEM';
  String customerId =
      appStore.isLoggedIn ? 'customer_id=${appStore.userId}&' : '';

  return ServiceResponse.fromJson(await handleResponse(
    await buildHttpResponse(
        'search-list?$categoryIds$customerId$providerIds$isPriceMinPara$isPriceMaxPara$subCategorys$searchPara$latitudes$longitudes$isFeatures$pages$perPages'),
  ));
}

Future<List<ServiceData>> searchServiceAPI({
  String categoryId = '',
  String providerId = '',
  String isPriceMin = '',
  String isPriceMax = '',
  String ratingId = '',
  String search = '',
  String latitude = '',
  String longitude = '',
  String isFeatured = '',
  String subCategory = '',
  int page = 1,
  required List<ServiceData> list,
  Function(bool)? lastPageCallBack,
}) async {
  String categoryIds = categoryId.isNotEmpty ? 'category_id=$categoryId&' : '';
  String searchPara = search.isNotEmpty ? 'search=$search&' : '';
  String providerIds = providerId.isNotEmpty ? 'provider_id=$providerId&' : '';
  String isPriceMinPara =
      isPriceMin.isNotEmpty ? 'is_price_min=$isPriceMin&' : '';
  String isPriceMaxPara =
      isPriceMax.isNotEmpty ? 'is_price_max=$isPriceMax&' : '';
  String ratingPara = ratingId.isNotEmpty ? 'is_rating=$ratingId&' : '';
  String latitudes = latitude.isNotEmpty ? 'latitude=$latitude&' : '';
  String longitudes = longitude.isNotEmpty ? 'longitude=$longitude&' : '';
  String isFeatures = isFeatured.isNotEmpty ? 'is_featured=$isFeatured&' : '';
  String subCategorys = subCategory.validate().isNotEmpty
      ? subCategory != "-1"
          ? 'subcategory_id=$subCategory&'
          : ''
      : '';
  String pages = 'page=$page&';
  String perPages = 'per_page=$PER_PAGE_ITEM';
  String customerId =
      appStore.isLoggedIn ? 'customer_id=${appStore.userId}&' : '';

  try {
    var res = ServiceResponse.fromJson(await handleResponse(
      await buildHttpResponse(
          'search-list?$categoryIds$customerId$providerIds$isPriceMinPara$isPriceMaxPara$ratingPara$subCategorys$searchPara$latitudes$longitudes$isFeatures$pages$perPages'),
    ));

    if (page == 1) list.clear();
    list.addAll(res.serviceList.validate());

    lastPageCallBack?.call(res.serviceList.validate().length != PER_PAGE_ITEM);
    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }

  return list;
}
//endregion

//region Category Api

Future<CategoryResponse> getCategoryList(String page) async {
  return CategoryResponse.fromJson(await handleResponse(await buildHttpResponse(
      'category-list?page=$page&per_page=50',
      method: HttpMethodType.GET)));
}

Future<List<CategoryData>> getCategoryListWithPagination(int page,
    {var perPage = PER_PAGE_CATEGORY_ITEM,
    required List<CategoryData> categoryList,
    Function(bool)? lastPageCallBack}) async {
  try {
    CategoryResponse res = CategoryResponse.fromJson(await handleResponse(
        await buildHttpResponse('category-list?per_page=$perPage&page=$page',
            method: HttpMethodType.GET)));

    if (page == 1) categoryList.clear();
    categoryList.addAll(res.categoryList.validate());

    cachedCategoryList = categoryList;

    lastPageCallBack
        ?.call(res.categoryList.validate().length != PER_PAGE_CATEGORY_ITEM);

    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }

  return categoryList;
}
//endregion

//region SubCategory Api
Future<CategoryResponse> getSubCategoryList({required int catId}) async {
  try {
    CategoryResponse res = CategoryResponse.fromJson(await handleResponse(
        await buildHttpResponse(
            'subcategory-list?category_id=$catId&per_page=all',
            method: HttpMethodType.GET)));
    appStore.setLoading(false);

    return res;
  } catch (e) {
    appStore.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<List<CategoryData>> getSubCategoryListAPI({required int catId}) async {
  try {
    CategoryResponse res = CategoryResponse.fromJson(await handleResponse(
        await buildHttpResponse(
            'subcategory-list?category_id=$catId&per_page=all',
            method: HttpMethodType.GET)));

    appStore.setLoading(false);

    // CategoryData allValue = CategoryData(id: -1, name: language.lblAll);
    // if (!res.categoryList!.any((element) => element.id == allValue.id)) {
    //   res.categoryList!.insert(0, allValue);
    // }

    if (!cachedSubcategoryList.any((element) => element?.$1 == catId)) {
      cachedSubcategoryList.add((catId, res.categoryList.validate()));
    } else {
      int index =
          cachedSubcategoryList.indexWhere((element) => element?.$1 == catId);
      cachedSubcategoryList[index] = (catId, res.categoryList.validate());
    }

    return res.categoryList.validate();
  } catch (e) {
    appStore.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}
//endregion

//region Provider Api
Future<ProviderInfoResponse> getProviderDetail(int id, {int? userId}) async {
  try {
    ProviderInfoResponse res = ProviderInfoResponse.fromJson(
        await handleResponse(await buildHttpResponse(
            'user-detail?id=$id&login_user_id=$userId',
            method: HttpMethodType.GET)));
    appStore.setLoading(false);
    if (!cachedProviderList.any((element) => element?.$1 == id)) {
      cachedProviderList.add((id, res));
    } else {
      int index = cachedProviderList.indexWhere((element) => element?.$1 == id);
      cachedProviderList[index] = (id, res);
    }
    return res;
  } catch (e) {
    appStore.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<ProviderListResponse> getProvider(
    {String? userType = "provider"}) async {
  return ProviderListResponse.fromJson(await handleResponse(
      await buildHttpResponse('user-list?user_type=$userType&per_page=all',
          method: HttpMethodType.GET)));
}
//endregion

//region Handyman Api
Future<UserData> getHandymanDetail(int id) async {
  return UserData.fromJson(await handleResponse(await buildHttpResponse(
      'user-detail?id=$id',
      method: HttpMethodType.GET)));
}

Future<BaseResponseModel> handymanRating(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('save-handyman-rating',
          request: request, method: HttpMethodType.POST)));
}

Future<Either<CouponBaseModel, CouponModel>> applyCoupn({
  required String coupon,
  required int bookingId,
}) async {
  var headers = buildHeaderTokens();

  var request = Request('POST', Uri.parse('${buildBaseUrl('apply-coupon')}'));

  request.body = json.encode({
    "coupon_code": coupon,
    "booking_id": bookingId,
  });

  request.headers.addAll(headers);

  StreamedResponse response = await request.send();

  final data = await Response.fromStream(response);

  if (response.statusCode == 200) {
    // print(await response.stream.bytesToString());
    return Right(CouponModel.fromJson(jsonDecode(data.body)));
  } else {
    // print(response.reasonPhrase);
    return Left(CouponBaseModel.fromJson(jsonDecode(data.body)));
  }

  // print('received data is ${response} and ${response.runtimeType}');
  // try {
  //   final response = await handleResponse(await buildHttpResponse('apply-coupon', request: request, method: HttpMethodType.POST));
  //   var coupon = CouponModel.fromJson(response);
  //   return Right(coupon);
  // } catch (e) {
  //   final response = await handleResponse(await buildHttpResponse('apply-coupon', request: request, method: HttpMethodType.POST));
  //   var error = BaseResponseModel.fromJson(response);
  //   print('Error here is ${e.toString()}');
  //   return Left(error);
  // }
  // return CouponModel.fromJson();
}

Future<BaseResponseModel> contactUs(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('contact-us',
          request: request, method: HttpMethodType.POST)));
}
//endregion

//region Booking Api
Future<List<BookingData>> getBookingList(int page,
    {var perPage = PER_PAGE_ITEM,
    String status = '',
    required List<BookingData> bookings,
    Function(bool)? lastPageCallback}) async {
  try {
    BookingListResponse res;

    if (status == BOOKING_TYPE_ALL) {
      res = BookingListResponse.fromJson(await handleResponse(
          await buildHttpResponse('booking-list?&per_page=$perPage&page=$page',
              method: HttpMethodType.GET)));
    } else {
      res = BookingListResponse.fromJson(await handleResponse(
          await buildHttpResponse(
              'booking-list?status=$status&per_page=$perPage&page=$page',
              method: HttpMethodType.GET)));
    }

    if (page == 1) bookings.clear();
    bookings.addAll(res.data.validate());
    lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

    cachedBookingList = bookings;

    appStore.setLoading(false);

    return bookings;
  } catch (e) {
    appStore.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<BookingDetailResponse> getBookingDetail(
    Map<String, dynamic> request) async {
  try {
    BookingDetailResponse bookingDetailResponse =
        BookingDetailResponse.fromJson(await handleResponse(
            await buildHttpResponse('booking-detail',
                request: request, method: HttpMethodType.POST)));
    bookingDetailResponse.bookingDetail?.couponData =
        bookingDetailResponse.couponData;

    int bookingId = request['booking_id'].toString().toInt();

    if (!cachedBookingDetailList.any((element) => element?.$1 == bookingId)) {
      cachedBookingDetailList.add((bookingId, bookingDetailResponse));
    } else {
      int index = cachedBookingDetailList
          .indexWhere((element) => element?.$1 == bookingId);
      cachedBookingDetailList[index] = (bookingId, bookingDetailResponse);
    }

    appStore.setLoading(false);
    return bookingDetailResponse;
  } catch (e) {
    appStore.setLoading(false);

    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<BaseResponseModel> updateBooking(Map request) async {
  BaseResponseModel baseResponse = BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse('booking-update',
          request: request, method: HttpMethodType.POST)));
  LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_LIST);

  return baseResponse;
}

Future<BookingDetailResponse> saveBooking(Map request) async {
  var res = await handleResponse(await buildHttpResponse('booking-save',
      request: request, method: HttpMethodType.POST));

  return await getBookingDetail({
    CommonKeys.bookingId: res[CommonKeys.bookingId],
    CommonKeys.customerId: appStore.userId,
  });
}

Future<List<BookingStatusResponse>> bookingStatus(
    {required List<BookingStatusResponse> list}) async {
  Iterable res = await (handleResponse(
      await buildHttpResponse('booking-status', method: HttpMethodType.GET)));
  list = res.map((e) => BookingStatusResponse.fromJson(e)).toList();
  cachedBookingStatusDropdown = list;

  return list.validate();
}
//endregion

//region Payment Api
Future<BaseResponseModel> savePayment(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('save-payment',
          request: request, method: HttpMethodType.POST)));
}

Future<List<PaymentData>> getPaymentList(int page, int id,
    List<PaymentData> list, Function(bool)? lastPageCallback) async {
  appStore.setLoading(true);
  var res = PaymentListResponse.fromJson(await handleResponse(
      await buildHttpResponse('payment-list?booking_id=$id',
          method: HttpMethodType.GET)));

  if (page == 1) list.clear();

  list.addAll(res.data.validate());
  appStore.setLoading(false);

  lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);

  return list;
}

//endregion

// Admin notifcation
Future<List<NotificationModel>> getAdminNotification() async {
  var headers = buildHeaderTokens();

  var request = Request(
    'GET',
    buildBaseUrl('push-notification-list'),
  );

  request.headers.addAll(headers);

  StreamedResponse response = await request.send();

  final data = await Response.fromStream(response);

  List<NotificationModel> notifications = [];

  print('Data from admin notificaitons is ${data.body}');

  if (response.statusCode == 200) {
    jsonDecode(data.body).forEach((notification) {
      notifications.add(NotificationModel.fromJson(notification));
    });
    cachedNotificationList = notifications.validate();

    return notifications;
  } else {
    return <NotificationModel>[];
  }
}

//region Notification Api
Future<List<NotificationData>> getNotification({Map? request}) async {
  try {
    NotificationListResponse res = NotificationListResponse.fromJson(
      await (handleResponse(await buildHttpResponse(
          'notification-list?customer_id=${appStore.userId}',
          request: request,
          method: HttpMethodType.POST))),
    );

    appStore.setLoading(false);
    // cachedNotificationList = res.notificationData.validate();
    return res.notificationData.validate();
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}
//endregion

//region Notification Api
Future<CouponListResponse> getCouponList({required int serviceId}) async {
  try {
    CouponListResponse res = CouponListResponse.fromJson(
      await (handleResponse(await buildHttpResponse(
          'coupon-list?service_id=$serviceId',
          method: HttpMethodType.GET))),
    );

    appStore.setLoading(false);
    cachedCouponListResponse = res;
    return res;
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}
//endregion

//region Review Api
Future<BaseResponseModel> updateReview(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('save-booking-rating',
          request: request, method: HttpMethodType.POST)));
}

Future<List<RatingData>> serviceReviews(Map request) async {
  try {
    ServiceReviewResponse res = ServiceReviewResponse.fromJson(
        await handleResponse(await buildHttpResponse(
            'service-reviews?per_page=all',
            request: request,
            method: HttpMethodType.POST)));
    appStore.setLoading(false);
    return res.ratingList.validate();
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<List<RatingData>> customerReviews() async {
  try {
    ServiceReviewResponse res = ServiceReviewResponse.fromJson(
        await handleResponse(await buildHttpResponse(
            'get-user-ratings?per_page=all',
            method: HttpMethodType.GET)));
    appStore.setLoading(false);
    cachedRatingList = res.ratingList;
    return res.ratingList.validate();
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<List<RatingData>> handymanReviews(Map request) async {
  try {
    ServiceReviewResponse res = ServiceReviewResponse.fromJson(
        await handleResponse(await buildHttpResponse(
            'handyman-reviews?per_page=all',
            request: request,
            method: HttpMethodType.POST)));
    appStore.setLoading(false);
    return res.ratingList.validate();
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
}

Future<BaseResponseModel> deleteReview({required int id}) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('delete-booking-rating',
          request: {"id": id}, method: HttpMethodType.POST)));
}

Future<BaseResponseModel> deleteHandymanReview({required int id}) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('delete-handyman-rating',
          request: {"id": id}, method: HttpMethodType.POST)));
}
//endregion

//region WishList Api
Future<List<ServiceData>> getWishlist(int page,
    {var perPage = PER_PAGE_ITEM,
    required List<ServiceData> services,
    Function(bool)? lastPageCallBack}) async {
  try {
    ServiceResponse serviceResponse = ServiceResponse.fromJson(
        await (handleResponse(await buildHttpResponse(
            'user-favourite-service?per_page=$perPage&page=$page',
            method: HttpMethodType.GET))));

    if (page == 1) services.clear();
    services.addAll(serviceResponse.serviceList.validate());

    lastPageCallBack
        ?.call(serviceResponse.serviceList.validate().length != PER_PAGE_ITEM);

    cachedServiceFavList = services;
    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
  return services;
}

Future<BaseResponseModel> addWishList(request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('save-favourite',
          method: HttpMethodType.POST, request: request)));
}

Future<BaseResponseModel> removeWishList(request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('delete-favourite',
          method: HttpMethodType.POST, request: request)));
}

//endregion

//region Provider WishList Api
Future<List<UserData>> getProviderWishlist(int page,
    {var perPage = PER_PAGE_ITEM,
    required List<UserData> providers,
    Function(bool)? lastPageCallBack}) async {
  try {
    ProviderListResponse res = ProviderListResponse.fromJson(
        await (handleResponse(await buildHttpResponse(
            'user-favourite-provider?per_page=$perPage&page=$page',
            method: HttpMethodType.GET))));

    if (page == 1) providers.clear();
    providers.addAll(res.providerList.validate());

    lastPageCallBack?.call(res.providerList.validate().length != PER_PAGE_ITEM);

    cachedProviderFavList = providers;
    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
  return providers;
}

Future<BaseResponseModel> addProviderWishList(request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('save-favourite-provider',
          method: HttpMethodType.POST, request: request)));
}

Future<BaseResponseModel> removeProviderWishList(request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('delete-favourite-provider',
          method: HttpMethodType.POST, request: request)));
}
//endregion

//region Get My Service List API
Future<ServiceResponse> getMyServiceList() async {
  return ServiceResponse.fromJson(await handleResponse(await buildHttpResponse(
      'service-list?customer_id=${appStore.userId.validate()}',
      method: HttpMethodType.GET)));
}
//endregion

//region Get My post job

Future<BaseResponseModel> savePostJob(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('save-post-job',
          request: request, method: HttpMethodType.POST)));
}

Future<BaseResponseModel> deletePostRequest({required num id}) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('post-job-delete/$id',
          request: {}, method: HttpMethodType.POST)));
}

Future<BaseResponseModel> deleteServiceRequest(int id) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('service-delete/$id',
          request: {}, method: HttpMethodType.POST)));
}

Future<List<PostJobData>> getPostJobList(int page,
    {var perPage = PER_PAGE_ITEM,
    required List<PostJobData> postJobList,
    Function(bool)? lastPageCallBack}) async {
  try {
    var res = GetPostJobResponse.fromJson(await handleResponse(
        await buildHttpResponse('get-post-job?per_page=$perPage&page=$page',
            method: HttpMethodType.GET)));

    if (page == 1) postJobList.clear();
    postJobList.addAll(res.myPostJobData.validate());

    lastPageCallBack
        ?.call(res.myPostJobData.validate().length != PER_PAGE_ITEM);
    cachedPostJobList = postJobList;
    appStore.setLoading(false);
  } catch (e) {
    appStore.setLoading(false);
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

    return res;
  } catch (e) {
    appStore.setLoading(false);
    log(e);
    throw errorSomethingWentWrong;
  }
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
          'isSadadPayment': true,
          'sadadToken': sadadToken,
        }),
    avoidTokenError: false,
    isSadadPayment: true,
  );
}
//endregion

// region Send Invoice on Email
Future<InvoiceResponseModel> sentInvoiceOnMail(Map request) async {
  return InvoiceResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('download-invoice',
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

Future<BaseResponseModel> deleteImage(Map request) async {
  return BaseResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('remove-file',
          request: request, method: HttpMethodType.POST)));
}
