import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hands_user_app/provider/fragments/provider_payment_fragment.dart';
import 'package:hands_user_app/provider/jobRequest/job_post_detail_screen.dart';
import 'package:hands_user_app/provider/screens/total_earning_screen.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../screens/booking_detail_screen.dart';
import '../screens/chat/user_chat_list_screen.dart';
import 'constant.dart';

Set<int> _shownNotificationIds = {};

//region Handle Background Firebase Message
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp().then((value) {}).catchError((e) {});
}

//endregion
Future<void> initFirebaseMessaging() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.instance.setAutoInitEnabled(true).then((value) {
    FirebaseMessaging.onMessage.listen((message) async {
      if (message.notification != null &&
          message.notification!.title.validate().isNotEmpty &&
          message.notification!.body.validate().isNotEmpty) {
        log('NOTIFICATIONDATA: ${message.data},');

        if (Platform.isIOS) {
          if (message.data.containsKey('post_request_id')) {
            _shownNotificationIds.add(
                (int.tryParse(message.data['post_request_id']) ??
                    message.data['post_request_id']));
          } else if (message.data.containsKey('id')) {
            _shownNotificationIds
                .add((int.tryParse(message.data['id']) ?? message.data['id']));
          } else {
            print('We dont have any of them');
          }

          print('_shownNotificationIds = $_shownNotificationIds');
        }

        showNotification(
          currentTimeStamp(),
          message.notification!.title.validate(),
          message.notification!.body.validate(),
          message,
        );
        // log('NOTIFICATIONDATA: ${message.data}');

        // showNotification(
        //   currentTimeStamp(),
        //   message.notification!.title.validate(),
        //   message.notification!.body.validate(),
        //   message,
        // );
      }
    });

    //When the app is in the background and opened directly from the push notification.
    // FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    //   //Handle onClick Notification
    //   // print(message.data);
    //   handleNotificationClick(message);
    // });

    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage? message) {
    //   //Handle onClick Notification
    //   if (message != null) {
    //     handleNotificationClick(message);
    //   }
    // });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  });

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
}

Future<void> subscribeToFirebaseTopic() async {
  if (appStore.isLoggedIn) {
    await initFirebaseMessaging();

    if (Platform.isIOS) {
      String? token = await FirebaseMessaging.instance.getToken();

      log('Platform IOS==========');
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        await FirebaseMessaging.instance
            .subscribeToTopic('user_${appStore.userId}');

        //
        print('trying sub to firebase notifications');
        try {
          getStringListAsync(CATEGORIES_IDS)?.forEach((element) async {
            await FirebaseMessaging.instance
                .subscribeToTopic('category_${int.parse(element)}');
            print('appStore.categoryID = ${int.parse(element)}... success.');
          });
        } catch (e) {
          print('error is subscription is ${e.toString()}');
        }

        if (isUserTypeHandyman) {
          FirebaseMessaging.instance
              .subscribeToTopic(ONESIGNAL_TAG_HANDYMAN_VALUE);
        } else {
          FirebaseMessaging.instance
              .subscribeToTopic(ONESIGNAL_TAG_PROVIDER_VALUE);
        }
      } else {
        await Future<void>.delayed(const Duration(seconds: 3));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          await FirebaseMessaging.instance
              .subscribeToTopic('user_${appStore.userId}');
          try {
            getStringListAsync(CATEGORIES_IDS)?.forEach((element) async {
              await FirebaseMessaging.instance
                  .subscribeToTopic('category_${int.parse(element)}');
              print('appStore.categoryID = ${int.parse(element)}... success.');
            });
          } catch (e) {
            print('error is subscription is ${e.toString()}');
          }

          if (isUserTypeHandyman) {
            FirebaseMessaging.instance
                .subscribeToTopic(ONESIGNAL_TAG_HANDYMAN_VALUE);
          } else {
            FirebaseMessaging.instance
                .subscribeToTopic(ONESIGNAL_TAG_PROVIDER_VALUE);
          }
        }
      }
    } else {
      FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
      try {
        getStringListAsync(CATEGORIES_IDS)?.forEach((element) async {
          await FirebaseMessaging.instance
              .subscribeToTopic('category_${int.parse(element)}');
          print('appStore.categoryID = ${int.parse(element)}... success.');
        });
        print(
            'appStore.categoryID = ${getStringListAsync(CATEGORIES_IDS)}... success. TO MAKE SUREEEEEEE');
      } catch (e) {
        print('error is subscription is ${e.toString()}');
      }
      if (isUserTypeHandyman) {
        FirebaseMessaging.instance
            .subscribeToTopic(ONESIGNAL_TAG_HANDYMAN_VALUE);
      } else {
        FirebaseMessaging.instance
            .subscribeToTopic(ONESIGNAL_TAG_PROVIDER_VALUE);
      }
    }

    log('Handyman Tag------> $ONESIGNAL_TAG_HANDYMAN_VALUE');
    log('Provider Tag------> $ONESIGNAL_TAG_PROVIDER_VALUE');
    log("topic---------> user_${appStore.userId}");
  }
}

Future<void> unsubscribeFirebaseTopic() async {
  await FirebaseMessaging.instance
      .unsubscribeFromTopic('user_${appStore.userId}')
      .whenComplete(() {
    log("topic-----unSubscribed----> user_${appStore.userId}");
  });
  FirebaseMessaging.instance
      .unsubscribeFromTopic(ONESIGNAL_TAG_PROVIDER_VALUE)
      .whenComplete(() {
    log('topic-----unSubscribed---->------> $ONESIGNAL_TAG_PROVIDER_VALUE');
  });
  FirebaseMessaging.instance
      .unsubscribeFromTopic(ONESIGNAL_TAG_HANDYMAN_VALUE)
      .whenComplete(() {
    log('topic-----unSubscribed---->------> $ONESIGNAL_TAG_HANDYMAN_VALUE');
  });

  getStringListAsync(CATEGORIES_IDS)?.forEach((element) async {
    await FirebaseMessaging.instance
        .unsubscribeFromTopic('category_${int.parse(element)}')
        .whenComplete(() {
      log("topic-----unSubscribed----> category_${int.parse(element)}");
    });
    print('appStore.categoryID = ${int.parse(element)}... success.');
  });
}

void handleNotificationClick(RemoteMessage message) {
  // print('Trying to handle notification click...');
  print('I am in clicking the notification');
  print('Message data is ${message.data}');

  if (message.data.containsKey('is_chat')) {
    if (message.data.isNotEmpty) {
      if (Navigator.canPop(getContext)) {
        Navigator.of(getContext).pop();
      }
      navigatorKey.currentState!
          .push(MaterialPageRoute(builder: (context) => ChatListScreen()));
      // navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => UserChatScreen(receiverUser: UserData.fromJson(message.data))));
    }
  } else if (message.data.containsKey('id')) {
    //  Booking/Job status updated
    print('Message ID is = ${message.data["id"]}');
    String? notId = message.data["id"].toString();

    if (notId.validate().isNotEmpty) {
      if (Navigator.canPop(getContext)) {
        Navigator.of(getContext).pop();
      }
      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (context) =>
              BookingDetailScreen(bookingId: notId.toString().toInt())));
    }
  } else if (message.data.containsKey('post_request_id')) {
    print('Message post_request_id is = ${message.data["post_request_id"]}');
    print('Message post_job_name is = ${message.data["post_job_name"]}');

    //  New Post Job Notification

    String? notId = message.data["post_request_id"].toString();
    String jobTitle = '';

    if (message.data.containsKey('post_job_name')) {
      jobTitle = message.data["post_job_name"].toString();
    }

    if (notId.validate().isNotEmpty) {
      if (Navigator.canPop(getContext)) {
        Navigator.of(getContext).pop();
      }

      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => JobPostDetailScreen(
            postJobDataId: notId.toInt(defaultValue: 0),
            postJobDataTitle: jobTitle,
          ),
        ),
      );
    }
  } else if (message.data.containsKey('payment')) {
    // if (Navigator.canPop(getContext)) {
    //   Navigator.of(getContext).pop();
    // }
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => TotalEarningScreen(),
      ),
    );
  }
}

void showNotification(
  int id,
  String title,
  String message,
  RemoteMessage remoteMessage,
) async {
  if (Platform.isIOS) {
    // try {
    if (_shownNotificationIds.contains(
        (int.tryParse(remoteMessage.data['post_request_id']) ??
            remoteMessage.data['post_request_id']))) {
      log('We will return here ... : ${remoteMessage.data}');
      _shownNotificationIds.clear();
      return;
    } else if (_shownNotificationIds.contains(
        (int.tryParse(remoteMessage.data['id']) ?? remoteMessage.data['id']))) {
      log('We will return here ... : ${remoteMessage.data}');
      _shownNotificationIds.clear();
      return;
    }
    // }
  }

  log('Continue notification: ${remoteMessage.data}');

  log(title);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //code for background notification channel
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'notification',
    'Notification',
    importance: Importance.high,
    enableLights: true,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_stat_onesignal_default');
  var iOS = const DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  var macOS = iOS;

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: iOS,
    macOS: macOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      handleNotificationClick(remoteMessage);
    },
  );

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'notification',
    'Notification',
    importance: Importance.high,
    visibility: NotificationVisibility.public,
    autoCancel: true,
    //color: primaryColor,
    // sound: RawResourceAndroidNotificationSound('notification.caf'),
    playSound: true,
    priority: Priority.high,
    icon: '@drawable/ic_stat_onesignal_default',
  );

  var darwinPlatformChannelSpecifics = const DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'notification.caf',
  );

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: darwinPlatformChannelSpecifics,
    macOS: darwinPlatformChannelSpecifics,
  );

  flutterLocalNotificationsPlugin.show(
    id,
    title,
    message,
    platformChannelSpecifics,
  );
}


// Set<int> _shownNotificationIds = {};

// //region Handle Background Firebase Message
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp().then((value) {}).catchError((e) {});
// }

// //endregion
// Future<void> initFirebaseMessaging() async {
//   await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     badge: true,
//     provisional: false,
//     sound: true,
//   );

//   FirebaseMessaging.instance.setAutoInitEnabled(true).then((value) {
//     FirebaseMessaging.onMessage.listen((message) async {
//       if (message.notification != null && message.notification!.title.validate().isNotEmpty && message.notification!.body.validate().isNotEmpty) {
//         log('NOTIFICATIONDATA: ${message.data},');

//         if (Platform.isIOS) {
//           if (message.data.containsKey('post_request_id')) {
//             _shownNotificationIds.add((int.tryParse(message.data['post_request_id']) ?? message.data['post_request_id']));
//           } else if (message.data.containsKey('id')) {
//             _shownNotificationIds.add((int.tryParse(message.data['id']) ?? message.data['id']));
//           } else {
//             print('We dont have any of them');
//           }

//           print('_shownNotificationIds = $_shownNotificationIds');
//         }

//         showNotification(
//           currentTimeStamp(),
//           message.notification!.title.validate(),
//           message.notification!.body.validate(),
//           message,
//         );
//         // log('NOTIFICATIONDATA: ${message.data}');

//         // showNotification(
//         //   currentTimeStamp(),
//         //   message.notification!.title.validate(),
//         //   message.notification!.body.validate(),
//         //   message,
//         // );
//       }
//     });

//     //When the app is in the background and opened directly from the push notification.
//     // FirebaseMessaging.onMessageOpenedApp.listen((message) async {
//     //   //Handle onClick Notification
//     //   // print(message.data);
//     //   handleNotificationClick(message);
//     // });

//     // FirebaseMessaging.instance
//     //     .getInitialMessage()
//     //     .then((RemoteMessage? message) {
//     //   //Handle onClick Notification
//     //   if (message != null) {
//     //     handleNotificationClick(message);
//     //   }
//     // });

//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   });

//   FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
// }

// Future<void> subscribeToFirebaseTopic() async {
//   if (appStore.isLoggedIn) {
//     await initFirebaseMessaging();

//     if (Platform.isIOS) {
//       String? token = await FirebaseMessaging.instance.getToken();

//       log('Platform IOS==========');
//       String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//       if (apnsToken != null) {
//         await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');

//         //
//         print('trying sub to firebase notifications');
//         try {
//           getStringListAsync(CATEGORIES_IDS)?.forEach((element) async {
//             await FirebaseMessaging.instance.subscribeToTopic('category_${int.parse(element)}');
//             print('appStore.categoryID = ${int.parse(element)}... success.');
//           });
//         } catch (e) {
//           print('error is subscription is ${e.toString()}');
//         }

//         if (isUserTypeHandyman) {
//           FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_HANDYMAN_VALUE);
//         } else {
//           FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_PROVIDER_VALUE);
//         }
//       } else {
//         await Future<void>.delayed(const Duration(seconds: 3));
//         apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//         if (apnsToken != null) {
//           await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
//           try {
//             getStringListAsync(CATEGORIES_IDS)?.forEach((element) async {
//               await FirebaseMessaging.instance.subscribeToTopic('category_${int.parse(element)}');
//               print('appStore.categoryID = ${int.parse(element)}... success.');
//             });
//           } catch (e) {
//             print('error is subscription is ${e.toString()}');
//           }

//           if (isUserTypeHandyman) {
//             FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_HANDYMAN_VALUE);
//           } else {
//             FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_PROVIDER_VALUE);
//           }
//         }
//       }
//     } else {
//       FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
//       try {
//         getStringListAsync(CATEGORIES_IDS)?.forEach((element) async {
//           await FirebaseMessaging.instance.subscribeToTopic('category_${int.parse(element)}');
//           print('appStore.categoryID = ${int.parse(element)}... success.');
//         });
//         print('appStore.categoryID = ${getStringListAsync(CATEGORIES_IDS)}... success. TO MAKE SUREEEEEEE');
//       } catch (e) {
//         print('error is subscription is ${e.toString()}');
//       }
//       if (isUserTypeHandyman) {
//         FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_HANDYMAN_VALUE);
//       } else {
//         FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_PROVIDER_VALUE);
//       }
//     }

//     log('Handyman Tag------> $ONESIGNAL_TAG_HANDYMAN_VALUE');
//     log('Provider Tag------> $ONESIGNAL_TAG_PROVIDER_VALUE');
//     log("topic---------> user_${appStore.userId}");
//   }
// }

// Future<void> unsubscribeFirebaseTopic() async {
//   await FirebaseMessaging.instance.unsubscribeFromTopic('user_${appStore.userId}').whenComplete(() {
//     log("topic-----unSubscribed----> user_${appStore.userId}");
//   });
//   FirebaseMessaging.instance.unsubscribeFromTopic(ONESIGNAL_TAG_PROVIDER_VALUE).whenComplete(() {
//     log('topic-----unSubscribed---->------> $ONESIGNAL_TAG_PROVIDER_VALUE');
//   });
//   FirebaseMessaging.instance.unsubscribeFromTopic(ONESIGNAL_TAG_HANDYMAN_VALUE).whenComplete(() {
//     log('topic-----unSubscribed---->------> $ONESIGNAL_TAG_HANDYMAN_VALUE');
//   });

//   getStringListAsync(CATEGORIES_IDS)?.forEach((element) async {
//     await FirebaseMessaging.instance.unsubscribeFromTopic('category_${int.parse(element)}').whenComplete(() {
//       log("topic-----unSubscribed----> category_${int.parse(element)}");
//     });
//     print('appStore.categoryID = ${int.parse(element)}... success.');
//   });
// }

// void handleNotificationClick(RemoteMessage message) {
//   print('Trying to handle notification click...');
//   print('I am in clicking the notification');
//   print('Message data is ${message.data}');

//   if (message.data.containsKey('is_chat')) {
//     if (message.data.isNotEmpty) {
//       if (Navigator.canPop(getContext)) {
//         Navigator.of(getContext).pop();
//       }
//       navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ChatListScreen()));
//       // navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => UserChatScreen(receiverUser: UserData.fromJson(message.data))));
//     }
//   } else if (message.data.containsKey('id')) {
//     //  Booking/Job status updated
//     print('Message ID is = ${message.data["id"]}');
//     String? notId = message.data["id"].toString();
//     try {
//       if (notId.validate().isNotEmpty) {
//         if (Navigator.canPop(getContext)) {
//           Navigator.of(getContext).pop();
//         }
//         navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: notId.toString().toInt())));
//       }
//     } catch (e) {
//       print('Error while navigating from notification is ((( ${e} ))) ===>>> ${e.toString()}');
//     }
//   } else if (message.data.containsKey('post_request_id')) {
//     print('Message post_request_id is = ${message.data["post_request_id"]}');
//     print('Message post_job_name is = ${message.data["post_job_name"]}');

//     //  New Post Job Notification

//     String? notId = message.data["post_request_id"].toString();
//     String jobTitle = '';

//     if (message.data.containsKey('post_job_name')) {
//       jobTitle = message.data["post_job_name"].toString();
//     }

//     if (notId.validate().isNotEmpty) {
//       if (1 == 1) {
//         // ProviderDashboardScreen(index: 0).launch(context,
//         //       isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
//         try {
//           if (Navigator.canPop(getContext)) {
//             Navigator.of(getContext).pop();
//           }

//           navigatorKey.currentState!.push(
//             MaterialPageRoute(
//               builder: (context) => JobPostDetailScreen(
//                 postJobDataId: notId.toInt(defaultValue: 0),
//                 postJobDataTitle: jobTitle,
//               ),
//             ),
//           );
//         } catch (e) {
//           print('Error while navigating from notification is ((( ${e} ))) ===>>> ${e.toString()}');
//         }
//         // JobPostDetailScreen(
//         //   postJobDataId: notId.toInt(defaultValue: 0),
//         //   postJobDataTitle: jobTitle,
//         // ).launch(getContext);
//       }
//       // navigatorKey.currentState!.push(MaterialPageRoute(
//       //     builder: (context) => JobPostDetailScreen(
//       //           postJobDataId: notId.toInt(defaultValue: 0),
//       //           postJobDataTitle: jobTitle,
//       //         )));
//     }
//   }
// }

// void showNotification(
//   int id,
//   String title,
//   String message,
//   RemoteMessage remoteMessage,
// ) async {
//   if (Platform.isIOS) {
//     // try {
//     if (_shownNotificationIds.contains((int.tryParse(remoteMessage.data['post_request_id']) ?? remoteMessage.data['post_request_id']))) {
//       log('We will return here ... : ${remoteMessage.data}');
//       _shownNotificationIds.clear();
//       return;
//     } else if (_shownNotificationIds.contains((int.tryParse(remoteMessage.data['id']) ?? remoteMessage.data['id']))) {
//       log('We will return here ... : ${remoteMessage.data}');
//       _shownNotificationIds.clear();
//       return;
//     }
//     // }
//   }

//   log('Continue notification: ${remoteMessage.data}');

//   log(title);
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   //code for background notification channel
//   AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'notification',
//     'Notification',
//     importance: Importance.high,
//     enableLights: true,
//     playSound: true,
//   );

//   await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

//   const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_stat_onesignal_default');
//   var iOS = const DarwinInitializationSettings(
//     requestSoundPermission: true,
//     requestBadgePermission: true,
//     requestAlertPermission: true,
//   );

//   var macOS = iOS;

//   final InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//     iOS: iOS,
//     macOS: macOS,
//   );

//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: (details) {
//       // handleNotificationClick(remoteMessage);
//     },
//   );

//   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     'notification',
//     'Notification',
//     importance: Importance.high,
//     visibility: NotificationVisibility.public,
//     autoCancel: true,
//     //color: primaryColor,
//     // sound: RawResourceAndroidNotificationSound('notification.caf'),
//     playSound: true,
//     priority: Priority.high,
//     icon: '@drawable/ic_stat_onesignal_default',
//   );

//   var darwinPlatformChannelSpecifics = const DarwinNotificationDetails(
//     presentAlert: true,
//     presentBadge: true,
//     presentSound: true,
//     sound: 'notification.caf',
//   );

//   var platformChannelSpecifics = NotificationDetails(
//     android: androidPlatformChannelSpecifics,
//     iOS: darwinPlatformChannelSpecifics,
//     macOS: darwinPlatformChannelSpecifics,
//   );

//   flutterLocalNotificationsPlugin.show(
//     id,
//     title,
//     message,
//     platformChannelSpecifics,
//   );
// }
