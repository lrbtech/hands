import 'package:hands_user_app/component/view_all_label_component.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/category_model.dart';
import 'package:hands_user_app/screens/category/category_screen.dart';
import 'package:hands_user_app/screens/dashboard/component/category_widget.dart';
import 'package:hands_user_app/screens/jobRequest/create_post_request_screen.dart';
import 'package:hands_user_app/screens/service/view_all_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryComponent extends StatefulWidget {
  final List<CategoryData>? categoryList;

  CategoryComponent({this.categoryList});

  @override
  CategoryComponentState createState() => CategoryComponentState();
}

class CategoryComponentState extends State<CategoryComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryList.validate().isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ViewAllLabel(
        //   label: language.category,
        //   list: widget.categoryList!,
        //   onTap: () {
        //     CategoryScreen().launch(context).then((value) {
        //       setStatusBarColor(Colors.transparent);
        //     });
        //   },
        // ).paddingSymmetric(horizontal: 16),
        // GridView.builder(
        //   physics: const NeverScrollableScrollPhysics(),
        //   shrinkWrap: true,
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 2.5),
        //   itemCount: widget.categoryList.validate().length > 6 ? 6 : widget.categoryList.validate().length,
        //   padding: EdgeInsets.zero,
        //   itemBuilder: (context, index) {
        //     CategoryData data = widget.categoryList![index];
        //     return SizedBox(
        //       width: double.infinity,
        //       child: GestureDetector(
        //         onTap: () {
        //           CreatePostRequestScreen(
        //             categoryId: data.id!,
        //           ).launch(context);
        //           // ViewAllServiceScreen(categoryId: data.id.validate(), categoryName: data.name, isFromCategory: true).launch(context);
        //         },
        //         child: CategoryWidget(
        //           categoryData: data,
        //           width: 200,
        //         ),
        //       ),
        //     );
        //   },
        // ).paddingSymmetric(horizontal: 10),
        // HorizontalList(
        //   itemCount: widget.categoryList.validate().length,
        //   padding: EdgeInsets.only(left: 16, right: 16),
        //   runSpacing: 8,
        //   spacing: 12,
        //   itemBuilder: (_, i) {
        //     CategoryData data = widget.categoryList![i];
        //     return GestureDetector(
        //       onTap: () {
        //         ViewAllServiceScreen(categoryId: data.id.validate(), categoryName: data.name, isFromCategory: true).launch(context);
        //       },
        //       child: CategoryWidget(categoryData: data),
        //     );
        //   },
        // ),
      ],
    );
  }
}
