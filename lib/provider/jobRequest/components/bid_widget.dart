import 'package:flutter/material.dart';
import 'package:hands_user_app/components/cached_image_widget.dart';
import 'package:hands_user_app/components/price_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/jobRequest/job_post_detail_screen.dart';
import 'package:hands_user_app/provider/jobRequest/models/post_job_data.dart';
import 'package:hands_user_app/provider/jobRequest/shimmer/guest_job_post_detail_screen.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/extensions/color_extension.dart';
import 'package:hands_user_app/provider/utils/extensions/string_extension.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class BidWidget extends StatelessWidget {
  final PostJobData? data;

  const BidWidget({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) return Offstage();

    return Container(
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: appStore.isDarkMode
                ? lightGrey.withOpacity(0.1)
                : context.primaryColor.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Stack(
            children: [
              CachedImageWidget(
                url: data!.service.validate().isNotEmpty &&
                        data!.service
                            .validate()
                            .first
                            .imageAttachments
                            .validate()
                            .isNotEmpty
                    ? data!.service
                        .validate()
                        .first
                        .imageAttachments!
                        .first
                        .validate()
                    : "",
                fit: BoxFit.cover,
                height: double.maxFinite,
                width: double.maxFinite,
                radius: 8,
              ),

              // Shadow
              Positioned.fill(
                // bottom: -2,
                child: Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF121212).withOpacity(0.05),
                          const Color(0xFF171717).withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Status
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Row(
                children: [
                  if (data?.isUrgent == 1)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          ic_urgent,
                          height: 20,
                          alignment: AlignmentDirectional.centerStart,
                        ),
                        Text(
                          appStore.selectedLanguageCode == 'en'
                              ? 'Urgent'
                              : 'عاجل',
                          style: boldTextStyle(
                            color: redColor,
                            size: 12,
                          ),
                        ),
                      ],
                    ).expand()
                  else
                    SizedBox().expand(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: data!.status.validate().getJobStatusColor,
                      borderRadius: radius(8),
                    ),
                    child: Text(
                      data!.status.validate().toPostJobStatus(),
                      style: boldTextStyle(
                        color: white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    getCategoryName(data?.category)!,
                    style: boldTextStyle(color: black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(data!.title.validate(),
                    style: primaryTextStyle(color: white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                2.height,
                PriceWidget(
                  price: data!.price.validate(),
                  isHourlyService: false,
                  // color:  white,
                  normalColor: white,
                  isFreeService: false,
                  size: 14,
                ),
                2.height,
                Text(formatDate(data!.createdAt.validate()),
                    style: secondaryTextStyle(color: lightGrey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    ).onTap(() {
      guest && getBoolAsync(HAS_IN_REVIEW)
          ? GuestJobPostDetailScreen(
              postJobDataId: data!.id!.toInt(),
              postJobDataTitle: data!.title!.validate(),
            ).launch(context)
          : JobPostDetailScreen(
              postJobDataId: data!.id!.toInt(),
              postJobDataTitle: data!.title!.validate(),
            ).launch(context);
    }, borderRadius: BorderRadius.circular(8));
  }
}
