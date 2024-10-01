import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/component/price_widget.dart';
import 'package:hands_user_app/model/base_response_model.dart';
import 'package:hands_user_app/model/get_my_post_job_list_response.dart';
import 'package:hands_user_app/network/network_utils.dart';
import 'package:hands_user_app/screens/booking/component/booking_item_component.dart';
import 'package:hands_user_app/screens/jobRequest/my_post_detail_screen.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:hands_user_app/component/custom_confirmation_dialog.dart';
import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';

import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/images.dart';

class MyPostRequestItemComponent extends StatefulWidget {
  final PostJobData data;
  final Function(bool) callback;

  MyPostRequestItemComponent({required this.data, required this.callback});

  @override
  _MyPostRequestItemComponentState createState() =>
      _MyPostRequestItemComponentState();
}

class _MyPostRequestItemComponentState
    extends State<MyPostRequestItemComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  cancelJob({required num id}) async {
    var headers = buildHeaderTokens();
    var request = Request(
      'POST',
      buildBaseUrl('cancel-post-job'),
    );
    request.body = json.encode({"id": id});
    request.headers.addAll(headers);

    StreamedResponse response = await request.send();

    final data = await Response.fromStream(response);

    if (response.statusCode == 200) {
      toast(
        jsonDecode(data.body)['message'],
        bgColor: greenColor,
        textColor: white,
      );
    } else {
      print(response.reasonPhrase);
      toast(
        jsonDecode(data.body)['message'],
        bgColor: redColor,
        textColor: white,
      );
    }
  }

  onPressCancelJob(num id) async {
    widget.callback.call(true);

    cancelJob(id: id.validate()).then((value) {
      appStore.setLoading(false);

      widget.callback.call(false);
    }).catchError((e) {
      appStore.setLoading(false);
    });
  }

  void deletePost(num id) {
    widget.callback.call(true);

    deletePostRequest(id: id.validate()).then((value) {
      appStore.setLoading(false);
      toast(value.message.validate());

      widget.callback.call(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        MyPostDetailScreen(
          postRequestId: widget.data.id.validate().toInt(),
          callback: () {
            widget.callback.call(true);
          },
        ).launch(context);
      },
      child: Container(
        decoration: boxDecorationWithRoundedCorners(
            borderRadius: radius(), backgroundColor: context.cardColor),
        width: context.width(),
        margin: EdgeInsets.only(top: 12, bottom: 0, left: 16, right: 16),
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedImageWidget(
              url: (widget.data.service.validate().isNotEmpty &&
                      widget.data.service
                          .validate()
                          .first
                          .attachments
                          .validate()
                          .isNotEmpty)
                  ? widget.data.service
                      .validate()
                      .first
                      .attachments
                      .validate()
                      .first
                      .validate()
                  : "",
              fit: BoxFit.cover,
              height: 60,
              width: 60,
              circle: false,
            ).cornerRadiusWithClipRRect(defaultRadius),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.data.title.validate(),
                            style: boldTextStyle(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)
                        .expand(),
                    if (widget.data.isUrgentRequest)
                      Container(
                        child: Image.asset(
                          'assets/icons/urgent.png',
                          width: 24,
                        ),
                      ).paddingSymmetric(horizontal: 3),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.data.status
                            .validate()
                            .getJobStatusColor
                            .withOpacity(0.1),
                        borderRadius: radius(8),
                      ),
                      child: Text(
                        widget.data.status.validate().toPostJobStatus(),
                        style: boldTextStyle(
                            color:
                                widget.data.status.validate().getJobStatusColor,
                            size: 12),
                      ),
                    ),
                  ],
                ),
                8.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PriceWidget(
                      price: widget.data.status.validate() ==
                              JOB_REQUEST_STATUS_ASSIGNED
                          ? widget.data.jobPrice.validate()
                          : widget.data.price.validate(),
                      isHourlyService: false,
                      color: textPrimaryColorGlobal,
                      isFreeService: false,
                      size: 14,
                    ).expand(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: white,
                      ),
                      child: Text(
                        '${getCategoryName(widget.data.category)}',
                        style: boldTextStyle(color: black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                10.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDate(widget.data.createdAt.validate()),
                      style: secondaryTextStyle(),
                    ).expand(),

                    InkWell(
                      onTap: () {
                        showCustomConfirmDialog(
                          context,
                          dialogType: DialogType.DELETE,
                          title: '${language.deleteMessage}?',
                          positiveText: language.lblYes,
                          negativeText: language.lblNo,
                          onAccept: (p0) {
                            ifNotTester(() {
                              deletePost(widget.data.id.validate());
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: redColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            language.lblDelete,
                            style: secondaryTextStyle(size: 12, color: white),
                          ),
                        ),
                      ),
                    ),

                    if (widget.data.status.validate().toPostJobStatus() !=
                        language.cancelled)
                      5.width,

                    if (widget.data.status.validate().toPostJobStatus() !=
                        language.cancelled)
                      InkWell(
                        onTap: () async {
                          showCustomConfirmDialog(
                            context,
                            dialogType: DialogType.CONFIRMATION,
                            title: '${language.lblCancelBooking}?',
                            positiveText: language.lblYes,
                            negativeText: language.lblNo,
                            primaryColor: redColor,
                            onAccept: (p0) async {
                              await onPressCancelJob(widget.data.id.validate());
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              language.lblCancel,
                              style: secondaryTextStyle(
                                size: 12,
                                color: white,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // IconButton(
                    //   icon: ic_delete.iconImage(size: 16, color: redColor),
                    //   visualDensity: VisualDensity.compact,
                    //   onPressed: () {
                    //     showCustomConfirmDialog(
                    //       context,
                    //       dialogType: DialogType.DELETE,
                    //       title: '${language.deleteMessage}?',
                    //       positiveText: language.lblYes,
                    //       negativeText: language.lblNo,
                    //       onAccept: (p0) {
                    //         ifNotTester(() {
                    //           deletePost(widget.data.id.validate());
                    //         });
                    //       },
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
