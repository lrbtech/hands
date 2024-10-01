import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hands_user_app/components/app_widgets.dart';
import 'package:hands_user_app/components/base_scaffold_widget.dart';
import 'package:hands_user_app/components/empty_error_state_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/provider/networks/network_utils.dart';
import 'package:hands_user_app/provider/components/info_widget.dart';
import 'package:hands_user_app/provider/screens/bank_account/add_or_edit_bank_account.dart';
import 'package:hands_user_app/provider/screens/bank_account/bank_account_widget.dart';
import 'package:hands_user_app/provider/screens/bank_account/models/bank_account_model.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  List<BankAccountModel> accounts = [];

  Future<List<BankAccountModel>>? future;

  bool canAdd = false;

  init() {
    future = null;
    future = getBankAccounts();
  }

  @override
  void initState() {
    super.initState();
    init();
    // LiveStream().on(LIVESTREAM_BANK_ACCOUNTS, (value) {
    //   print('Updating bank accounts');
    //   init();
    // });
  }

  @override
  void dispose() {
    // LiveStream().dispose(LIVESTREAM_BANK_ACCOUNTS);
    super.dispose();
  }

  Future<List<BankAccountModel>> getBankAccounts() async {
    var headers = buildHeaderTokens();
    var request = http.Request(
      'GET',
      buildBaseUrl('bank-list'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    final data = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      jsonDecode(data.body).forEach((acc) {
        accounts.add(BankAccountModel.fromJson(acc));
      });

      print('accounts = ${accounts.length}');
      return accounts;
    } else {
      // print(response.reasonPhrase);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.bankAccount,
      actions: [
        if (canAdd)
          IconButton(
            onPressed: () {
              AddOrEditBankAccount().launch(context);
            },
            icon: Icon(
              Icons.add,
              color: white,
            ),
          ),
      ],
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoaderWidget();
          }
          if (snapshot.hasError) {
            return snapWidgetHelper(
              snapshot,
              // loadingWidget: HandymanDashboardShimmer(),
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  imageWidget: ErrorStateWidget(),
                  retryText: languages.reload,
                  onRetry: () {
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  },
                );
              },
            );
          }

          if (!canAdd) {
            afterBuildCreated(() {
              canAdd = (snapshot.data!.length == 0);
              setState(() {});
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoWidget(
                  info: languages.bankAccountDescription,
                ),
                20.height,
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) =>
                      BankAccountWidget(account: snapshot.data![index]),
                  separatorBuilder: (context, index) => 10.height,
                  itemCount: snapshot.data!.length,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget
}
