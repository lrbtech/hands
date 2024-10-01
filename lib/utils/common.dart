import 'dart:convert';
import 'dart:io';

import 'package:hands_user_app/component/app_common_dialog.dart';
import 'package:hands_user_app/component/html_widget.dart';
import 'package:hands_user_app/component/location_service_dialog.dart';
import 'package:hands_user_app/component/new_update_dialog.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/dashboard_model.dart';
import 'package:hands_user_app/model/remote_config_data_model.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/auth/sign_in_screen.dart';
import 'package:hands_user_app/services/location_service.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/permissions.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:html/parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/configuration_response.dart';
import 'constant.dart';

Future<bool> get isIqonicProduct async =>
    await getPackageName() == appPackageName;

bool get isUserTypeHandyman => appStore.userType == USER_TYPE_HANDYMAN;

bool get isUserTypeProvider => appStore.userType == USER_TYPE_PROVIDER;

bool get isUserTypeUser => appStore.userType == USER_TYPE_USER;

bool get isLoginTypeUser => appStore.loginType == LOGIN_TYPE_USER;

bool get isLoginTypeGoogle => appStore.loginType == LOGIN_TYPE_GOOGLE;

bool get isLoginTypeApple => appStore.loginType == LOGIN_TYPE_APPLE;

bool get isLoginTypeOTP => appStore.loginType == LOGIN_TYPE_OTP;

ThemeMode get appThemeMode =>
    appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light;

bool get isCurrencyPositionLeft =>
    getStringAsync(CURRENCY_POSITION, defaultValue: CURRENCY_POSITION_LEFT) ==
    CURRENCY_POSITION_LEFT;

bool get isCurrencyPositionRight =>
    getStringAsync(CURRENCY_POSITION, defaultValue: CURRENCY_POSITION_LEFT) ==
    CURRENCY_POSITION_RIGHT;

bool get isRTL => RTL_LanguageS.contains(appStore.selectedLanguageCode);

Future<void> commonLaunchUrl(String address,
    {LaunchMode launchMode = LaunchMode.inAppWebView}) async {
  await launchUrl(Uri.parse(address), mode: launchMode).catchError((e) {
    toast('${language.invalidURL}: $address');
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

void launchMap(String? url) {
  if (url.validate().isNotEmpty) {
    commonLaunchUrl(GOOGLE_MAP_PREFIX + url!,
        launchMode: LaunchMode.externalApplication);
  }
}

void launchMail(String url) {
  if (url.validate().isNotEmpty) {
    commonLaunchUrl('$MAIL_TO$url', launchMode: LaunchMode.externalApplication);
  }
}

void checkIfLink(BuildContext context, String value, {String? title}) {
  if (value.validate().isEmpty) return;

  String temp = parseHtmlString(value.validate());
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
      safariVCOption: custom_tabs.SafariViewControllerOption(
        preferredBarTintColor: primaryColor,
        preferredControlTintColor: Colors.white,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: true,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
      ),
    );
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
}

InputDecoration inputDecoration(BuildContext context,
    {Widget? prefixIcon, String? labelText, double? borderRadius}) {
  return InputDecoration(
    contentPadding: EdgeInsets.only(left: 12, bottom: 10, top: 10, right: 10),
    labelText: labelText,
    labelStyle: secondaryTextStyle(),
    alignLabelWithHint: true,
    prefixIcon: prefixIcon,
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
    fillColor: context.cardColor,
  );
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

String formatDate(String? dateTime,
    {bool isFromMicrosecondsSinceEpoch = false,
    bool isLanguageNeeded = true,
    bool isTime = false,
    bool showDateWithTime = false}) {
  final languageCode = isLanguageNeeded ? appStore.selectedLanguageCode : null;
  final parsedDateTime = isFromMicrosecondsSinceEpoch
      ? DateTime.fromMicrosecondsSinceEpoch(dateTime.validate().toInt() * 1000)
      : DateTime.parse(dateTime.validate());
  if (isTime) {
    return DateFormat('${getStringAsync(TIME_FORMAT)}', languageCode)
        .format(parsedDateTime);
  } else {
    if (getStringAsync(DATE_FORMAT).validate().contains('dS')) {
      int day = parsedDateTime.day;
      if (DateFormat('${getStringAsync(DATE_FORMAT)}', languageCode)
          .format(parsedDateTime)
          .contains('$day')) {
        return DateFormat(
                '${getStringAsync(DATE_FORMAT).replaceAll('S', '')} ${showDateWithTime ? getStringAsync(TIME_FORMAT) : ''}',
                languageCode)
            .format(parsedDateTime)
            .replaceFirst('$day', '${addOrdinalSuffix(day)}');
      }
    }
    return DateFormat(
            '${getStringAsync(DATE_FORMAT)} ${showDateWithTime ? getStringAsync(TIME_FORMAT) : ''}',
            languageCode)
        .format(parsedDateTime);
  }
}

String formatBookingDate(String? dateTime,
    {String format = DATE_FORMAT_1,
    bool isFromMicrosecondsSinceEpoch = false,
    bool isLanguageNeeded = false,
    bool isTime = false,
    bool showDateWithTime = false}) {
  final languageCode = isLanguageNeeded ? appStore.selectedLanguageCode : null;
  final parsedDateTime = isFromMicrosecondsSinceEpoch
      ? DateTime.fromMicrosecondsSinceEpoch(dateTime.validate().toInt() * 1000)
      : DateTime.parse(dateTime.validate());

  return DateFormat(format, 'en').format(parsedDateTime);
}

String getSlotWithDate({required String date, required String slotTime}) {
  DateTime originalDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
  DateTime newTime = DateFormat('HH:mm:ss').parse(slotTime);
  DateTime newDateTime = DateTime(originalDateTime.year, originalDateTime.month,
      originalDateTime.day, newTime.hour, newTime.minute, newTime.second);
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(newDateTime);
}

String extractTime(String inputString) {
  RegExp timePattern =
      RegExp(r'(\d{1,2}):(\d{2})\s*(?:AM|PM)?', // Matches 12-hour format time
          caseSensitive: false);
  RegExpMatch? match = timePattern.firstMatch(inputString);
  if (match != null) {
    return match.group(0).validate(); // Returns the first matched time
  }
  return ''; // Return null if no time found
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

Future<bool> addToWishList({required int serviceId}) async {
  Map req = {"id": "", "service_id": serviceId, "user_id": appStore.userId};
  return await addWishList(req).then((res) {
    toast(language.serviceAddedToFavourite);
    return true;
  }).catchError((error) {
    toast(error.toString());
    return false;
  });
}

Future<bool> removeToWishList({required int serviceId}) async {
  Map req = {"user_id": appStore.userId, 'service_id': serviceId};

  return await removeWishList(req).then((res) {
    toast(language.serviceRemovedFromFavourite);
    return true;
  }).catchError((error) {
    toast(error.toString());
    return false;
  });
}

void locationWiseService(BuildContext context, VoidCallback onTap) async {
  Permissions.cameraFilesAndLocationPermissionsGranted().then((value) async {
    await setValue(PERMISSION_STATUS, value);

    if (value) {
      bool? res = await showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        builder: (p0) {
          return AppCommonDialog(
            title: language.lblAlert,
            child: LocationServiceDialog(),
          );
        },
      );

      if (res ?? false) {
        appStore.setLoading(true);

        await setValue(PERMISSION_STATUS, value);
        await getUserLocation().then((value) async {
          await appStore.setCurrentLocation(!appStore.isCurrentLocation);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        });

        onTap.call();
      }
    }
  }).catchError((e) {
    toast(e.toString(), print: true);
  });
}

// Logic For Calculate Time
String calculateTimer(int secTime) {
  int hour = 0, minute = 0, seconds = 0;

  hour = secTime ~/ 3600;

  minute = ((secTime - hour * 3600)) ~/ 60;

  seconds = secTime - (hour * 3600) - (minute * 60);

  String hourLeft =
      hour.toString().length < 2 ? "0" + hour.toString() : hour.toString();

  String minuteLeft = minute.toString().length < 2
      ? "0" + minute.toString()
      : minute.toString();

  String minutes = minuteLeft == '00' ? '01' : minuteLeft;

  String result = "$hourLeft:$minutes";

  log(seconds);

  return result;
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
        ? '$result $minutes ${language.min}'
        : '$minutes ${language.min}';
  }
  return result;
}

String getPaymentStatusText(String? status, String? method) {
  if (status!.isEmpty) {
    return language.lblPending;
  } else if (status == SERVICE_PAYMENT_STATUS_PAID ||
      status == PENDING_BY_ADMIN) {
    return language.paid;
  } else if (status == SERVICE_PAYMENT_STATUS_ADVANCE_PAID) {
    return language.advancePaid;
  } else if (status == SERVICE_PAYMENT_STATUS_PENDING &&
      method == PAYMENT_METHOD_COD) {
    return language.pendingApproval;
  } else if (status == SERVICE_PAYMENT_STATUS_PENDING) {
    return language.lblPending;
  } else {
    return "";
  }
}

String buildPaymentStatusWithMethod(String status, String method) {
  return '${getPaymentStatusText(status, method)}${(status == SERVICE_PAYMENT_STATUS_PAID || status == PENDING_BY_ADMIN) ? ' ${language.by} ${method.capitalizeFirstLetter()}' : ''}';
}

Color getRatingBarColor(int rating, {bool showRedForZeroRating = false}) {
  if (rating == 1 || rating == 2) {
    return showRedForZeroRating ? showRedForZeroRatingColor : ratingBarColor;
  } else if (rating == 3) {
    return Color(0xFFff6200);
  } else if (rating == 4 || rating == 5) {
    return Color(0xFF73CB92);
  } else {
    return showRedForZeroRating ? showRedForZeroRatingColor : ratingBarColor;
  }
}

Future<FirebaseRemoteConfig> setupFirebaseRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  try {
    remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: Duration.zero, minimumFetchInterval: Duration.zero));
    await remoteConfig.fetch();
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    // throw language.firebaseRemoteCannotBe;
  }
  if (remoteConfig.getString(USER_CHANGE_LOG).isNotEmpty)
    await compareValuesInSharedPreference(
        USER_CHANGE_LOG, remoteConfig.getString(USER_CHANGE_LOG));
  if (remoteConfig.getString(USER_CHANGE_LOG).validate().isNotEmpty) {
    remoteConfigDataModel = RemoteConfigDataModel.fromJson(
        jsonDecode(remoteConfig.getString(USER_CHANGE_LOG)));

    await compareValuesInSharedPreference(
        IN_MAINTENANCE_MODE, remoteConfigDataModel.inMaintenanceMode);

    if (isIOS) {
      await compareValuesInSharedPreference(
          HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_APP_STORE_REVIEW));
    } else if (isAndroid) {
      await compareValuesInSharedPreference(
          HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_PLAY_STORE_REVIEW));
    }
  }

  return remoteConfig;
}

void ifNotTester(VoidCallback callback) {
  if (appStore.userEmail != DEFAULT_EMAIL) {
    callback.call();
  } else {
    toast(language.lblUnAuthorized);
  }
}

void doIfLoggedIn(BuildContext context, VoidCallback callback) {
  if (appStore.isLoggedIn) {
    callback.call();
  } else {
    SignInScreen(returnExpected: true).launch(context).then((value) {
      if (value ?? false) {
        callback.call();
      }
    });
  }
}

Widget get trailing {
  return RotatedBox(
      quarterTurns: appStore.selectedLanguageCode == 'ar' ? 2 : 0,
      child: ic_arrow_right.iconImage(size: 16));
}

void showNewUpdateDialog(BuildContext context,
    {required int currentAppVersionCode}) async {
  showInDialog(
    context,
    contentPadding: EdgeInsets.zero,
    barrierDismissible:
        currentAppVersionCode >= getIntAsync(USER_APP_MINIMUM_VERSION).toInt(),
    builder: (_) {
      return WillPopScope(
        onWillPop: () {
          return Future(() =>
              currentAppVersionCode >=
              getIntAsync(USER_APP_MINIMUM_VERSION).toInt());
        },
        child: NewUpdateDialog(
            canClose: currentAppVersionCode >=
                getIntAsync(USER_APP_MINIMUM_VERSION).toInt()),
      );
    },
  );
}

Future<void> showForceUpdateDialog(BuildContext context) async {
  if (getBoolAsync(UPDATE_NOTIFY, defaultValue: true)) {
    getPackageInfo().then((value) {
      if (isAndroid &&
          getIntAsync(USER_APP_LATEST_VERSION).toInt() >
              value.versionCode.validate().toInt()) {
        showNewUpdateDialog(context,
            currentAppVersionCode: value.versionCode.validate().toInt());
      } else if (isIOS &&
          getIntAsync(USER_APP_LATEST_VERSION).toInt() >
              value.versionCode.validate().toInt()) {
        showNewUpdateDialog(context,
            currentAppVersionCode: value.versionCode.validate().toInt());
      }
    });
  }
}

bool isTodayAfterDate(DateTime val) => val.isAfter(todayDate);

Widget mobileNumberInfoWidget() {
  return RichTextWidget(
    list: [
      TextSpan(text: language.addYourCountryCode, style: secondaryTextStyle()),
      TextSpan(text: ' "91-", "236-" ', style: boldTextStyle(size: 12)),
      TextSpan(
        text: ' (${language.help})',
        style: boldTextStyle(size: 12, color: primaryColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrlCustomTab("https://countrycode.org/");
          },
      ),
    ],
  );
}

Future<bool> compareValuesInSharedPreference(String key, dynamic value) async {
  bool status = false;
  try {
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
  } catch (e) {
    log('compareValuesInSharedPreference Error: $e');
  }

  return status;
}

Future<File> getCameraImage({bool isCamera = true}) async {
  final pickedImage = await ImagePicker()
      .pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
  return File(pickedImage!.path);
}

Future<List<File>> getMultipleImageSource({bool isCamera = true}) async {
  final pickedImage = await ImagePicker().pickMultiImage();
  return pickedImage.map((e) => File(e.path)).toList();
}

Future<void> setConfigData(SiteConfig configData) async {
  setValue(PRICE_DECIMAL_POINTS,
      configData.digitafterDecimalPoint.validate().toInt());
  setValue(DATE_FORMAT, getDateFormat(configData.dateFormat.validate()));
  setValue(TIME_FORMAT, getDisplayTimeFormat(configData.timeFormat.validate()));

  // setValue(APPSTORE_URL, getDisplayTimeFormat(configData.appstoreUrl.validate()));
  // setValue(PROVIDER_APPSTORE_URL, getDisplayTimeFormat(configData.providerAppstoreUrl.validate()));
  // setValue(PLAY_STORE_URL, getDisplayTimeFormat(configData.playstoreUrl.validate()));
  // setValue(PROVIDER_PLAY_STORE_URL, getDisplayTimeFormat(configData.providerPlaystoreUrl.validate()));
}

Future<void> setGeneralSetting(GeneralSettingModel generalSettingModel) async {
  setValue(SITE_DESCRIPTION_AR, generalSettingModel.siteDescriptionAR);
  setValue(SITE_DESCRIPTION, generalSettingModel.siteDescription);
  setValue(SITE_COPYRIGHT, generalSettingModel.siteCopyright.validate());
  print("Kareem SITE_DESCRIPTION = ${getStringAsync(SITE_DESCRIPTION)}");
  print("Kareem SITE_DESCRIPTION API = ${generalSettingModel.siteDescription}");
  print("Kareem SITE_DESCRIPTION_AR = ${getStringAsync(SITE_DESCRIPTION_AR)}");
  print(
      "Kareem SITE_DESCRIPTION_AR API = ${generalSettingModel.siteDescriptionAR}");
}

Future<void> setSocialMedia(SocialMedia socialMedia) async {
  setValue(FACEBOOK_URL, socialMedia.facebookUrl.validate());
  setValue(INSTAGRAM_URL, socialMedia.instagramUrl.validate());
  setValue(TWITTER_URL, socialMedia.twitterUrl.validate());
  setValue(YOUTUBE_URL, socialMedia.youtubeUrl.validate());
}
