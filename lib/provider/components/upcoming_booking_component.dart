import 'package:flutter/material.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/booking_list_response.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/booking_item_component.dart';
import '../../components/view_all_label_component.dart';
import '../../provider/utils/constant.dart';

class UpcomingBookingComponent extends StatelessWidget {
  final List<BookingDatas> bookingData;

  const UpcomingBookingComponent({required this.bookingData});

  @override
  Widget build(BuildContext context) {
    if (bookingData.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        ViewAllLabel(
          label: languages.upcomingBookings,
          list: bookingData,
          onTap: () {
            LiveStream().emit(LIVESTREAM_PROVIDER_ALL_BOOKING, 1);
            LiveStream().emit(LIVESTREAM_HANDYMAN_ALL_BOOKING, 1);
          },
        ),
        8.height,
        AnimatedListView(
          itemCount: bookingData.length,
          shrinkWrap: true,
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          itemBuilder: (_, i) => BookingItemComponent(
              bookingData: bookingData[i], showDescription: false),
        ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}
