import 'package:flutter/material.dart';
import 'package:hands_user_app/components/image_border_component.dart';
import 'package:hands_user_app/models/notification_list_response.dart';

import 'package:hands_user_app/models/provider_notification_model.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationModelProvider data;

  NotificationWidget({required this.data});

  static String getTime(String inputString, String time) {
    List<String> wordList = inputString.split(" ");

    if (wordList.isNotEmpty) {
      return wordList[0] + ' ' + time;
    } else {
      return ' ';
    }
  }

  Color _getBGColor(BuildContext context) {
    if (1 == 1) {
      return context.scaffoldBackgroundColor;
    } else {
      return context.cardColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: boxDecorationDefault(
        color: _getBGColor(context),
        borderRadius: radius(0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          1 != 1
              ? ImageBorder(
                  src: data.title.validate(),
                  height: 40,
                )
              : ImageBorder(
                  src: appLogo,
                  height: 40,
                ),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${data.title}',
                    style: boldTextStyle(size: 14),
                  ).expand(),
                  Text(formatDate(data.createdAt).validate(),
                      style: secondaryTextStyle(size: 10)),
                ],
              ),
              4.height,
              Text(data.description!,
                  style: secondaryTextStyle(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
