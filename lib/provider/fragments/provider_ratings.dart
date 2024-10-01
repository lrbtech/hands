import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/empty_error_state_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/ratings_model.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/fragments/shimmer/provider_payment_shimmer.dart';
import 'package:hands_user_app/provider/jobRequest/shimmer/bid_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:rate_in_stars/rate_in_stars.dart';

class ProviderRatings extends StatefulWidget {
  const ProviderRatings({super.key});

  @override
  State<ProviderRatings> createState() => _ProviderRatingsState();
}

class _ProviderRatingsState extends State<ProviderRatings> {
  List<Rating> list = [];
  Future<List<Rating>>? future;
  UniqueKey keyForStatus = UniqueKey();
  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = getUserRatings(page, list, (p0) {
      isLastPage = p0;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages.ratings.replaceAll(':', ''),
        textColor: white,
        color: context.primaryColor,
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<Rating>>(
            initialData: cachedRatingsList,
            future: future,
            loadingWidget: BidShimmer(),
            onSuccess: (list) {
              return AnimatedListView(
                itemCount: list.length,
                shrinkWrap: true,
                padding: EdgeInsets.all(8),
                physics: AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                itemBuilder: (p0, index) {
                  Rating data = list[index];

                  return Container(
                    margin: EdgeInsets.all(4),
                    padding: EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: lightGrey.withOpacity(0.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: lightGrey,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: grey,
                              ),
                            ),
                            SizedBox(width: 10),
                            // info
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data.username ?? '',
                                      style: boldTextStyle(),
                                    ).expand(),

                                    // Date
                                    Text(
                                      data.date != null
                                          ? getDate(data.date!)
                                          : '',
                                      style: secondaryTextStyle(),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    RatingStars(
                                      rating: data.rating?.toDouble() ?? 0,
                                      color: orange,
                                      editable: false,
                                      iconSize: 14,
                                    ),
                                    SizedBox(),
                                  ],
                                ),
                                SizedBox(height: 2),
                              ],
                            ).expand(),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          data.review ?? '',
                          style: primaryTextStyle(),
                        ),
                      ],
                    ),
                  );
                },
                emptyWidget: NoDataWidget(
                  title: appStore.selectedLanguageCode == "en"
                      ? "No ratings "
                      : "لا يوجد تقييمات",
                  imageWidget: EmptyStateWidget(),
                ),
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: languages.reload,
                onRetry: () {
                  keyForStatus = UniqueKey();
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(
            builder: (context) => LoaderWidget().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}

String getDate(String dateTimeString) {
  // Parse the string with the specified format
  final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'");
  final parsedDateTime = formatter.parse(dateTimeString);

  // Extract the date part and convert to UTC
  final date = parsedDateTime.toUtc();

  // Format the date as "DD Month YYYY"
  final outputFormatter = DateFormat('d MMM yyyy');
  final formattedDate = outputFormatter.format(date);

  return formattedDate;
}
