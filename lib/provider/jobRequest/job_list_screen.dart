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

class JobListScreen extends StatefulWidget {
  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  // final GlobalKey topKey = GlobalKey();
  final scrollController = ScrollController();
  // final PagingController<int, List<PostJobData>> _pagingController = PagingController(firstPageKey: 1);

  bool isLoading = false;

// Categories
  // TextEditingController _controller = TextEditingController(text: 'all');
  SignUpCategory? selectedCategory;
  String? selectedCategoryString;
  List<SignUpCategory>? categoriesList;
  List<String>? categoriesListString;
  int? selectedIndex;

  // Filter
  String selectedFilterValue = languages.latestJobs;
  List<String> filters = [
    languages.latestJobs,
    languages.activeJobsOnTop,
    languages.urgentJobsOnTop,
    languages.priceHighToLow,
    languages.priceLowToHigh,
  ];

  List<String> apiFilters = [
    "latest",
    "active",
    "urgent",
    "price_high_to_low",
    "price_low_to_high",
  ];

  void changeSelectedFilter({required int index}) {
    selectedFilterValue = filters[index];
    selectedIndex = index;
  }

  int getSelectCategoryId() {
    if (appStorePro.selectedLanguageCode == 'en') {
      selectedCategory = categoriesList
          ?.where((element) => element.name == selectedCategoryString)
          .first;
    } else {
      selectedCategory = categoriesList
          ?.where((element) => element.nameAr == selectedCategoryString)
          .first;
    }

    print(
        'Category is ${selectedCategory!.name} and ID is ${selectedCategory!.id!}');

    return selectedCategory!.id ?? 0;
  }

  late Future<List<PostJobData>> future;
  List<PostJobData> myPostJobList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    // _pagingController.addPageRequestListener((pageKey) {
    //   page = pageKey;
    //   // _fetchPage(pageKey);
    //   init();
    // });
    init();
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });
    subCategories = await getSubscribedCategories().whenComplete(() async {
      await getSignUpCategoryList(perPage: 'all').then(
        (categories) {
          categoriesList = [];
          categoriesListString = [];
          if (appStorePro.selectedLanguageCode == 'en') {
            categoriesListString!.add('all');
          } else {
            categoriesListString!.add('الكل');
          }

          categoriesList!.addAll(categories.data!);
          categoriesList!.forEach((element) {
            if (appStorePro.selectedLanguageCode == 'en') {
              categoriesListString!.add(element.name!);
            } else {
              categoriesListString!.add(element.nameAr!);
            }
          });

          print('List length = ${categoriesList?.length}');
          print(
              'LAST ONE IS = ${categoriesList?.last.nameAr}, ID = ${categoriesList?.last.id}');
          setState(() {});
        },
      );
    });

    myPostJobList = await getPostJobList(
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

  List<SubscribedCategory> subCategories = [];

  Future<List<SubscribedCategory>> getSubscribedCategories() async {
    List<SubscribedCategory> subscribedCategories = [];
    var headers = buildHeaderTokens();

    var request = Request(
      'GET',
      buildBaseUrl('subscribed-category-list'),
    );

    request.headers.addAll(headers);

    StreamedResponse response = await request.send();

    final data = await Response.fromStream(response);

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      print('getSubscribedCategories SUCCESS');
      jsonDecode(data.body).forEach((element) {
        // print('Element: $element');
        subscribedCategories.add(SubscribedCategory.fromJson(element));
      });
      print('subscribedCategories = ${subscribedCategories.length}');
      return subscribedCategories;
    } else {
      // print(response.reasonPhrase);
      print('getSubscribedCategories ERROR');
      toast(jsonDecode(data.body)['message']);
      return [];
    }
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
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                useSafeArea: true,
                builder: (context) => AlertDialog(
                  // co
                  insetPadding: EdgeInsets.all(20),
                  backgroundColor: white,
                  // scrollable: true,
                  // scr
                  titlePadding: EdgeInsets.all(20),
                  contentPadding: EdgeInsets.all(20),
                  elevation: 0,
                  actions: [],
                  content: StatefulBuilder(
                    builder: (BuildContext context,
                            void Function(void Function()) setState2) =>
                        SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      // height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(),
                              // if (categoriesList != null)
                              //   Text(
                              //     languages.hintSelectCategory,
                              //     style: boldTextStyle(color: black),
                              //   )
                              // else
                              //   SizedBox(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: black,
                                  child: Icon(
                                    Icons.close,
                                    color: white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          20.height,
                          if (categoriesListString != null)
                            CustomDropdown.search(
                              initialItem: selectedCategoryString ??
                                  categoriesListString![0],
                              hintText: selectedCategoryString,
                              searchHintText: languages.selectCategory,
                              items: categoriesListString ?? [],
                              excludeSelected: false,
                              noResultFoundText: languages.noCategoriesFound,
                              noResultFoundBuilder: (context, text) => Padding(
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: Text(
                                    text,
                                    style: primaryTextStyle(
                                      color: appStorePro.isDarkMode
                                          ? white
                                          : context.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              decoration: CustomDropdownDecoration(
                                closedFillColor: context.cardColor,
                                expandedFillColor:
                                    context.scaffoldBackgroundColor,
                                listItemStyle: primaryTextStyle(
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : context.primaryColor,
                                ),
                                listItemDecoration: ListItemDecoration(
                                  selectedColor: greenColor,
                                ),
                                headerStyle: primaryTextStyle(
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : context.primaryColor,
                                ),
                              ),
                              onChanged: (value) async {
                                print('value = $value');
                                selectedCategoryString = value.toString();
                                Navigator.of(context).pop();
                                // if (selectedCategoryString != 'all' && selectedCategoryString != 'الكل') {
                                //   selectedCategoryString = value.toString();
                                //   print('PARAMETER is ${getSelectCategoryId().validate().toString()}');
                                // }

                                // print('PARAMETER is ${getSelectCategoryId().validate().toString()}');
                                // myPostJobList = [];
                                setState(() {});

                                if (selectedCategoryString != 'all' &&
                                    selectedCategoryString != 'الكل') {
                                  bool canFilter = false;

                                  subCategories.forEach((c) {
                                    print(
                                        'c.id.validate() = ${c.categoryId.validate()}');
                                    print(
                                        'getSelectCategoryId().validate() = ${getSelectCategoryId().validate()}');
                                    if (c.categoryId.validate() ==
                                        getSelectCategoryId().validate()) {
                                      canFilter = true;
                                    }
                                  });

                                  if (canFilter) {
                                    print('We entereed here');
                                    scrollController.animateTo(
                                      0.0, // Scroll to position 0.0 (top)
                                      duration: Duration(
                                          milliseconds:
                                              500), // Animation duration
                                      curve: Curves.ease, // Animation curve
                                    );
                                    page = 1;

                                    myPostJobList = await getPostJobList(
                                      page,
                                      postJobList: myPostJobList,
                                      lastPageCallback: (val) =>
                                          isLastPage = val,
                                      filter: apiFilters[selectedIndex ?? 0],
                                      category: getSelectCategoryId()
                                          .validate()
                                          .toString(),
                                    );
                                  } else {
                                    if (appStorePro.selectedLanguageCode ==
                                        'en') {
                                      toast(
                                          'You can not choose category you did not subscribe to.');
                                    } else {
                                      toast(
                                          'لا يمكنك اختيار فئة لست مشترك فيها.');
                                    }
                                  }
                                } else {
                                  print('NOT ALL CATEGORY');
                                  scrollController.animateTo(
                                    0.0, // Scroll to position 0.0 (top)
                                    duration: Duration(
                                        milliseconds:
                                            500), // Animation duration
                                    curve: Curves.ease, // Animation curve
                                  );
                                  page = 1;

                                  myPostJobList = await getPostJobList(
                                    page,
                                    postJobList: myPostJobList,
                                    lastPageCallback: (val) => isLastPage = val,
                                    filter: apiFilters[selectedIndex ?? 0],
                                  );
                                }

                                setState(() {});
                              },
                            ),
                          150.height,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              // width: 100,
              height: 25,
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: filter.iconImage(
                  color: black, size: 20, fit: BoxFit.fitHeight),
            ),
          ),
          14.width,

          // Sort
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                useSafeArea: true,
                builder: (context) => AlertDialog(
                  // co
                  insetPadding: EdgeInsets.all(20),
                  backgroundColor: white,
                  // scrollable: true,
                  // scr
                  titlePadding: EdgeInsets.all(20),
                  contentPadding: EdgeInsets.all(20),
                  elevation: 0,
                  actions: [],
                  content: StatefulBuilder(
                    builder: (BuildContext context,
                            void Function(void Function()) setState2) =>
                        SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      // height: MediaQuery.of(context).size.height,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                languages.filterByTitle,
                                style: boldTextStyle(color: black),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: black,
                                  child: Icon(
                                    Icons.close,
                                    color: white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          20.height,

                          // Buttons
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) => FilterButton(
                              onPressed: () async {
                                changeSelectedFilter(index: index);
                                setState2(() {});

                                Navigator.of(context).pop();
                                myPostJobList = [];
                                setState(() {});

                                if (selectedCategoryString != 'all' &&
                                    selectedCategoryString != 'الكل') {
                                  try {
                                    myPostJobList = await getPostJobList(
                                      page,
                                      postJobList: myPostJobList,
                                      lastPageCallback: (val) =>
                                          isLastPage = val,
                                      filter: apiFilters[selectedIndex ?? 0],
                                      category: getSelectCategoryId()
                                          .validate()
                                          .toString(),
                                    );
                                  } catch (e) {
                                    myPostJobList = await getPostJobList(
                                      page,
                                      postJobList: myPostJobList,
                                      lastPageCallback: (val) =>
                                          isLastPage = val,
                                      filter: apiFilters[selectedIndex ?? 0],
                                      // category: getSelectCategoryId().validate().toString(),
                                    );
                                  }
                                } else {
                                  myPostJobList = await getPostJobList(
                                    page,
                                    postJobList: myPostJobList,
                                    lastPageCallback: (val) => isLastPage = val,
                                    filter: apiFilters[selectedIndex ?? 0],
                                  );
                                }

                                setState(() {});
                              },
                              title: filters[index],
                              selectedValue: selectedFilterValue,
                              onChanged: (selected) async {
                                changeSelectedFilter(index: index);
                                setState2(() {});

                                Navigator.of(context).pop();
                                myPostJobList = [];

                                setState(() {});
                                myPostJobList = await getPostJobList(
                                  page,
                                  postJobList: myPostJobList,
                                  lastPageCallback: (val) => isLastPage = val,
                                  filter: apiFilters[selectedIndex ?? 0],
                                );
                                setState(() {});
                              },
                            ),
                            separatorBuilder: (context, index) => 20.height,
                            itemCount: filters.length,
                          ),

                          // 20.height,
                          // if (categoriesList != null)
                          //   Text(
                          //     languages.hintSelectCategory,
                          //     style: boldTextStyle(color: black),
                          //   ),
                          // if (categoriesList != null) 10.height,
                          // if (categoriesList != null)
                          //   Container(
                          //     padding: EdgeInsets.symmetric(horizontal: 8),
                          //     decoration: BoxDecoration(
                          //       color: context.cardColor,
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //     child: FlutterDropdownSearch(
                          //       // suffixIcon: Icons.arrow_drop_down,
                          //       hintText: languages.hintSelectCategory,
                          //       hintStyle: secondaryTextStyle(),
                          //       style: primaryTextStyle(),
                          //       dropdownTextStyle: primaryTextStyle(),
                          //       textFieldBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(12),
                          //         borderSide: BorderSide.none,
                          //       ),
                          //       dropdownBgColor: context.cardColor,
                          //       textController: _controller,
                          //       items: categoriesList!.map((e) => appStorePro.selectedLanguageCode == 'en' ? (e.name ?? '') : (e.nameAr ?? '')).toList(),
                          //       dropdownHeight: 150,
                          //     ),
                          //   ),

                          // 20.height,

                          // Center(
                          //   child: AppButton(),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              // width: 100,
              height: 25,
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  sort.iconImage(color: black, size: 20, fit: BoxFit.fitHeight),
            ),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                ic_notification.iconImage(color: white, size: 20),
                Positioned(
                  top: -14,
                  right: -6,
                  child: Observer(
                    builder: (context) {
                      if (appStorePro.notificationCount.validate() > 0)
                        return Container(
                          padding: EdgeInsets.all(4),
                          child: FittedBox(
                            child: Text(
                                appStorePro.notificationCount.toString(),
                                style: primaryTextStyle(
                                    size: 12, color: Colors.white)),
                          ),
                          decoration: boxDecorationDefault(
                              color: Colors.red, shape: BoxShape.circle),
                        );

                      return Offstage();
                    },
                  ),
                )
              ],
            ),
            onPressed: () async {
              NotificationFragment().launch(context);
            },
          ),
        ],
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
              // PagedGridView(
              //   pagingController: _pagingController,
              //   builderDelegate: PagedChildBuilderDelegate(
              //     itemBuilder: (BuildContext context, item, int index) {
              //       return BidWidget(
              //         data: myPostJobList.validate()[index],
              //       );
              //     },
              //   ),
              //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: 2,
              //     mainAxisSpacing: 10,
              //     crossAxisSpacing: 10,
              //   ),
              // ),

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
                      LoaderWidget().visible(appStorePro.isLoading)),
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
//                       if (appStorePro.notificationCount.validate() > 0)
//                         return Container(
//                           padding: EdgeInsets.all(4),
//                           child: FittedBox(
//                             child: Text(appStorePro.notificationCount.toString(), style: primaryTextStyle(size: 12, color: Colors.white)),
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
//               //     //     appStorePro.setLoading(true);

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
//                   appStorePro.setLoading(true);

//                   init();
//                   setState(() {});
//                 },
//               );
//             },
//             loadingWidget: JobPostRequestShimmer(),
//           ),
//           Observer(builder: (context) => LoaderWidget().visible(appStorePro.isLoading)),
//         ],
//       ),
//     );
//   }
// }

 