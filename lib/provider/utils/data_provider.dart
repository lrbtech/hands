import 'package:flutter/cupertino.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/about_model.dart';
import 'package:hands_user_app/provider/utils/extensions/context_ext.dart';
import 'package:hands_user_app/provider/utils/images.dart';

List<AboutModel> getAboutDataModel({BuildContext? context}) {
  List<AboutModel> aboutList = [];

  aboutList.add(AboutModel(
      title: context!.translate.lblTermsAndConditions, image: termCondition));
  aboutList.add(
      AboutModel(title: languages.lblPrivacyPolicy, image: privacy_policy));
  aboutList.add(
      AboutModel(title: languages.lblHelpAndSupport, image: termCondition));
  aboutList.add(AboutModel(title: languages.lblHelpLineNum, image: calling));
  aboutList.add(AboutModel(title: languages.lblRateUs, image: rateUs));

  return aboutList;
}
