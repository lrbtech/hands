import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/component/loader_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/provider/fragment/booking_fragment.dart';
import 'package:hands_user_app/provider/fragments/provider_payment_fragment.dart';
import 'package:hands_user_app/provider/jobRequest/bid_list_screen.dart';
import 'package:hands_user_app/provider/screens/bank_account/bank_account_screen.dart';
import 'package:hands_user_app/provider/screens/categories_screen.dart';
import 'package:hands_user_app/provider/screens/verify_provider_screen.dart';
import 'package:hands_user_app/provider/service_address/service_addresses_screen.dart';
// import 'package:hands_user_app/provider/utils/images.dart';
import 'package:hands_user_app/screens/about_screen.dart';
import 'package:hands_user_app/screens/address/addresses_screen.dart';
import 'package:hands_user_app/screens/auth/edit_profile_screen.dart';
import 'package:hands_user_app/screens/auth/sign_in_screen.dart';
import 'package:hands_user_app/screens/blog/view/blog_list_screen.dart';
import 'package:hands_user_app/screens/contact_us/contact_us.dart';
import 'package:hands_user_app/screens/dashboard/customer_rating_screen.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/jobRequest/my_post_request_list_screen.dart';
import 'package:hands_user_app/screens/provider/Colors.dart';
import 'package:hands_user_app/screens/provider/Widgets/Image_Urls.dart';
import 'package:hands_user_app/screens/setting_screen.dart';
import 'package:hands_user_app/screens/wallet/user_wallet_balance_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hands_user_app/component/custom_confirmation_dialog.dart';

import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../favourite_provider_screen.dart';
import '../component/wallet_history.dart';

class ProfileFragment extends StatefulWidget {
  @override
  ProfileFragmentState createState() => ProfileFragmentState();
}

class ProfileFragmentState extends State<ProfileFragment> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<num>? futureWalletBalance;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (appStore.isLoggedIn) appStore.setUserWalletAmount();

    afterBuildCreated(() {
      appStore.setLoading(false);
      setStatusBarColor(context.primaryColor);
    });
  }

  void loadBalance() {
    futureWalletBalance = getUserWalletBalance();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.profile,
        textColor: appStore.isDarkMode ? white : textPrimaryColor,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 0.0,
        color: context.scaffoldBackgroundColor,
        showBack: false,
        actions: [
          IconButton(
            icon: ic_setting.iconImage(
                color: appStore.isDarkMode ? white : context.primaryColor,
                size: 20),
            onPressed: () async {
              SettingScreen().launch(context);
            },
          ),
        ],
      ),
      body: Observer(
        builder: (BuildContext context) {
          return Stack(
            children: [
              AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                padding: EdgeInsets.only(
                  bottom: 32,
                ),
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (appStore.isLoggedIn) _buildProfileCard(context),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       24.height,
                  //       // Stack(
                  //       //   alignment: Alignment.bottomRight,
                  //       //   children: [
                  //       //     Container(
                  //       //       decoration: boxDecorationDefault(
                  //       //         border: Border.all(color: primaryColor, width: 3),
                  //       //         shape: BoxShape.circle,
                  //       //       ),
                  //       //       child: Container(
                  //       //         decoration: boxDecorationDefault(
                  //       //           border: Border.all(color: context.scaffoldBackgroundColor, width: 4),
                  //       //           shape: BoxShape.circle,
                  //       //         ),
                  //       //         child: CachedImageWidget(
                  //       //           url: appStore.userProfileImage,
                  //       //           height: 90,
                  //       //           width: 90,
                  //       //           fit: BoxFit.cover,
                  //       //           radius: 60,
                  //       //         ),
                  //       //       ),
                  //       //     ),
                  //       //     Positioned(
                  //       //       bottom: 0,
                  //       //       right: 8,
                  //       //       child: Container(
                  //       //         alignment: Alignment.center,
                  //       //         padding: EdgeInsets.all(6),
                  //       //         decoration: boxDecorationDefault(
                  //       //           shape: BoxShape.circle,
                  //       //           color: primaryColor,
                  //       //           border: Border.all(color: context.cardColor, width: 2),
                  //       //         ),
                  //       //         child: Icon(AntDesign.edit, color: white, size: 18),
                  //       //       ).onTap(() {
                  //       //         EditProfileScreen().launch(context);
                  //       //       }),
                  //       //     ),
                  //       //   ],
                  //       // ),

                  //       // Container(
                  //       //   decoration: boxDecorationDefault(
                  //       //     border: Border.all(
                  //       //         color: context.primaryColor, width: 2),
                  //       //     shape: BoxShape.circle,
                  //       //   ),
                  //       //   child: CachedImageWidget(
                  //       //     url: appStore.userProfileImage,
                  //       //     height: 90,
                  //       //     width: 90,
                  //       //     fit: BoxFit.cover,
                  //       //     radius: 60,
                  //       //   ),
                  //       // ),
                  //       // 10.height,
                  //       // Row(
                  //       //   children: [
                  //       //     Expanded(
                  //       //       child: Column(
                  //       //         crossAxisAlignment: CrossAxisAlignment.start,
                  //       //         children: [
                  //       //           Text(appStore.userFullName,
                  //       //               style: boldTextStyle(
                  //       //                   color: appStore.isDarkMode
                  //       //                       ? white
                  //       //                       : primaryColor,
                  //       //                   size: 20)),
                  //       //           Text(appStore.userEmail,
                  //       //               style: boldTextStyle(
                  //       //                   size: 14,
                  //       //                   color: Color(0xFF6D7698))),
                  //       //         ],
                  //       //       ),
                  //       //     ),
                  //       //     // GestureDetector(
                  //       //     //   onTap: () =>
                  //       //     //       EditProfileScreen().launch(context),
                  //       //     //   child: CircleAvatar(
                  //       //     //     backgroundColor: primaryColor,
                  //       //     //     child: Icon(
                  //       //     //       Icons.edit,
                  //       //     //       color: white,
                  //       //     //     ),
                  //       //     //   ),
                  //       //     // ),
                  //       //     // AppButton(
                  //       //     //   onTap: () => EditProfileScreen().launch(context),
                  //       //     //   color: primaryColor,
                  //       //     //   enableScaleAnimation: false,
                  //       //     //   text: language.editProfile,
                  //       //     //   height: 40,
                  //       //     //   width: 120,
                  //       //     // )
                  //       //   ],
                  //       // ),
                  //       // 24.height,
                  //     ],
                  //   ),
                  // ),
                  if (appStore.isLoggedIn && appStore.userType == "provider")
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topRight: Radius.circular(10),
                              )),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, bottom: 10, right: 20, left: 15),
                            child: Text(
                              "Bookings",
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                    ),
                  Observer(builder: (context) {
                    return Column(
                      // title: Text(language.lblGENERAL, style: boldTextStyle(color: primaryColor)),
                      // headingDecoration: BoxDecoration(color: context.primaryColor.withOpacity(0.1)),
                      // divider:
                      //color: appStore.isDarkMode ? context.cardColor :null, Offstage(),
                      children: [
                        if (appStore.isLoggedIn && appStore.isEnableUserWallet)
                          SettingItemWidget(
                            leading: ic_un_fill_wallet.iconImage(
                                size: SETTING_ICON_SIZE),
                            title: language.walletBalance,
                            onTap: () {
                              UserWalletBalanceScreen().launch(context);
                            },
                            trailing: Text(
                              '${isCurrencyPositionLeft ? appStore.currencySymbol : ''}${appStore.userWalletAmount.toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS))}${isCurrencyPositionRight ? appStore.currencySymbol : ''}',
                              style: boldTextStyle(color: Colors.green),
                            ),
                            /*trailing: SnapHelperWidget(
                              future: futureWalletBalance,
                              loadingWidget: Text(language.loading),
                              onSuccess: (balance) => Text(
                                '${isCurrencyPositionLeft ? appStore.currencySymbol : ''}${balance.toStringAsFixed(appStore.priceDecimalPoints)}${isCurrencyPositionRight ? appStore.currencySymbol : ''}',
                                style: boldTextStyle(color: Colors.green),
                              ),
                              errorWidget: IconButton(
                                onPressed: () {
                                  loadBalance();
                                  setState(() {});
                                },
                                icon: Icon(Icons.refresh_rounded),
                              ),
                            ),*/
                          ),
                        if (appStore.isLoggedIn && appStore.isEnableUserWallet)
                          SettingItemWidget(
                            leading:
                                ic_document.iconImage(size: SETTING_ICON_SIZE),
                            title: language.walletHistory,
                            trailing: trailing,
                            onTap: () {
                              UserWalletHistoryScreen().launch(context);
                            },
                          ),
                        if (appStore.isLoggedIn && appStore.isEnableUserWallet)
                          Divider(
                            color:
                                appStore.isDarkMode ? context.cardColor : null,
                            thickness: 1,
                            height: 0,
                          ).paddingSymmetric(horizontal: 10),
                        if (appStore.isLoggedIn)
                          SettingItemWidget(
                            leading:
                                Icon(Iconsax.location, size: SETTING_ICON_SIZE),
                            title: language.lblYourAddress,
                            trailing: trailing,
                            onTap: () {
                              doIfLoggedIn(context, () {
                                AddressesScreen(fromDashboard: true)
                                    .launch(context);
                              });
                            },
                          ),

                        if (appStore.isLoggedIn)
                          SettingItemWidget(
                            leading:
                                ic_document.iconImage(size: SETTING_ICON_SIZE),
                            title: "My Booking",
                            trailing: trailing,
                            onTap: () async {
                              doIfLoggedIn(context, () {
                                MyPostRequestListScreen().launch(context);
                              });
                            },
                          ),
                        if (appStore.isLoggedIn &&
                            appStore.userType == "provider")
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Divider(
                              color: appStore.isDarkMode ? Colors.white : null,
                              thickness: 2,
                              height: 0,
                            ).paddingSymmetric(horizontal: 10),
                          ),

                        if (appStore.isLoggedIn &&
                            appStore.userType == "provider")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                child: Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                          right: 20,
                                          left: 15),
                                      child: Center(
                                        child: Text(
                                          "Jobs",
                                          style: TextStyle(
                                              color: primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        if (appStore.isLoggedIn)
                          if (appStore.isLoggedIn &&
                              appStore.userType == "provider")
                            Column(
                              children: [
                                SettingItemWidget(
                                  leading: ic_document.iconImage(
                                      size: SETTING_ICON_SIZE),
                                  title: language.myPostJobList,
                                  trailing: trailing,
                                  onTap: () async {
                                    doIfLoggedIn(context, () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return BookingFragment();
                                          },
                                        ),
                                        (_) => false,
                                      );
                                      // MyPostRequestListScreen().launch(context);
                                      // BookingFragment().launch(context);
                                    });
                                  },
                                ),

                                SettingItemWidget(
                                  leading: Image.asset(
                                      'assets/icons/ic_services_address.png',
                                      height: 16,
                                      width: 16,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8)),
                                  title: languages.lblServiceAddress,
                                  trailing: Icon(Icons.chevron_right,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8),
                                      size: 24),
                                  onTap: () {
                                    ServiceAddressesScreen().launch(context);
                                  },
                                ),

                                SettingItemWidget(
                                  leading: Image.asset(
                                      'assets/icons/categories.png',
                                      height: 16,
                                      width: 16,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8)),
                                  title: languages.myCategories,
                                  trailing: Icon(Icons.chevron_right,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8),
                                      size: 24),
                                  onTap: () {
                                    CategoriesScreen().launch(context);
                                  },
                                ),

                                SettingItemWidget(
                                  leading: Image.asset(
                                      'assets/icons/ic_list.png',
                                      height: 16,
                                      width: 16,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8)),
                                  title: languages.bidList,
                                  trailing: Icon(Icons.chevron_right,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8),
                                      size: 24),
                                  onTap: () {
                                    BidListScreen().launch(context);
                                  },
                                ),

                                SettingItemWidget(
                                  leading: Image.asset(ic_document,
                                      height: 16,
                                      width: 16,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8)),
                                  title: languages.btnVerifyId,
                                  trailing: Icon(Icons.chevron_right,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8),
                                      size: 24),
                                  onTap: () {
                                    VerifyProviderScreen().launch(context);
                                  },
                                ),

                                // Bank account
                                SettingItemWidget(
                                  leading: Image.asset(
                                      'assets/icons/back_account.png',
                                      height: 16,
                                      width: 16,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8)),
                                  title: languages.bankAccount,
                                  trailing: Icon(Icons.chevron_right,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8),
                                      size: 24),
                                  onTap: () {
                                    BankAccountScreen().launch(context);
                                  },
                                ),

                                SettingItemWidget(
                                  leading: Image.asset(
                                      "assets/icons/ic_fill_wallet.png",
                                      height: 16,
                                      width: 16,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8)),
                                  title: languages.lblPayment,
                                  trailing: Icon(Icons.chevron_right,
                                      color: appStore.isDarkMode
                                          ? white
                                          : gray.withOpacity(0.8),
                                      size: 24),
                                  onTap: () {
                                    ProviderPaymentFragment().launch(context);
                                  },
                                ),
                              ],
                            ),
                        if (appStore.isLoggedIn)
                          if (appStore.isLoggedIn &&
                              appStore.userType == "provider")
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Divider(
                                color:
                                    appStore.isDarkMode ? Colors.white : null,
                                thickness: 2,
                                height: 0,
                              ).paddingSymmetric(horizontal: 10),
                            ),

                        // i\f (appStore.isLoggedIn)
                        //   Divider(
                        // color: appStore.isDarkMode ? context.cardColor :null,
                        //     thickness: 1,
                        //     height: 0,
                        //   ).paddingSymmetric(horizontal: 10),
                        // SettingItemWidget(
                        //   leading: ic_heart.iconImage(size: SETTING_ICON_SIZE),
                        //   title: language.lblFavorite,
                        //   trailing: trailing,
                        //   onTap: () {
                        //     doIfLoggedIn(context, () {
                        //       FavouriteServiceScreen().launch(context);
                        //     });
                        //   },
                        // ),

                        // SettingItemWidget(
                        //   leading: ic_heart.iconImage(size: SETTING_ICON_SIZE),
                        //   title: language.favouriteProvider,
                        //   trailing: trailing,
                        //   onTap: () {
                        //     doIfLoggedIn(context, () {
                        //       FavouriteProviderScreen().launch(context);
                        //     });
                        //   },
                        // ),

                        if (otherSettingStore.blogEnable.getBoolInt())
                          SettingItemWidget(
                            leading:
                                ic_document.iconImage(size: SETTING_ICON_SIZE),
                            title: language.blogs,
                            trailing: trailing,
                            onTap: () {
                              BlogListScreen().launch(context);
                            },
                          ),
                        if (otherSettingStore.blogEnable.getBoolInt())
                          Divider(
                            color:
                                appStore.isDarkMode ? context.cardColor : null,
                            thickness: 1,
                            height: 0,
                          ).paddingSymmetric(horizontal: 10),
                        // SettingItemWidget(
                        //   leading: ic_star.iconImage(size: SETTING_ICON_SIZE),
                        //   title: language.rateUs,
                        //   trailing: trailing,
                        //   onTap: () async {
                        //     if (isAndroid) {
                        //       if (getStringAsync(PLAY_STORE_URL).isNotEmpty) {
                        //         commonLaunchUrl(getStringAsync(PLAY_STORE_URL), launchMode: LaunchMode.externalApplication);
                        //       } else {
                        //         commonLaunchUrl('${getSocialMediaLink(LinkProvider.PLAY_STORE)}${await getPackageName()}', launchMode: LaunchMode.externalApplication);
                        //       }
                        //     } else if (isIOS) {
                        //       if (getStringAsync(APPSTORE_URL).isNotEmpty) {
                        //         commonLaunchUrl(getStringAsync(APPSTORE_URL), launchMode: LaunchMode.externalApplication);
                        //       } else {
                        //         commonLaunchUrl(IOS_LINK_FOR_USER, launchMode: LaunchMode.externalApplication);
                        //       }
                        //     }
                        //   },
                        // ),
                        // Divider(
                        //   color: appStore.isDarkMode ? context.cardColor : null,
                        //   thickness: 1,
                        //   height: 0,
                        // ).paddingSymmetric(horizontal: 10),
                        // SettingItemWidget(
                        //   leading: ic_star.iconImage(size: SETTING_ICON_SIZE),
                        //   title: language.myReviews,
                        //   trailing: trailing,
                        //   onTap: () async {
                        //     doIfLoggedIn(context, () {
                        //       CustomerRatingScreen().launch(context);
                        //     });
                        //   },
                        // ),

                        SettingItemWidget(
                          leading:
                              ic_about_us.iconImage(size: SETTING_ICON_SIZE),
                          title: language.lblAboutApp,
                          trailing: trailing,
                          onTap: () {
                            // setValue(SITE_DESCRIPTION, generalSettingModel.siteDescription);
                            AboutScreen().launch(context);
                          },
                        ),

                        SettingItemWidget(
                          leading:
                              ic_shield_done.iconImage(size: SETTING_ICON_SIZE),
                          title: language.privacyPolicy,
                          trailing: trailing,
                          onTap: () {
                            if (appStore.selectedLanguageCode == 'en') {
                              appStore.setPrivacyPolicy(cachedDashboardResponse
                                      ?.privacyPolicy?.value
                                      .validate() ??
                                  PRIVACY_POLICY_URL);
                            } else {
                              appStore.setPrivacyPolicy(cachedDashboardResponse
                                      ?.privacyPolicy?.valueAr
                                      .validate() ??
                                  PRIVACY_POLICY_URL);
                            }
                            checkIfLink(
                                context, appStore.privacyPolicy.validate(),
                                title: language.privacyPolicy);
                          },
                        ),

                        SettingItemWidget(
                          leading:
                              ic_document.iconImage(size: SETTING_ICON_SIZE),
                          title: language.termsCondition,
                          trailing: trailing,
                          onTap: () {
                            if (appStore.selectedLanguageCode == 'en') {
                              appStore.setTermConditions(cachedDashboardResponse
                                      ?.termConditions?.value
                                      .validate() ??
                                  TERMS_CONDITION_URL);
                            } else {
                              appStore.setTermConditions(cachedDashboardResponse
                                      ?.termConditions?.valueAr
                                      .validate() ??
                                  TERMS_CONDITION_URL);
                            }
                            checkIfLink(
                                context, appStore.termConditions.validate(),
                                title: language.termsCondition);
                          },
                        ),

                        // if (appStore.inquiryEmail.isNotEmpty)
                        //   SettingItemWidget(
                        //     leading: ic_helpAndSupport.iconImage(size: SETTING_ICON_SIZE),
                        //     title: language.helpSupport,
                        //     trailing: trailing,
                        //     onTap: () {
                        //       checkIfLink(context, appStore.inquiryEmail.validate(), title: language.helpSupport);
                        //     },
                        //   ),

                        // if (appStore.inquiryEmail.isNotEmpty)
                        //   Divider(
                        //     color:
                        //         appStore.isDarkMode ? context.cardColor : null,
                        //     thickness: 1,
                        //     height: 0,
                        //   ).paddingSymmetric(horizontal: 10),
                        if (appStore.helplineNumber.isNotEmpty)
                          SettingItemWidget(
                            leading:
                                ic_calling.iconImage(size: SETTING_ICON_SIZE),
                            title: language.lblHelplineNumber,
                            trailing: trailing,
                            onTap: () {
                              launchCall(appStore.helplineNumber.validate());
                            },
                          ),

                        // Contact form
                        SettingItemWidget(
                          leading:
                              ic_contact_us.iconImage(size: SETTING_ICON_SIZE),
                          title: language.lblContactUs,
                          trailing: trailing,
                          onTap: () {
                            ContactUsScreen().launch(context);
                            // launchCall(appStore.helplineNumber.validate());
                          },
                        ),

                        // if (appStore.helplineNumber.isNotEmpty)
                        SettingItemWidget(
                          leading: Icon(MaterialCommunityIcons.logout,
                              color: context.iconColor,
                              size: SETTING_ICON_SIZE),
                          title: language.signIn,
                          trailing: trailing,
                          onTap: () {
                            getAppConfigurations();
                            SignInScreen().launch(context);
                          },
                        ).visible(!appStore.isLoggedIn),
                        // if (!appStore.isLoggedIn)
                        //   Divider(
                        //     color:
                        //         appStore.isDarkMode ? context.cardColor : null,
                        //     thickness: 1,
                        //     height: 0,
                        //   ).paddingSymmetric(horizontal: 10),
                        Column(
                          // title: Text(language.lblDangerZone.toUpperCase(), style: boldTextStyle(color: redColor)),
                          // headingDecoration: BoxDecoration(color: redColor.withOpacity(0.08)),
                          // divider:
                          //color: appStore.isDarkMode ? context.cardColor :null, Offstage(),
                          children: [
                            // if (appStore.isLoggedIn)
                            //   Divider(
                            //     color: appStore.isDarkMode
                            //         ? context.cardColor
                            //         : null,
                            //     thickness: 1,
                            //     height: 0,
                            //   ).paddingSymmetric(horizontal: 10),
                            SettingItemWidget(
                              leading: Icon(MaterialCommunityIcons.logout,
                                  color: context.iconColor,
                                  size: SETTING_ICON_SIZE),
                              title: language.logout,
                              trailing: trailing,
                              onTap: () async {
                                await logout(context);
                                // SignInScreen().launch(context);
                              },
                            ).visible(appStore.isLoggedIn),
                          ],
                        ).visible(appStore.isLoggedIn),
                        // 30.height.visible(!appStore.isLoggedIn),
                        // 30.height.visible(appStore.isLoggedIn),
                        50.height,
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       // if (getStringAsync(FACEBOOK_URL).isNotEmpty)
                        //       IconButton(
                        //         icon: Image.asset(ic_facebook, height: 35),
                        //         onPressed: () {
                        //           commonLaunchUrl(
                        //               'https://www.facebook.com/profile.php?id=61559767691065',
                        //               launchMode:
                        //                   LaunchMode.externalApplication);
                        //         },
                        //       ),
                        //       // if (getStringAsync(INSTAGRAM_URL).isNotEmpty)
                        //       IconButton(
                        //         icon: Image.asset(ic_instagram, height: 35),
                        //         onPressed: () {
                        //           commonLaunchUrl(
                        //               'https://www.instagram.com/handsappuae/',
                        //               launchMode:
                        //                   LaunchMode.externalApplication);
                        //           // commonLaunchUrl(getStringAsync(INSTAGRAM_URL), launchMode: LaunchMode.externalApplication);
                        //         },
                        //       ),
                        //       // if (getStringAsync(TWITTER_URL).isNotEmpty)
                        //       IconButton(
                        //         icon: Image.asset(ic_x, height: 35),
                        //         onPressed: () {
                        //           commonLaunchUrl('https://x.com/handsappuae',
                        //               launchMode:
                        //                   LaunchMode.externalApplication);
                        //           // commonLaunchUrl(getStringAsync(TWITTER_URL), launchMode: LaunchMode.externalApplication);
                        //         },
                        //       ),
                        //       // if (getStringAsync(LINKEDIN_URL).isNotEmpty)
                        //       IconButton(
                        //         icon: Image.asset(ic_snapchat, height: 35),
                        //         onPressed: () {
                        //           commonLaunchUrl(
                        //               'https://www.snapchat.com/add/handsappuae',
                        //               launchMode:
                        //                   LaunchMode.externalApplication);
                        //           // commonLaunchUrl(getStringAsync(LINKEDIN_URL), launchMode: LaunchMode.externalApplication);
                        //         },
                        //       ),
                        //       // if (getStringAsync(YOUTUBE_URL).isNotEmpty)
                        //       IconButton(
                        //         icon: Image.asset(ic_tiktok, height: 35),
                        //         onPressed: () {
                        //           commonLaunchUrl(
                        //               'https://www.tiktok.com/@handsappuae?lang=en',
                        //               launchMode:
                        //                   LaunchMode.externalApplication);
                        //           // commonLaunchUrl(getStringAsync(YOUTUBE_URL), launchMode: LaunchMode.externalApplication);
                        //         },
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // 80.height,
                      ],
                    );
                  }),
                  // Column(
                  //   // title: Text(language.lblAboutApp.toUpperCase(), style: boldTextStyle(color: primaryColor)),
                  //   // headingDecoration: BoxDecoration(color: context.primaryColor.withOpacity(0.1)),
                  //   // divider:
                  //color: appStore.isDarkMode ? context.cardColor :null, Offstage(),
                  //   children: [
                  //     8.height,

                  //   ],
                  // ),

                  // Text('Hi Eric Backman , This is you as an old man .')
                  // SnapHelperWidget<PackageInfoData>(
                  //   future: getPackageInfo(),
                  //   onSuccess: (data) {
                  //     return TextButton(
                  //       child: VersionInfoWidget(prefixText: 'v', textStyle: secondaryTextStyle()),
                  //       onPressed: () {
                  //         showAboutDialog(
                  //           context: context,
                  //           applicationName: APP_NAME,
                  //           applicationVersion: data.versionName,
                  //           applicationIcon: Image.asset(appLogo, height: 50),
                  //         );
                  //       },
                  //     ).center();
                  //   },
                  // ),
                ],
              ),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
        child: Container(
          height: 201,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 2),
                blurRadius: 1,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )
            ],
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(225, 250, 249, 246),
                Color.fromARGB(255, 0, 12, 44),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStarRating(),
              const SizedBox(height: 20),
              _buildProfileDetails(),
              const SizedBox(height: 15),
              _buildBalanceDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Padding(
      padding: const EdgeInsets.only(left: 89, top: 10, right: 80),
      child: SizedBox(
        height: 25,
        width: 192,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Row(
              children: [
                Image.asset(
                  index < 3
                      ? AppIcons.activestarIcon
                      : AppIcons.nonactivestarIcon,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                ),
                if (index < 4) const SizedBox(width: 6.29),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 0, 191, 255),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedImageWidget(
                url: appStore.userProfileImage,
                height: 90,
                width: 90,
                fit: BoxFit.cover,
                radius: 60,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${appStore.userFullName}",
                style: GoogleFonts.workSans(
                  color: AppColors.purewhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${appStore.userEmail}',
                style: GoogleFonts.workSans(
                  color: AppColors.greylight,
                  fontSize: 14,
                ),
              ),
              Text(
                '+${appStore.userContactNumber}',
                style: GoogleFonts.workSans(
                  color: AppColors.greylight,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance',
                style: GoogleFonts.workSans(
                  color: AppColors.bgcolor,
                  fontSize: 14,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'AED ',
                      style: GoogleFonts.workSans(
                        color: Colors.yellow,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '${appStore.userWalletAmount}',
                      style: GoogleFonts.workSans(
                        color: AppColors.darkstheme,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildEditButton(),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () => EditProfileScreen().launch(context),
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
        ),
        child: Center(
          child: Image.asset(
            AppIcons.editIcon,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
