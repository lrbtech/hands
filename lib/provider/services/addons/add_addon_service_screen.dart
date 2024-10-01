import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/provider/utils/extensions/context_ext.dart';
import 'package:hands_user_app/provider/utils/extensions/string_extension.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_widgets.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../models/booking_detail_response.dart';
import '../../../models/service_model.dart';
import '../../../models/static_data_model.dart';
import '../../../provider/networks/rest_apis.dart';
import '../../../provider/utils/common.dart';
import '../../../provider/utils/configs.dart';
import '../../../provider/utils/constant.dart';
import '../../../provider/utils/images.dart';
import '../../../provider/utils/model_keys.dart';
import 'component/select_addon_service_component.dart';

class AddAddonServiceScreen extends StatefulWidget {
  final ServiceAddon? addonServiceData;

  AddAddonServiceScreen({this.addonServiceData});

  @override
  _AddAddonServiceScreenState createState() => _AddAddonServiceScreenState();
}

class _AddAddonServiceScreenState extends State<AddAddonServiceScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController addonNameCont = TextEditingController();
  TextEditingController addonPriceCont = TextEditingController();

  FocusNode addonPriceFocus = FocusNode();

  List<StaticDataModel> statusListStaticData = [
    StaticDataModel(key: ACTIVE, value: languages.active),
    StaticDataModel(key: INACTIVE, value: languages.inactive),
  ];

  StaticDataModel? addonStatusModel;

  File? imageFile;
  XFile? pickedFile;

  String addonStatus = ACTIVE;

  bool isUpdate = false;

  ServiceData? selectedService;
  List<ServiceData> serviceList = [];
  int? serviceId;
  int page = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isUpdate = widget.addonServiceData != null;

    if (isUpdate) {
      appStorePro.selectedServiceList.clear();
      appStorePro.selectedServiceData = ServiceData();

      addonNameCont.text = widget.addonServiceData!.name.validate().trim();
      addonPriceCont.text =
          widget.addonServiceData!.price.toString().validate();
      addonStatus =
          widget.addonServiceData!.status.validate() == 1 ? ACTIVE : INACTIVE;
      serviceId = widget.addonServiceData!.serviceId.validate();
      appStorePro.selectedServiceData.name =
          widget.addonServiceData!.serviceName.validate();

      if (widget.addonServiceData != null) {
        imageFile = File(widget.addonServiceData!.serviceAddonImage.validate());
      }

      if (addonStatus == ACTIVE) {
        addonStatusModel = statusListStaticData.first;
      } else {
        addonStatusModel = statusListStaticData[1];
      }
    } else {
      appStorePro.selectedServiceList.clear();
      appStorePro.selectedServiceData = ServiceData();
      addonStatus = statusListStaticData.first.key!;
    }

    setState(() {});
  }

  void _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
    }
  }

  void _getFromCamera() async {
    pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: languages.lblGallery,
              leading: Icon(Icons.image, color: context.iconColor),
              onTap: () async {
                _getFromGallery();
                finish(context);
              },
            ),
            SettingItemWidget(
              title: languages.camera,
              leading: Icon(Icons.camera, color: context.iconColor),
              onTap: () {
                _getFromCamera();
                finish(context);
              },
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }

  // region Form Widget
  Widget buildFormWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Wrap(
        runSpacing: 16,
        children: [
          Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                8.height,
                AppTextField(
                  controller: addonNameCont,
                  textFieldType: TextFieldType.NAME,
                  nextFocus: addonPriceFocus,
                  errorThisFieldRequired: context.translate.hintRequired,
                  decoration: inputDecoration(context,
                      hint: languages.addonServiceName,
                      fillColor: context.scaffoldBackgroundColor),
                ),
                24.height,
                Observer(builder: (context) {
                  return Container(
                    width: context.width(),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.scaffoldBackgroundColor),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Marquee(
                              child: Text(
                                appStorePro.selectedServiceData.name
                                        .validate()
                                        .isNotEmpty
                                    ? appStorePro.selectedServiceData.name
                                        .validate()
                                    : languages.selectService,
                                style: appStorePro.selectedServiceData.name
                                        .validate()
                                        .isNotEmpty
                                    ? primaryTextStyle()
                                    : secondaryTextStyle(),
                              ).paddingSymmetric(horizontal: 16, vertical: 12),
                            ).expand(),
                            TextButton(
                              child: Text(
                                  appStorePro.selectedServiceData.name != null
                                      ? context.translate.lblEdit
                                      : languages.hintAddService,
                                  style: boldTextStyle()),
                              onPressed: () async {
                                serviceId = await SelectAddonServiceComponent(
                                  serviceAddonData: widget.addonServiceData,
                                  selectedServiceId:
                                      appStorePro.selectedServiceData.id,
                                  isUpdate: widget.addonServiceData != null
                                      ? true
                                      : false,
                                ).launch(context);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                24.height,
                AppTextField(
                  controller: addonPriceCont,
                  textFieldType: TextFieldType.NUMBER,
                  focus: addonPriceFocus,
                  decoration: inputDecoration(
                    context,
                    hint: languages.lblPrice,
                    fillColor: context.scaffoldBackgroundColor,
                    prefix: Text(appStore.currencySymbol,
                        style: primaryTextStyle(size: LABEL_TEXT_SIZE),
                        textAlign: TextAlign.center),
                  ),
                  validator: (s) {
                    if (s!.isEmpty) return errorThisFieldRequired;

                    if (s.toDouble() <= 0)
                      return languages.priceAmountValidationMessage;
                    return null;
                  },
                ),
                24.height,

                ///StaticDataModel logic : changes in active/ inactive status
                DropdownButtonFormField<StaticDataModel>(
                  dropdownColor: context.scaffoldBackgroundColor,
                  value: addonStatusModel != null
                      ? addonStatusModel
                      : statusListStaticData.first,
                  items: statusListStaticData.map((StaticDataModel data) {
                    return DropdownMenuItem<StaticDataModel>(
                      value: data,
                      child: Text(data.value.validate(),
                          style: primaryTextStyle()),
                    );
                  }).toList(),
                  decoration: inputDecoration(
                    context,
                    fillColor: context.scaffoldBackgroundColor,
                    hint: context.translate.lblStatus,
                  ),
                  onTap: () {
                    hideKeyboard(context);
                  },
                  onChanged: (StaticDataModel? value) async {
                    addonStatus = value!.key.validate();
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null) return errorThisFieldRequired;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // endregion

  // region Action
  Future checkValidation() async {
    if (serviceId != null && serviceId != -1) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        hideKeyboard(context);

        Map<String, dynamic> req = {
          AddonServiceKey.addonId: widget.addonServiceData != null
              ? widget.addonServiceData!.id.validate() != 0
                  ? widget.addonServiceData!.id.validate()
                  : null
              : null,
          AddonServiceKey.name: addonNameCont.text.validate(),
          AddonServiceKey.price: addonPriceCont.text.validate(),
          AddonServiceKey.status: addonStatus.validate() == ACTIVE ? '1' : '0',
          if (serviceId != null && serviceId != -1)
            AddonServiceKey.serviceId: serviceId.validate(),
        };

        addAddonMultiPart(
                value: req,
                imageFile: (!imageFile!.path.contains('http') &&
                        imageFile!.path.isNotEmpty)
                    ? imageFile
                    : null)
            .then((value) {
          //
        }).catchError((e) {
          log('Error:  $e');
          toast(e.toString());
        });
      }
    } else {
      toast(languages.pleaseSelectAService);
    }
  }

  // endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        isUpdate ? languages.editAddonService : languages.addAddonService,
        textColor: white,
        color: context.primaryColor,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
            child: Column(
              children: [
                (imageFile != null && imageFile!.path.isNotEmpty)
                    ? Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 110,
                              height: 110,
                              child: Loader(),
                            ).visible(imageFile!.path.isNotEmpty),
                            CachedImageWidget(
                              url: imageFile!.path,
                              height: 110,
                              width: 110,
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(defaultRadius),
                            Positioned(
                              top: 110 * 3 / 4 + 4,
                              left: 110 * 3 / 4 + 4,
                              child: GestureDetector(
                                onTap: () {
                                  hideKeyboard(context);
                                  _showBottomSheet(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: boxDecorationDefault(
                                      shape: BoxShape.circle,
                                      color: Colors.white),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: boxDecorationDefault(
                                        shape: BoxShape.circle,
                                        color: primaryColor),
                                    child: const Icon(Icons.edit,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).paddingBottom(16),
                      )
                    : Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              hideKeyboard(context);
                              _showBottomSheet(context);
                            },
                            child: DottedBorderWidget(
                              color: context.primaryColor,
                              radius: defaultRadius,
                              child: Container(
                                padding: EdgeInsets.all(26),
                                alignment: Alignment.center,
                                decoration: boxDecorationWithShadow(
                                    blurRadius: 0,
                                    backgroundColor: context.cardColor,
                                    borderRadius: radius()),
                                child: Column(
                                  children: [
                                    ic_no_photo.iconImage(size: 46),
                                    8.height,
                                    Text(languages.chooseImage,
                                        style: secondaryTextStyle()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          16.height,
                          Text(languages.noteYouCanUpload,
                              style: secondaryTextStyle(size: 10)),
                        ],
                      ),
                16.height,
                buildFormWidget(),
              ],
            ),
          ),
          Positioned(
            right: 16,
            left: 16,
            bottom: 16,
            child: AppButton(
              text: context.translate.btnSave,
              height: 40,
              color: context.primaryColor,
              textStyle: boldTextStyle(color: white),
              width: context.width() - context.navigationBarHeight,
              onTap: () {
                ifNotTester(context, () {
                  if ((imageFile != null && imageFile!.path.isNotEmpty)) {
                    checkValidation();
                  } else {
                    toast(languages.pleaseSelectImages);
                    hideKeyboard(context);
                    _showBottomSheet(context);
                  }
                });
              },
            ),
          ),
          Observer(
              builder: (_) =>
                  LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
