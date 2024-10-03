import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/notification_model';
import 'package:hands_user_app/model/notification_model.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/booking/booking_detail_screen.dart';
import 'package:hands_user_app/screens/notification/components/notification_widget.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<List<NotificationModel>>? future;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init({Map? req}) async {
    // future = getNotification(request: req);
    future = getAdminNotification();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.lblNotification,
      actions: [
        IconButton(
          icon: Icon(Icons.clear_all_rounded, color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ),
          onPressed: () async {
            appStore.setLoading(true);

            init(req: {NotificationKey.type: MARK_AS_READ});

            setState(() {});
          },
        ),
      ],
      child: SnapHelperWidget<List<NotificationModel>>(
        future: future,
        initialData: cachedNotificationList,
        loadingWidget: LoaderWidget(),
        errorBuilder: (error) {
          return NoDataWidget(
            title: error,
            imageWidget: ErrorStateWidget(),
            retryText: language.reload,
            onRetry: () {
              appStore.setLoading(true);

              init();
              setState(() {});
            },
          );
        },
        onSuccess: (list) {
          return AnimatedListView(
            shrinkWrap: true,
            itemCount: list.length,
            slideConfiguration: sliderConfigurationGlobal,
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            emptyWidget: NoDataWidget(
              title: language.noNotifications,
              subTitle: language.noNotificationsSubTitle,
              imageWidget: EmptyStateWidget(),
            ),
            onSwipeRefresh: () {
              appStore.setLoading(true);

              init();
              setState(() {});
              return 2.seconds.delay;
            },
            itemBuilder: (context, index) {
              NotificationModel data = list[index];

              return GestureDetector(
                onTap: () async {
                  // if (data.data!.notificationType.validate() == NOTIFICATION_TYPE_BOOKING) {
                  //   await BookingDetailScreen(bookingId: data.data!.id.validate()).launch(context);

                  //   init();
                  //   setState(() {});
                  // } else if (data.data!.notificationType.validate() == NOTIFICATION_TYPE_POST_JOB) {
                  //   //
                  // } else {
                  //   //
                  // }
                },
                child: NotificationWidget(data: data),
              );
            },
          );
        },
      ),
    );
  }
}
