import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/component/custom_confirmation_dialog.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/get_my_post_job_list_response.dart';
import 'package:hands_user_app/model/provider_info_response.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/jobRequest/components/bidder_item_component.dart';
import 'package:hands_user_app/screens/jobRequest/my_post_detail_screen.dart';
import 'package:hands_user_app/services/firebase/firebase_database_service.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

class BiddersListScreen extends StatefulWidget {
  const BiddersListScreen({required this.postJobData, super.key});

  final PostJobData postJobData;

  @override
  State<BiddersListScreen> createState() => _BiddersListScreenState();
}

class _BiddersListScreenState extends State<BiddersListScreen> {
  // Livetime Bidders List
  List<BidderData> biddersList = [];

  // Firebase Realtime DB subscription to listen on changes
  StreamSubscription<DatabaseEvent>? dataBaseEvent;
  final database = FirebaseDatabase.instance;

  double getBestPrice() {
    if (biddersList.isNotEmpty) {
      biddersList.sort(
        (a, b) => a.price!.compareTo(b.price!),
      );
      afterBuildCreated(() => setState(() {}));
      return biddersList.first.price!.toDouble();
    } else {
      return 0.0;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init(initState: true);
  }

  init({bool initState = false}) {
    final reference =
        database.ref().child('$JOB_REQUESTS/${widget.postJobData.id}/bidders/');

    if (dataBaseEvent == null) {
      dataBaseEvent = reference.onChildAdded.listen((event) async {
        print((event.snapshot.value));
        print((event.snapshot.value).runtimeType);
        print((event.snapshot.value) as Map);
        final x =
            BidderData.fromJson(json.decode(json.encode(event.snapshot.value)));
        ProviderInfoResponse provider = await getProviderDetail(
            x.providerId.validate(),
            userId: appStore.userId.validate());
        x.provider!.providersServiceRating =
            provider.userData!.providersServiceRating;
        x.provider!.totalServiceRating = provider.userData!.totalServiceRating;

        biddersList.add(x);
        biddersList.sort(
          (a, b) => a.price!.compareTo(b.price!),
        );
        setState(() {});

        // Notify Snackbar
        notifyBid();
      });
    }
  }

  notifyBid() async {
    snackBar(context,
        title: appStore.selectedLanguageCode == 'en'
            ? 'New bid arrived'
            : 'وصل عرض جديد على طلبك',
        backgroundColor: greenColor,
        textColor: white);
    try {
      final player = AudioPlayer();
      // don't forget to delete 'assets/' from the path 👇👇
      player.play(AssetSource('bid.wav'));
      if (await Vibrate.canVibrate) {
        Vibrate.vibrate();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> afterAccept() async {
    // print('AFTER ACCEPT IS CALLED FROMN BIDDERS LIST SCREEN');
    try {
      dataBaseEvent?.cancel();
      await database
          .ref()
          .child('$JOB_REQUESTS/${widget.postJobData.id}')
          .remove();
      // finish(context);
      // finish(context);
    } catch (e) {
      print('--------->ERROR : $e');
      if (!kReleaseMode) {
        throw e;
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dataBaseEvent?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        toast(appStore.selectedLanguageCode == 'en'
            ? 'Please select provider first'
            : 'الرجاء اختيار مقدم الخدمة اولا');
      },
      child: AppScaffold(
        appBarTitle: appStore.selectedLanguageCode == 'en'
            ? 'Available Providers'
            : 'مقدمي الخدمة المتاحين',
        showBackButton: false,
        centerTitle: true,
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              20.height,
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: context.cardColor,
                      borderRadius: radius(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2AB749),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_circle,
                              color: white,
                              size: 24,
                            ),
                          ),
                        ),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appStore.selectedLanguageCode == 'en'
                                    ? 'Available service providers.'
                                    : 'مقدمي الخدمة المتاحين',
                                style: primaryTextStyle(size: 12),
                              ),
                              Text(
                                appStore.selectedLanguageCode == 'en'
                                    ? 'Based on your request, below are all available providers who approved your scopes of work.'
                                    : 'بناءً على طلبك، فيما يلي جميع مقدمي الخدمة المتاحين الذين وافقوا على منطقتك.',
                                style: secondaryTextStyle(
                                    size: 10, weight: FontWeight.w100),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).paddingSymmetric(horizontal: 10).expand(),
                  // AppButton(
                  //   width: 48,
                  //   height: 48,
                  //   onTap: () {},
                  //   splashColor: Colors.transparent,
                  //   padding: EdgeInsets.zero,
                  //   child: Container(
                  //     padding: EdgeInsets.zero,
                  //     width: 52,
                  //     height: 52,
                  //     decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)),
                  //     child: Center(child: ic_filter.iconImage(color: white)),
                  //   ),
                  // )
                ],
              ).paddingSymmetric(horizontal: 5),
              20.height,
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: biddersList.length,
                shrinkWrap: true,
                // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .7),
                itemBuilder: (context, index) {
                  return BidderItemComponent(
                    fromRealTime: true,
                    data: biddersList[index],
                    postRequestId: widget.postJobData.id!.toInt(),
                    postJobData: widget.postJobData,
                    serviceId: widget.postJobData.serviceId!,
                    afterAccept: afterAccept,
                    bestPrice: getBestPrice() == biddersList[index].price,
                    bidderPrice: biddersList[index].price.validate(),
                  );
                },
              ),
              80.height
              // Text(widget.postJobData.service?.length.toString() ?? 'NULL'),
              // Text(widget.postJobData.description.validate()),
              // Text(widget.postJobData.address.validate()),
              // Text(widget.postJobData.date.validate()),
              // Text(widget.postJobData.isUrgent.toString().validate()),
              // ...biddersList
              //     .map(
              //       (e) => Text(e.price.toString() +
              //           " - " +
              //           e.postRequestId.toString() +
              //           " - " +
              //           e.providerId.toString() +
              //           " - " +
              //           e.id.toString() +
              //           " - " +
              //           e.provider!.displayName.validate() +
              //           " - " +
              //           e.provider!.email.validate() +
              //           " - " +
              //           e.provider!.designation.validate()),
              //     )
              //     .toList(),
              // Text(
              //   biddersList.length.toString(),
              // ).onTap(() => setState(() {
              //       biddersList.clear();

              //       database.ref().child('$JOB_REQUESTS/${widget.postJobData.id}/bidders').get().then((value) {
              //         for (var snap in value.children) {
              //           print(snap.key);
              //           biddersList.add(BidderData.fromJson(json.decode(snap.value.toString())));
              //           setState(() {});
              //         }
              //       });
              //     }))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            label: Row(
              children: [
                Icon(
                  Iconsax.back_square,
                  color: white,
                ),
                10.width,
                Text(
                  language.goToHome,
                  style: boldTextStyle(color: white),
                ),
              ],
            ),
            onPressed: () {
              showCustomConfirmDialog(
                context,
                primaryColor: context.primaryColor,
                title: language.bidScreenBackToHomeMessage,
                positiveText: language.lblYes,
                negativeText: language.lblCancel,
                onAccept: (c) async {
                  afterAccept()
                      .then((value) => DashboardScreen(
                            postJobId: widget.postJobData.id!.toInt(),
                          ).launch(context, isNewTask: true))
                      .catchError((e) {
                    print(e.toString());
                    DashboardScreen(
                      postJobId: widget.postJobData.id!.toInt(),
                    ).launch(context, isNewTask: true);
                  });
                },
              );
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}

Map<String, dynamic> convertMap(Map<Object?, Object?> inputMap) {
  Map<String, dynamic> outputMap = {};
  inputMap.forEach((key, value) {
    if (key != null) {
      outputMap[key.toString()] = value;
    }
  });
  return outputMap;
}

Map<String, dynamic> convertObjectToMap(Object? obj) {
  if (obj == null) {
    return {};
  } else if (obj is Map) {
    Map<String, dynamic> resultMap = {};
    obj.forEach((key, value) {
      resultMap[key.toString()] = convertObjectToMap(value);
    });
    return resultMap;
  } else {
    throw ArgumentError('Input object is not a Map');
  }
}
