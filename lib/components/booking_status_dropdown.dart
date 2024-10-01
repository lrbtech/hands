import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:hands_user_app/models/booking_status_response.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/extensions/string_extension.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

// ignore: must_be_immutable
class BookingStatusDropdown extends StatefulWidget {
  final Function(String)? callBack;
  String? statusType;

  final Function(BookingStatusResponses value) onValueChanged;
  final bool isValidate;

  BookingStatusDropdown({
    this.callBack,
    required this.onValueChanged,
    required this.isValidate,
    this.statusType,
    Key? key,
  }) : super(key: key);

  @override
  _BookingStatusDropdownState createState() => _BookingStatusDropdownState();
}

class _BookingStatusDropdownState extends State<BookingStatusDropdown> {
  String status = '';
  AsyncMemoizer<List<BookingStatusResponses>> statusMemoizer = AsyncMemoizer();
  BookingStatusResponses? selectedData;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    LiveStream().on(LIVESTREAM_HANDY_BOARD, (index) {
      if (index is Map) {
        widget.statusType = index['type'];
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_HANDY_BOARD);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingStatusResponses>>(
      initialData: cachedBookingStatusDropdowns,
      future: statusMemoizer.runOnce(() => bookingStatus(list: [])),
      builder: (context, snap) {
        if (snap.hasData) {
          if (!snap.data!.any((element) => element.id == 0)) {
            snap.data!.insert(
              0,
              BookingStatusResponses(
                  label: BOOKING_PAYMENT_STATUS_ALL,
                  id: 0,
                  status: 0,
                  value: BOOKING_PAYMENT_STATUS_ALL),
            );
          }

          if (widget.statusType.validate().isNotEmpty) {
            snap.data.validate().forEach((e) {
              if (e.label.validate().toLowerCase() ==
                  widget.statusType.validate().toLowerCase()) {
                selectedData = e;
              }
            });
          } else {
            selectedData = snap.data!.first;
          }

          return DropdownButtonFormField<BookingStatusResponses>(
            onChanged: (BookingStatusResponses? val) {
              widget.onValueChanged.call(val!);
            },
            validator: widget.isValidate
                ? (c) {
                    if (c == null) return errorThisFieldRequired;
                    return null;
                  }
                : null,
            value: selectedData,
            dropdownColor: context.cardColor,
            decoration: inputDecoration(context),
            items: List.generate(
              snap.data!.length,
              (index) {
                BookingStatusResponses data = snap.data![index];
                return DropdownMenuItem<BookingStatusResponses>(
                  child: Text(data.value.validate().toBookingStatus(),
                      style: primaryTextStyle()),
                  value: data,
                );
              },
            ),
          );
        }
        return snapWidgetHelper(snap,
            defaultErrorMessage: "", loadingWidget: SizedBox());
      },
    );
  }
}
