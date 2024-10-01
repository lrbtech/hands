import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/base_scaffold_widget.dart';
import 'package:hands_user_app/components/empty_error_state_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/sign_up_categories_model.dart';
import 'package:hands_user_app/provider/networks/network_utils.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/components/info_widget.dart';
import 'package:hands_user_app/provider/jobRequest/models/post_job_data.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/firebase_messaging_utils.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  final TextEditingController searchController = TextEditingController();

  // Variables
  List<SignUpCategory> categoriesList = [];
  List<int> categoriesIDs = [];
  List<int> subscribedCategoriesIDs = [];
  List<SignUpCategory> searchedList = [];
  List<SignUpCategory> availableCategoriesList = [];
  List<SubscribedCategory> subscribedCategories = [];
  List<SignUpCategory> selectedCategories = [];
  List<int> selectedIDs = [];

  Future? future;

  // Methods
  init() {
    getSubscribedCategories().then((value) {
      getSignUpCategoryList(perPage: 'all').then(
        (categories) {
          categoriesList = [];

          categoriesList.addAll(categories.data ?? []);

          searchedList = categoriesList;

          categoriesList.forEach((element) {
            categoriesIDs.add(element.id.validate());
          });
          print('IDS are $categoriesIDs');

          print('List length = ${categoriesList?.length}');
          print(
              'LAST ONE IS = ${categoriesList?.last.nameAr}, ID = ${categoriesList?.last.id}');
          setState(() {});

          setState(() {});
        },
      );

      categoriesList.forEach((e) {
        print('ID from signup is ${e.id}');
      });

      subscribedCategories.forEach((subCat) {
        print('ID from SubscribedCategory is ${subCat.id}');

        subscribedCategoriesIDs.add(subCat.categoryId.validate());
        selectedIDs.add(subCat.categoryId.validate());

        print('subscribedCategoriesIDs = $subscribedCategoriesIDs');

        // print('');
        // categoriesList.removeWhere((element) => element.id == subCat.categoryId);
      });

      print('categoriesList = ${categoriesList.length}');

      future = value;
    });
  }

  getSubscribedCategories() async {
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
    } else {
      // print(response.reasonPhrase);
      print('getSubscribedCategories ERROR');
      toast(jsonDecode(data.body)['message']);
    }
  }

  subscribeToCategories() async {
    subscribedCategoriesIDs.forEach((element) {
      selectedIDs.remove(element);
    });

    if (selectedIDs.isNotEmpty) {
      showDialog(
        context: context,
        builder: (x) => LoaderWidget(),
      );

      var headers = buildHeaderTokens();

      var request = Request(
        'POST',
        buildBaseUrl('subscribed-category-save'),
      );
      request.body = json.encode({
        "category_ids": selectedIDs,
      });
      request.headers.addAll(headers);

      StreamedResponse response = await request.send();

      final data = await Response.fromStream(response);

      if (response.statusCode == 200) {
        unsubscribeFirebaseTopic().then((value) async {
          List<String> ids = [...appStorePro.categoriesIDs];

          selectedIDs.forEach((element) {
            ids.add(element.toString());
          });

          ids = ids.toSet().toList();
          print('Now ids = ${ids}');

          await appStorePro.setCategoriesIDs(ids.validate());

          ids.forEach((id) async {
            await FirebaseMessaging.instance.subscribeToTopic('category_$id');
            print('Sub to category_${id} id DONE');
          });

          // subscribeToFirebaseTopic();

          Navigator.of(context).pop();
          Navigator.of(context).pop();

          Navigator.of(context).pop();
          CategoriesScreen().launch(context);
        });
      } else {
        Navigator.of(context).pop();

        toast(jsonDecode(data.body)['message']);
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  deleteCategory({required int id}) async {
    showDialog(
      context: context,
      builder: (x) => LoaderWidget(),
    );
    var headers = buildHeaderTokens();
    var request = Request(
      'POST',
      Uri.parse(
        '${BASE_URL}subscribed-category-delete/$id',
      ),
    );

    request.headers.addAll(headers);

    StreamedResponse response = await request.send();

    final data = await Response.fromStream(response);

    if (response.statusCode == 200) {
      await unsubscribeFirebaseTopic().then((value) async {
        List<String> ids = [...appStorePro.categoriesIDs];

        selectedIDs.forEach((element) {
          ids.add(element.toString());
        });

        var x = subscribedCategories
            .where((element) => element.id == id)
            .first
            .categoryId;
        print('ids WAS = ${ids} and removed id is ${x}');
        ids.removeWhere((element) => element == x.toString());

        ids = ids.toSet().toList();
        print('Now ids = ${ids}');

        await appStorePro.setCategoriesIDs(ids.validate());

        // subscribeToFirebaseTopic();

        ids.forEach((id) async {
          await FirebaseMessaging.instance.subscribeToTopic('category_$id');
          print('Sub to category_${id} id DONE');
        });

        Navigator.of(context).pop();
        Navigator.of(context).pop();
        CategoriesScreen().launch(context);
      });
    } else {
      Navigator.of(context).pop();
      toast(jsonDecode(data.body)['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.myCategories,
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return NoDataWidget(
              title: snapshot.error.toString(),
              imageWidget: ErrorStateWidget(),
              retryText: languages.reload,
              onRetry: () {
                init();
                setState(() {});
              },
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoaderWidget();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoWidget(
                    info: languages.subscribedCategoriesDescription,
                  ),

                  20.height,

                  GestureDetector(
                    onTap: () {
                      // List<int> inactiveIDs = [];

                      // subscribedCategoriesIDs.forEach((sub) {
                      //   if (categoriesIDs.contains(sub)) {
                      //     inactiveIDs.add(sub);
                      //   }
                      // });

                      selectedIDs = [];

                      subscribedCategories.forEach((subCat) {
                        print('ID from SubscribedCategory is ${subCat.id}');

                        // subscribedCategoriesIDs.add(subCat.categoryId.validate());
                        selectedIDs.add(subCat.categoryId.validate());

                        print(
                            'subscribedCategoriesIDs = $subscribedCategoriesIDs');

                        // print('');
                        // categoriesList.removeWhere((element) => element.id == subCat.categoryId);
                      });

                      showDialog(
                        context: context,
                        builder: (context) => SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: AlertDialog(
                            backgroundColor: white,
                            elevation: 0,
                            scrollable: true,
                            content: StatefulBuilder(
                              builder: (BuildContext context,
                                      void Function(void Function())
                                          setState2) =>
                                  Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languages.search,
                                    style: boldTextStyle(
                                      color: black,
                                    ),
                                  ),
                                  4.height,
                                  AppTextField(
                                    textFieldType: TextFieldType.NAME,
                                    controller: searchController,
                                    textStyle: primaryTextStyle(),
                                    decoration:
                                        inputDecoration(context).copyWith(
                                      hintText: languages.search,
                                      hintStyle: primaryTextStyle(),
                                    ),
                                    onChanged: (cat) {
                                      print('cat is $cat');
                                      // var x = ;
                                      // searchedList.where((element) => element.id == )
                                      setState2(() {
                                        searchedList = categoriesList;

                                        if (searchController.text.isNotEmpty) {
                                          searchedList = categoriesList
                                              .where((element) =>
                                                  element.name
                                                      .validate()
                                                      .toLowerCase()
                                                      .contains(searchController
                                                          .text
                                                          .toLowerCase()) ||
                                                  element.nameAr
                                                      .validate()
                                                      .toLowerCase()
                                                      .contains(searchController
                                                          .text
                                                          .toLowerCase()))
                                              .toList();
                                        } else {
                                          searchedList = categoriesList;
                                        }

                                        if (cat.isEmpty) {
                                          searchedList = categoriesList;
                                        }
                                      });
                                    },
                                  ),
                                  15.height,
                                  Text(
                                    languages.hintSelectCategory,
                                    style: boldTextStyle(),
                                  ),
                                  10.height,
                                  Column(
                                    children: searchedList
                                        .map(
                                          (e) => Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: CheckboxListTile(
                                                fillColor:
                                                    MaterialStateProperty.all(
                                                        context.cardColor),
                                                checkColor: greenColor,
                                                activeColor: context.cardColor,
                                                tileColor:
                                                    appStorePro.isDarkMode
                                                        ? grey.withOpacity(0.2)
                                                        : white,

                                                // enabled: subscribedCategoriesIDs.contains(e.id.validate()),
                                                value: selectedIDs
                                                    .contains(e.id.validate()),
                                                title: Text('${e.name}'),
                                                onChanged: (x) async {
                                                  // selectedIDs = [];
                                                  // selectedCategories = values;
                                                  if (!selectedIDs.contains(
                                                      e.id.validate())) {
                                                    selectedIDs
                                                        .add(e.id.validate());
                                                  } else {
                                                    selectedIDs.remove(
                                                        e.id.validate());
                                                  }

                                                  // selectedCategories.forEach((element) {
                                                  //   selectedIDs.add(element.id ?? 0);
                                                  // });

                                                  print(
                                                      'selectedIDs = ${selectedIDs}');

                                                  // await subscribeToCategories();

                                                  // print("selectedCategories = ${selectedCategories.length}");
                                                  // selectedCategories = values;

                                                  // selectedCategories.forEach((element) {

                                                  //  });

                                                  // selectedIDs

                                                  setState2(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  15.height,
                                  AppButton(
                                    width: double.maxFinite,
                                    color: context.primaryColor,
                                    text: languages.confirm,
                                    onTap: () async {
                                      await subscribeToCategories();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languages.hintSelectCategory,
                            style: boldTextStyle(),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: appStorePro.isDarkMode ? white : black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // MultiSelectDialogField(
                  //   backgroundColor: white,
                  //   checkColor: white,
                  //   buttonIcon: Icon(Icons.arrow_drop_down),
                  //   title: Text(
                  //     languages.hintSelectCategory,
                  //     style: primaryTextStyle(color: black),
                  //   ),
                  //   searchIcon: Icon(
                  //     Icons.search,
                  //     color: black,
                  //   ),
                  //   closeSearchIcon: Icon(
                  //     Icons.close,
                  //     color: black,
                  //   ),
                  //   buttonText: Text(
                  //     selectedCategories!.isEmpty ? languages.hintSelectCategory : languages.editCategories,
                  //     style: secondaryTextStyle(),
                  //   ),
                  //   confirmText: Text(
                  //     languages.confirm,
                  //     style: primaryTextStyle(color: black),
                  //   ),
                  //   cancelText: Text(
                  //     languages.lblCancel,
                  //     style: primaryTextStyle(color: gray),
                  //   ),
                  //   searchable: true,
                  //   searchHint: languages.lblSearchHere,
                  //   searchTextStyle: primaryTextStyle(color: black),
                  //   separateSelectedItems: true,
                  //   selectedColor: greenColor,
                  //   searchHintStyle: primaryTextStyle(color: gray),
                  //   // selectedColor: primaryColor,
                  //   selectedItemsTextStyle: boldTextStyle(),

                  //   decoration: BoxDecoration(
                  //     color: context.cardColor,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   items: categoriesList
                  //       .map(
                  //         (e) => MultiSelectItem(
                  //           e,
                  //           appStorePro.selectedLanguageCode == 'en' ? e.name ?? '' : e.nameAr ?? '',
                  //         ),
                  //       )
                  //       .toList(),
                  //   listType: MultiSelectListType.LIST,

                  //   onConfirm: (values) async {
                  //     selectedIDs = [];
                  //     selectedCategories = values;

                  //     selectedCategories.forEach((element) {
                  //       selectedIDs.add(element.id ?? 0);
                  //     });

                  //     print('selectedIDs = ${selectedIDs}');

                  //     await subscribeToCategories();

                  //     // print("selectedCategories = ${selectedCategories.length}");
                  //     // selectedCategories = values;

                  //     // selectedCategories.forEach((element) {

                  //     //  });

                  //     // selectedIDs

                  //     setState(() {});
                  //   },
                  // ),

                  20.height,

                  // List of his categories
                  Text(
                    languages.myCategories,
                    style: boldTextStyle(),
                  ),
                  12.height,
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subscribedCategories.length,
                    itemBuilder: (context, index) => CategoryItem(
                      title: categoriesList
                              .where((element) =>
                                  element.id ==
                                  subscribedCategories[index].categoryId)
                              .first
                              .name ??
                          '',
                      onPressDelete: () {
                        showConfirmDialogCustom(
                          context,
                          dialogType: DialogType.DELETE,
                          title: languages.lblDelete,
                          subTitle: languages.lblDoYouWantToDelete,
                          positiveText: appStorePro.selectedLanguageCode == 'en'
                              ? "Yes"
                              : 'نعم',
                          negativeText: appStorePro.selectedLanguageCode == 'en'
                              ? "No"
                              : 'لا',
                          primaryColor: Color(0xFFe04f5f),
                          onAccept: (BuildContext) async {
                            if (await isNetworkAvailable()) {
                              deleteCategory(
                                  id: subscribedCategories[index].id ?? 0);
                            } else {
                              toast(errorInternetNotAvailable);
                            }
                          },
                        );
                      },
                    ),
                    separatorBuilder: (context, index) => 10.height,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final VoidCallback onPressDelete;

  const CategoryItem(
      {super.key, required this.title, required this.onPressDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: 12,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: boldTextStyle(),
          ).expand(),
          IconButton(
            onPressed: onPressDelete,
            icon: Icon(
              Icons.delete,
              color: redColor,
            ),
          ),
        ],
      ),
    );
  }
}

class SubscribedCategory {
  int? id;
  int? providerId;
  int? categoryId;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  SubscribedCategory({
    this.id,
    this.providerId,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  SubscribedCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    providerId = json['provider_id'] ?? 0;
    categoryId = json['category_id'] ?? 0;
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    deletedAt = json['deleted_at'] ?? '';
  }
}
