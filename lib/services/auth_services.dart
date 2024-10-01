import 'dart:convert';

import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/login_model.dart';
import 'package:hands_user_app/model/user_data_model.dart';
import 'package:hands_user_app/network/network_utils.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/auth/auth_user_services.dart';
import 'package:hands_user_app/screens/auth/opt_dialog_component.dart';
import 'package:hands_user_app/screens/auth/sign_up_screen.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn(
      // clientId: "610524636818-171k7n0kd3bhh9q5cqrgssqh9rujlu73.apps.googleusercontent.com",
      );

  //region Google Login
  Future<LoginResponse?> signInWithGoogle(BuildContext context) async {
    print("************************************************************");
    print("Starting...");
    print("************************************************************");
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      print("************************************************************");
      print("Not equal NULL!");
      print("************************************************************");
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User user = authResult.user!;

      print("************************************************************");
      print("User = ${user.email}");
      print("************************************************************");

      assert(!user.isAnonymous);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      await googleSignIn.signOut();

      String firstName = '';
      String lastName = '';
      if (currentUser.displayName.validate().split(' ').length >= 1)
        firstName = currentUser.displayName.splitBefore(' ');
      if (currentUser.displayName.validate().split(' ').length >= 2)
        lastName = currentUser.displayName.splitAfter(' ');

      /// Create a temporary request to send
      UserData tempUserData = UserData()
        ..contactNumber = currentUser.phoneNumber.validate()
        ..email = currentUser.email.validate()
        ..firstName = firstName.validate()
        ..lastName = lastName.validate()
        ..profileImage = currentUser.photoURL.validate()
        ..socialImage = currentUser.photoURL.validate()
        ..userType = USER_TYPE_USER
        ..loginType = LOGIN_TYPE_GOOGLE
        ..playerId = getStringAsync(PLAYERID)
        ..uid = user.uid
        ..username =
            (currentUser.email.validate().splitBefore('@').replaceAll('.', ''))
                .toLowerCase();

      print("************************************************************");
      print("Data = ${tempUserData.toJson()}");
      print("************************************************************");

      print("************************************************************");
      print("Login current users");
      print("************************************************************");
      return await loginCurrentUsers(context,
          req: tempUserData.toJson(), isSocialLogin: true);
    } else {
      appStore.setLoading(false);
      throw USER_NOT_CREATED;
    }
  }

//endregion

  //region Email

  Future<String> signUpWithEmailPassword(BuildContext context,
      {required UserData userData}) async {
    return await _auth
        .createUserWithEmailAndPassword(
            email: userData.email.validate(),
            password: DEFAULT_FIREBASE_PASSWORD)
        .then((userCredential) async {
      User currentUser = userCredential.user!;

      userData.uid = currentUser.uid.validate();
      userData.createdAt = Timestamp.now().toDate().toString();
      userData.updatedAt = Timestamp.now().toDate().toString();
      userData.playerId = getStringAsync(PLAYERID);

      log("Step 1 ${userData.toFirebaseJson()}");

      return await setRegisterData(userData: userData);
    }).catchError((e) {
      throw "User is Not Registered in Firebase";
    });
  }

  Future<String> signInWithEmailPassword(
      {required String email, String? uid, bool isSocialLogin = false}) async {
    if (isSocialLogin) {
      return uid.validate();
    }
    return await _auth
        .signInWithEmailAndPassword(
            email: email, password: DEFAULT_FIREBASE_PASSWORD)
        .then((value) async {
      return value.user!.uid.validate();
    }).catchError((e) async {
      appStore.setLoading(false);
      log(e.toString());
      throw language.userNotFound;
    });
  }

  //endregion

  Future<String> setRegisterData({required UserData userData}) async {
    return await userService
        .addDocumentWithCustomId(
            userData.uid.validate(), userData.toFirebaseJson())
        .then((value) async {
      return value.id.validate();
    }).catchError((e) {
      throw false;
    });
  }

  Future<bool> sendOTP({required int number}) async {
    var response = await buildHttpResponse('customer_otp_send?phone=$number',
        method: HttpMethodType.POST);
    print(response);
    print(response.statusCode);
    print(response.body);
    return (response.statusCode == 200);
  }

  Future<UserData?> verifyOTP(context,
      {required int number, required otp}) async {
    try {
      Response unHandeldResponse = await buildHttpResponse(
          'customer_otp_verify?phone=$number&otp=$otp',
          method: HttpMethodType.POST);
      if (unHandeldResponse.statusCode == 200 &&
          json.decode(unHandeldResponse.body)['data']['is_exist_user'] == 0) {
        appStore.setLoading(false);
        SignUpScreen(
          isOTPLogin: true,
          phoneNumber: number.toString(),
        ).launch(context);
        return null;
      }
      var response = await handleResponse(unHandeldResponse);
      print(response['data']);
      UserData uData = UserData.fromJson(response['data']);

      print(uData);

      return uData;
    } catch (e) {
      appStore.setLoading(false);
      log(e);
      throw errorSomethingWentWrong;
    }
  }

  //region Google OTP
  Future loginWithOTP(BuildContext context,
      {String phoneNumber = "",
      String? countryCode,
      String? countryISOCode}) async {
    log("PHONE NUMBER VERIFIED +$countryCode$phoneNumber");
    if (1 == 1) {
      bool sentSuccessfully =
          await sendOTP(number: int.parse('$countryCode$phoneNumber'));
      if (sentSuccessfully) {
        appStore.setLoading(false);
        await OtpDialogComponent(
          onTap: (otpCode) async {
            if (otpCode != null) {
              try {
                UserData? data = await verifyOTP(context,
                    number: int.parse('$countryCode$phoneNumber'),
                    otp: otpCode);
                if (data != null) {
                  print("*******&&&&&&&&^^^^^^^%%%%%%######");
                  print(data.displayName);
                  // print(data.toJson());
                  // toast(data.toJson()['id']);
                  await appStore.setLoginType(LOGIN_TYPE_USER);
                  await saveUserData(data);
                  // TextInput.finishAutofillContext();
                  saveDataToPreference(context, userData: data,
                      onRedirectionClick: () {
                    // TextInput.finishAutofillContext();
                    // if (widget.isFromServiceBooking.validate() || widget.isFromDashboard.validate() || widget.returnExpected.validate()) {
                    // if (widget.isFromDashboard.validate()) {
                    //   setStatusBarColor(context.primaryColor);
                    // }
                    if (1 == 2) {
                      finish(context, true);
                    } else {
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

                    appStore.setLoading(false);
                  });
                }
              } catch (e) {
                toast(e.toString());
              }

              // r
            }
          },
        ).launch(context);
      }
      return;
      // saveUserData(data)
    }
    // return await _auth.verifyPhoneNumber(
    //   phoneNumber: "+$countryCode$phoneNumber",
    //   verificationCompleted: (PhoneAuthCredential credential) {
    //     toast(language.verified);
    //   },
    //   verificationFailed: (FirebaseAuthException e) {
    //     appStore.setLoading(false);
    //     if (e.code == 'invalid-phone-number') {
    //       toast(language.theEnteredCodeIsInvalidPleaseTryAgain, print: true);
    //     } else {
    //       toast(e.toString(), print: true);
    //     }
    //   },
    //   codeSent: (String verificationId, int? resendToken) async {
    //     toast(language.otpCodeIsSentToYourMobileNumber);

    //     appStore.setLoading(false);

    //     /// Opens a dialog when the code is sent to the user successfully.
    //   },
    //   codeAutoRetrievalTimeout: (String verificationId) {
    //     //
    //   },
    // );
  }

//endregion
  Future<void> loginFromFirebaseUser(User currentUser,
      {LoginResponse? loginData,
      String? displayName,
      String? loginType}) async {
    if (await userService.isUserExist(loginData!.userData!.email)) {
      log("Firebase User Exist");

      await userService
          .userByEmail(loginData.userData!.email)
          .then((user) async {
        await saveUserData(loginData.userData!);
      }).catchError((e) {
        log(e);
        throw e;
      });
    } else {
      log("Creating Firebase User");

      loginData.userData!.uid = currentUser.uid.validate();
      loginData.userData!.userType = LOGIN_TYPE_USER;
      loginData.userData!.loginType = loginType;
      loginData.userData!.playerId = getStringAsync(PLAYERID);
      if (isIOS) {
        loginData.userData!.displayName = displayName;
      }

      await userService
          .addDocumentWithCustomId(
              currentUser.uid.validate(), loginData.userData!.toJson())
          .then((value) async {
        log("Firebase User Created");
        await saveUserData(loginData.userData!);
      }).catchError((e) {
        throw language.lblUserNotCreated;
      });
    }
  }

  // region Apple Sign
  Future<void> appleSignIn() async {
    if (await TheAppleSignIn.isAvailable()) {
      AuthorizationResult result = await TheAppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleIdCredential = result.credential!;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode!),
          );

          final authResult = await _auth.signInWithCredential(credential);
          final user = authResult.user!;

          log('User:- $user');

          if (result.credential!.email != null) {
            appStore.setLoading(true);

            await saveAppleData(result).then((value) {
              appStore.setLoading(false);
            }).catchError((e) {
              appStore.setLoading(false);
              throw e;
            });
          }
          await setValue(APPLE_UID, user.uid.validate());
          await setValue(APPLE_EMAIL, user.email.validate());

          await saveAppleDataWithoutEmail(user).then((value) {
            appStore.setLoading(false);
          }).catchError((e) {
            appStore.setLoading(false);
            throw e;
          });

          break;
        case AuthorizationStatus.error:
          throw ("${language.lblSignInFailed}: ${result.error!.localizedDescription}");
        case AuthorizationStatus.cancelled:
          throw ('${language.lblUserCancelled}');
      }
    } else {
      throw language.lblAppleSignInNotAvailable;
    }
  }

  Future<void> saveAppleData(AuthorizationResult result) async {
    await setValue(APPLE_EMAIL, result.credential!.email);
    await setValue(APPLE_GIVE_NAME, result.credential!.fullName!.givenName);
    await setValue(APPLE_FAMILY_NAME, result.credential!.fullName!.familyName);
  }

  Future<void> saveAppleDataWithoutEmail(User user) async {
    log('UID: ${getStringAsync(APPLE_UID)}');
    log('Email:- ${getStringAsync(APPLE_EMAIL)}');
    log('appleGivenName:- ${getStringAsync(APPLE_GIVE_NAME)}');
    log('appleFamilyName:- ${getStringAsync(APPLE_FAMILY_NAME)}');

    var req = {
      'email': getStringAsync(APPLE_EMAIL),
      'first_name': getStringAsync(APPLE_GIVE_NAME),
      'last_name': getStringAsync(APPLE_FAMILY_NAME),
      "username": getStringAsync(APPLE_EMAIL),
      "profile_image": '',
      "social_image": '',
      'accessToken': '12345678',
      'login_type': LOGIN_TYPE_APPLE,
      "user_type": LOGIN_TYPE_USER,
    };

    log("Apple Login Json" + jsonEncode(req));

    await loginUser(req, isSocialLogin: true).then((value) async {
      await loginFromFirebaseUser(user,
          loginData: value,
          displayName: value.userData!.displayName.validate(),
          loginType: LOGIN_TYPE_APPLE);
    }).catchError((e) {
      log(e.toString());
      throw e;
    });
  }

//endregion
}
