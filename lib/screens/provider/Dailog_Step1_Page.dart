import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/category_model.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/provider/Utils/Custom_Dailog_Botton.dart';
import 'package:hands_user_app/screens/provider/Utils/Gender_Radio.dart';
import 'package:hands_user_app/screens/provider/Widgets/Custom_Textfield.dart';
import 'package:hands_user_app/screens/provider/Widgets/Image_Urls.dart';
import 'package:hands_user_app/screens/provider/Widgets/Title_Text.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import 'Widgets/countery.dart';

class Step1 extends StatefulWidget {
  Function(Map) onNext;
  Step1(
    this.onNext,
  );

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  String? _selectedGender;
  List professional = [
    "Painter",
    "Carpenter",
    "Driver",
    "Ac Mechanic",
    "Car Mechanic",
    "Plumper",
    "Electrician",
    "Engineer",
    "Designer",
    "Architect",
    "IT Technician",
    "Cook"
  ];
  bool error_pro = false;
  String? select_pro;
  bool error_country = false;
  String? select_country;
  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  bool error_professional = false;
  bool error_national = false;
  bool error_passportNo = false;
  bool error_dob = false;
  bool error_gender = false;
  validateStep1() {
    setState(() {
      error_professional = false;
      error_national = false;
      error_passportNo = false;
      error_dob = false;
      error_gender = false;
    });
    if (_controller.text == "") {
      setState(() {
        error_professional = true;
      });
    } else if (select_country == null) {
      setState(() {
        error_national = true;
      });
    } else if (_passportController.text == '') {
      setState(() {
        error_passportNo = true;
      });
    } else if (_dobController.text == '') {
      setState(() {
        error_dob = true;
      });
    } else if (_selectedGender == null) {
      setState(() {
        error_gender = true;
      });
    } else {
      widget.onNext(<String, dynamic>{
        'user_id': appStore.userId,
        'residential_status': 1,
        'category_name': _controller.text,
        'nationality': select_country,
        'passport_number': _passportController.text,
        'gender': _selectedGender,
        'date_of_birth': _dobController.text,
      });
    }
  }

  List<CategoryData>? categoryList;
  List<String>? future;
  TextEditingController _controller = TextEditingController();
  Future<List<String>> getProvidersCategoryList() async {
    categoryList = [];
    await getCategoryList(CATEGORY_LIST_ALL).then((value) {
      if (value.categoryList!.isNotEmpty) {
        categoryList!.addAll(value.categoryList.validate());
      }

      setState(() {});
    });

    List<String> x = [];

    categoryList?.forEach((element) {
      String? name =
          appStore.selectedLanguageCode == 'en' ? element.name : element.nameAr;
      x.add(name ?? '');
    });

    return x;
  }

  Future<void> init() async {
    // appStore.setLoading(true);

    future = await getProvidersCategoryList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text =
            "${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.height,
            heading(context: context, text: "Choose Professional"),
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
              child: CustomDropdown.search(
                hintText: "Select Professional",
                searchHintText: language.lblSearchFor,
                items: future ?? [],
                excludeSelected: false,
                noResultFoundText: language.noCategoryFound,
                noResultFoundBuilder: (context, text) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      text,
                      style: primaryTextStyle(
                        color:
                            appStore.isDarkMode ? white : context.primaryColor,
                      ),
                    ),
                  ),
                ),
                decoration: CustomDropdownDecoration(
                  closedSuffixIcon: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  closedFillColor: white,
                  closedBorder: Border.all(
                      color:
                          error_professional ? Colors.red : Colors.transparent),
                  expandedFillColor: context.scaffoldBackgroundColor,
                  listItemStyle: primaryTextStyle(
                    color: appStore.isDarkMode ? white : context.primaryColor,
                  ),
                  listItemDecoration: ListItemDecoration(
                    selectedColor: greenColor,
                  ),
                  headerStyle: primaryTextStyle(
                    color: appStore.isDarkMode
                        ? Colors.black
                        : context.primaryColor,
                  ),
                ),
                onChanged: (value) {
                  log('changing value to: $value');
                  _controller.text = value.toString();
                  setState(() {});
                },
              ),
            ),
            10.height,
            heading(context: context, text: "Choose Nationality"),
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
              child: CustomDropdown.search(
                hintText: "Select Nationality",
                searchHintText: language.lblSearchFor,
                items: country,
                excludeSelected: false,
                noResultFoundText: language.noCategoryFound,
                noResultFoundBuilder: (context, text) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      text,
                      style: primaryTextStyle(
                        color:
                            appStore.isDarkMode ? white : context.primaryColor,
                      ),
                    ),
                  ),
                ),
                decoration: CustomDropdownDecoration(
                  closedSuffixIcon: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: const Color.fromARGB(255, 98, 97, 97),
                  ),
                  closedFillColor: white,
                  closedBorder: Border.all(
                      color: error_national ? Colors.red : Colors.transparent),
                  expandedFillColor: context.scaffoldBackgroundColor,
                  listItemStyle: primaryTextStyle(
                    color: appStore.isDarkMode ? white : context.primaryColor,
                  ),
                  listItemDecoration: ListItemDecoration(
                    selectedColor: greenColor,
                  ),
                  headerStyle: primaryTextStyle(
                    color: appStore.isDarkMode
                        ? Colors.black
                        : context.primaryColor,
                  ),
                ),
                onChanged: (value) {
                  log('changing value to: $value');
                  setState(() {
                    select_country = value.toString();
                  });
                },
              ),
            ),
            10.height,
            heading(context: context, text: "Passport Number"),
            customTextField(
                error: error_passportNo,
                context: context,
                hintText: "Enter the number",
                assets1: "",
                controller: _passportController,
                obscureText: false),
            heading(context: context, text: "Date Of Birth"),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: customTextField(
                  error: error_dob,
                  context: context,
                  hintText: "DD/MM/YY",
                  assets1: "",
                  obscureText: false,
                  controller: _dobController,
                ),
              ),
            ),
            heading(context: context, text: "Gender"),
            genderSelection(
              error: error_gender,
              activeColor: Colors.white,
              context: context,
              selectedGender: _selectedGender,
              onChanged: (String? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            customDialogButton(
                text: "Next",
                context: context,
                onPressed: () {
                  validateStep1();
                }),
          ],
        ),
      ),
    );
  }
}
