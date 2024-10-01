import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/user_data.dart';
import 'package:hands_user_app/provider/networks/network_utils.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/model_keys.dart';

import 'package:hands_user_app/screens/auth/sign_in_screen.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

void saveDataToPreferences(BuildContext context,
    {required UserDatas UserDatas}) async {
  print("emailsign call");
  if (UserDatas.status == 1) {
    saveUserDatass(UserDatas);

    // onRedirectionClick.call();
    registerInFirebase(context, UserDatas: UserDatas);
  }
  // else {
  //   toast(languages.pleaseContactYourAdmin);
  //   push(SignInScreen(),
  //       isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
  // }
}

void registerInFirebase(BuildContext context,
    {required UserDatas UserDatas}) async {
  await firebaseLogin(context, data: UserDatas).then((value) async {
    log("Hurray Firebase login successful");
    appStore.setUId(value.validate());
  }).catchError((e) async {
    log("================== Error In Firebase =========================");
  });
}

Future<String> firebaseLogin(BuildContext context,
    {required UserDatas data}) async {
  try {
    final firebaseEmail = data.email.validate();
    final firebaseUid =
        await authServices.signInWithEmailPassword(email: firebaseEmail);

    log("***************** User Already Registered in Firebase*****************");

    if (await userService.isUserExistWithUid(firebaseUid)) {
      return firebaseUid;
    } else {
      data.uid = firebaseUid;
      return await authServices
          .setRegisterData(UserDatas: data)
          .catchError((ee) {
        throw "Cannot Register";
      });
    }
  } catch (e) {
    log("======= $e");
    if (e.toString() == USER_NOT_FOUND) {
      log("***************** ($e) User Not Found, Again registering the current user *****************");

      return await registerUserInFirebase(context, user: data);
    } else {
      throw e.toString();
    }
  }
}

Future<String> registerUserInFirebase(BuildContext context,
    {required UserDatas user}) async {
  try {
    log("*************************************************** Login user is registering again.  ***************************************************");
    return authServices.signUpWithEmailPassword(context, UserDatas: user);
  } catch (e) {
    throw e.toString();
  }
}
