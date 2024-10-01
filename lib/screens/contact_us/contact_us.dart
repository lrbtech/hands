import 'package:flutter/material.dart';
import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/base_response_model.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  Future<void> onPressSubmit() async {
    if (formKey.currentState!.validate()) {
      Map request = {
        "full_name": fullNameController.text,
        "phone_no": phoneNumberController.text,
        "email": emailController.text,
        "subject": subjectController.text,
        "user_message": messageController.text,
      };

      BaseResponseModel res = await contactUs(request);

      bool error = res.message == 'Something went wrong.';

      Fluttertoast.showToast(
        msg: res.message ?? 'no message here',
        backgroundColor: error ? greenColor : primaryColor,
      );

      fullNameController.clear();
      phoneNumberController.clear();
      emailController.clear();
      subjectController.clear();
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.lblContactUs,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    contact_us_image,
                    height: 200,
                  ),
                ),
                10.height,

                // Full name
                Text(
                  language.fullName,
                  style: boldTextStyle(),
                ),
                10.height,
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  controller: fullNameController,
                  errorThisFieldRequired: language.requiredText,
                  decoration: inputDecoration(
                    context,
                    // prefixIcon: ic_message.iconImage(size: 10).paddingAll(14),
                  ),
                  autoFillHints: [AutofillHints.email],
                ),

                20.height,

                // Email address
                Text(
                  language.email,
                  style: boldTextStyle(),
                ),
                10.height,
                AppTextField(
                  textFieldType: TextFieldType.EMAIL_ENHANCED,
                  controller: emailController,
                  errorThisFieldRequired: language.requiredText,
                  decoration: inputDecoration(
                    context,
                    // prefixIcon: ic_message.iconImage(size: 10).paddingAll(14),
                  ),
                  autoFillHints: [AutofillHints.email],
                ),

                20.height,

                // Phone number
                Text(
                  language.phoneNumber,
                  style: boldTextStyle(),
                ),
                10.height,
                AppTextField(
                  textFieldType: TextFieldType.PHONE,
                  controller: phoneNumberController,
                  errorThisFieldRequired: language.requiredText,
                  decoration: inputDecoration(
                    context,
                    // prefixIcon: ic_message.iconImage(size: 10).paddingAll(14),
                  ),
                  autoFillHints: [AutofillHints.telephoneNumber],
                ),

                20.height,

                // Subject
                Text(
                  language.subject,
                  style: boldTextStyle(),
                ),
                10.height,
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  controller: subjectController,
                  errorThisFieldRequired: language.requiredText,
                  decoration: inputDecoration(
                    context,
                    // prefixIcon: ic_message.iconImage(size: 10).paddingAll(14),
                  ),
                  // autoFillHints: [AutofillHints.],
                ),

                20.height,

                // How can we help
                Text(
                  language.howCanWeHelp,
                  style: boldTextStyle(),
                ),
                10.height,
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  validator: (s) {
                    if (s!.trim().isEmpty) {
                      return language.requiredText.validate(value: errorThisFieldRequired);
                    }
                    return null;
                  },
                  maxLines: 5,
                  controller: messageController,
                  decoration: inputDecoration(
                    context,
                    // prefixIcon: ic_message.iconImage(size: 10).paddingAll(14),
                  ),
                ),

                20.height,

                AppButton(
                  width: double.infinity,
                  text: language.btnSubmit,
                  textColor: appStore.isDarkMode ? primaryColor : white,
                  color: appStore.isDarkMode ? white : primaryColor,
                  onTap: () async {
                    await onPressSubmit();
                  },
                ),
                // AppTextField(
                //   keyboardType: TextInputType.multiline,
                //   textFieldType: TextFieldType.EMAIL_ENHANCED,
                //   controller: TextEditingController(),
                //   errorThisFieldRequired: language.requiredText,
                //   maxLines: 10,
                //   decoration: inputDecoration(
                //     context,
                //     // prefixIcon: ic_message.iconImage(size: 10).paddingAll(14),
                //   ),
                //   // autoFillHints: [AutofillHints.email],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
