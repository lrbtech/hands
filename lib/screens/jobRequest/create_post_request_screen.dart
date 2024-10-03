import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dropdown_search/flutter_dropdown_search.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hands_user_app/app_theme.dart';
import 'package:hands_user_app/component/back_widget.dart';
import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/component/custom_image_picker.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/category_model.dart';
import 'package:hands_user_app/model/get_my_post_job_list_response.dart';
import 'package:hands_user_app/model/package_data_model.dart';
import 'package:hands_user_app/model/service_data_model.dart';
import 'package:hands_user_app/network/network_utils.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/address/addresses_screen.dart';
import 'package:hands_user_app/screens/booking/component/custom_booking_stepper.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/jobRequest/model/timeslot.dart';
import 'package:hands_user_app/screens/jobRequest/my_post_request_list_screen.dart';
import 'package:hands_user_app/screens/jobRequest/reltime_bidders_list.dart';
import 'package:hands_user_app/screens/provider/Utils/Gender_Radio.dart';
import 'package:hands_user_app/screens/provider/Utils/memberSelect.dart';
import 'package:hands_user_app/screens/provider/Utils/offerSelect.dart';
import 'package:hands_user_app/services/firebase/firebase_database_service.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:hands_user_app/component/custom_confirmation_dialog.dart';
import 'package:timer_count_down/timer_count_down.dart';

enum JobDateType { Today, Tomorrow, Scheduled }

class CreatePostRequestScreen extends StatefulWidget {
  final int? categoryId;
  final bool isUrgent;
  final JobDateType jobDateType;

  CreatePostRequestScreen(
      {this.categoryId, this.isUrgent = false, required this.jobDateType});

  @override
  _CreatePostRequestScreenState createState() =>
      _CreatePostRequestScreenState();
}

class _CreatePostRequestScreenState extends State<CreatePostRequestScreen> {
  late StreamSubscription<bool> keyboardSubscription;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UniqueKey uniqueKey = UniqueKey();

  ImagePicker picker = ImagePicker();

  // Step 1 Controllers
  TextEditingController postTitleCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController priceCont = TextEditingController();
  TextEditingController _controller = TextEditingController();

  // Step 2 Controllers
  TextEditingController addressCont = TextEditingController();

  FocusNode descriptionFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  String? _selectedMember = "Yes";
  String? _selectedOffer = "Yes";
  List<ServiceData> myServiceList = [];
  List<ServiceData> selectedServiceList = [];
  List<File> imageFiles = [];
  List<Attachments> attachmentsArray = [];
  int? members = 1;
  int _selectedTimeFrameId = -1;
  DateTime? _selectedDate;

  StreamSubscription<DatabaseEvent>? dataBaseEvent;
  final database = FirebaseDatabase.instance;

  List<Attachments> tempAttachments = [];

  List<Timeslot> slots = [
    Timeslot(
        slot: Timeslots.Morning,
        name: 'Morning',
        nameAr: 'الصباح',
        time: '6am - 12am',
        timeString: '6AM - 12PM',
        timeStringAr: '٦ صباحاً - ١٢ ظهراً'),
    Timeslot(
        slot: Timeslots.Noon,
        name: 'Noon',
        nameAr: 'النهار',
        time: '12pm - 6pm',
        timeString: '12PM - 6PM',
        timeStringAr: '١٢ ظهراً - ٦ مساءً'),
    Timeslot(
        slot: Timeslots.Night,
        name: 'Night',
        nameAr: 'الليل',
        time: '6pm - 12pm',
        timeString: '6PM - 12AM',
        timeStringAr: '٦ مساءً - ١٢ صباحاً'),
  ];

  void selectTimeFrame({required int timeFrameId}) {
    _selectedTimeFrameId = timeFrameId;
    setState(() {});
  }

  //region Remove Attachment
  Future<void> removeAttachment({required int id}) async {
    appStore.setLoading(true);

    Map req = {
      CommonKeys.type: 'service_attachment',
      CommonKeys.id: id,
    };

    await deleteImage(req).then((value) {
      tempAttachments.validate().removeWhere((element) => element.id == id);
      setState(() {});

      uniqueKey = UniqueKey();

      appStore.setLoading(false);
      toast(value.message.validate(), print: true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  bool keyboardVisible = false;

  @override
  void initState() {
    var keyboardVisibilityController = KeyboardVisibilityController();

    print(
        'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
      keyboardVisible = visible;
      afterBuildCreated(() => setState(() {}));
    });

    super.initState();
    init();
  }

  void dispose() {
    keyboardSubscription.cancel();

    super.dispose();
  }

  List<String>? future;
  Future<void> init() async {
    // appStore.setLoading(true);

    future = await getProvidersCategoryList();

    appStore.currentBookingStep = 0;

    if (widget.jobDateType == JobDateType.Today) {
      _selectedDate = DateTime.now();
    } else if (widget.jobDateType == JobDateType.Scheduled) {
      _selectedDate = null;
    }

    // await getMyServiceList().then((value) {
    //   appStore.setLoading(false);

    //   if (value.userServices != null) {
    //     myServiceList = value.userServices.validate();
    //   }
    // }).catchError((e) {
    //   appStore.setLoading(false);
    //   toast(e.toString());
    // });

    setState(() {});
  }

  Future<void> getMultipleFile() async {
    await picker.pickMultiImage().then((value) {
      // imageFiles.addAll(value);
      value.forEach((val) {
        imageFiles.add(File(val.path));
      });
      setState(() {});
    });
  }

  // CategoryData? selectedCategory;

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

  Time? selectedTime;

  String timeToString(Time? time) {
    if (time != null) {
      if (time.hour.toString().length == 1) {
        return '0${time.hour}:00';
      }

      return '${time.hour}:00';
    }
    return '';
  }

  void dateTap() async {
    if (widget.jobDateType != JobDateType.Scheduled) {
      return;
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.jobDateType == JobDateType.Scheduled
          ? DateTime.now().add(Duration(days: 1))
          : DateTime.now(),
      lastDate: DateTime.now().add(
        Duration(days: 7),
      ),
      builder: (_, child) {
        return Theme(
          data: appStore.isDarkMode ? context.theme : context.theme,
          child: child!,
        );
      },
    );
    if (selectedDate != null) {
      print(formatBookingDate(selectedDate.toString(), format: DATE_FORMAT_1));
      _selectedTimeFrameId = -1;
      _selectedDate = selectedDate;

      setState(() {});
    }
  }

  void createPostJobClick() async {
    if (_selectedDate == null) {
      toast(language.pleaseSelectBookingDate, bgColor: redColor);
      return;
    }
    if (selectedTime == null) {
      if (widget.isUrgent) {
        // selectTimeFrame(timeFrameId: 1);
      } else {
        toast(language.pleaseSelectTheSlotsFirst, bgColor: redColor);
        return;
      }
    }
    appStore.setLoading(true);
    List<int> serviceList = [];

    if (selectedServiceList.isNotEmpty) {
      selectedServiceList.forEach((element) {
        serviceList.add(element.id.validate());
      });
    }

    MultipartRequest multiPartRequest =
        await getMultiPartRequest('save-post-job');

    multiPartRequest.fields[PostJob.postTitle] = postTitleCont.text.validate();
    multiPartRequest.fields[PostJob.description] =
        descriptionCont.text.validate();
    multiPartRequest.fields[PostJob.addressId] =
        appStore.tempAddress!.id.toString();
    multiPartRequest.fields[PostJob.members] =
        _selectedMember == "Yes" ? members.toString() : '0';
    multiPartRequest.fields[PostJob.price] = priceCont.text;
    // multiPartRequest.fields[PostJob.isPublic] = '1';
    String? id = '';
    if (appStore.selectedLanguageCode == 'en') {
      id = categoryList
          ?.where((element) => element.name == _controller.text)
          .first
          .id
          .toString();
    } else {
      id = categoryList
          ?.where((element) => element.nameAr == _controller.text)
          .first
          .id
          .toString();
    }
    print('Selected category id = $id');
    multiPartRequest.fields[PostJob.category] = id.validate();
    multiPartRequest.fields[PostJob.status] = JOB_REQUEST_STATUS_REQUESTED;
    // multiPartRequest.fields[PostJob.latitude]= appStore.latitude.toString();
    // multiPartRequest.fields[PostJob.longitude]= appStore.longitude;
    if (widget.categoryId != null && widget.categoryId is int) {
      multiPartRequest.fields[PostJob.categoryId] =
          widget.categoryId.toString();
    }
    multiPartRequest.fields[PostJob.date] =
        formatBookingDate(_selectedDate.toString(), format: DATE_FORMAT_1);
    if (!widget.isUrgent) {
      // multiPartRequest.fields[PostJob.timeslotId] = (_selectedTimeFrameId + 1).toString();
      multiPartRequest.fields[PostJob.timeslotId] =
          (selectedTime!.hour + 1).toString();
    }
    multiPartRequest.fields[PostJob.isUrgent] = widget.isUrgent ? '1' : '0';

    if (imageFiles.isNotEmpty) {
      List<File> tempImages = imageFiles
          .where((element) => !element.path.contains("https"))
          .toList();

      multiPartRequest.files.clear();
      await Future.forEach<File>(tempImages, (element) async {
        int i = tempImages.indexOf(element);
        multiPartRequest.files.add(await MultipartFile.fromPath(
            '${CreateService.serviceAttachment + i.toString()}', element.path));
      });

      if (tempImages.isNotEmpty)
        multiPartRequest.fields[CreateService.attachmentCount] =
            tempImages.length.toString();
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        if (1 == 1) {
          print('Data from sendMultiPartRequest is ${data}');
          PostJobData jobData = PostJobData.fromJson(json.decode(data)['data']);
          print('MY ADDRESS = ${json.decode(data)['data']}');
          await firebaseDbService
              .firebaseJobRequest(jobRequest: jobData)
              .then((value) {
            showInDialog(context, contentPadding: EdgeInsets.zero,
                builder: (context) {
              return PopScope(
                canPop: false,
                onPopInvoked: (_) {},
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.passthrough,
                  children: [
                    ClipRRect(
                      borderRadius: radius(20),
                      child: Container(
                        width: context.width() * .9,
                        height: 300,
                        decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: context.scaffoldBackgroundColor,
                            borderRadius: radius(20)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            10.height,
                            Lottie.asset('assets/lottie/empty_lottie.json',
                                height: 100, repeat: true),
                            10.height,
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Countdown(
                                seconds: [null, 0, 0.0, '']
                                        .contains(appStore.radarTime)
                                    ? DEFAULT_RADAR_TIMER_IN_SECONDS
                                    : appStore.radarTime!,
                                interval: Duration(milliseconds: 100),
                                onFinished: () {
                                  dataBaseEvent?.cancel();
                                  dataBaseEvent = null;
                                  DashboardScreen(
                                    postJobId: jobData.id!.toInt(),
                                  ).launch(context);
                                },
                                build: (BuildContext context, double time) =>
                                    Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Text(time.toString()),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: appStore.isDarkMode
                                            ? white
                                            : primaryColor,
                                        border: Border.all(
                                            color: appStore.isDarkMode
                                                ? white
                                                : primaryColor,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                          child: Text(
                                        time
                                            .toString()
                                            .split('.')
                                            .first
                                            .toString(),
                                        style: boldTextStyle(
                                            size: 20,
                                            color: !appStore.isDarkMode
                                                ? white
                                                : primaryColor),
                                      )),
                                    ),
                                    10.width,
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: appStore.isDarkMode
                                            ? white
                                            : primaryColor,
                                        border: Border.all(
                                            color: appStore.isDarkMode
                                                ? white
                                                : primaryColor,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                          child: Text(
                                        '0${time.toString().split('.').last.toString()}',
                                        style: boldTextStyle(
                                          size: 20,
                                          color: !appStore.isDarkMode
                                              ? white
                                              : primaryColor,
                                        ),
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            20.height,
                            Text(
                              appStore.selectedLanguageCode == 'en'
                                  ? 'We are finding the best Hands for your request. Please be patient wth us.'
                                  : 'نحن نبحث عن أفضل مقدمين خدمات لتلبية طلبك. يرجى التحلي بالصبر معنا.',
                              textAlign: TextAlign.center,
                              style:
                                  primaryTextStyle(color: textSecondaryColor),
                            ).paddingSymmetric(horizontal: 10),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        style: IconButton.styleFrom(
                            backgroundColor: Color(0xFFde3a3b),
                            fixedSize: Size(24, 24)),
                        onPressed: () {
                          showCustomConfirmDialog(
                            context,
                            primaryColor: context.primaryColor,
                            title: language.bidScreenBackToHomeMessage,
                            positiveText: language.lblYes,
                            negativeText: language.lblCancel,
                            onAccept: (c) async {
                              dataBaseEvent?.cancel();
                              dataBaseEvent = null;
                              DashboardScreen(
                                postJobId: jobData.id!.toInt(),
                              ).launch(c, isNewTask: true);
                            },
                          );
                        },
                        icon: Center(
                          child: Icon(
                            Icons.close,
                            size: 24,
                            color: white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }, barrierDismissible: false);
          });

          print('kareem = ${jobData.id}');

          final reference =
              database.ref().child('$JOB_REQUESTS/${jobData.id}/bidders');
          dataBaseEvent = reference.onChildAdded.listen((event) {
            if (!appStore.isLoggedIn) {
              dataBaseEvent!.cancel();
              return;
            }
            if (event.snapshot.value != null) {
              print("----------->${event.snapshot.value}");
              var data = event.snapshot.value;
              finish(context);
              appStore.setLoading(false);
              dataBaseEvent?.cancel();
              BiddersListScreen(
                postJobData: jobData,
              ).launch(context);
            }
          });

          return;
        }
        appStore.setLoading(false);
        try {
          toast(jsonDecode(data)['message'].validate());
        } catch (e) {
          print(e.toString());
        }

        DashboardScreen().launch(context);
        MyPostRequestListScreen().launch(context);
      },
      onError: (error) {
        appStore.setLoading(false);
        toast(error.toString(), print: true);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
    // savePostJob(request).then((value) {}).catchError((e) {});
  }

  void deleteService(ServiceData data) {
    appStore.setLoading(true);

    deleteServiceRequest(data.id.validate()).then((value) {
      appStore.setLoading(false);
      toast(value.message.validate());
      init();
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  // KeyboardStateNotifier;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
      },
      child: AppScaffold(
        appBarTitle: language.newPostJobRequest,
        child: Stack(
          children: [
            AnimatedScrollView(
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              padding: EdgeInsets.only(bottom: 60),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('Category Id : ${widget.categoryId}'),
                    // Text('Sub Category Id : ${widget.subCategoryId}'),
                    30.height,
                    CustomStepperWidget().paddingSymmetric(horizontal: 40),

                    30.height,
                    if (appStore.currentBookingStep == 0)
                      Column(
                        children: [
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: context.cardColor,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 20),
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: Form(
                              key: formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (future != null)
                                    Row(
                                      children: [
                                        Text(
                                          language.lblCategory,
                                          style: boldTextStyle(),
                                        ),
                                        4.width,
                                        Text(
                                          '*',
                                          style: boldTextStyle(color: redColor),
                                        )
                                      ],
                                    ),
                                  if (future != null) 5.height,

                                  // TEST
                                  if (future != null)
                                    CustomDropdown.search(
                                      hintText: language.selectCategory,
                                      searchHintText: language.lblSearchFor,
                                      items: future ?? [],
                                      excludeSelected: false,
                                      noResultFoundText:
                                          language.noCategoryFound,
                                      noResultFoundBuilder: (context, text) =>
                                          Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Center(
                                          child: Text(
                                            text,
                                            style: primaryTextStyle(
                                              color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ,
                                            ),
                                          ),
                                        ),
                                      ),
                                      decoration: CustomDropdownDecoration(
                                        closedFillColor:
                                            context.scaffoldBackgroundColor,
                                        expandedFillColor:
                                            context.scaffoldBackgroundColor,
                                        listItemStyle: primaryTextStyle(
                                          color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ,
                                        ),
                                        listItemDecoration: ListItemDecoration(
                                          selectedColor: greenColor,
                                        ),
                                        headerStyle: primaryTextStyle(
                                          color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        log('changing value to: $value');
                                        _controller.text = value.toString();
                                        setState(() {});
                                      },
                                    ),

                                  // if (future != null)
                                  //   Container(
                                  //     padding: EdgeInsets.symmetric(horizontal: 8),
                                  //     decoration: BoxDecoration(
                                  //       color: appStore.isDarkMode ? context.scaffoldBackgroundColor : white,
                                  //       borderRadius: BorderRadius.circular(12),
                                  //     ),
                                  //     child: FlutterDropdownSearch(
                                  //       hintStyle: primaryTextStyle(color: dimGrey.withOpacity(0.8)),
                                  //       hintText: language.selectCategory,
                                  //       dropdownTextStyle: primaryTextStyle(),
                                  //       style: primaryTextStyle(),
                                  //       textFieldBorder: OutlineInputBorder(
                                  //         borderRadius: BorderRadius.circular(12),
                                  //         borderSide: BorderSide.none,
                                  //       ),
                                  //       dropdownBgColor: appStore.isDarkMode ? context.cardColor : white,
                                  //       textController: _controller,
                                  //       items: future,
                                  //       dropdownHeight: 120,
                                  //     ),
                                  //   ),

                                  16.height,
                                  Row(
                                    children: [
                                      Text(
                                        language.postJobTitle,
                                        style: boldTextStyle(),
                                      ),
                                      4.width,
                                      Text(
                                        '*',
                                        style: boldTextStyle(color: redColor),
                                      )
                                    ],
                                  ),
                                  5.height,
                                  AppTextField(
                                    controller: postTitleCont,
                                    textFieldType: TextFieldType.NAME,
                                    errorThisFieldRequired:
                                        language.requiredText,
                                    nextFocus: descriptionFocus,
                                    decoration: inputDecoration(
                                      context,
                                    ).copyWith(
                                      hintText: language.postJobTitleHint,
                                      hintStyle: primaryTextStyle(
                                          color: dimGrey.withOpacity(0.8)),
                                      fillColor:
                                          context.scaffoldBackgroundColor,
                                    ),
                                  ),
                                  16.height,
                                  Row(
                                    children: [
                                      Text(
                                        language.postJobDescription,
                                        style: boldTextStyle(),
                                      ),
                                      4.width,
                                      Text(
                                        '*',
                                        style: boldTextStyle(color: redColor),
                                      )
                                    ],
                                  ),
                                  5.height,
                                  AppTextField(
                                    controller: descriptionCont,
                                    textFieldType: TextFieldType.MULTILINE,
                                    errorThisFieldRequired:
                                        language.requiredText,
                                    maxLines: 5,
                                    focus: descriptionFocus,
                                    nextFocus: priceFocus,
                                    // enableChatGPT: otherSettingStore.enableChatGpt == 1 ? true : false,
                                    // promptFieldInputDecorationChatGPT: inputDecoration(context).copyWith(
                                    //   hintText: language.writeHere,
                                    //   fillColor: context.scaffoldBackgroundColor,
                                    //   filled: true,
                                    // ),
                                    // testWithoutKeyChatGPT: otherSettingStore.testWithoutKey == 1 ? true : false,
                                    // loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                                    decoration: inputDecoration(
                                      context,
                                    ).copyWith(
                                      fillColor:
                                          context.scaffoldBackgroundColor,
                                      hintText: language.postJobDescriptionHint,
                                      hintStyle: primaryTextStyle(
                                          color: dimGrey.withOpacity(0.8)),
                                    ),
                                  ),
                                  16.height,
                                  Row(
                                    children: [
                                      Text(
                                        "Do you want add members?",
                                        style: boldTextStyle(),
                                      ),
                                      4.width,
                                      // Text(
                                      //   '*',
                                      //   style: boldTextStyle(color: redColor),
                                      // )
                                    ],
                                  ),
                                  8.height,
                                  Container(
                                    width: 200,
                                    decoration: BoxDecoration(
                                      color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: memberSelect(
                                      context: context,
                                      activeColor: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
                                      selectedGender: _selectedMember,
                                      textColor: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedMember = value;
                                        });
                                      },
                                    ),
                                  ),

                                  16.height,
                                  _selectedMember == "Yes"
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "How many members you want?",
                                                  style: boldTextStyle(),
                                                ),
                                                4.width,
                                                // Text(
                                                //   '*',
                                                //   style: boldTextStyle(color: redColor),
                                                // )
                                              ],
                                            ),
                                            16.height,
                                            Container(
                                              // width: 200,
                                              height: 40,
                                              width: 120,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFAF9F6),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (members! > 1) {
                                                        setState(() {
                                                          members =
                                                              members! - 1;
                                                        });
                                                      }
                                                    },
                                                    child: Image.asset(
                                                      "assets/icons/minus.png",
                                                      width: 25,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${members}",
                                                    style:
                                                        TextStyle(fontSize: 22),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        members = members! + 1;
                                                      });
                                                    },
                                                    child: Image.asset(
                                                      "assets/icons/add.png",
                                                      width: 25,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(),

                                  16.height,
                                ],
                              ).paddingAll(16),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: context.width(),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 30),
                                      child: AppButton(
                                        child: Text(
                                          appStore.currentBookingStep == 0
                                              ? language.btnNext
                                              : (appStore.selectedLanguageCode ==
                                                      'en'
                                                  ? 'Find Hands'
                                                  : 'إبحث الآن'),
                                          style: boldTextStyle(color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6)),
                                        ),
                                        color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C),
                                        elevation: 5,
                                        onTap: () {
                                          if (appStore.currentBookingStep ==
                                              0) {
                                            hideKeyboard(context);
                                            if (formKey.currentState!
                                                .validate()) {
                                              formKey.currentState!.save();
                                              appStore.currentBookingStep = 1;
                                              setState(() {});
                                            }
                                          } else {
                                            hideKeyboard(context);
                                            if (appStore.tempAddress == null) {
                                              toast(language
                                                  .pleaseEnterYourAddress);
                                              setState(() {});
                                              return;
                                            }

                                            createPostJobClick();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width,
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: context.cardColor,
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Suggest your offer?",
                                  style: boldTextStyle(),
                                ),
                                10.height,
                                Container(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: offerSelect(
                                    context: context,
                                    activeColor: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
                                    selectedGender: _selectedOffer,
                                    textColor: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedOffer = value;
                                      });
                                    },
                                  ),
                                ),
                                _selectedOffer == "Yes"
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          15.height,
                                          Text(
                                            "Add your suggested offer!",
                                            style: boldTextStyle(),
                                          ),
                                          10.height,
                                          Directionality(
                                            textDirection:
                                                appStore.selectedLanguageCode ==
                                                        "en"
                                                    ? TextDirection.ltr
                                                    : TextDirection.rtl,
                                            child: AppTextField(
                                              textFieldType:
                                                  TextFieldType.NUMBER,
                                              controller: priceCont,
                                              focus: priceFocus,
                                              errorThisFieldRequired:
                                                  language.requiredText,
                                              textStyle: boldTextStyle(),
                                              isValidationRequired: false,
                                              decoration: inputDecoration(
                                                      context,
                                                      prefixIcon: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          // 10.width,
                                                          // Icon(
                                                          //   Iconsax.dollar_circle,
                                                          //   color: primaryColor,
                                                          // ),
                                                          10.width,
                                                          Text(
                                                            'AED',
                                                            style:
                                                                boldTextStyle(),
                                                          ),
                                                        ],
                                                      ).paddingSymmetric(
                                                          horizontal: 5))
                                                  .copyWith(
                                                      hintText: language
                                                          .priceHint,
                                                      hintStyle:
                                                          secondaryTextStyle(
                                                              color: dimGrey
                                                                  .withOpacity(
                                                                      0.8)),
                                                      fillColor: context
                                                          .scaffoldBackgroundColor),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: false,
                                                      signed: false),
                                              // validator: (s) {
                                              //   if (s!.isEmpty) return errorThisFieldRequired;

                                              //   if (s.toDouble() <= 0) return language.priceAmountValidationMessage;
                                              //   return null;
                                              // },
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                          20.height,
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: context.cardColor,
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      language.lblDate,
                                      style: boldTextStyle(),
                                    ),
                                    4.width,
                                    Text(
                                      '*',
                                      style: boldTextStyle(color: redColor),
                                    )
                                  ],
                                ),
                                10.height,
                                Container(
                                  decoration: boxDecorationWithRoundedCorners(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 15,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Iconsax.calendar,
                                        color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
                                      ),
                                      10.width,
                                      Text(
                                        _selectedDate != null
                                            ? formatBookingDate(
                                                    _selectedDate.toString(),
                                                    format: DATE_FORMAT_1)
                                                .substring(0, 12)
                                            : language.lblSelectDate,
                                        style: boldTextStyle()
                                            .copyWith(color: black),
                                      ),
                                      Spacer(),
                                      if (widget.jobDateType ==
                                          JobDateType.Today)
                                        Text(
                                          language.today,
                                          style: boldTextStyle(color: redColor),
                                        ),
                                      if (widget.jobDateType ==
                                          JobDateType.Tomorrow)
                                        Text(
                                          language.tomorrow,
                                          style: boldTextStyle(color: redColor),
                                        ),
                                      if (widget.jobDateType ==
                                              JobDateType.Scheduled &&
                                          _selectedDate != null)
                                        IconButton(
                                          icon: Icon(Iconsax.edit),
                                          onPressed: () => dateTap(),
                                        )
                                    ],
                                  ),
                                ).onTap(() => dateTap()),
                                20.height,
                                Row(
                                  children: [
                                    Text(
                                      language.lblTime,
                                      style: boldTextStyle(),
                                    ),
                                    4.width,
                                    Text(
                                      '*',
                                      style: boldTextStyle(color: redColor),
                                    )
                                  ],
                                ),
                                10.height,
                                widget.isUrgent
                                    ? Container(
                                        width: context.width(),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        decoration:
                                            boxDecorationWithRoundedCorners(
                                          border: Border.all(
                                            color: _selectedTimeFrameId == 0
                                                ? primaryColor
                                                : transparentColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Iconsax.timer_1,
                                              color: redColor,
                                            ),
                                            10.width,
                                            Center(
                                              child: Text(
                                                appStore.selectedLanguageCode ==
                                                        'en'
                                                    ? "Now"
                                                    : "الان",
                                                style: boldTextStyle(
                                                    color: redColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          Navigator.of(context).push(
                                            showPicker(
                                              context: context,
                                              value: widget.jobDateType ==
                                                      JobDateType.Today
                                                  ? (selectedTime ??
                                                      Time(
                                                          hour: DateTime.now()
                                                                  .hour +
                                                              1,
                                                          minute: 0))
                                                  : (selectedTime ??
                                                      Time(hour: 0, minute: 0)),
                                              disableMinute: true,
                                              minHour: widget.jobDateType ==
                                                      JobDateType.Today
                                                  ? (DateTime.now().hour + 1)
                                                      .toDouble()
                                                  : 0,
                                              maxHour: 23,
                                              sunrise:
                                                  TimeOfDay(hour: 6, minute: 0),
                                              sunset: TimeOfDay(
                                                  hour: 18, minute: 0),
                                              duskSpanInMinutes: 120,
                                              amLabel: language.am,
                                              pmLabel: language.pm,
                                              okText: language.confirm,
                                              cancelText: language.lblCancel,
                                              blurredBackground: true,
                                              hmsStyle: primaryTextStyle(
                                                  color: redColor),
                                              accentColor: context.primaryColor,
                                              okStyle: boldTextStyle(
                                                color: context.primaryColor,
                                                size: 14,
                                              ),
                                              cancelStyle: secondaryTextStyle(
                                                size: 14,
                                              ),
                                              onChange: (time) {
                                                setState(() {
                                                  selectedTime = time;
                                                });
                                                print(
                                                    'Time is ${timeToString(selectedTime)} and hour is ${selectedTime!.hour + 1}');
                                              },
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration:
                                              boxDecorationWithRoundedCorners(),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 15,
                                          ),
                                          width: double.maxFinite,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Iconsax.clock,
                                                color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
                                              ),
                                              10.width,
                                              Text(
                                                selectedTime != null
                                                    ? selectedTime!
                                                        .format(context)
                                                    : language.selectTime,
                                                style: boldTextStyle(
                                                    color:
                                                        context.primaryColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )

                                // : Row(
                                //     children: [
                                //       ...slots.map((e) {
                                //         if (e.isAvailable(_selectedDate ?? DateTime.now())) {
                                //           return Container(
                                //             padding: EdgeInsets.symmetric(
                                //               horizontal: 10,
                                //               vertical: 5,
                                //             ),
                                //             decoration: boxDecorationWithRoundedCorners(
                                //               borderRadius: BorderRadius.circular(10),
                                //               border: Border.all(
                                //                 width: 1,
                                //               ),
                                //               backgroundColor: 1 == 1
                                //                   ? getRightBackgroundColor(
                                //                       slots.indexOf(e),
                                //                       _selectedTimeFrameId,
                                //                     )
                                //                   : _selectedTimeFrameId == slots.indexOf(e)
                                //                       ? black
                                //                       : white,
                                //             ),
                                //             child: Column(
                                //               crossAxisAlignment: CrossAxisAlignment.center,
                                //               children: [
                                //                 Text(
                                //                   appStore.selectedLanguageCode == 'en' ? e.name : e.nameAr,
                                //                   style: primaryTextStyle(
                                //                     color: getRightTextColor(
                                //                       slots.indexOf(e),
                                //                       _selectedTimeFrameId,
                                //                     ),
                                //                   ),
                                //                   textAlign: TextAlign.center,
                                //                 ),
                                //                 Text(
                                //                   appStore.isArabic ? e.timeStringAr : e.timeString,
                                //                   style: secondaryTextStyle(
                                //                     size: 10,
                                //                     color: getRightTextColor(
                                //                       slots.indexOf(e),
                                //                       _selectedTimeFrameId,
                                //                     ),
                                //                     // .withOpacity(.6),
                                //                   ),
                                //                 ),
                                //               ],
                                //             ),
                                //           ).paddingSymmetric(horizontal: 4).onTap(() => selectTimeFrame(timeFrameId: slots.indexOf(e))).expand();
                                //         } else {
                                //           return Offstage();
                                //         }
                                //       })
                                //     ],
                                //   )

                                /// Slots

                                // : Row(
                                //     children: [
                                //       Container(
                                //         padding: EdgeInsets.symmetric(
                                //           horizontal: 10,
                                //           vertical: 5,
                                //         ),
                                //         decoration: boxDecorationWithRoundedCorners(
                                //           border: Border.all(
                                //             width: 1,
                                //           ),
                                //           backgroundColor: _selectedTimeFrameId == 0 ? black : white,
                                //         ),
                                //         child: Column(
                                //           children: [
                                //             Text(
                                //               appStore.selectedLanguageCode == 'en' ? 'Morning' : 'الصباح',
                                //               style: primaryTextStyle(
                                //                 color: getRightTextColor(
                                //                   0,
                                //                   _selectedTimeFrameId,
                                //                 ),
                                //               ),
                                //             ),
                                //             Text(
                                //               '6am - 12pm',
                                //               style: secondaryTextStyle(),
                                //             ),
                                //           ],
                                //         ),
                                //       ).paddingSymmetric(horizontal: 4).onTap(() => selectTimeFrame(timeFrameId: 0)).expand(),
                                //       Container(
                                //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                //         decoration: boxDecorationWithRoundedCorners(
                                //           border: Border.all(
                                //             width: 1,
                                //           ),
                                //           backgroundColor: _selectedTimeFrameId == 1 ? black : white,
                                //         ),
                                //         child: Column(
                                //           children: [
                                //             Text(
                                //               appStore.selectedLanguageCode == 'en' ? 'Noon' : 'النهار',
                                //               style: primaryTextStyle(
                                //                 color: getRightTextColor(
                                //                   1,
                                //                   _selectedTimeFrameId,
                                //                 ),
                                //               ),
                                //             ),
                                //             Text(
                                //               '12am - 6pm',
                                //               style: secondaryTextStyle(),
                                //             ),
                                //           ],
                                //         ),
                                //       ).paddingSymmetric(horizontal: 4).onTap(() => selectTimeFrame(timeFrameId: 1)).expand(),
                                //       Container(
                                //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                //         decoration: boxDecorationWithRoundedCorners(
                                //           border: Border.all(
                                //             width: 1,
                                //           ),
                                //           backgroundColor: _selectedTimeFrameId == 2 ? black : white,
                                //         ),
                                //         child: Column(
                                //           children: [
                                //             Text(
                                //               appStore.selectedLanguageCode == 'en' ? 'Night' : 'الليل',
                                //               style: primaryTextStyle(
                                //                 color: getRightTextColor(
                                //                   2,
                                //                   _selectedTimeFrameId,
                                //                 ),
                                //               ),
                                //             ),
                                //             Text(
                                //               '6pm - 12am',
                                //               style: secondaryTextStyle(),
                                //             ),
                                //           ],
                                //         ),
                                //       ).paddingSymmetric(horizontal: 4).onTap(() => selectTimeFrame(timeFrameId: 2)).expand(),
                                //     ],
                                //   ),
                              ],
                            ),
                          ),
                          20.height,
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: context.cardColor,
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      language.lblPickAddress,
                                      style: boldTextStyle(),
                                    ),
                                    4.width,
                                    Text(
                                      '*',
                                      style: boldTextStyle(color: redColor),
                                    )
                                  ],
                                ),
                                10.height,
                                Container(
                                  decoration: boxDecorationDefault(),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 10),
                                  child: appStore.tempAddress != null
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Iconsax.location,
                                              color: context.primaryColor,
                                            ).paddingSymmetric(horizontal: 5),
                                            Flexible(
                                                child: Text(
                                              appStore.tempAddress!.address
                                                  .validate(),
                                              style: secondaryTextStyle(),
                                            ))
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Icon(
                                              Iconsax.info_circle,
                                              color: redColor,
                                            ),
                                            10.width,
                                            Text(
                                              language.setAddress,
                                              style: primaryTextStyle(
                                                color: redColor,
                                              ),
                                            )
                                          ],
                                        ),
                                ).onTap(() => AddressesScreen(
                                      fromSelection: true,
                                    ).launch(context)),
                              ],
                            ),
                          ),
                          20.height,
                          CustomImagePicker(
                            key: uniqueKey,
                            onRemoveClick: (value) {
                              if (tempAttachments.validate().isNotEmpty &&
                                  imageFiles.isNotEmpty) {
                                showConfirmDialogCustom(
                                  context,
                                  dialogType: DialogType.DELETE,
                                  title: language.deleteImage,
                                  positiveText: language.lblDelete,
                                  negativeText: language.lblCancel,
                                  onAccept: (p0) {
                                    imageFiles.removeWhere(
                                        (element) => element.path == value);
                                    if (value.startsWith('http')) {
                                      removeAttachment(
                                          id: tempAttachments
                                              .validate()
                                              .firstWhere((element) =>
                                                  element.url == value)
                                              .id
                                              .validate());
                                    }
                                  },
                                );
                              } else {
                                showConfirmDialogCustom(
                                  context,
                                  dialogType: DialogType.DELETE,
                                  title: language.deleteImage,
                                  positiveText: language.lblDelete,
                                  negativeText: language.lblCancel,
                                  onAccept: (p0) {
                                    imageFiles.removeWhere(
                                        (element) => element.path == value);
                                    // if (isUpdate) {
                                    //   uniqueKey = UniqueKey();
                                    // }
                                    setState(() {});
                                  },
                                );
                              }
                            },
                            selectedImages: imageFiles
                                .validate()
                                .map((e) => e.path.validate())
                                .toList(),
                            onFileSelected: (List<File> files) async {
                              imageFiles = files;
                              setState(() {});
                            },
                          ),
                          // 100.height,
                        ],
                      ).paddingAll(10),

                    if (appStore.currentBookingStep == 1)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: context.width(),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 0),
                                  child: AppButton(
                                    child: Text(
                                      appStore.currentBookingStep == 0
                                          ? language.btnNext
                                          : (appStore.selectedLanguageCode ==
                                                  'en'
                                              ? 'Find Hands'
                                              : 'إبحث الآن'),
                                      style: boldTextStyle(color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6)),
                                    ),
                                    color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C),
                                    elevation: 5,
                                    onTap: () {
                                      if (appStore.currentBookingStep == 0) {
                                        hideKeyboard(context);
                                        if (formKey.currentState!.validate()) {
                                          formKey.currentState!.save();
                                          appStore.currentBookingStep = 1;
                                          setState(() {});
                                        }
                                      } else {
                                        hideKeyboard(context);
                                        if (appStore.tempAddress == null) {
                                          toast(
                                              language.pleaseEnterYourAddress);
                                          setState(() {});
                                          return;
                                        }

                                        createPostJobClick();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // if (appStore.currentBookingStep == 0) 200.height,
                  ],
                ),
              ],
            ),
            // if (appStore.currentBookingStep == 1)
            //   Align(
            //     alignment: Alignment.bottomCenter,
            //     child: SizedBox(
            //       width: context.width(),
            //       child: Row(
            //         children: [
            //           Expanded(
            //             flex: 2,
            //             child: Padding(
            //               padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            //               child: AppButton(
            //                 child: Text(
            //                   appStore.currentBookingStep == 0 ? language.btnNext : (appStore.selectedLanguageCode == 'en' ? 'Find Hands' : 'إبحث الآن'),
            //                   style: boldTextStyle(color: black),
            //                 ),
            //                 color: white,
            //                 elevation: 5,
            //                 onTap: () {
            //                   if (appStore.currentBookingStep == 0) {
            //                     hideKeyboard(context);
            //                     if (formKey.currentState!.validate()) {
            //                       formKey.currentState!.save();
            //                       appStore.currentBookingStep = 1;
            //                     }
            //                   } else {
            //                     hideKeyboard(context);
            //                     if (appStore.tempAddress == null) {
            //                       toast(language.pleaseEnterYourAddress);
            //                       return;
            //                     }

            //                     createPostJobClick();
            //                   }
            //                 },
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),

            // Visibility(
            //   // visible: MediaQuery.of(context).viewPadding.bottom == 0,
            //   visible: !keyboardVisible,
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     child: SizedBox(
            //       width: context.width(),
            //       child: Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
            //           child: Row(
            //             children: [
            //               Expanded(
            //                 flex: 2,
            //                 child: Padding(
            //                   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            //                   child: AppButton(
            //                     child: Text(
            //                       appStore.currentBookingStep == 0 ? language.btnNext : (appStore.selectedLanguageCode == 'en' ? 'Yalla ! Find Hands' : 'يلا أبحث'),
            //                       style: boldTextStyle(color: black),
            //                     ),
            //                     color: white,
            //                     elevation: 5,
            //                     onTap: () {
            //                       if (appStore.currentBookingStep == 0) {
            //                         hideKeyboard(context);
            //                         if (formKey.currentState!.validate()) {
            //                           formKey.currentState!.save();
            //                           appStore.currentBookingStep = 1;
            //                         }
            //                       } else {
            //                         hideKeyboard(context);
            //                         if (appStore.tempAddress == null) {
            //                           toast(language.pleaseEnterYourAddress);
            //                           return;
            //                         }

            //                         createPostJobClick();
            //                       }
            //                     },
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           )),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Color getRightBackgroundColor(int index, int selectedID) {
    if (index == selectedID) {
      return primaryColor;
    } else {
      return white;
    }
  }

  Color getRightTextColor(int index, int selectedID) {
    if (index == selectedID) {
      return white;
    } else {
      return primaryColor;
    }
  }
}
