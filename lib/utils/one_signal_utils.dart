// import 'package:hands_user_app/main.dart';
// import 'package:hands_user_app/utils/model_keys.dart';
// import 'package:nb_utils/nb_utils.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

// import '../screens/auth/auth_user_services.dart';
// import 'constant.dart';

// Future<void> initializeOneSignal() async {
//   OneSignal.initialize(getStringAsync(ONESIGNAL_API_KEY));
//   Future.delayed(const Duration(seconds: 5), () {
//     OneSignal.User.pushSubscription.optIn();

//     saveOneSignalPlayerId();
//   });
// }

// Future<void> saveOneSignalPlayerId() async {
//   if (appStore.isLoggedIn) {
//     await OneSignal.login(appStore.userId.validate().toString()).then((value) {
//       OneSignal.User.addTagWithKey(ONESIGNAL_TAG_KEY, ONESIGNAL_TAG_VALUE);
//       OneSignal.User.addTagWithKey(UserKeys.email, appStore.userEmail);

//       if (OneSignal.User.pushSubscription.id.validate().isNotEmpty) {
//         appStore.setPlayerId(OneSignal.User.pushSubscription.id.validate());
//         updatePlayerId(playerId: OneSignal.User.pushSubscription.id.validate());
//       }
//     }).catchError((e) {
//       log('Error saving subscription id - $e');
//     });
//   }
// }
