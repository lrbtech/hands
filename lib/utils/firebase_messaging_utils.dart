import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../screens/booking/booking_detail_screen.dart';
import '../screens/service/service_detail_screen.dart';
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
      if (message.notification != null && message.notification!.title.validate().isNotEmpty && message.notification!.body.validate().isNotEmpty) {
        log('NOTIFICATIONDATA: ${message.data}');

        if (Platform.isIOS) {
          _shownNotificationIds.add(message.data['id']);
          print('_shownNotificationIds = $_shownNotificationIds');
        }

        showNotification(
          currentTimeStamp(),
          message.notification!.title.validate(),
          message.notification!.body.validate(),
          message,
        );
      }
    });

    //NEW
    // FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    //   //Handle onClick Notification
    //   if (message != null) {
    //     log("data 2 ==> ${message.data}");
    //     handleNotificationClick(message);
    //     print('From FirebaseMessaging.instance.getInitialMessage, ${message.notification?.title}, ${message.notification?.body}');
    //   }
    // });

    // //When the app is in the background and opened directly from the push notification.
    // FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    //   //Handle onClick Notification
    //   log("data 1 ==> ${message.data}");
    //   handleNotificationClick(message);
    //   print('From onMessageOpenedApp, ${message.notification?.title}, ${message.notification?.body}');
    // });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  });

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
}

Future<void> subscribeToFirebaseTopic() async {
  if (appStore.isLoggedIn) {
    await initFirebaseMessaging();

    if (Platform.isIOS) {
      log('Platform IOS==========');
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
        FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_VALUE);
      } else {
        await Future<void>.delayed(const Duration(seconds: 3));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken != null) {
          await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
          FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_VALUE);
        }
      }
    } else {
      await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
      FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_VALUE);
    }

    log("topic-----subscribed----> user_${appStore.userId}");
    log("topic-----subscribed----> $ONESIGNAL_TAG_VALUE");
  }
}

Future<void> unsubscribeFirebaseTopic() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic('user_${appStore.userId}').whenComplete(() {
    log("topic-----unSubscribed----> user_${appStore.userId}");
  });
  await FirebaseMessaging.instance.unsubscribeFromTopic(ONESIGNAL_TAG_VALUE).whenComplete(() {
    log("topic-----unSubscribed----> $ONESIGNAL_TAG_VALUE");
  });
}

void handleNotificationClick(RemoteMessage message) {
  print('I am in clicking the notification');
  print('Message data is ${message.data}');

  if (message.data.containsKey('is_chat')) {
    LiveStream().emit(LIVESTREAM_FIREBASE, 3);
    /*if (message.data.isNotEmpty) {
      // navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ChatListScreen()));
      // log('message.data=============== ${message.data}');
      // log('UserData.fromJson(message.data)=============== ${UserData.fromJson(message.data)}');
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => UserChatScreen(receiverUser: UserData.fromJson(message.data))));
    }*/
  } else if (message.data.containsKey('id')) {
    String? notId = message.data["id"].toString();
    if (notId.validate().isNotEmpty) {
      if (Navigator.canPop(getContext)) {
        Navigator.of(getContext).pop();
      }
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: notId.toString().toInt())));
    }
  } else if (message.data.containsKey('service_id')) {
    String? notId = message.data["service_id"];
    if (notId.validate().isNotEmpty) {
      if (Navigator.canPop(getContext)) {
        Navigator.of(getContext).pop();
      }
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ServiceDetailScreen(serviceId: notId.toInt())));
    }
  }
}

void handleNotificationClick2(RemoteMessage message) {
  if (message.data.containsKey('is_chat')) {
    LiveStream().emit(LIVESTREAM_FIREBASE, 3);
    /*if (message.data.isNotEmpty) {
      // navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ChatListScreen()));
      // log('message.data=============== ${message.data}');
      // log('UserData.fromJson(message.data)=============== ${UserData.fromJson(message.data)}');
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => UserChatScreen(receiverUser: UserData.fromJson(message.data))));
    }*/
  } else if (message.data.containsKey('id')) {
    String? notId = message.data["id"].toString();
    if (notId.validate().isNotEmpty) {
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: notId.toString().toInt())));
    }
  } else if (message.data.containsKey('service_id')) {
    String? notId = message.data["service_id"];
    if (notId.validate().isNotEmpty) {
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ServiceDetailScreen(serviceId: notId.toInt())));
    }
  }
}

void showNotification(int id, String title, String message, RemoteMessage remoteMessage) async {
  log(title);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //code for background notification channel
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'notification',
    'Notification',
    importance: Importance.high,
    enableLights: true,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_stat_onesignal_default');
  var iOS = const DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );
  var macOS = iOS;
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iOS, macOS: macOS);
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
    playSound: true,
    priority: Priority.high,
    icon: '@drawable/ic_stat_onesignal_default',
  );

  var darwinPlatformChannelSpecifics = const DarwinNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: darwinPlatformChannelSpecifics,
    macOS: darwinPlatformChannelSpecifics,
  );

  flutterLocalNotificationsPlugin.show(id, title, message, platformChannelSpecifics);
}


// import 'dart:io';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:nb_utils/nb_utils.dart';

// import '../main.dart';
// import '../screens/booking/booking_detail_screen.dart';
// import '../screens/service/service_detail_screen.dart';
// import 'constant.dart';

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
//         log('NOTIFICATIONDATA: ${message.data}');

//         if (Platform.isIOS) {
//           try {
//             _shownNotificationIds.add(message.data['service_id']);
//           } catch (e) {
//             _shownNotificationIds.add(message.data['id']);
//           }
//           print('_shownNotificationIds = $_shownNotificationIds');
//         }

//         showNotification(
//           currentTimeStamp(),
//           message.notification!.title.validate(),
//           message.notification!.body.validate(),
//           message,
//         );
//       }

//       // FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationClick);
//     });

//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//   });

//   FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
// }

// Future<void> subscribeToFirebaseTopic() async {
//   if (appStore.isLoggedIn) {
//     await initFirebaseMessaging();

//     if (Platform.isIOS) {
//       String? token = await FirebaseMessaging.instance.getToken();

//       if (token != null) {
//         print('FCM token is $token');
//         log('Platform IOS==========');
//         String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//         if (apnsToken != null) {
//           print('USER ID here is user_${appStore.userId}');
//           print('APNs token is ${apnsToken}');
//           try {
//             await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
//           } catch (e) {
//             print('Subscribe error is ${e.runtimeType} ... ${e}, msg: ${e.toString()}');
//           }
//           FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_VALUE);
//         } else {
//           print('APNs token is NULL');

//           await Future<void>.delayed(const Duration(seconds: 3));
//           apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//           if (apnsToken != null) {
//             await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
//             FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_VALUE);
//           }
//         }
//       } else {
//         print('FCM token is NULL');
//       }
//     } else {
//       await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}');
//       FirebaseMessaging.instance.subscribeToTopic(ONESIGNAL_TAG_VALUE);
//     }

//     log("topic-----subscribed----> user_${appStore.userId}");
//     log("topic-----subscribed----> $ONESIGNAL_TAG_VALUE");
//   }
// }

// Future<void> unsubscribeFirebaseTopic() async {
//   await FirebaseMessaging.instance.unsubscribeFromTopic('user_${appStore.userId}').whenComplete(() {
//     log("topic-----unSubscribed----> user_${appStore.userId}");
//   });
//   await FirebaseMessaging.instance.unsubscribeFromTopic(ONESIGNAL_TAG_VALUE).whenComplete(() {
//     log("topic-----unSubscribed----> $ONESIGNAL_TAG_VALUE");
//   });
// }

// void handleNotificationClick(RemoteMessage message) {
//   print('I am in clicking the notification');
//   print('Message data is ${message.data}');

//   if (message.data.containsKey('is_chat')) {
//     LiveStream().emit(LIVESTREAM_FIREBASE, 3);
//     /*if (message.data.isNotEmpty) {
//       // navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ChatListScreen()));
//       // log('message.data=============== ${message.data}');
//       // log('UserData.fromJson(message.data)=============== ${UserData.fromJson(message.data)}');
//       navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => UserChatScreen(receiverUser: UserData.fromJson(message.data))));
//     }*/
//   } else if (message.data.containsKey('id')) {
//     String? notId = message.data["id"].toString();
//     if (notId.validate().isNotEmpty) {
//       if (Navigator.canPop(getContext)) {
//         Navigator.of(getContext).pop();
//       }
//       navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: notId.toString().toInt())));
//     }
//   } else if (message.data.containsKey('service_id')) {
//     String? notId = message.data["service_id"];
//     if (notId.validate().isNotEmpty) {
//       if (Navigator.canPop(getContext)) {
//         Navigator.of(getContext).pop();
//       }
//       navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ServiceDetailScreen(serviceId: notId.toInt())));
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
//     try {
//       if (_shownNotificationIds.contains(remoteMessage.data['service_id'])) {
//         log('We will return here ... : ${remoteMessage.data}');
//         _shownNotificationIds.clear();
//         return;
//       }
//     } catch (e) {
//       if (_shownNotificationIds.contains(remoteMessage.data['id'])) {
//         log('We will return here ... : ${remoteMessage.data}');
//         _shownNotificationIds.clear();
//         return;
//       }
//     }
//   }

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

//   var iOS = DarwinInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//       defaultPresentAlert: true,
//       defaultPresentSound: true,
//       defaultPresentBadge: true,
//       onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) {
//         // handleNotificationClick(remoteMessage);
//       });

//   var macOS = iOS;
//   final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iOS, macOS: macOS);

//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: (details) {
//       // handleNotificationClick(remoteMessage);
//     },
//     // onDidReceiveBackgroundNotificationResponse: (details) {
//     //   handleNotificationClick(remoteMessage);
//     // },
//   );

//   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     'notification',
//     'Notification',
//     importance: Importance.high,
//     visibility: NotificationVisibility.public,
//     autoCancel: true,
//     //color: primaryColor,
//     playSound: true,
//     priority: Priority.high,
//     icon: '@drawable/ic_stat_onesignal_default',
//     // sound: "default",
//   );

//   var darwinPlatformChannelSpecifics = DarwinNotificationDetails(
//     presentAlert: true,
//     presentBadge: true,
//     presentSound: true,
//     sound: 'default',
//     threadIdentifier: '$id',
//     interruptionLevel: InterruptionLevel.active,
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