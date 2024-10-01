import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/booking/component/view_invoice_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceRequestDialogComponent extends StatefulWidget {
  final int? bookingId;

  InvoiceRequestDialogComponent({required this.bookingId});

  @override
  State<InvoiceRequestDialogComponent> createState() =>
      _InvoiceRequestDialogComponentState();
}

class _InvoiceRequestDialogComponentState
    extends State<InvoiceRequestDialogComponent> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    emailCont.text = appStore.userEmail.validate();
  }

  Future<void> sentMail() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      Map req = {
        UserKeys.email: emailCont.text.validate(),
        CommonKeys.bookingId: widget.bookingId.validate(),
      };

      sentInvoiceOnMail(req).then((res) async {
        // toast(res.message.validate());
        if (res.pdf != null) {
          if (res.pdf!.isNotEmpty) {
            final storageStatus =
                await Permission.manageExternalStorage.request();

            if (storageStatus == PermissionStatus.granted) {
              // Proceed with downloading the PDF (rest of your download logic)
              downloadPDF(res.pdf!);
            } else if (storageStatus == PermissionStatus.permanentlyDenied) {
              // User has permanently denied permission
              openAppSettings(); // Open app settings for user to change permissions
            } else {}
          }
        }
      }).catchError((e) {
        toast(e.toString(), print: true);
      }).whenComplete(() => appStore.setLoading(false));
    }
  }

  Future<void> downloadPDF(String url) async {
    try {
      final response = await get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getExternalStorageDirectory();

        final fileName = url.split('/').last; // Extract filename from URL
        final file = File('${dir?.absolute.path}/$fileName');

        await file.writeAsBytes(response.bodyBytes);

        final fileUri = Uri.parse(file.path);

        print('File path is ${fileUri.toString()}');

        finish(context);

        appStore.setLoading(false);
        // finish(context, true);

        try {
          ViewInvoiceScreen(
            path: fileUri.toString(),
          ).launch(context);
        } catch (e) {
          print('Navigation error is ${e.toString()}');
        }
      } else {
        // Handle non-200 status code error
        print(
            'Download failed: Status code ${response.statusCode} and -> ${response.body}');
        // toast(language.downloadInvoiceFailed);
        appStore.setLoading(false);
        finish(context, true);
      }
    } on Exception catch (e) {
      // Handle other download errors
      // print(e.toString());
      print('Failed to download PDF: ${e.toString()}');
      // toast(language.downloadInvoiceFailed);
      appStore.setLoading(false);
      finish(context, true);
    }
  }

  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              width: context.width(),
              decoration: boxDecorationDefault(
                  color: context.primaryColor,
                  borderRadius: radiusOnly(
                      topRight: defaultRadius, topLeft: defaultRadius)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(language.requestInvoice,
                      style: boldTextStyle(color: Colors.white)),
                  IconButton(
                    onPressed: () {
                      finish(context);
                    },
                    icon: Icon(Icons.clear, color: Colors.white, size: 20),
                  )
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.invoiceSubTitle, style: primaryTextStyle()),
                20.height,
                Observer(
                  builder: (_) => AppTextField(
                    textFieldType: TextFieldType.EMAIL_ENHANCED,
                    controller: emailCont,
                    errorThisFieldRequired: language.requiredText,
                    decoration: inputDecoration(context,
                        labelText: language.hintEmailTxt),
                  ).visible(!appStore.isLoading, defaultWidget: Loader()),
                ),
                30.height,
                AppButton(
                  text: language.send,
                  height: 40,
                  color: primaryColor,
                  textStyle: primaryTextStyle(color: white),
                  width: context.width() - context.navigationBarHeight,
                  onTap: () {
                    sentMail();
                  },
                ),
              ],
            ).paddingAll(16),
          ],
        ),
      ),
    );
  }
}
