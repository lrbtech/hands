import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:geocoding/geocoding.dart';
import 'package:hands_user_app/components/html_widget.dart';
import 'package:hands_user_app/components/new_update_dialog.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/LatLong.dart';
import 'package:hands_user_app/models/remote_config_data_model.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/model_keys.dart';
import 'package:html/parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/configuration_response.dart';
import 'colors.dart';

//region App Default Settings
void defaultSettings() {
  passwordLengthGlobal = 6;
  appButtonBackgroundColorGlobal = primaryColor;
  defaultRadius = 12;
  defaultAppButtonTextColorGlobal = Colors.white;
  defaultElevation = 0;
  defaultBlurRadius = 0;
  defaultSpreadRadius = 0;
  defaultAppButtonRadius = defaultRadius;
  defaultAppButtonElevation = 0;
  textBoldSizeGlobal = 14;
  textPrimarySizeGlobal = 14;
  textSecondarySizeGlobal = 12;
}
//endregion

//region Set User Values when user is logged In
Future<void> setLoginValues() async {
  if (appStorePro.isLoggedIn) {
    await appStorePro.setUserId(getIntAsync(USER_ID), isInitializing: true);
    await appStorePro.setCategoryId(getIntAsync(CATEGORY_ID),
        isInitializing: true);
    await appStorePro.setFirstName(getStringAsync(FIRST_NAME),
        isInitializing: true);
    await appStorePro.setLastName(getStringAsync(LAST_NAME),
        isInitializing: true);
    await appStorePro.setUserEmail(getStringAsync(USER_EMAIL),
        isInitializing: true);
    await appStorePro.setUserName(getStringAsync(USERNAME),
        isInitializing: true);
    await appStorePro.setContactNumber(getStringAsync(CONTACT_NUMBER),
        isInitializing: true);
    await appStorePro.setUserProfile(getStringAsync(PROFILE_IMAGE),
        isInitializing: true);
    await appStorePro.setCountryId(getIntAsync(COUNTRY_ID),
        isInitializing: true);
    await appStorePro.setStateId(getIntAsync(STATE_ID), isInitializing: true);
    await appStorePro.set24HourFormat(getBoolAsync(HOUR_FORMAT_STATUS),
        isInitializing: true);
    await appStorePro.setUId(getStringAsync(UID), isInitializing: true);
    await appStorePro.setCityId(getIntAsync(CITY_ID), isInitializing: true);
    await appStorePro.setUserType(getStringAsync(USER_TYPE),
        isInitializing: true);
    await appStorePro.setServiceAddressId(getIntAsync(SERVICE_ADDRESS_ID),
        isInitializing: true);
    await appStorePro.setProviderId(getIntAsync(PROVIDER_ID),
        isInitializing: true);

    await appStorePro.setCurrencyCode(getStringAsync(CURRENCY_COUNTRY_CODE),
        isInitializing: true);
    await appStorePro.setCurrencyCountryId(getStringAsync(CURRENCY_COUNTRY_ID),
        isInitializing: true);
    await appStorePro.setCurrencySymbol(getStringAsync(CURRENCY_COUNTRY_SYMBOL),
        isInitializing: true);
    await appStorePro.setCreatedAt(getStringAsync(CREATED_AT),
        isInitializing: true);
    await appStorePro.setTotalBooking(getIntAsync(TOTAL_BOOKING),
        isInitializing: true);
    await appStorePro.setCompletedBooking(getIntAsync(COMPLETED_BOOKING),
        isInitializing: true);

    await appStorePro.setToken(getStringAsync(TOKEN), isInitializing: true);

    await appStorePro.setTester(getBoolAsync(IS_TESTER), isInitializing: true);
    await appStorePro.setPrivacyPolicy(getStringAsync(PRIVACY_POLICY),
        isInitializing: true);
    await appStorePro.setTermConditions(getStringAsync(TERM_CONDITIONS),
        isInitializing: true);
    await appStorePro.setInquiryEmail(getStringAsync(INQUIRY_EMAIL),
        isInitializing: true);
    await appStorePro.setHelplineNumber(getStringAsync(HELPLINE_NUMBER),
        isInitializing: true);
    await appStorePro.setCategoryBasedPackageService(
        getBoolAsync(CATEGORY_BASED_SELECT_PACKAGE_SERVICE),
        isInitializing: true);
    await appStorePro.setPlayerId(getStringAsync(PLAYERID),
        isInitializing: true);

    await setSaveSubscription();

    await appStorePro.setDesignation(getStringAsync(DESIGNATION),
        isInitializing: true);
  }
}

Future<void> setSaveSubscription(
    {int? isSubscribe,
    String? title,
    String? identifier,
    String? endAt}) async {
  await appStorePro.setPlanTitle(title ?? getStringAsync(PLAN_TITLE),
      isInitializing: title == null);
  await appStorePro.setIdentifier(identifier ?? getStringAsync(PLAN_IDENTIFIER),
      isInitializing: identifier == null);
  await appStorePro.setPlanEndDate(endAt ?? getStringAsync(PLAN_END_DATE),
      isInitializing: endAt == null);
  await appStorePro.setPlanSubscribeStatus(isSubscribe.validate() == 1,
      isInitializing: isSubscribe == null);
}

//endregion

int getRemainingPlanDays() {
  if (appStorePro.planEndDate.isNotEmpty) {
    var now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    DateTime endAt = DateFormat(DATE_FORMAT_7).parse(appStorePro.planEndDate);

    return (date.difference(endAt).inDays).abs();
  } else {
    return 0;
  }
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(
        id: 1,
        name: 'English',
        languageCode: 'en',
        fullLanguageCode: 'en-US',
        flag: 'assets/flag/ic_us.png'),
    // LanguageDataModel(id: 2, name: 'Hindi', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(
        id: 3,
        name: 'Arabic',
        languageCode: 'ar',
        fullLanguageCode: 'ar-AR',
        flag: 'assets/flag/ic_ar.png'),
    // LanguageDataModel(id: 4, name: 'French', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/flag/ic_fr.png'),
    // LanguageDataModel(id: 5, name: 'German', languageCode: 'de', fullLanguageCode: 'de-DE', flag: 'assets/flag/ic_de.png'),
  ];

  /*if (getStringAsync(SERVER_LANGUAGES).isNotEmpty) {
    Iterable it = jsonDecode(getStringAsync(SERVER_LANGUAGES));
    var res = it.map((e) => LanguageOption.fromJson(e)).toList();

    localeLanguageList.clear();

    res.forEach((element) {
      localeLanguageList.add(LanguageDataModel(languageCode: element.id.validate().toString(), flag: element.flagImage, name: element.title));
    });

    return localeLanguageList;
  } else {
    return [
      LanguageDataModel(id: 1, name: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/flag/ic_us.png'),
      LanguageDataModel(id: 2, name: 'Hindi', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
      LanguageDataModel(id: 3, name: 'Arabic', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/flag/ic_ar.png'),
      LanguageDataModel(id: 4, name: 'French', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/flag/ic_fr.png'),
      LanguageDataModel(id: 5, name: 'German', languageCode: 'de', fullLanguageCode: 'de-DE', flag: 'assets/flag/ic_de.png'),
    ];
  }*/
}

InputDecoration inputDecoration(BuildContext context,
    {Widget? prefixIcon,
    Widget? prefix,
    String? hint,
    Color? fillColor,
    String? counterText,
    double? borderRadius}) {
  return InputDecoration(
    contentPadding: EdgeInsets.only(left: 12, bottom: 10, top: 10, right: 10),
    labelText: hint,
    labelStyle: secondaryTextStyle(),
    alignLabelWithHint: true,
    counterText: counterText,
    prefixIcon: prefixIcon,
    prefix: prefix,
    enabledBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.red, width: 0.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
    errorMaxLines: 2,
    border: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    ),
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: primaryColor, width: 0.0),
    ),
    filled: true,
    fillColor: fillColor ?? context.cardColor,
  );
}

void setCurrencies(
    {required List<Configurations>? value,
    List<PaymentSetting>? paymentSetting}) {
  if (value != null && value.validate().isNotEmpty) {
    Configurations data =
        value.firstWhere((element) => element.type == "CURRENCY");

    if (data.country != null) {
      if (data.country!.currencyCode.validate() != appStorePro.currencyCode)
        appStorePro.setCurrencyCode(data.country!.currencyCode.validate());
      if (data.country!.id.toString().validate() !=
          appStorePro.countryId.toString())
        appStorePro
            .setCurrencyCountryId(data.country!.id.toString().validate());
      if (data.country!.symbol.validate() != appStorePro.currencySymbol)
        appStorePro.setCurrencySymbol(data.country!.symbol.validate());
    }
    if (paymentSetting != null) {
      setValue(PAYMENT_LIST, PaymentSetting.encode(paymentSetting.validate()));
    }
  }
}

Future<void> setConfigData(SiteConfig configData) async {
  setValue(PRICE_DECIMAL_POINTS,
      configData.digitafterDecimalPoint.validate().toInt());
  setValue(DATE_FORMAT, getDateFormat(configData.dateFormat.validate()));
  setValue(TIME_FORMAT, getDisplayTimeFormat(configData.timeFormat.validate()));
}

Future<void> serviceConfig(ServiceConfig serviceConfig) async {
  setValue(
      SLOT_SERVICE_ENABLE, serviceConfig.slotService.validate().getBoolInt());
  setValue(
      SERVICE_PKG_ENABLE, serviceConfig.servicePkg.validate().getBoolInt());
  setValue(SERVICE_ADD_ON_ENABLE,
      serviceConfig.serviceAddOn.validate().getBoolInt());
  setValue(REMOTE_SERVICE_ENABLE,
      serviceConfig.onlineService.validate().getBoolInt());
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

String formatDate(String? dateTime,
    {String format = DATE_FORMAT_1,
    bool isFromMicrosecondsSinceEpoch = false,
    bool isLanguageNeeded = true,
    bool isTime = false,
    bool showDateWithTime = false}) {
  final parsedDateTime = isFromMicrosecondsSinceEpoch
      ? DateTime.fromMicrosecondsSinceEpoch(dateTime.validate().toInt() * 1000)
      : DateTime.parse(dateTime.validate());
  if (isTime) {
    return DateFormat('${getStringAsync(TIME_FORMAT)}',
            isLanguageNeeded ? appStorePro.selectedLanguageCode : null)
        .format(parsedDateTime);
  } else {
    if (getStringAsync(DATE_FORMAT).validate().contains('dS')) {
      int day = parsedDateTime.day;
      if (DateFormat('${getStringAsync(DATE_FORMAT)}',
              isLanguageNeeded ? appStorePro.selectedLanguageCode : null)
          .format(parsedDateTime)
          .contains('$day')) {
        return DateFormat(
                '${getStringAsync(DATE_FORMAT).validate().replaceAll('S', '')} ${showDateWithTime ? getStringAsync(TIME_FORMAT) : ''}',
                isLanguageNeeded ? appStorePro.selectedLanguageCode : null)
            .format(parsedDateTime)
            .replaceFirst('$day', '${addOrdinalSuffix(day)}');
      }
    }
    return DateFormat(
            '${getStringAsync(DATE_FORMAT).validate()} ${showDateWithTime ? getStringAsync(TIME_FORMAT) : ''}',
            isLanguageNeeded ? appStorePro.selectedLanguageCode : null)
        .format(parsedDateTime);
  }
}

String getTime(String? time,
    {String format = DISPLAY_TIME_FORMAT,
    bool isFromMicrosecondsSinceEpoch = false,
    bool isLanguageNeeded = true}) {
  final parsedTime = isFromMicrosecondsSinceEpoch
      ? DateTime.fromMicrosecondsSinceEpoch(time!.validate().toInt() * 1000)
      : DateTime.parse(time.validate());
  return DateFormat(getStringAsync(TIME_FORMAT),
          isLanguageNeeded ? appStorePro.selectedLanguageCode : null)
      .format(parsedTime);
}

String getSlotWithDate({required String date, required String slotTime}) {
  DateTime originalDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
  DateTime newTime = DateFormat('HH:mm:ss').parse(slotTime);
  DateTime newDateTime = DateTime(originalDateTime.year, originalDateTime.month,
      originalDateTime.day, newTime.hour, newTime.minute, newTime.second);
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(newDateTime);
}

String getDateFormat(String phpFormat) {
  final formatMapping = {
    'Y': 'yyyy',
    'm': 'MM',
    'd': 'dd',
    'j': 'd',
    'S': 'S',
    'M': 'MMM',
    'F': 'MMMM',
    'l': 'EEEE',
    'D': 'EEE',
    'H': 'HH',
    'i': 'mm',
    's': 'ss',
    'A': 'a',
    'T': 'z',
    'v': 'S',
    'U': 'y-MM-ddTHH:mm:ssZ',
    'u': 'y-MM-ddTHH:mm:ss.SSSZ',
    'G': 'H',
    'B': 'EEE, d MMM y HH:mm:ss Z',
  };

  String dartFormat = phpFormat.replaceAllMapped(
    RegExp('[YmjdSFMlDHisaTvGuB]'),
    (match) => formatMapping[match.group(0)] ?? match.group(0).validate(),
  );

  dartFormat = dartFormat.replaceAllMapped(
    RegExp(r"\\(.)"),
    (match) => match.group(1) ?? '',
  );

  return dartFormat;
}

String addOrdinalSuffix(int day) {
  if (day >= 11 && day <= 13) {
    return '${day}th';
  }
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

String getDisplayTimeFormat(String phpFormat) {
  switch (phpFormat) {
    case 'H:i':
      return 'HH:mm';
    case 'H:i:s':
      return 'HH:mm:ss';
    case 'g:i A':
      return 'h:mm a';
    case 'H:i:s T':
      return 'HH:mm:ss z';
    case 'H:i:s.v':
      return 'HH:mm:ss.S';
    case 'U':
      return 'HH:mm:ssZ';
    case 'u':
      return 'HH:mm:ss.SSSZ';
    case 'G.i':
      return 'H.mm';
    case '@BMT':
      return 'HH:mm:ss Z';
    default:
      return DISPLAY_TIME_FORMAT; // Return the same format if not found in the mapping
  }
}

bool containsTime(String dateString) {
  RegExp timeRegex = RegExp(r'\b\d{1,2}:\d{1,2}(:\d{1,2})?\b');

  return timeRegex.hasMatch(dateString);
}

Future<LatLng> getLatLongFromAddress({required String address}) async {
  List<Location> locations = await locationFromAddress(address).catchError((e) {
    throw e.toString();
  });
  return LatLng(
      latitude: locations.first.latitude.validate(),
      longitude: locations.first.longitude.validate());
}

Future<void> commonLaunchUrl(String url,
    {LaunchMode launchMode = LaunchMode.inAppWebView}) async {
  await launchUrl(Uri.parse(url), mode: launchMode).catchError((e) {
    toast('Invalid URL: $url');
    throw e;
  });
}

void launchCall(String? url) {
  if (url.validate().isNotEmpty) {
    if (isIOS)
      commonLaunchUrl('tel://' + url!,
          launchMode: LaunchMode.externalApplication);
    else
      commonLaunchUrl('tel:' + url!,
          launchMode: LaunchMode.externalApplication);
  }
}

void launchMail(String? url) {
  if (url.validate().isNotEmpty) {
    commonLaunchUrl('mailto:' + url!,
        launchMode: LaunchMode.externalApplication);
  }
}

void launchMap(String? url) {
  if (url.validate().isNotEmpty) {
    commonLaunchUrl(GOOGLE_MAP_PREFIX + url!,
        launchMode: LaunchMode.externalApplication);
  }
}

calculateLatLong(String address) async {
  try {
    List<Location> destinationPlaceMark = await locationFromAddress(address);
    double? destinationLatitude = destinationPlaceMark[0].latitude;
    double? destinationLongitude = destinationPlaceMark[0].longitude;
    List<double?> destinationCoordinatesString = [
      destinationLatitude,
      destinationLongitude
    ];
    return destinationCoordinatesString;
  } catch (e) {
    throw errorSomethingWentWrong;
  }
}

bool get isRTL => RTL_LANGUAGES.contains(appStorePro.selectedLanguageCode);

bool get isCurrencyPositionLeft =>
    getStringAsync(CURRENCY_POSITION, defaultValue: CURRENCY_POSITION_LEFT) ==
    CURRENCY_POSITION_LEFT;

bool get isCurrencyPositionRight =>
    getStringAsync(CURRENCY_POSITION, defaultValue: CURRENCY_POSITION_LEFT) ==
    CURRENCY_POSITION_RIGHT;

String calculateExperience() {
  int exp = 0;

  return exp.toString();
}

bool isCommissionTypePercent(String? type) =>
    type.validate() == COMMISSION_TYPE_PERCENT;

bool get isUserTypeHandyman => appStorePro.userType == USER_TYPE_HANDYMAN;

bool get isUserTypeProvider => appStorePro.userType == USER_TYPE_PROVIDER;

void launchUrlCustomTab(String? url) {
  if (url.validate().isNotEmpty) {
    custom_tabs.launch(
      url!,
      customTabsOption: custom_tabs.CustomTabsOption(
        enableDefaultShare: true,
        enableInstantApps: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        toolbarColor: primaryColor,
      ),
    );
  }
}

// Logic For Calculate Time
String calculateTimer(int secTime) {
  //int hour = 0, minute = 0, seconds = 0;
  int hour = 0, minute = 0;

  hour = secTime ~/ 3600;

  minute = ((secTime - hour * 3600)) ~/ 60;

  //seconds = secTime - (hour * 3600) - (minute * 60);

  String hourLeft =
      hour.toString().length < 2 ? "0" + hour.toString() : hour.toString();

  String minuteLeft = minute.toString().length < 2
      ? "0" + minute.toString()
      : minute.toString();

  String minutes = minuteLeft == '00' ? '01' : minuteLeft;

  String result = "$hourLeft:$minutes";

  return result;
}

Widget subSubscriptionPlanWidget(
    {Color? planBgColor,
    String? planTitle,
    String? planSubtitle,
    String? planButtonTxt,
    Function? onTap,
    Color? btnColor}) {
  return Container(
    color: planBgColor,
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(planTitle.validate(), style: boldTextStyle()),
            8.height,
            Text(planSubtitle.validate(), style: secondaryTextStyle()),
          ],
        ).flexible(),
        8.width,
        AppButton(
          child: Text(planButtonTxt.validate(),
              style: boldTextStyle(color: white)),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: btnColor,
          elevation: 0,
          onTap: () {
            onTap?.call();
          },
        ),
      ],
    ),
  );
}

Brightness getStatusBrightness({required bool val}) {
  return val ? Brightness.light : Brightness.dark;
}

String getPaymentStatusText(String? status, String? method) {
  if (status!.isEmpty) {
    return languages.pending;
  } else if (status == PAID || status == PENDING_BY_ADMINS) {
    return languages.paid;
  } else if (status == PAYMENT_STATUS_ADVANCE) {
    return languages.advancePaid;
  } else if (status == PENDING && method == PAYMENT_METHOD_COD) {
    return languages.pendingApproval;
  } else if (status == PENDING) {
    return languages.pending;
  } else {
    return "";
  }
}

String getReasonText(BuildContext context, String val) {
  if (val == BookingStatusKeys.cancelled) {
    return languages.lblReasonCancelling;
  } else if (val == BookingStatusKeys.rejected) {
    return languages.lblReasonRejecting;
  } else if (val == BookingStatusKeys.failed) {
    return languages.lblFailed;
  }
  return '';
}

Future<bool> get isIqonicProduct async =>
    await getPackageName() == APP_PACKAGE_NAME;

void checkIfLink(BuildContext context, String value, {String? title}) {
  String temp = parseHtmlString(value.validate());
  if (value.validate().isEmpty) return;

  if (temp.startsWith("https") || temp.startsWith("http")) {
    launchUrlCustomTab(temp.validate());
  } else if (temp.validateEmail()) {
    launchMail(temp);
  } else if (temp.validatePhone() || temp.startsWith('+')) {
    launchCall(temp);
  } else {
    HtmlWidget(postContent: value, title: title).launch(context);
  }
}

String buildPaymentStatusWithMethod(String status, String method) {
  return '${getPaymentStatusText(status, method)}${(status == BOOKING_STATUS_PAID || status == PENDING_BY_ADMINS) ? ' ${languages.by} ${languages.bankCards}' : ''}';
  // return '${getPaymentStatusText(status, method)}${(status == BOOKING_STATUS_PAID || status == PENDING_BY_ADMINS) ? ' ${languages.by} $method' : ''}';
}

Color getRatingBarColor(int rating) {
  if (rating == 1 || rating == 2) {
    return ratingBarColor;
  } else if (rating == 3) {
    return Color(0xFFff6200);
  } else if (rating == 4 || rating == 5) {
    return Color(0xFF73CB92);
  } else {
    return ratingBarColor;
  }
}

String formatBookingDate(String? dateTime,
    {String format = DATE_FORMAT_1,
    bool isFromMicrosecondsSinceEpoch = false,
    bool isLanguageNeeded = true}) {
  if (isFromMicrosecondsSinceEpoch) {
    return DateFormat(
            format, isLanguageNeeded ? appStorePro.selectedLanguageCode : null)
        .format(DateTime.fromMicrosecondsSinceEpoch(
            dateTime.validate().toInt() * 1000));
  } else {
    return DateFormat(
            format, isLanguageNeeded ? appStorePro.selectedLanguageCode : null)
        .format(DateTime.parse(dateTime.validate()));
  }
}

Future<FirebaseRemoteConfig> setupFirebaseRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration.zero, minimumFetchInterval: Duration.zero));
  await remoteConfig.fetch();
  await remoteConfig.fetchAndActivate();

  if (remoteConfig.getString(PROVIDER_CHANGE_LOG).validate().isNotEmpty) {
    remoteConfigDataModels = RemoteConfigDataModels.fromJson(
        jsonDecode(remoteConfig.getString(PROVIDER_CHANGE_LOG)));

    setValue(PROVIDER_CHANGE_LOG, remoteConfig.getString(PROVIDER_CHANGE_LOG));

    if (isIOS) {
      await setValue(
          HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_APP_STORE_REVIEW));
    } else if (isAndroid) {
      await setValue(
          HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_PLAY_STORE_REVIEW));
    }
  }

  return remoteConfig;
}

void ifNotTester(BuildContext context, VoidCallback callback) {
  if (!appStorePro.isTester) {
    callback.call();
  } else {
    toast(languages.lblUnAuthorized);
  }
}

void forceUpdate(BuildContext context,
    {required int currentAppVersionCode}) async {
  showInDialog(
    context,
    contentPadding: EdgeInsets.zero,
    barrierDismissible: currentAppVersionCode >=
        getIntAsync(PROVIDER_APP_MINIMUM_VERSION).toInt(),
    builder: (_) {
      return WillPopScope(
        onWillPop: () {
          return Future(() =>
              currentAppVersionCode >=
              getIntAsync(PROVIDER_APP_MINIMUM_VERSION).toInt());
        },
        child: NewUpdateDialog(
            canClose: currentAppVersionCode >=
                getIntAsync(PROVIDER_APP_MINIMUM_VERSION).toInt()),
      );
    },
  );
}

Future<void> showForceUpdateDialog(BuildContext context) async {
  if (getBoolAsync(UPDATE_NOTIFY, defaultValue: true)) {
    getPackageInfo().then((value) {
      if (isAndroid &&
          getIntAsync(PROVIDER_APP_LATEST_VERSION).toInt() >
              value.versionCode.validate().toInt()) {
        forceUpdate(context,
            currentAppVersionCode: value.versionCode.validate().toInt());
      } else if (isIOS &&
          getIntAsync(PROVIDER_APP_LATEST_VERSION).toInt() >
              value.versionCode.validate().toInt()) {
        forceUpdate(context,
            currentAppVersionCode: value.versionCode.validate().toInt());
      }
    });
  }
}

Widget mobileNumberInfoWidget(BuildContext context) {
  return RichTextWidget(
    list: [
      TextSpan(
          text: '${languages.lblAddYourCountryCode}',
          style: secondaryTextStyle()),
      TextSpan(text: ' "91-", "236-" ', style: boldTextStyle(size: 12)),
      TextSpan(
        text: ' (${languages.lblHelp})',
        style: boldTextStyle(size: 12, color: primaryColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrlCustomTab("https://countrycode.org/");
          },
      ),
    ],
  );
}

Future<List<File>> getMultipleImageSource({bool isCamera = true}) async {
  final pickedImage = await ImagePicker().pickMultiImage();
  return pickedImage.map((e) => File(e.path)).toList();
}

Future<File> getCameraImage({bool isCamera = true}) async {
  final pickedImage = await ImagePicker()
      .pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
  return File(pickedImage!.path);
}

String getDateInString({required DateTimeRange dateTime, String? format}) {
  if (dateTime.start.isToday)
    return languages.today;
  else if (dateTime.start.isTomorrow)
    return languages.tomorrow;
  else if (dateTime.start.isYesterday)
    return languages.yesterday;
  else {
    return "${formatDate(dateTime.start.toString(), format: format.validate())} - ${formatDate(dateTime.end.toString(), format: format.validate())}'s";
  }
}

String convertToHourMinute(String timeStr) {
  if (timeStr.isEmpty) {
    return ''; // Handle empty time string
  }

  // Normalize time string to always have two digits for hours
  List<String> parts = timeStr.split(':');
  int hours = int.parse(parts[0]) % 24; // Ensure hours are within 24 hours
  int minutes = int.parse(parts[1]);

  // Construct the resulting string
  String result = '';
  if (hours > 0) {
    result += '${hours}h';
  }
  if (minutes > 0) {
    result = (result.validate().isNotEmpty)
        ? '$result $minutes ${languages.min}'
        : '$minutes ${languages.min}';
  }
  return result;
}

Future<bool> compareValuesInSharedPreference(String key, dynamic value) async {
  bool status = false;
  if (value is String) {
    status = getStringAsync(key) == value;
  } else if (value is bool) {
    status = getBoolAsync(key) == value;
  } else if (value is int) {
    status = getIntAsync(key) == value;
  } else if (value is double) {
    status = getDoubleAsync(key) == value;
  }

  if (!status) {
    await setValue(key, value);
  }
  return status;
}

ThemeMode get appThemeMode =>
    appStorePro.isDarkMode ? ThemeMode.dark : ThemeMode.light;

String getDateFromString(String data) {
  String date = '';

  DateTime? tryParseDate = DateTime.tryParse(data);

  if (tryParseDate != null) {
    date = '${tryParseDate.day} / ${tryParseDate.month} / ${tryParseDate.year}';
  }

  return date;
}

// String getTimeFromString(String data) {
//   DateTime? tryParseDate = DateTime.tryParse(data);
//   String time = '';
//   String amOrPM = '';
//
//   if (tryParseDate != null) {
//     time = data.split(' ').last;
//
//     // AM or PM
//     amOrPM = tryParseDate.hour < 12 ? "AM" : "PM";
//
//     time = time.substring(0, time.lastIndexOf(':'));
//
//     if (time == '00:00') {
//       time = '12:00';
//     }
//   }
//
//   return '$time $amOrPM';
// }
