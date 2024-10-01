import 'package:nb_utils/nb_utils.dart';

/// DO NOT CHANGE THIS PACKAGE NAME
var appPackageName = isAndroid ? 'com.handsappuae.user' : 'com.handsappuae.user';

//region Common Configs
const DEFAULT_FIREBASE_PASSWORD = '12345678';
const DECIMAL_POINT = 2;
const PER_PAGE_ITEM = 20;
const PER_PAGE_CATEGORY_ITEM = 50;
const LABEL_TEXT_SIZE = 16;
const double SETTING_ICON_SIZE = 18;
const double CATEGORY_ICON_SIZE = 70;
const double SUBCATEGORY_ICON_SIZE = 45;
const APP_BAR_TEXT_SIZE = 18;
const MARK_AS_READ = 'markas_read';
const PERMISSION_STATUS = 'permissionStatus';

// region Default values
const DISPLAY_DATE_FORMAT = 'MMMM d, y';
const DISPLAY_TIME_FORMAT = 'h:mm a';
//endregion

const ONESIGNAL_TAG_KEY = 'appType';
const ONESIGNAL_TAG_VALUE = 'userApp';
const PER_PAGE_CHAT_LIST_COUNT = 50;

const USER_NOT_CREATED = "User not created";
const USER_CANNOT_LOGIN = "User can't login";
const USER_NOT_FOUND = "User not found";

const BOOKING_TYPE_ALL = 'all';
const CATEGORY_LIST_ALL = "all";

const BOOKING_TYPE_USER_POST_JOB = 'user_post_job';
const BOOKING_TYPE_SERVICE = 'service';

const DONE = 'Done';
const SERVICE = 'service';

const PAYMENT_STATUS_PAID = 'paid';

const NOTIFICATION_TYPE_BOOKING = 'booking';
const NOTIFICATION_TYPE_POST_JOB = 'post_Job';
const SERVICE_ATTACHMENT = 'service_attachment';

const IS_EMAIL_VERIFIED = 'IS_EMAIL_VERIFIED';
const EMAIL_VERIFICATION_LINK = 'EMAIL_VERIFICATION_LINK';

//endregion

//region LIVESTREAM KEYS
const LIVESTREAM_TOKEN = 'tokenStream';
const LIVESTREAM_UPDATE_BOOKING_LIST = "UpdateBookingList";
const LIVESTREAM_UPDATE_SERVICE_LIST = "LIVESTREAM_UPDATE_SERVICE_LIST";
const LIVESTREAM_UPDATE_DASHBOARD = "streamUpdateDashboard";
const LIVESTREAM_START_TIMER = "startTimer";
const LIVESTREAM_PAUSE_TIMER = "pauseTimer";
const LIVESTREAM_UPDATE_BIDER = 'updateBiderData';
const LIVESTREAM_FIREBASE = "LIVESTREAM_FIREBASE";
//endregion

//region default USER login
const DEFAULT_EMAIL = '';
const DEFAULT_PASS = '';
//endregion

//region THEME MODE TYPE
const THEME_MODE_LIGHT = 0;
const THEME_MODE_DARK = 1;
const THEME_MODE_SYSTEM = 2;
//endregion

// region Package Type
const PACKAGE_TYPE_SINGLE = 'single';
const PACKAGE_TYPE_MULTIPLE = 'multiple';
//endregion

//region Other Settings
const SOCIAL_LOGIN = 'SOCIAL_LOGIN';
const GOOGLE_LOGIN = 'GOOGLE_LOGIN';
const APPLE_LOGIN = 'APPLE_LOGIN';
const OTP_LOGIN = 'OTP_LOGIN';
const POST_JOB_REQUEST = 'POST_JOB_REQUEST';
const BLOG = 'BLOG';
//end region

// region APP CHANGE LOG
const FORCE_UPDATE_USER_APP = 'FORCE_UPDATE_USER_APP';
const USER_APP_MINIMUM_VERSION = 'USER_APP_MINIMUM_VERSION';
const USER_APP_LATEST_VERSION = 'USER_APP_LATEST_VERSION';
const FORCE_UPDATE_USER = 'forceUpdateInUser';
const USER_CHANGE_LOG = 'userChangeLog';
const LATEST_VERSIONCODE_USER_APP_ANDROID = 'latestVersionCodeUserAndroid';
const LATEST_VERSIONCODE_USER_APP_IOS = 'latestVersionCodeUseriOS';
//endregion

//region SHARED PREFERENCES KEYS
const IS_FIRST_TIME = 'IsFirstTime';
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const USER_ID = 'USER_ID';
const FIRST_NAME = 'FIRST_NAME';
const LAST_NAME = 'LAST_NAME';
const USER_EMAIL = 'USER_EMAIL';
const USER_PASSWORD = 'USER_PASSWORD';
const PROFILE_IMAGE = 'PROFILE_IMAGE';
const IS_REMEMBERED = "IS_REMEMBERED";
const TOKEN = 'TOKEN';
const USERNAME = 'USERNAME';
const DISPLAY_NAME = 'DISPLAY_NAME';
const CONTACT_NUMBER = 'CONTACT_NUMBER';
const COUNTRY_ID = 'COUNTRY_ID';
const STATE_ID = 'STATE_ID';
const CITY_ID = 'CITY_ID';
const ADDRESS = 'ADDRESS';
const PLAYERID = 'PLAYERID';
const FIREBASE_TOKEN = 'FIREBASE_FCM_TOKEN';
const UID = 'UID';
const LATITUDE = 'LATITUDE';
const LONGITUDE = 'LONGITUDE';
const CURRENT_ADDRESS = 'CURRENT_ADDRESS';
const LOGIN_TYPE = 'LOGIN_TYPE';
const PAYMENT_LIST = 'PAYMENT_LIST';
const USER_TYPE = 'USER_TYPE';
const HOUR_FORMAT_STATUS = 'HOUR_FORMAT_STATUS';
const DATE_FORMAT = 'DATE_FORMAT';
const TIME_FORMAT = 'TIME_FORMAT';
const PRICE_DECIMAL_POINTS = 'PRICE_DECIMAL_POINTS';

const PRIVACY_POLICY = 'PRIVACY_POLICY';
const TERM_CONDITIONS = 'TERM_CONDITIONS';
const INQUIRY_EMAIL = 'INQUIRY_EMAIL';
const HELPLINE_NUMBER = 'HELPLINE_NUMBER';
const USE_MATERIAL_YOU_THEME = 'USE_MATERIAL_YOU_THEME';
const IN_MAINTENANCE_MODE = 'inMaintenanceMode';
const HAS_IN_APP_STORE_REVIEW = 'hasInAppStoreReview1';
const HAS_IN_PLAY_STORE_REVIEW = 'hasInPlayStoreReview1';
const HAS_IN_REVIEW = 'hasInReview';
const SERVER_LANGUAGES = 'SERVER_LANGUAGES';
const AUTO_SLIDER_STATUS = 'AUTO_SLIDER_STATUS';
const UPDATE_NOTIFY = 'UPDATE_NOTIFY';
const CURRENCY_POSITION = 'CURRENCY_POSITION';
const ENABLE_USER_WALLET = 'ENABLE_USER_WALLET';
const SITE_DESCRIPTION = 'SITE_DESCRIPTION';
const SITE_DESCRIPTION_AR = 'SITE_DESCRIPTION_AR';
const SITE_COPYRIGHT = 'SITE_COPYRIGHT';
const FACEBOOK_URL = 'FACEBOOK_URL';
const INSTAGRAM_URL = 'INSTAGRAM_URL';
const TWITTER_URL = 'TWITTER_URL';
const LINKEDIN_URL = 'LINKEDIN_URL';
const YOUTUBE_URL = 'YOUTUBE_URL';
const FIREBASE_NOTIFICATION_STATUS = 'FIREBASE_NOTIFICATION_STATUS';

const APPLE_EMAIL = 'APPLE_EMAIL';
const APPLE_UID = 'APPLE_UID';
const APPLE_GIVE_NAME = 'APPLE_GIVE_NAME';
const APPLE_FAMILY_NAME = 'APPLE_FAMILY_NAME';
const SADAD_PAYMENT_ACCESS_TOKEN = 'SADAD_PAYMENT_ACCESS_TOKEN';

const APPSTORE_URL = 'APPSTORE_URL';
const PLAY_STORE_URL = 'PLAY_STORE_URL';
const PROVIDER_PLAY_STORE_URL = 'PROVIDER_PLAY_STORE_URL';
const PROVIDER_APPSTORE_URL = 'PROVIDER_APPSTORE_URL';

const BOOKING_ID_CLOSED_ = 'BOOKING_ID_CLOSED_';
const IS_ADVANCE_PAYMENT_ALLOWED = 'IS_ADVANCE_PAYMENT_ALLOWED';

const ADD_BOOKING = 'add_booking';
const ASSIGNED_BOOKING = 'assigned_booking';
const TRANSFER_BOOKING = 'transfer_booking';
const UPDATE_BOOKING_STATUS = 'update_booking_status';
const CANCEL_BOOKING = 'cancel_booking';
const PAYMENT_MESSAGE_STATUS = 'payment_message_status';
//endregion

//region CURRENCY POSITION
const CURRENCY_POSITION_LEFT = 'left';
const CURRENCY_POSITION_RIGHT = 'right';
//endregion

//region CONFIGURATION KEYS
const CONFIGURATION_TYPE_CURRENCY = 'CURRENCY';
const CONFIGURATION_TYPE_CURRENCY_POSITION = 'CURRENCY_POSITION';
const CONFIGURATION_KEY_CURRENCY_COUNTRY_ID = 'CURRENCY_COUNTRY_ID';
const CURRENCY_COUNTRY_SYMBOL = 'CURRENCY_COUNTRY_SYMBOL';
const CURRENCY_COUNTRY_CODE = 'CURRENCY_COUNTRY_CODE';
const CURRENCY_COUNTRY_ID = 'CURRENCY_COUNTRY_ID';
const IS_CURRENT_LOCATION = 'CURRENT_LOCATION';
const ONESIGNAL_API_KEY = 'ONESIGNAL_API_KEY';
const ONESIGNAL_REST_API_KEY = 'ONESIGNAL_REST_API_KEY';
const ONESIGNAL_CHANNEL_KEY = 'ONESIGNAL_CHANNEL_ID';
const ONESIGNAL_APP_ID_PROVIDER = 'ONESIGNAL_ONESIGNAL_APP_ID_PROVIDER';
const ONESIGNAL_REST_API_KEY_PROVIDER = 'ONESIGNAL_ONESIGNAL_REST_API_KEY_PROVIDER';
const ONESIGNAL_CHANNEL_KEY_PROVIDER = 'ONESIGNAL_ONESIGNAL_CHANNEL_ID_PROVIDER';

//endregion

//region ConfigurationKeys
const String generalSettingKey = 'general-setting';
const String themeSetupKey = 'theme-setup';
const String siteSetupKey = 'site-setup';
const String serviceConfigurationsKey = 'service-configurations';
const String otherSettingKey = 'OTHER_SETTING';
const String socialMediaKey = 'social-media';
//endregion

//region User Types
const USER_TYPE_PROVIDER = 'provider';
const USER_TYPE_HANDYMAN = 'handyman';
const USER_TYPE_USER = 'user';
//endregion

//region LOGIN TYPE
const LOGIN_TYPE_USER = 'user';
const LOGIN_TYPE_GOOGLE = 'google';
const LOGIN_TYPE_OTP = 'mobile';
const LOGIN_TYPE_APPLE = 'apple';
//endregion

//region SERVICE TYPE
const SERVICE_TYPE_FIXED = 'fixed';
const SERVICE_TYPE_PERCENT = 'percent';
const SERVICE_TYPE_HOURLY = 'hourly';
const SERVICE_TYPE_FREE = 'free';
//endregion

//region TAX TYPE
const TAX_TYPE_FIXED = 'fixed';
const TAX_TYPE_PERCENT = 'percent';
//endregion

//region COUPON TYPE
const COUPON_TYPE_FIXED = 'fixed';
const COUPON_TYPE_PERCENT = 'percentage';
//endregion
//region Visit Type
const VISIT_OPTION_ON_SITE = 'on_site';
const VISIT_OPTION_ONLINE = 'online';
// endregion
//region PAYMENT METHOD
const PAYMENT_METHOD_COD = 'cash';
const PAYMENT_METHOD_STRIPE = 'stripe';
const PAYMENT_METHOD_RAZOR = 'razorPay';
const PAYMENT_METHOD_FLUTTER_WAVE = 'flutterwave';
const PAYMENT_METHOD_CINETPAY = 'cinet';
const PAYMENT_METHOD_SADAD_PAYMENT = 'sadad';
const PAYMENT_METHOD_FROM_WALLET = 'wallet';
const PAYMENT_METHOD_PAYPAL = 'paypal';
const PAYMENT_METHOD_PAYSTACK = 'paystack';
const PAYMENT_METHOD_AIRTEL = 'airtel';
const PAYMENT_METHOD_PHONEPE = 'phonepe';
const PAYMENT_METHOD_PIX = 'PIX';
const PAYMENT_METHOD_MIDTRANS = 'midtrans';
//endregion

//region SERVICE PAYMENT STATUS
const SERVICE_PAYMENT_STATUS_PAID = 'paid';
const PENDING_BY_ADMIN = 'pending_by_admin';
const SERVICE_PAYMENT_STATUS_ADVANCE_PAID = 'advanced_paid';
const SERVICE_PAYMENT_STATUS_PENDING = 'pending';
//endregion

//region FireBase Collection Name
const MESSAGES_COLLECTION = "messages";
const USER_COLLECTION = "users";
const CONTACT_COLLECTION = "contact";
const CHAT_DATA_IMAGES = "chatImages";

const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
const PER_PAGE_CHAT_COUNT = 50;
//endregion

//region BOOKING STATUS
const BOOKING_PAYMENT_STATUS_ALL = 'all';
const BOOKING_STATUS_PENDING = 'pending';
const BOOKING_STATUS_ACCEPT = 'accept';
const BOOKING_STATUS_ON_GOING = 'on_going';
const BOOKING_STATUS_IN_PROGRESS = 'in_progress';
const BOOKING_STATUS_HOLD = 'hold';
const BOOKING_STATUS_CANCELLED = 'cancelled';
const BOOKING_STATUS_REJECTED = 'rejected';
const BOOKING_STATUS_FAILED = 'failed';
const BOOKING_STATUS_COMPLETED = 'completed';
const BOOKING_STATUS_REFUNDED = 'refund';
const BOOKING_STATUS_PENDING_APPROVAL = 'pending_approval';
const BOOKING_STATUS_WAITING_ADVANCED_PAYMENT = 'waiting';
const BOOKING_STATUS_PAID = 'paid';
const PAYMENT_STATUS_ADVANCE = 'advanced_paid';
//endregion

//region FILE TYPE
const TEXT = "TEXT";
const IMAGE = "IMAGE";

const VIDEO = "VIDEO";
const AUDIO = "AUDIO";
//endregion

//region CHAT LANGUAGE
const List<String> RTL_LanguageS = ['ar', 'ur'];
//endregion

//region Gallery File Types
enum GalleryFileTypes { CANCEL, CAMERA, GALLERY }
//endregion

//region MessageType
enum MessageType {
  TEXT,
  IMAGE,
  VIDEO,
  AUDIO,
}
//endregion

//region MessageExtension
extension MessageExtension on MessageType {
  String? get name {
    switch (this) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.VIDEO:
        return 'VIDEO';
      case MessageType.AUDIO:
        return 'AUDIO';
      default:
        return null;
    }
  }
}
//endregion

//region DateFormat
const DATE_FORMAT_1 = 'dd-MMM-yyyy hh:mm a';
const DATE_FORMAT_2 = 'd MMM, yyyy';
const DATE_FORMAT_3 = 'dd-MMM-yyyy';
const HOUR_12_FORMAT = 'hh:mm a';
const DATE_FORMAT_4 = 'dd MMM';
const DATE_FORMAT_7 = 'yyyy-MM-dd';
const DATE_FORMAT_8 = 'd MMM, yyyy hh:mm a';
const YEAR = 'yyyy';
const BOOKING_SAVE_FORMAT = "yyyy-MM-dd kk:mm:ss";
//endregion

//region Mail And Tel URL
const MAIL_TO = 'mailto:';
const TEL = 'tel:';
const GOOGLE_MAP_PREFIX = 'https://www.google.com/maps/search/?api=1&query=';

//endregion

SlideConfiguration sliderConfigurationGlobal = SlideConfiguration(duration: 400.milliseconds, delay: 50.milliseconds);

// region JOB REQUEST STATUS
const JOB_REQUESTS = "job_requests";
const JOB_TRACKING = "job_tracking";

const JOB_REQUEST_STATUS_REQUESTED = "requested";
const JOB_REQUEST_STATUS_ACCEPTED = "accepted";
const JOB_REQUEST_STATUS_ASSIGNED = "assigned";
// endregion

const PAYPAL_STATUS = 2;

// whatsapp msg string
const String whatsappString = "Hello, Hands ! \n\nI am facing an issue with this job ";
const String whatsappStringAr = "مرحبا هاندز, \n\n لدي مشكلة في العمل ";
