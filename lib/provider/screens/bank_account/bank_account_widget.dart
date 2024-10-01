import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/networks/network_utils.dart';
import 'package:hands_user_app/provider/screens/bank_account/add_or_edit_bank_account.dart';
import 'package:hands_user_app/provider/screens/bank_account/bank_account_screen.dart';
import 'package:hands_user_app/provider/screens/bank_account/models/bank_account_model.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class BankAccountWidget extends StatelessWidget {
  final BankAccountModel account;

  const BankAccountWidget({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.2),
            offset: Offset(0, 3),
            blurRadius: 3,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            ic_back_account,
            height: 40,
            width: 40,
            color: gray.withOpacity(0.8),
          ),
          12.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account name
              Text(
                '${account.bankName}'.toUpperCase(),
                style: boldTextStyle(size: 16, color: black),
              ),

              // Account
              Text(
                '${account.accountName}'.toUpperCase(),
                style: secondaryTextStyle(),
              ),

              Text(
                '${account.accountNo}'.toUpperCase(),
                style: secondaryTextStyle(size: 20),
              ),
            ],
          ).expand(),
          CircleAvatar(
            backgroundColor: black,
            radius: 16,
            child: IconButton(
              onPressed: () {
                AddOrEditBankAccount(
                  account: account,
                ).launch(context);
              },
              icon: Center(
                child: Icon(
                  Icons.edit,
                  color: lightGray,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  deleteBankAccount({required int id, required BuildContext context}) async {
    showDialog(
      context: context,
      builder: (context) => LoaderWidget(),
    );

    var headers = buildHeaderTokens();

    var request = http.Request('POST', buildBaseUrl('bank-delete/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    final data = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      BankAccountScreen().launch(context);
      // LiveStream().emit(LIVESTREAM_BANK_ACCOUNTS);
    } else {
      Navigator.of(context).pop();
      toast(jsonDecode(data.body)['message']);
    }
  }
}
