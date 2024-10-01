import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/category_model.dart';
import 'package:hands_user_app/network/network_utils.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/provider/Utils/Custom_Dailog_Botton.dart';
import 'package:hands_user_app/screens/provider/Utils/Gender_Radio.dart';
import 'package:hands_user_app/screens/provider/Utils/Single_Radiobutton.dart';
import 'package:hands_user_app/screens/provider/Widgets/Custom_Textfield.dart';
import 'package:hands_user_app/screens/provider/Widgets/Dailog_Container.dart';
import 'package:hands_user_app/screens/provider/Widgets/Image_Urls.dart';
import 'package:hands_user_app/screens/provider/Widgets/Title_Text.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/model_keys_provider.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;

class ResidentPage extends StatefulWidget {
  ResidentPage({super.key, required void Function() onNext});

  @override
  State<ResidentPage> createState() => _ResidentPageState();
}

class _ResidentPageState extends State<ResidentPage> {
  String? _selectedGender;
  TextEditingController _dobController = TextEditingController();
  TextEditingController _emiratesIdNoController = TextEditingController();
  bool isAgreed = false;

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? uploadEmiratesId;
  captureFiles() async {
    _picker
        .pickImage(
      source: ImageSource.gallery,
    )
        .then((XFile? recordedVideo) {
      if (recordedVideo != null && recordedVideo.path != null) {
        setState(() {
          uploadEmiratesId = recordedVideo;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  bool error_professional = false;
  bool error_emirates = false;
  bool error_emiratesNo = false;
  bool error_emirateIdFile = false;
  bool error_dob = false;
  bool error_gender = false;
  bool error_policy = false;
  submitProvider() {
    setState(() {
      error_professional = false;
      error_emirates = false;
      error_emiratesNo = false;
      error_emirateIdFile = false;
      error_dob = false;
      error_gender = false;
      error_policy = false;
    });
    if (_controller.text == "") {
      setState(() {
        error_professional = true;
      });
    } else if (emirate == null) {
      setState(() {
        error_emirates = true;
      });
    } else if (_emiratesIdNoController.text == "") {
      setState(() {
        error_emiratesNo = true;
      });
    } else if (uploadEmiratesId == null) {
      setState(() {
        error_emirateIdFile = true;
      });
    } else if (_dobController.text == "") {
      setState(() {
        error_dob = true;
      });
    } else if (_selectedGender == null) {
      setState(() {
        error_gender = true;
      });
    } else if (!isAgreed) {
      setState(() {
        error_policy = true;
      });
    } else {
      sendProviderData();
    }
  }

  sendProviderData() {
    appStore.setLoading(true);
    http
        .post(
      Uri.parse("${BASE_URL}provider-update"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'APP_KEY': "8Shm171pe2oTGvJlql7nxe2Ys/tHJaiiVq6vr5wIu5EJhEEmI3gVi"
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': appStore.userId,
        'residential_status': 0,
        'category_name': _controller.text,
        'emirates': emirate,
        'emirates_id_no': _emiratesIdNoController.text,
        'gender': _selectedGender,
        'date_of_birth': _dobController.text
      }),
    )
        .then((response) {
      addDocument(4);
    });
  }

  void addDocument(int? docId, {int? updateId}) async {
    MultipartRequest multiPartRequest =
        await getMultiPartRequest('provider-document-save');
    multiPartRequest.fields[CommonKeys.id] =
        updateId != null ? updateId.toString() : '';
    multiPartRequest.fields[CommonKeys.providerId] = appStore.userId.toString();
    multiPartRequest.fields[AddDocument.documentId] = docId.toString();
    multiPartRequest.fields[AddDocument.isVerified] = '0';

    if (uploadEmiratesId != null) {
      multiPartRequest.files.add(await MultipartFile.fromPath(
          AddDocument.providerDocument, uploadEmiratesId!.path));
    }
    log(multiPartRequest);

    multiPartRequest.headers.addAll(buildHeaderTokens());

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        print("provider-document-save ${data}");
        toast("Submited Successfully!", print: true);
        Navigator.of(context).pop();
        // toast(languages.toastSuccess, print: true);
        // providerDocuments.clear();
        // getProviderDocList();
      },
      onError: (error) {
        toast(error.toString(), print: true);
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  List<CategoryData>? categoryList;

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

  List<String>? future;
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
  List emirates = [
    "Dubai",
    "Abu Dhabi",
    "Sharjah",
    "Ajman",
    "Umm Al Quwain",
    "Ras Al Khaimah",
    "Fujairah"
  ];
  String? emirate;
  // bool error_emirate = false;
  // bool error_pro = false;
  String? select_pro;
  TextEditingController _controller = TextEditingController();
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.height,
              Row(
                children: [
                  heading(context: context, text: "Choose Professional"),
                  Text(
                    '*',
                    style: boldTextStyle(color: redColor),
                  )
                ],
              ),
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
                          color: appStore.isDarkMode
                              ? white
                              : context.primaryColor,
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
                        color: error_professional
                            ? Colors.red
                            : Colors.transparent),
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
              Row(
                children: [
                  heading(context: context, text: "Choose Emirates"),
                  Text(
                    '*',
                    style: boldTextStyle(color: redColor),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
                child: CustomDropdown.search(
                  hintText: "Select Emirates",
                  searchHintText: language.lblSearchFor,
                  items: emirates,
                  excludeSelected: false,
                  noResultFoundText: language.noCategoryFound,
                  noResultFoundBuilder: (context, text) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        text,
                        style: primaryTextStyle(
                          color: appStore.isDarkMode
                              ? white
                              : context.primaryColor,
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
                            error_emirates ? Colors.red : Colors.transparent),
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
                    setState(() {
                      emirate = value.toString();
                    });
                  },
                ),
              ),
              Row(
                children: [
                  heading(context: context, text: "Emirates ID NO."),
                  Text(
                    '*',
                    style: boldTextStyle(color: redColor),
                  )
                ],
              ),
              customTextField(
                context: context,
                hintText: "00-0000-0000000-0",
                assets1: "",
                controller: _emiratesIdNoController,
                // assets2: AppIcons.dropdownIcon,
                error: error_emiratesNo,
                obscureText: false,
              ),
              GestureDetector(
                onTap: () {
                  captureFiles();
                },
                child: customDialogContainer(
                    context: context,
                    title: "Upload Emirates ID",
                    description:
                        "Upload your scope of work images.\nOr use camera to capture them.",
                    imagePath: uploadEmiratesId != null
                        ? uploadEmiratesId!.path
                        : AppIcons.browseIcon,
                    buttonText: "Brows images",
                    error: error_emirateIdFile,
                    error_text: "Please upload Emirates ID",
                    network: uploadEmiratesId != null ? true : false),
              ),
              Row(
                children: [
                  heading(context: context, text: "Gender"),
                  Text(
                    '*',
                    style: boldTextStyle(color: redColor),
                  )
                ],
              ),
              genderSelection(
                error: error_gender,
                context: context,
                activeColor: Colors.white,
                selectedGender: _selectedGender,
                onChanged: (String? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              Row(
                children: [
                  heading(context: context, text: "Date Of Birth"),
                  Text(
                    '*',
                    style: boldTextStyle(color: redColor),
                  )
                ],
              ),
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
              agreeToPolicyRadioButton(
                error: error_policy,
                isSelected: isAgreed,
                onChanged: (bool? newValue) {
                  setState(() {
                    isAgreed = newValue ?? false;
                  });
                },
                context: context,
                text: 'Agree to policy',
                activeColor: Colors.white,
                textColor: Theme.of(context).colorScheme.onSecondary,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Almarai',
              ),
              customDialogButton(
                text: 'Submit',
                context: context,
                onPressed: () => submitProvider(),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Observer(
          builder: (context) =>
              LoaderWidget().center().visible(appStore.isLoading)),
    );
  }
}
