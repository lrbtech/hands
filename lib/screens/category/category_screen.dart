import 'package:hands_user_app/component/back_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/category_model.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/category/shimmer/category_shimmer.dart';
import 'package:hands_user_app/screens/dashboard/component/category_widget.dart';
import 'package:hands_user_app/screens/jobRequest/create_post_request_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';
import '../../utils/constant.dart';
import '../service/view_all_service_screen.dart';

class CategoryScreen extends StatefulWidget {
  final bool showBackButton;
  CategoryScreen({this.showBackButton = true});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<CategoryData>> future;
  List<CategoryData> categoryList = [];

  int page = 1;
  bool isLastPage = false;
  bool isApiCalled = false;

  UniqueKey key = UniqueKey();

  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getCategoryListWithPagination(page, categoryList: categoryList,
        lastPageCallBack: (val) {
      isLastPage = val;
    });
    if (page == 1) {
      key = UniqueKey();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.category,
        textColor: Colors.black,
        showBack: widget.showBackButton,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 0.0,
        color: white,
        systemUiOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness:
                appStore.isDarkMode ? Brightness.light : Brightness.light,
            statusBarColor: context.primaryColor),
        backWidget: BackWidget(),
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<CategoryData>>(
            initialData: cachedCategoryList,
            future: future,
            loadingWidget: CategoryShimmer(),
            onSuccess: (snap) {
              if (snap.isEmpty) {
                return NoDataWidget(
                  title: language.noCategoryFound,
                  imageWidget: EmptyStateWidget(),
                );
              }

              return AnimatedScrollView(
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                children: [
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10),
                    itemCount: snap.length,
                    itemBuilder: (_, index) {
                      CategoryData data = snap[index];
                      return GestureDetector(
                        onTap: () {
                          // CreatePostRequestScreen(
                          //   categoryId: data.id!.toInt(),
                          // ).launch(context);
                          // ViewAllServiceScreen(categoryId: data.id.validate(), categoryName: data.name, isFromCategory: true).launch(context);
                        },
                        child: CategoryWidget(
                          categoryData: data,
                          isFromCategory: true,
                        ),
                      );
                    },
                  ),
                  80.height
                  // AnimatedWrap(
                  //   key: key,
                  //   runSpacing: 10,
                  //   spacing: 10,
                  //   itemCount: snap.length,
                  //   listAnimationType: ListAnimationType.FadeIn,
                  //   fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  //   scaleConfiguration: ScaleConfiguration(duration: 300.milliseconds, delay: 50.milliseconds),
                  //   itemBuilder: (_, index) {
                  //     CategoryData data = snap[index];

                  //     return GestureDetector(
                  //       onTap: () {
                  //         ViewAllServiceScreen(categoryId: data.id.validate(), categoryName: data.name, isFromCategory: true).launch(context);
                  //       },
                  //       child: CategoryWidget(categoryData: data, width: context.width() / 3.5),
                  //     );
                  //   },
                  // ),
                ],
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(
              builder: (BuildContext context) =>
                  LoaderWidget().visible(appStore.isLoading.validate())),
        ],
      ),
    );
  }
}
