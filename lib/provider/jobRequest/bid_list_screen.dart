import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/back_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/components/info_widget.dart';
import 'package:hands_user_app/provider/jobRequest/components/bid_widget.dart';
import 'package:hands_user_app/provider/jobRequest/shimmer/bid_shimmer.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';
import 'components/job_item_widget.dart';
import 'models/bidder_data.dart';

class BidListScreen extends StatefulWidget {
  @override
  _BidListScreenState createState() => _BidListScreenState();
}

class _BidListScreenState extends State<BidListScreen> {
  late Future<List<BidderData>> future;
  List<BidderData> bidList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = getBidList(
      page: page,
      bidList: bidList,
      lastPageCallback: (val) {
        isLastPage = val;
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages.bidList,
        textColor: white,
        showBack: true,
        backWidget: BackWidget(),
        color: context.primaryColor,
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.pixels >=
                      notification.metrics.extentAfter) {
                // User scrolled to the end
                if (bidList.length >= page * PER_PAGE_ITEM) {
                  page = page + 1;

                  init();
                  setState(() {});
                }
              }
              return false;
            },
            child: SnapHelperWidget<List<BidderData>>(
              future: future,
              onSuccess: (data) {
                if (data.isEmpty) {
                  return NoDataWidget(
                    title: languages.noDataFound,
                    imageWidget: EmptyStateWidget(),
                  ).center();
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      16.height,
                      InfoWidget(
                        info: languages.bidListDescription,
                      ),
                      16.height,
                      GridView.builder(
                        itemCount: data.validate().length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) =>
                            BidWidget(data: data[index].postJobData),
                      ),
                    ],
                  ),
                );
                // return AnimatedListView(
                //   itemCount: data.validate().length,
                //   shrinkWrap: true,
                //   physics: AlwaysScrollableScrollPhysics(),
                //   listAnimationType: ListAnimationType.FadeIn,
                //   fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                //   padding: EdgeInsets.all(8),
                //   itemBuilder: (_, i) => JobItemWidget(data: data[i].postJobData),
                //   onNextPage: () {
                //     if (!isLastPage) {
                //       page++;
                //       appStore.setLoading(true);
                //
                //       init();
                //       setState(() {});
                //     }
                //   },
                //   onSwipeRefresh: () async {
                //     page = 1;
                //
                //     init();
                //     setState(() {});
                //
                //     return await 2.seconds.delay;
                //   },
                // );
              },
              loadingWidget: BidShimmer(),
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  imageWidget: ErrorStateWidget(),
                  retryText: languages.reload,
                  onRetry: () {
                    page = 1;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  },
                );
              },
            ),
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
