import 'dart:convert';
import 'dart:io';

import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/user_data_model.dart';

class NotificationService {
  Future<void> sendPushNotifications(String title, String content, {String? image, required UserData receiverUser, required UserData senderUserData}) async {
    Map<String, dynamic> data = senderUserData.toJson();

    /*if (email.validate().isNotEmpty) {
      data.putIfAbsent("email", () => email);
      data.putIfAbsent("sender_uid", () => uid);
      data.putIfAbsent("receiver_uid", () => receiverPlayerId);
    }*/

    data.putIfAbsent("is_chat", () => true);

    String oneSignalAppId = getStringAsync(ONESIGNAL_APP_ID_PROVIDER);
    String oneSignalRestKey = getStringAsync(ONESIGNAL_REST_API_KEY_PROVIDER);
    String oneSignalChannelId = getStringAsync(ONESIGNAL_CHANNEL_KEY_PROVIDER);

    log(oneSignalAppId);
    log(oneSignalRestKey);
    log(oneSignalChannelId);

    Map req = otherSettingStore.firebaseKey.isNotEmpty
        ? {
            'to': "/topics/user_${receiverUser.id.validate()}",
            "collapse_key": "type_a",
            "notification": {
              "body": content,
              "title": "$title sent you a message",
            },
            'data': data,
          }
        : {
            'headings': {
              'en': '$title sent you a message',
            },
            'contents': {
              'en': content,
            },
            'big_picture': image.validate().isNotEmpty ? image.validate() : '',
            'large_icon': image.validate().isNotEmpty ? image.validate() : '',
            'small_icon': appLogo,
            'data': data,
            'android_visibility': 1,
            'app_id': oneSignalAppId,
            'android_channel_id': oneSignalChannelId,
            'include_player_ids': [receiverUser.playerId.validate().trim()],
            'android_group': '$APP_NAME',
            /*"filters": [{"field": "providerApp", "relation": "=", "value": title}]*/
          };

    log(req);
    var header = otherSettingStore.firebaseKey.isNotEmpty
        ? {
            HttpHeaders.authorizationHeader: 'key=${otherSettingStore.firebaseKey.validate()}',
            HttpHeaders.contentTypeHeader: 'application/json',
          }
        : {
            HttpHeaders.authorizationHeader: 'Basic $oneSignalRestKey',
            HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          };

    Response res = await post(
      Uri.parse(otherSettingStore.firebaseKey.isNotEmpty ? 'https://fcm.googleapis.com/fcm/send' : 'https://onesignal.com/api/v1/notifications'),
      body: jsonEncode(req),
      headers: header,
    );

    log(res.statusCode);
    log(res.body);

    if (res.statusCode.isSuccessful()) {
    } else {
      throw errorSomethingWentWrong;
    }
  }
}
