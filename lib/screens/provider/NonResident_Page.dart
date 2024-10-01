import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/network/network_utils.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';
import 'package:hands_user_app/screens/provider/Dailog_Step1_Page.dart';
import 'package:hands_user_app/screens/provider/Dialog_Step2_Page.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/model_keys_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

class NonresidentPage extends StatefulWidget {
  const NonresidentPage({super.key});

  @override
  State<NonresidentPage> createState() => _NonresidentPageState();
}

class _NonresidentPageState extends State<NonresidentPage> {
  int activeStep = 0;

  void _setActiveStep(int step) {
    // print("step $step");

    if (step == 0) {
      setState(() {
        activeStep = step;
      });
    }
  }

  Map? data;
  Map? files;
  sendProviderData() {
    appStore.setLoading(true);
    http
        .post(
      Uri.parse("${BASE_URL}provider-update"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'APP_KEY': "8Shm171pe2oTGvJlql7nxe2Ys/tHJaiiVq6vr5wIu5EJhEEmI3gVi"
      },
      body: jsonEncode(data),
    )
        .then((response) {
      addDocument(3, files!['uploadPassport']);
      addDocument(6, files!['uploadVisa']);
      addDocument(7, files!['uploadSelfie']);
      appStore.setLoading(false);
      print("response ${response}");
      toast("Submited Successfully!", print: true);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });
  }

  void addDocument(int? docId, String file) async {
    MultipartRequest multiPartRequest =
        await getMultiPartRequest('provider-document-save');
    multiPartRequest.fields[CommonKeys.id] = '';
    multiPartRequest.fields[CommonKeys.providerId] = appStore.userId.toString();
    multiPartRequest.fields[AddDocument.documentId] = docId.toString();
    multiPartRequest.fields[AddDocument.isVerified] = '0';

    // if (uploadEmiratesId != null) {
    multiPartRequest.files
        .add(await MultipartFile.fromPath(AddDocument.providerDocument, file));
    // }
    log(multiPartRequest);

    multiPartRequest.headers.addAll(buildHeaderTokens());

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        // appStore.setLoading(false);
        print("provider-document-save ${data}");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStep(context, step: 0, label: "Step 1"),
                _buildStep(context, step: 1, label: "Step 2"),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: activeStep,
              children: [
                Step1((value) {
                  setState(() {
                    data = value;
                  });
                  // print("Steps ${int}");
                  onNext();
                }),
                Step2((value) {
                  setState(() {
                    files = value;
                  });
                  sendProviderData();
                })
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Observer(
          builder: (context) =>
              LoaderWidget().center().visible(appStore.isLoading)),
    );
  }

  onNext() {
    print("Steps");
    setState(() {
      activeStep = 1;
    });
    // _setActiveStep(1);
  }

  Widget _buildStep(BuildContext context,
      {required int step, required String label}) {
    bool isActive = activeStep == step;

    return GestureDetector(
      onTap: () => _setActiveStep(step),
      child: Column(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Theme.of(context).colorScheme.onBackground
                  : AppColors.skyblue,
            ),
            child: Center(
              child: CircleAvatar(
                radius: 15,
                backgroundColor: isActive
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.purewhite,
                child: Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onBackground,
                  size: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.almarai(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
