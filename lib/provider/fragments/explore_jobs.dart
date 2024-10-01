import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/back_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/dashboard_model.dart';
import 'package:hands_user_app/models/dashboard_response.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/fragments/shimmer/provider_dashboard_shimmer.dart';
import 'package:hands_user_app/provider/jobRequest/components/bid_widget.dart';
import 'package:hands_user_app/provider/jobRequest/models/bidder_data.dart';
import 'package:hands_user_app/provider/jobRequest/models/post_job_data.dart';
import 'package:hands_user_app/provider/jobRequest/shimmer/bid_shimmer.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';

class ExploreJobsFragment extends StatefulWidget {
  const ExploreJobsFragment({
    super.key,
  });

  @override
  State<ExploreJobsFragment> createState() => _ExploreJobsFragmentState();
}

class _ExploreJobsFragmentState extends State<ExploreJobsFragment> {
  late Future<DashboardResponses> future;

  Future<void> init() async {
    future = providerDashboard().whenComplete(
      () {
        setState(() {});
      },
    );
  }

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<DashboardResponses>(
          initialData: cachedProviderDashboardResponse,
          future: future,
          builder: (context, snap) {
            if (snap.hasData) {
              if (snap.data!.myPostJobData.validate().isEmpty) {
                return NoDataWidget(
                  title: languages.noDataFound,
                  imageWidget: EmptyStateWidget(),
                ).center();
              }
              return AnimatedScrollView(
                padding: EdgeInsets.only(bottom: 16),
                physics: AlwaysScrollableScrollPhysics(),
                crossAxisAlignment: CrossAxisAlignment.start,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                children: [
                  GridView.builder(
                    itemCount: snap.data!.myPostJobData.validate().length,
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) => BidWidget(
                      data: snap.data!.myPostJobData.validate()[index],
                    ),
                  ),
                ],
                onSwipeRefresh: () async {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
              );
            }

            return snapWidgetHelper(
              snap,
              loadingWidget: ProviderDashboardShimmer(),
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
            );
          },
        ),
        Observer(
            builder: (context) => LoaderWidget().visible(appStore.isLoading))
      ],
    );
  }
}
