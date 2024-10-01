import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

const APP_NAME = 'Hands UAE';
const APP_NAME_TAG_LINE = 'Hands App For Services Workers';
var defaultPrimaryColor = Color(0xFF000C2C);

// Don't add slash at the end of the url
const DOMAIN_URL =
    'http://hands.lrbinfotech.com'; // Don't add slash at the end of the url
// const DOMAIN_URL =
//     'https://handsappuae.com/secure-admin-panel'; // Don't add slash at the end of the url
const BASE_URL = '$DOMAIN_URL/api/';

const DEFAULT_LANGUAGE = 'en';

/// You can change this to your Provider App package name
/// This will be used in Registered As Partner in Sign In Screen where your users can redirect to the Play/App Store for Provider App
/// You can specify in Admin Panel, These will be used if you don't specify in Admin Panel
const PROVIDER_PACKAGE_NAME = '';
const IOS_LINK_FOR_PARTNER = "";

const IOS_LINK_FOR_USER = '';

const DASHBOARD_AUTO_SLIDER_SECOND = 5;

const TERMS_CONDITION_URL = 'https://handsappuae.com/term-conditions';
const PRIVACY_POLICY_URL = 'https://handsappuae.com/privacy-policy';
const INQUIRY_SUPPORT_EMAIL = 'infoe@handsappuae.com';

/// You can add help line number here for contact. It's demo number
const HELP_LINE_NUMBER = '+15265897485';

//Airtel Money Payments
///It Supports ["UGX", "NGN", "TZS", "KES", "RWF", "ZMW", "CFA", "XOF", "XAF", "CDF", "USD", "XAF", "SCR", "MGA", "MWK"]
const AIRTEL_CURRENCY_CODE = "MWK";
const AIRTEL_COUNTRY_CODE = "MW";
const AIRTEL_TEST_BASE_URL = 'https://openapiuat.airtel.africa/'; //Test Url
const AIRTEL_LIVE_BASE_URL = 'https://openapi.airtel.africa/'; // Live Url

/// PAYSTACK PAYMENT DETAIL
const PAYSTACK_CURRENCY_CODE = 'NGN';

/// Nigeria Currency

/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'AE';
const STRIPE_CURRENCY_CODE = 'AED';

/// RAZORPAY PAYMENT DETAIL
const RAZORPAY_CURRENCY_CODE = 'INR';

/// PAYPAL PAYMENT DETAIL
const PAYPAL_CURRENCY_CODE = 'USD';

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

DateTime todayDate = DateTime(2022, 8, 24);

int DEFAULT_RADAR_TIMER_IN_SECONDS = 60;

Country defaultCountry() {
  return Country(
    phoneCode: '971',
    countryCode: 'AE',
    e164Sc: 971,
    geographic: true,
    level: 1,
    name: 'United Arab Emirates',
    example: '561234567', // Replace with a valid UAE phone number
    displayName: 'United Arab Emirates (AE) [+971]',
    displayNameNoCountryCode: 'United Arab Emirates (AE)',
    e164Key: '971-AE-0',
    fullExampleWithPlusSign:
        '+971561234567', // Replace with a valid UAE phone number
  );
}
