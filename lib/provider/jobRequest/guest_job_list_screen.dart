import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:conditional_builder_rec/conditional_builder_rec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_search/flutter_dropdown_search.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/provider/fragment/notification_fragment.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/sign_up_categories_model.dart';
import 'package:hands_user_app/provider/networks/network_utils.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/jobRequest/components/bid_widget.dart';
import 'package:hands_user_app/provider/jobRequest/shimmer/job_request_shimmer.dart';
import 'package:hands_user_app/provider/provider_dashboard_screen.dart';
import 'package:hands_user_app/provider/screens/categories_screen.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/extensions/string_extension.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:http/http.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import 'components/job_item_widget.dart';
import 'models/post_job_data.dart';

class GuestJobListScreen extends StatefulWidget {
  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<GuestJobListScreen> {
  // final GlobalKey topKey = GlobalKey();
  final scrollController = ScrollController();

  bool isLoading = false;

  late Future<List<PostJobData>> future;
  List<PostJobData> myPostJobList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });

    myPostJobList = await guestGetPostJobList(
      page,
      // perPage: 12,
      postJobList: myPostJobList,
      lastPageCallback: (val) => isLastPage = val,
    ).whenComplete(() {
      isLoading = false;
      setState(() {});
    });

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBarTitle: languages.jobRequestList,
      appBar: appBarWidget(
        [
          languages.providerHome,
          // languages.lblBooking,
          // languages.lblPayment,
          languages.lblProfile,
          languages.exploreJobs,
          // (1 == 1 ? languages.bidList : languages.jobRequestList),
        ][2],
        color: primaryColor,
        textColor: Colors.white,
        showBack: false,
      ),

      body: ConditionalBuilderRec(
        condition: myPostJobList.isNotEmpty,
        fallback: (context) => isLoading
            ? JobPostRequestShimmer()
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/empty_jobs.svg',
                      height: 170,
                    ),
                    Text(
                      languages.emptyJobList,
                      style: boldTextStyle(
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
        builder: (context) => NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.pixels >=
                    notification.metrics.extentAfter) {
              // User scrolled to the end
              if (myPostJobList.length >= page * PER_PAGE_ITEM) {
                page = page + 1;

                init();
              }
            }
            return false;
          },
          child: Stack(
            children: [
              GridView.builder(
                controller: scrollController,
                itemCount: myPostJobList.validate().length,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) => BidWidget(
                  data: myPostJobList.validate()[index],
                ),
              ),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:hands_user_app/components/app_widgets.dart';
// import 'package:hands_user_app/fragments/notification_fragment.dart';
// import 'package:hands_user_app/main.dart';
// import 'package:hands_user_app/provider/networks/rest_apis.dart';
// import 'package:hands_user_app/provider/jobRequest/components/bid_widget.dart';
// import 'package:hands_user_app/provider/jobRequest/shimmer/job_request_shimmer.dart';
// import 'package:hands_user_app/provider/provider_dashboard_screen.dart';
// import 'package:hands_user_app/utils/configs.dart';
// import 'package:hands_user_app/utils/extensions/string_extension.dart';
// import 'package:hands_user_app/utils/images.dart';
// import 'package:nb_utils/nb_utils.dart';

// import '../../components/base_scaffold_widget.dart';
// import '../../components/empty_error_state_widget.dart';
// import 'components/job_item_widget.dart';
// import 'models/post_job_data.dart';

// class JobListScreen extends StatefulWidget {
//   @override
//   _JobListScreenState createState() => _JobListScreenState();
// }

// class _JobListScreenState extends State<JobListScreen> {
// // Filter
//   String selectedFilterValue = '';
//   List<String> filters = [
//     languages.activeJobsOnTop,
//     languages.urgentJobsOnTop,
//     languages.priceHighToLow,
//     languages.latestJobs,
//   ];

//   void changeSelectedFilter({required int index}) {
//     selectedFilterValue = filters[index];
//   }

//   late Future<List<PostJobData>> future;
//   List<PostJobData> myPostJobList = [];

//   int page = 1;
//   bool isLastPage = false;

//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   Future<void> init() async {
//     future = getPostJobList(
//       page,
//       postJobList: myPostJobList,
//       lastPageCallback: (val) => isLastPage = val,
//     );
//     setState(() {});
//   }

//   @override
//   void setState(fn) {
//     if (mounted) super.setState(fn);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBarTitle: languages.jobRequestList,
//       appBar: appBarWidget(
//         [
//           languages.providerHome,
//           // languages.lblBooking,
//           // languages.lblPayment,
//           languages.lblProfile,
//           languages.exploreJobs,
//           // (1 == 1 ? languages.bidList : languages.jobRequestList),
//         ][2],
//         color: primaryColor,
//         textColor: Colors.white,
//         showBack: false,
//         actions: [
//           if (2 == 2)
//             GestureDetector(
//               onTap: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     insetPadding: EdgeInsets.all(20),
//                     backgroundColor: white,
//                     titlePadding: EdgeInsets.all(20),
//                     contentPadding: EdgeInsets.all(20),
//                     elevation: 0,
//                     actions: [],
//                     content: StatefulBuilder(
//                       builder: (BuildContext context, void Function(void Function()) setState2) => SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.7,
//                         // height: MediaQuery.of(context).size.width * 0.5,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Title
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   languages.filterByTitle,
//                                   style: boldTextStyle(),
//                                 ),
//                                 GestureDetector(
//                                   onTap: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                   child: CircleAvatar(
//                                     radius: 15,
//                                     backgroundColor: black,
//                                     child: Icon(
//                                       Icons.close,
//                                       color: white,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             20.height,

//                             // Buttons
//                             ListView.separated(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               padding: EdgeInsets.zero,
//                               itemBuilder: (context, index) => FilterButton(
//                                 title: filters[index],
//                                 selectedValue: selectedFilterValue,
//                                 onChanged: (selected) async {
//                                   changeSelectedFilter(index: index);
//                                   setState2(() {});

//                                   Navigator.of(context).pop();

//                                   future = getPostJobList(
//                                     page,
//                                     postJobList: myPostJobList,
//                                     lastPageCallback: (val) => isLastPage = val,
//                                   );
//                                   setState(() {});
//                                 },
//                               ),
//                               separatorBuilder: (context, index) => 20.height,
//                               itemCount: filters.length,
//                             ),
//                             Center(
//                               child: AppButton(),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               child: Container(
//                 // width: 100,
//                 height: 25,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: filter.iconImage(color: black, size: 20, fit: BoxFit.fitHeight),
//               ),
//             ),
//           // IconButton(
//           //   icon: filter.iconImage(color: white, size: 20),
//           //   onPressed: () async {
//           //     ChatListScreen().launch(context);
//           //   },
//           // ),
//           IconButton(
//             icon: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 ic_notification.iconImage(color: white, size: 20),
//                 Positioned(
//                   top: -14,
//                   right: -6,
//                   child: Observer(
//                     builder: (context) {
//                       if (appStore.notificationCount.validate() > 0)
//                         return Container(
//                           padding: EdgeInsets.all(4),
//                           child: FittedBox(
//                             child: Text(appStore.notificationCount.toString(), style: primaryTextStyle(size: 12, color: Colors.white)),
//                           ),
//                           decoration: boxDecorationDefault(color: Colors.red, shape: BoxShape.circle),
//                         );

//                       return Offstage();
//                     },
//                   ),
//                 )
//               ],
//             ),
//             onPressed: () async {
//               NotificationFragment().launch(context);
//             },
//           ),
//         ],
//       ),

//       body: Stack(
//         children: [
//           SnapHelperWidget<List<PostJobData>>(
//             future: future,
//             errorWidget: NoDataWidget(
//               title: languages.noDataFound,
//               imageWidget: EmptyStateWidget(),
//             ),
//             onSuccess: (data) {
//               // if (1 == 1) {
//               //   return AnimatedGrid(
//               //     physics: AlwaysScrollableScrollPhysics(),
//               //     // listAnimationType: ListAnimationType.FadeIn,
//               //     // fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
//               //     padding: EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 60),
//               //     initialItemCount: data.validate().length,
//               //     // shrinkWrap: true,
//               //     // emptyWidget: NoDataWidget(
//               //     //   title: languages.noDataFound,
//               //     //   imageWidget: EmptyStateWidget(),
//               //     // ),
//               //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               //       crossAxisCount: 2,
//               //       mainAxisSpacing: 10,
//               //       crossAxisSpacing: 10,
//               //     ),
//               //     itemBuilder: (context, i, _) => BidWidget(data: data[i]),
//               //     // onNextPage: () {
//               //     //   if (!isLastPage) {
//               //     //     page++;
//               //     //     appStore.setLoading(true);

//               //     //     init();
//               //     //     setState(() {});
//               //     //   }
//               //     // },
//               //     // onSwipeRefresh: () async {
//               //     //   page = 1;

//               //     //   init();
//               //     //   setState(() {});

//               //     //   return await 2.seconds.delay;
//               //     // },
//               //   );
//               // }

//               return GridView.builder(
//                 itemCount: myPostJobList.validate().length,
//                 shrinkWrap: true,
//                 physics: AlwaysScrollableScrollPhysics(),
//                 padding: EdgeInsets.all(8),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   mainAxisSpacing: 10,
//                   crossAxisSpacing: 10,
//                 ),
//                 itemBuilder: (context, index) => BidWidget(
//                   data: myPostJobList.validate()[index],
//                 ),
//               );
//             },
//             errorBuilder: (error) {
//               return NoDataWidget(
//                 title: error,
//                 imageWidget: ErrorStateWidget(),
//                 retryText: languages.reload,
//                 onRetry: () {
//                   page = 1;
//                   appStore.setLoading(true);

//                   init();
//                   setState(() {});
//                 },
//               );
//             },
//             loadingWidget: JobPostRequestShimmer(),
//           ),
//           Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
//         ],
//       ),
//     );
//   }
// }

 