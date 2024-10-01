import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/component/empty_error_state_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/address_model.dart';
import 'package:hands_user_app/screens/address/add_edit_address_screen.dart';
import 'package:hands_user_app/screens/address/repository/addresses_repo.dart';
import 'package:hands_user_app/screens/map/map_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen(
      {this.fromSelection = false, this.fromDashboard = false, super.key});
  final bool fromSelection;
  final bool fromDashboard;

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  Future<List<AddressModel>>? future;

  List<AddressModel> addressList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    LiveStream().on('address_list', (p0) {
      init();
      // setState(() {});
    });
  }

  void init() async {
    future = getAddressList(
      addressData: addressList,
      page: page,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    LiveStream().dispose('address_list');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: widget.fromSelection
          ? language.lblPickAddress
          : language.lblYourAddress,
      actions: (widget.fromSelection)
          ? [
              IconButton(
                onPressed: () => MapScreen().launch(context),
                icon: Icon(
                  Iconsax.add,
                  color: appStore.isDarkMode ? white : primaryColor,
                  size: 30,
                ),
              )
            ]
          : null,
      child: Stack(
        children: [
          SizedBox(
            height: context.height(),
            child: SnapHelperWidget<List<AddressModel>>(
              initialData: cachedAddressList,
              future: future,
              loadingWidget: LoaderWidget(),
              onSuccess: (snap) {
                return AnimatedListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(8),
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  itemCount: snap.length,
                  emptyWidget: NoDataWidget(
                      title: appStore.isArabic
                          ? 'لا يوجد عناوين'
                          : 'No Addresses Found',
                      imageWidget: EmptyStateWidget()),
                  shrinkWrap: true,
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      appStore.setLoading(true);

                      init();
                      setState(() {});
                    }
                  },
                  onSwipeRefresh: () async {
                    page = 1;

                    init();
                    setState(() {});

                    return await 2.seconds.delay;
                  },
                  disposeScrollController: true,
                  itemBuilder: (BuildContext context, index) {
                    AddressModel address = snap[index];
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.fromSelection) {
                              appStore.setTempAddress(address: address);
                              setState(() {});
                            }
                          },
                          child:
                              // widget.fromSelection
                              (1 == 1)
                                  ? Container(
                                      // height: 100,

                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: white,
                                        border: Border.all(
                                            color: widget.fromSelection &&
                                                    address.id ==
                                                        appStore.tempAddress?.id
                                                ? context.primaryColor
                                                : lightGrey.withOpacity(0.5)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              // Icon
                                              address.name
                                                          .validate()
                                                          .toLowerCase() ==
                                                      'home'
                                                  ? Icon(
                                                      CupertinoIcons.home,
                                                      color: widget
                                                              .fromDashboard
                                                          ? context.primaryColor
                                                          : (widget.fromSelection &&
                                                                  address.id ==
                                                                      appStore
                                                                          .tempAddress
                                                                          ?.id
                                                              ? context
                                                                  .primaryColor
                                                              : grey),
                                                    )
                                                  : Image.asset(
                                                      ic_location,
                                                      height: 24,
                                                      width: 24,
                                                    ),

                                              10.width,

                                              // Title
                                              Text(
                                                address.name
                                                            .validate()
                                                            .toLowerCase() ==
                                                        'home'
                                                    ? language.homeAddress
                                                    : (appStore.selectedLanguageCode ==
                                                            'en'
                                                        ? 'Other'
                                                        : 'عنوان آخر'),
                                                style: boldTextStyle(
                                                  size: 15,
                                                  color: widget.fromDashboard
                                                      ? context.primaryColor
                                                      : (widget.fromSelection &&
                                                              address.id ==
                                                                  appStore
                                                                      .tempAddress
                                                                      ?.id
                                                          ? context.primaryColor
                                                          : grey),
                                                ),
                                              ),

                                              Spacer(),

                                              // if selected
                                              if (widget.fromSelection &&
                                                  address.id ==
                                                      appStore.tempAddress?.id)
                                                Image.asset(
                                                  ic_select,
                                                  width: 25,
                                                  height: 25,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                            ],
                                          ),
                                          12.height,
                                          Row(
                                            children: [
                                              Text(
                                                address.address.validate(),
                                                style: primaryTextStyle(
                                                    color: widget
                                                                .fromSelection &&
                                                            address.id ==
                                                                appStore
                                                                    .tempAddress
                                                                    ?.id
                                                        ? context.primaryColor
                                                            .withOpacity(0.7)
                                                        : grey),
                                              ).expand(),
                                              if (!widget.fromSelection)
                                                20.width,
                                              if (!widget.fromSelection)
                                                CircleAvatar(
                                                  backgroundColor: black,
                                                  child: IconButton(
                                                      onPressed: () {
                                                        MapScreen(
                                                          latLong: address
                                                              .latitude
                                                              .toDouble(),
                                                          latitude: address
                                                              .longitude
                                                              .toDouble(),
                                                          address: address,
                                                        ).launch(context);
                                                      },
                                                      icon: Icon(
                                                        CupertinoIcons.pencil,
                                                        color: white,
                                                      )),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )

                                  /// Other widget
                                  : Stack(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                address.name
                                                            .validate()
                                                            .toLowerCase() ==
                                                        'home'
                                                    ? CupertinoIcons.home
                                                    : Iconsax.location,
                                                color: appStore.isDarkMode
                                                    ? white
                                                    : primaryColor,
                                              ),
                                              15.width,
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        address.name.validate(),
                                                        style: boldTextStyle()),
                                                    Text(
                                                        address.address
                                                            .validate(),
                                                        style:
                                                            secondaryTextStyle()),
                                                  ],
                                                ),
                                              ),
                                              if (!widget.fromSelection)
                                                10.width,
                                              if (!widget.fromSelection)
                                                CircleAvatar(
                                                  backgroundColor: appStore
                                                          .isDarkMode
                                                      ? white
                                                      : context.primaryColor,
                                                  child: IconButton(
                                                      onPressed: () {
                                                        MapScreen(
                                                          latLong: address
                                                              .latitude
                                                              .toDouble(),
                                                          latitude: address
                                                              .longitude
                                                              .toDouble(),
                                                          address: address,
                                                        ).launch(context);
                                                      },
                                                      icon: Icon(
                                                        CupertinoIcons.pencil,
                                                        color: appStore
                                                                .isDarkMode
                                                            ? context
                                                                .primaryColor
                                                            : white,
                                                      )),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (widget.fromSelection &&
                                            address.id ==
                                                appStore.tempAddress?.id)
                                          Positioned.directional(
                                            textDirection:
                                                appStore.selectedLanguageCode ==
                                                        "en"
                                                    ? TextDirection.ltr
                                                    : TextDirection.rtl,
                                            top: 0,
                                            end: 10,
                                            child: Icon(
                                              Icons.check_circle,
                                              color: greenColor,
                                            ),
                                          )
                                      ],
                                    ),
                        ),
                        if (index != (snap.length - 1)) Divider(),
                        if (index == (snap.length - 1))
                          SizedBox(
                            height: 120,
                          ),
                      ],
                    );
                  },
                );
              },
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  imageWidget: ErrorStateWidget(),
                  retryText: language.reload,
                  onRetry: () {
                    page = 1;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  },
                );
              },
            ),
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
      floatingActionButtonLocation: !widget.fromSelection
          ? null
          : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!widget.fromSelection)
              FloatingActionButton(
                onPressed: () => MapScreen().launch(context),
                child: Icon(
                  Iconsax.location_add,
                  color: white,
                  size: 30,
                ),
              ),
            10.height,
            if (widget.fromSelection)
              Row(
                children: [
                  FloatingActionButton(
                      onPressed: appStore.tempAddress == null
                          ? null
                          : () => finish(context),
                      child: Text(
                        language.setAddress,
                        style: boldTextStyle(color: white),
                      )).expand(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
