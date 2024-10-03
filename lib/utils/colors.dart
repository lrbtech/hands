import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:flutter/material.dart';

var primaryColor = appStore.isDarkMode ? darkPrimaryColor : lightPrimaryColor;
var secondaryColor = appStore.isDarkMode ?  lightPrimaryColor : darkPrimaryColor ;
const darkPrimaryColor = Color(0xFF000C2C);
const secondaryPrimaryColor = Color.fromARGB(255, 255, 255, 255);
const lightPrimaryColor = Color(0xFFfaf9f6);
//Text Color
const appTextPrimaryColor = Color(0xff1C1F34);
const appTextSecondaryColor = Color(0xff6C757D);
var cardColor = appStore.isDarkMode ? lightPrimaryColor : darkPrimaryColor;
const borderColor = Color(0xFFEBEBEB);

const scaffoldColorDark = Color(0xFF000C2C);
const scaffoldSecondaryDark = Color(0xFF1C1F26);
const appButtonColorDark = Color(0xFF282828);

const ratingBarColor = Color(0xfff5c609);
const verifyAcColor = Colors.blue;
const favouriteColor = Colors.red;
const unFavouriteColor = Colors.grey;

//Status Color
const pending = Color(0xFFEA2F2F);
const accept = Color(0xFF00968A);
const on_going = Color(0xFFFD6922);
const in_progress = Color(0xFFB953C0);
const hold = Color(0xFFFFBD49);
const cancelled = Color(0xffFF0303);
const rejected = Color(0xFF8D0E06);
const failed = Color(0xFFC41520);
const completed = Color(0xFF3CAE5C);
const defaultStatus = Color(0xFF3CAE5C);
const pendingApprovalColor = Color(0xFF690AD3);
const waiting = Color(0xFF2CAFAF);
const refunded = Color.fromARGB(255, 235, 88, 88);

const add_booking = Color(0xFFEA2F2F);
const assigned_booking = Color(0xFFFD6922);
const transfer_booking = Color(0xFF00968A);
const update_booking_status = Color(0xFF3CAE5C);
const cancel_booking = Color(0xFFC41520);
const payment_message_status = Color(0xFFFFBD49);
const defaultActivityStatus = Color(0xFF3CAE5C);

const walletCardColor = Color(0xFF1C1E33);
const showRedForZeroRatingColor = Color(0xFFFA6565);
