import 'package:hands_user_app/component/image_border_component.dart';
import 'package:hands_user_app/model/notification_model';
import 'package:hands_user_app/model/notification_model.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationModel data;

  NotificationWidget({required this.data});

  /*static String getTime(String inputString, String time) {
    List<String> wordList = inputString.split(" ");
    if (wordList.isNotEmpty) {
      return wordList[0] + ' ' + time;
    } else {
      return ' ';
    }
  }*/

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
          // data.profileImage.validate().isNotEmpty
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text('${data.type.validate().split('_').join(' ').capitalizeFirstLetter()}', style: boldTextStyle(size: 12)).expand(),
                  Text('${data.title}', style: boldTextStyle(size: 12)).expand(),
                  Text(
                      formatDate(
                        data.createdAt.validate(),
                        showDateWithTime: true,
                      ),
                      style: secondaryTextStyle()),
                ],
              ),
              4.height,
              Text(
                '${data.description}',
                style: secondaryTextStyle(),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
