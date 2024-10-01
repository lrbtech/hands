import 'package:flutter/material.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/utils/colors.dart';

import '../constant.dart';

const int averageWordsPerMinute = 180;

extension intExt on String {
  Widget iconImage({double? size, Color? color, BoxFit? fit}) {
    return Image.asset(
      this,
      height: size ?? 24,
      width: size ?? 24,
      fit: fit ?? BoxFit.cover,
      color:
          color ?? (appStore.isDarkMode ? Colors.white : appTextSecondaryColor),
      errorBuilder: (context, error, stackTrace) => placeHolderWidget(
          height: size ?? 24, width: size ?? 24, fit: fit ?? BoxFit.cover),
    );
  }

  String toBookingStatus({String? method}) {
    String temp = this.toLowerCase();

    if (temp == BOOKING_PAYMENT_STATUS_ALL) {
      return languages.all;
    } else if (temp == BOOKING_STATUS_PENDING) {
      return languages.pending;
    } else if (temp == BOOKING_STATUS_ACCEPT) {
      return languages.accepted;
    } else if (temp == BOOKING_STATUS_ON_GOING) {
      return languages.onGoing;
    } else if (temp == BOOKING_STATUS_IN_PROGRESS) {
      return languages.inProgress;
    } else if (temp == BOOKING_STATUS_HOLD) {
      return languages.hold;
    } else if (temp == BOOKING_STATUS_CANCELLED) {
      return languages.cancelled;
    } else if (temp == BOOKING_STATUS_REJECTED) {
      return languages.rejected;
    } else if (temp == BOOKING_STATUS_FAILED) {
      return languages.failed;
    } else if (temp == BOOKING_STATUS_COMPLETED) {
      return languages.completed;
    } else if (temp == BOOKING_STATUS_PENDING_APPROVAL) {
      return languages.pendingApproval;
    } else if (temp == BOOKING_STATUS_WAITING_ADVANCED_PAYMENT) {
      return languages.waiting;
    } else if (temp == 'pending_approval_again') {
      return languages.pendingApproval;
    } else if (temp == BOOKING_STATUS_REFUND) {
      return languages.refund;
    }

    return this;
  }

  String toPostJobStatus({String? method}) {
    String temp = this.toLowerCase();
    if (temp == JOB_REQUEST_STATUS_REQUESTED) {
      return languages.requested;
    } else if (temp == JOB_REQUEST_STATUS_ACCEPTED) {
      return languages.accepted;
    } else if (temp == JOB_REQUEST_STATUS_ASSIGNED) {
      return languages.assigned;
    }

    return this;
  }

  int getWordsCount() {
    return this.split(' ').length;
  }

  int getEstimatedTimeInMin() {
    return (this.getWordsCount() / averageWordsPerMinute).ceil();
  }
}
