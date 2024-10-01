import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/base_scaffold_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/networks/network_utils.dart';
import 'package:hands_user_app/provider/screens/bank_account/bank_account_screen.dart';
import 'package:hands_user_app/provider/screens/bank_account/models/bank_account_model.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class AddOrEditBankAccount extends StatefulWidget {
  final BankAccountModel? account;

  const AddOrEditBankAccount({super.key, this.account});

  @override
  State<AddOrEditBankAccount> createState() => _AddOrEditBankAccountState();
}

class _AddOrEditBankAccountState extends State<AddOrEditBankAccount> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController bankNameCont = TextEditingController();
  final TextEditingController accountNumberCont = TextEditingController();
  final TextEditingController ibanCont = TextEditingController();
  final TextEditingController accountNameCont = TextEditingController();
  final TextEditingController swiftCont = TextEditingController();
  final TextEditingController branchNameCont = TextEditingController();

  clear() {
    bankNameCont.clear();
    accountNumberCont.clear();
    ibanCont.clear();
    accountNameCont.clear();
    swiftCont.clear();
    branchNameCont.clear();
  }

  addOrEditNewBankAccount() async {
    print('addOrEditNewBankAccount STARTED');
    showDialog(
      context: context,
      builder: (context) => LoaderWidget(),
    );

    var headers = buildHeaderTokens();
    var request = http.Request(
      'POST',
      buildBaseUrl('bank-save'),
    );
    request.body = json.encode({
      "id": widget.account != null ? "${widget.account!.id!}" : "",
      "provider_id": appStore.userId,
      "bank_name": bankNameCont.text,
      "branch_name": branchNameCont.text,
      "account_no": accountNumberCont.text,
      "account_name": accountNameCont.text,
      "iban": ibanCont.text,
      "swift": swiftCont.text,
      "status": 1,
    });

    print('Body is ${request.body}');
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    final data = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      print('SUCCESS and data is ${data.body}');
      clear();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      BankAccountScreen().launch(context);
    } else {
      print('ERROR and data is ${data.body}');
      Navigator.of(context).pop();
      toast(jsonDecode(data.body)['message']);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      bankNameCont.text = widget.account!.bankName!;
      accountNumberCont.text = widget.account!.accountNo!;
      ibanCont.text = widget.account!.iban!;
      accountNameCont.text = widget.account!.accountName!;
      swiftCont.text = widget.account!.swift!;
      branchNameCont.text = widget.account!.branchName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: widget.account != null
          ? languages.editAccount
          : languages.addBankAccount,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                12.height,
                Center(
                  child: Image.asset(
                    'assets/images/bank_img.png',
                    height: 120,
                  ),
                ),
                20.height,
                // Account name
                Text(
                  languages.accountName,
                  style: boldTextStyle(),
                ),
                6.height,
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  controller: accountNameCont,
                  decoration: inputDecoration(context),
                  validator: (s) {
                    if (s!.isEmpty)
                      return languages.hintRequired;
                    else
                      return null;
                  },
                ),

                12.height,

                // Bank name
                Text(
                  languages.bankName,
                  style: boldTextStyle(),
                ),
                6.height,
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  controller: bankNameCont,
                  decoration: inputDecoration(context),
                  validator: (s) {
                    if (s!.isEmpty)
                      return languages.hintRequired;
                    else
                      return null;
                  },
                ),

                12.height,

                // Branch name
                Text(
                  languages.branchName,
                  style: boldTextStyle(),
                ),
                6.height,
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  controller: branchNameCont,
                  decoration: inputDecoration(context),
                  validator: (s) {
                    if (s!.isEmpty)
                      return languages.hintRequired;
                    else
                      return null;
                  },
                ),

                12.height,

                Text(
                  languages.accountNumber,
                  style: boldTextStyle(),
                ),
                6.height,
                AppTextField(
                  textFieldType: TextFieldType.NUMBER,
                  controller: accountNumberCont,
                  decoration: inputDecoration(context),
                  validator: (s) {
                    if (s!.isEmpty)
                      return languages.hintRequired;
                    else
                      return null;
                  },
                ),

                12.height,

                Text(
                  'IBAN',
                  style: boldTextStyle(),
                ),
                6.height,
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  controller: ibanCont,
                  decoration: inputDecoration(context),
                  validator: (s) {
                    if (s!.isEmpty)
                      return languages.hintRequired;
                    else
                      return null;
                  },
                ),

                12.height,

                Text(
                  'SWIFT',
                  style: boldTextStyle(),
                ),
                6.height,
                AppTextField(
                  textFieldType: TextFieldType.NAME,
                  controller: swiftCont,
                  decoration: inputDecoration(context),
                  validator: (s) {
                    if (s!.isEmpty)
                      return languages.hintRequired;
                    else
                      return null;
                  },
                ),

                20.height,

                AppButton(
                  width: double.infinity,
                  color: context.primaryColor,
                  text: widget.account != null
                      ? languages.editAccount
                      : languages.addBankAccount,
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      await addOrEditNewBankAccount();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
