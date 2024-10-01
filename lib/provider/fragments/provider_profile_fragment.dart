import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:hands_user_app/auth/change_password_screen.dart';
// import 'package:hands_user_app/auth/edit_profile_screen.dart';
// import 'package:hands_user_app/auth/sign_in_screen.dart';
import 'package:hands_user_app/components/cached_image_widget.dart';
import 'package:hands_user_app/components/theme_selection_dailog.dart';
// import 'package:hands_user_app/provider/fragments/booking_fragment.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/models/dashboard_response.dart';
import 'package:hands_user_app/models/user_data.dart';
import 'package:hands_user_app/provider/networks/rest_apis.dart';
import 'package:hands_user_app/provider/components/commission_component.dart';
import 'package:hands_user_app/provider/fragments/provider_payment_fragment.dart';
import 'package:hands_user_app/provider/jobRequest/bid_list_screen.dart';
import 'package:hands_user_app/provider/packages/package_list_screen.dart';
import 'package:hands_user_app/provider/service_address/service_addresses_screen.dart';
import 'package:hands_user_app/provider/subscription/subscription_history_screen.dart';
import 'package:hands_user_app/provider/screens/about_us_screen.dart';
import 'package:hands_user_app/provider/screens/bank_account/bank_account_screen.dart';
import 'package:hands_user_app/provider/screens/categories_screen.dart';
import 'package:hands_user_app/provider/screens/languages_screen.dart';
import 'package:hands_user_app/provider/screens/verify_provider_screen.dart';
import 'package:hands_user_app/provider/utils/colors.dart';
import 'package:hands_user_app/provider/utils/common.dart';
import 'package:hands_user_app/provider/utils/configs.dart';
import 'package:hands_user_app/provider/utils/constant.dart';
import 'package:hands_user_app/provider/utils/extensions/string_extension.dart';
import 'package:hands_user_app/provider/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:star_rating/star_rating.dart';

import '../services/addons/addon_service_list_screen.dart';

class ProviderProfileFragment extends StatefulWidget {
  final List<UserDatas>? list;

  ProviderProfileFragment({this.list});

  @override
  ProviderProfileFragmentState createState() => ProviderProfileFragmentState();
}

class ProviderProfileFragmentState extends State<ProviderProfileFragment> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double? rating;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
    // rating = 0;
    rating = await getRatingInProfile() ?? 1;
    print('rating  = ${rating}');
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          return guest && getBoolAsync(HAS_IN_REVIEW)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        languages.loginToContinueProfile,
                        style: boldTextStyle(
                          size: 18,
                        ),
                      ),
                      SizedBox(height: 20),
                      AppButton(
                        width: MediaQuery.of(context).size.width - 100,
                        color:
                            appStore.isDarkMode ? white : context.primaryColor,
                        onTap: () {
                          // SignInScreen().launch(context);
                        },
                        text: languages.signIn,
                        textColor:
                            !appStore.isDarkMode ? white : context.primaryColor,
                      ),
                    ],
                  ),
                )
              : AnimatedScrollView(
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  children: [
                    FadeInDown(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          24.height,
                          if (appStore.userProfileImage.isNotEmpty)
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  decoration: boxDecorationDefault(
                                    border: Border.all(
                                        color: primaryColor, width: 3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    decoration: boxDecorationDefault(
                                      border: Border.all(
                                          color:
                                              context.scaffoldBackgroundColor,
                                          width: 4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CachedImageWidget(
                                      url: appStore.userProfileImage.validate(),
                                      height: 90,
                                      fit: BoxFit.cover,
                                      circle: true,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 8,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(6),
                                    decoration: boxDecorationDefault(
                                      shape: BoxShape.circle,
                                      color: primaryColor,
                                      border: Border.all(
                                          color: context.cardColor, width: 2),
                                    ),
                                    child: Icon(AntDesign.edit,
                                        color: white, size: 18),
                                  ).onTap(() {
                                    // EditProfileScreen().launch(
                                    //   context,
                                    //   pageRouteAnimation:
                                    //       PageRouteAnimation.Fade,
                                    // );
                                  }),
                                ),
                              ],
                            ),
                          16.height,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                appStore.userFullName,
                                style: boldTextStyle(
                                    color: appStore.isDarkMode
                                        ? white
                                        : primaryColor,
                                    size: 16),
                              ),
                              4.height,
                              Text(appStore.userEmail,
                                  style: secondaryTextStyle()),
                            ],
                          ),
                        ],
                      ).center().visible(appStore.isLoggedIn),
                    ),
                    if (appStorePro.earningTypeSubscription &&
                        appStorePro.isPlanSubscribe)
                      Column(
                        children: [
                          32.height,
                          Container(
                            decoration: boxDecorationWithRoundedCorners(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                              backgroundColor: appStorePro.isDarkMode
                                  ? cardDarkColor
                                  : primaryColor.withOpacity(0.1),
                            ),
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(languages.lblCurrentPlan,
                                        style: secondaryTextStyle(
                                            color: appStorePro.isDarkMode
                                                ? white
                                                : appTextSecondaryColor)),
                                    Text(languages.lblValidTill,
                                        style: secondaryTextStyle(
                                            color: appStorePro.isDarkMode
                                                ? white
                                                : appTextSecondaryColor)),
                                  ],
                                ),
                                16.height,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        appStorePro.planTitle
                                            .validate()
                                            .capitalizeFirstLetter(),
                                        style: boldTextStyle()),
                                    Text(
                                      formatDate(
                                          appStorePro.planEndDate.validate(),
                                          format: DATE_FORMAT_2),
                                      style: boldTextStyle(color: primaryColor),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    16.height,
                    if (getStringAsync(DASHBOARD_COMMISSION)
                        .validate()
                        .isNotEmpty) ...[
                      FadeInUp(
                        child: CommissionComponent(
                          commission: Commission.fromJson(
                              jsonDecode(getStringAsync(DASHBOARD_COMMISSION))),
                          rating: rating,
                        ),
                      ),
                      16.height,
                    ],
                    FadeInUpBig(
                      child: Container(
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(32),
                              topLeft: Radius.circular(32)),
                          backgroundColor: appStorePro.isDarkMode
                              ? cardDarkColor
                              : cardColor,
                        ),
                        child: Column(
                          children: [
                            16.height,

                            // Bank account
                            SettingItemWidget(
                              leading: Image.asset(ic_back_account,
                                  height: 16,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.bankAccount,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () {
                                BankAccountScreen().launch(context);
                              },
                            ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),

                            // Categories
                            SettingItemWidget(
                              leading: Image.asset(ic_categories,
                                  height: 16,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.myCategories,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () {
                                CategoriesScreen().launch(context);
                              },
                            ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),
                            if (appStorePro.earningTypeSubscription)
                              SettingItemWidget(
                                leading: Image.asset(services,
                                    height: 16,
                                    width: 16,
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : gray.withOpacity(0.8)),
                                title: languages.lblSubscriptionHistory,
                                trailing: Icon(Icons.chevron_right,
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : gray.withOpacity(0.8),
                                    size: 24),
                                onTap: () async {
                                  SubscriptionHistoryScreen()
                                      .launch(context)
                                      .then((value) {
                                    setState(() {});
                                  });
                                },
                              ),
                            if (appStorePro.earningTypeSubscription)
                              Divider(
                                  height: 0,
                                  thickness: 1,
                                  indent: 15.0,
                                  endIndent: 15.0,
                                  color: context.dividerColor),
                            // SettingItemWidget(
                            //   leading: Image.asset(services,
                            //       height: 16,
                            //       width: 16,
                            //       color: appStorePro.isDarkMode
                            //           ? white
                            //           : gray.withOpacity(0.8)),
                            //   title: languages.lblServices,
                            //   trailing: Icon(Icons.chevron_right,
                            //       color: appStorePro.isDarkMode
                            //           ? white
                            //           : gray.withOpacity(0.8),
                            //       size: 24),
                            //   onTap: () {
                            //     ServiceListScreen().launch(context);
                            //   },
                            // ),
                            // Divider(
                            //     height: 0,
                            //     thickness: 1,
                            //     indent: 15.0,
                            //     endIndent: 15.0,
                            //     color: context.dividerColor),
                            if (appStorePro.userType != USER_TYPE_HANDYMAN)
                              SettingItemWidget(
                                leading: Image.asset(ic_document,
                                    height: 16,
                                    width: 16,
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : gray.withOpacity(0.8)),
                                title: languages.btnVerifyId,
                                trailing: Icon(Icons.chevron_right,
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : gray.withOpacity(0.8),
                                    size: 24),
                                onTap: () {
                                  VerifyProviderScreen().launch(context);
                                },
                              ),
                            if (appStorePro.userType != USER_TYPE_HANDYMAN)
                              Divider(
                                  height: 0,
                                  thickness: 1,
                                  indent: 15.0,
                                  endIndent: 15.0,
                                  color: context.dividerColor),
                            // if (appStorePro.userType != USER_TYPE_HANDYMAN)
                            //   SettingItemWidget(
                            //     leading: Image.asset(ic_blog,
                            //         height: 16,
                            //         width: 16,
                            //         color: appStorePro.isDarkMode
                            //             ? white
                            //             : gray.withOpacity(0.8)),
                            //     title: languages.blogs,
                            //     trailing: Icon(Icons.chevron_right,
                            //         color: appStorePro.isDarkMode
                            //             ? white
                            //             : gray.withOpacity(0.8),
                            //         size: 24),
                            //     onTap: () {
                            //       BlogListScreen().launch(context);
                            //     },
                            //   ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),
                            // SettingItemWidget(
                            //   leading: Image.asset(handyman,
                            //       height: 16,
                            //       width: 16,
                            //       color: appStorePro.isDarkMode
                            //           ? white
                            //           : gray.withOpacity(0.8)),
                            //   title: languages.lblAllHandyman,
                            //   trailing: Icon(Icons.chevron_right,
                            //       color: appStorePro.isDarkMode
                            //           ? white
                            //           : gray.withOpacity(0.8),
                            //       size: 24),
                            //   onTap: () {
                            //     HandymanListScreen().launch(context);
                            //   },
                            // ),
                            // Divider(
                            //     height: 0,
                            //     thickness: 1,
                            //     indent: 15.0,
                            //     endIndent: 15.0,
                            //     color: context.dividerColor),
                            if (getBoolAsync(SERVICE_PKG_ENABLE))
                              SettingItemWidget(
                                leading: Image.asset(ic_packages,
                                    height: 16,
                                    width: 16,
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : gray.withOpacity(0.8)),
                                title: languages.packages,
                                trailing: Icon(Icons.chevron_right,
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : gray.withOpacity(0.8),
                                    size: 24),
                                onTap: () {
                                  PackageListScreen().launch(context);
                                },
                              ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),
                            if (getBoolAsync(SERVICE_ADD_ON_ENABLE))
                              SettingItemWidget(
                                leading: Image.asset(ic_addon_service,
                                    height: 17,
                                    width: 17,
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : gray.withOpacity(0.8)),
                                title: languages.addonServices,
                                trailing: Icon(Icons.chevron_right,
                                    color: appStorePro.isDarkMode
                                        ? white
                                        : gray.withOpacity(0.8),
                                    size: 24),
                                onTap: () {
                                  AddonServiceListScreen().launch(context);
                                },
                              ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),
                            // if (getBoolAsync(SLOT_SERVICE_ENABLE))
                            //   SettingItemWidget(
                            //     leading: Image.asset(ic_time_slots,
                            //         height: 14,
                            //         width: 16,
                            //         color: appStorePro.isDarkMode
                            //             ? white
                            //             : gray.withOpacity(0.8)),
                            //     title: languages.timeSlots,
                            //     trailing: Icon(Icons.chevron_right,
                            //         color: appStorePro.isDarkMode
                            //             ? white
                            //             : gray.withOpacity(0.8),
                            //         size: 24),
                            //     onTap: () {
                            //       MyTimeSlotsScreen().launch(context);
                            //     },
                            //   ),
                            // Divider(
                            //     height: 0,
                            //     thickness: 1,
                            //     indent: 15.0,
                            //     endIndent: 15.0,
                            //     color: context.dividerColor),
                            SettingItemWidget(
                              leading: Image.asset(servicesAddress,
                                  height: 16,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.lblServiceAddress,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () {
                                ServiceAddressesScreen().launch(context);
                              },
                            ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),

                            /// My jobs
                            SettingItemWidget(
                              leading: Image.asset(ic_explore_jobs_active,
                                  height: 16,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.lblBooking,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () {
                                // BookingFragment().launch(context);
                              },
                            ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),

                            /// Payment
                            SettingItemWidget(
                              leading: Image.asset(ic_fill_wallet,
                                  height: 16,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.lblPayment,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () {
                                ProviderPaymentFragment().launch(context);
                              },
                            ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),
                            SettingItemWidget(
                              leading: Image.asset(list,
                                  height: 16,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.bidList,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () {
                                BidListScreen().launch(context);
                              },
                            ),
                            // Divider(
                            //     height: 0,
                            //     thickness: 1,
                            //     indent: 15.0,
                            //     endIndent: 15.0,
                            //     color: context.dividerColor),
                            // SettingItemWidget(
                            //   leading: Image.asset(ic_tax,
                            //       height: 18,
                            //       width: 16,
                            //       color: appStorePro.isDarkMode
                            //           ? white
                            //           : gray.withOpacity(0.8)),
                            //   title: languages.lblTaxes,
                            //   trailing: Icon(Icons.chevron_right,
                            //       color: appStorePro.isDarkMode
                            //           ? white
                            //           : gray.withOpacity(0.8),
                            //       size: 24),
                            //   onTap: () {
                            //     TaxesScreen().launch(context);
                            //   },
                            // ),
                            // if (appStorePro.earningTypeCommission)
                            //   Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       Divider(
                            //           height: 0,
                            //           thickness: 1,
                            //           indent: 15.0,
                            //           endIndent: 15.0,
                            //           color: context.dividerColor),
                            //       SettingItemWidget(
                            //         leading: Image.asset(ic_un_fill_wallet,
                            //             height: 16,
                            //             width: 16,
                            //             color: appStorePro.isDarkMode
                            //                 ? white
                            //                 : gray.withOpacity(0.8)),
                            //         title: languages.lblWalletHistory,
                            //         trailing: Icon(Icons.chevron_right,
                            //             color: appStorePro.isDarkMode
                            //                 ? white
                            //                 : gray.withOpacity(0.8),
                            //             size: 24),
                            //         onTap: () {
                            //           WalletHistoryScreen().launch(context);
                            //         },
                            //       ),
                            //     ],
                            //   ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),

                            SettingItemWidget(
                              leading: Image.asset(ic_theme,
                                  height: 18,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.appTheme,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () async {
                                await showInDialog(
                                  context,
                                  builder: (context) =>
                                      ThemeSelectionDaiLog(context),
                                  contentPadding: EdgeInsets.zero,
                                );
                              },
                            ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),
                            SettingItemWidget(
                              leading: Image.asset(language_alt,
                                  height: 14,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.language,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () {
                                LanguagesScreen().launch(context);
                              },
                            ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),
                            SettingItemWidget(
                              leading: Image.asset(changePassword,
                                  height: 18,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.changePassword,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () {
                                // ChangePasswordScreen().launch(context);
                              },
                            ),
                            Divider(
                                    height: 0,
                                    indent: 16,
                                    endIndent: 16,
                                    color: context.dividerColor)
                                .visible(appStorePro.isLoggedIn),
                            SettingItemWidget(
                              leading: Image.asset(about,
                                  height: 14,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.lblAbout,
                              trailing: Icon(Icons.chevron_right,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8),
                                  size: 24),
                              onTap: () {
                                AboutUsScreen().launch(context);
                              },
                            ),
                            Divider(
                                height: 0,
                                thickness: 1,
                                indent: 15.0,
                                endIndent: 15.0,
                                color: context.dividerColor),
                            SettingItemWidget(
                              leading: Image.asset(ic_check_update,
                                  height: 16,
                                  width: 16,
                                  color: appStorePro.isDarkMode
                                      ? white
                                      : gray.withOpacity(0.8)),
                              title: languages.lblOptionalUpdateNotify,
                              trailing: Transform.scale(
                                scale: 0.7,
                                child: Switch.adaptive(
                                  value: getBoolAsync(UPDATE_NOTIFY,
                                      defaultValue: true),
                                  onChanged: (v) {
                                    setValue(UPDATE_NOTIFY, v);
                                    setState(() {});
                                  },
                                ).withHeight(24),
                              ),
                            ),
                            8.height,
                          ],
                        ),
                      ),
                    ),
                    // SettingSection(
                    //   title: Text(languages.lblDangerZone.toUpperCase(),
                    //       style: boldTextStyle(color: redColor)),
                    //   headingDecoration:
                    //       BoxDecoration(color: redColor.withOpacity(0.08)),
                    //   divider: Offstage(),
                    //   items: [
                    //     8.height,
                    //     SettingItemWidget(
                    //       leading: ic_delete_account.iconImage(
                    //           size: 20,
                    //           color: appStorePro.isDarkMode
                    //               ? white
                    //               : gray.withOpacity(0.8)),
                    //       paddingBeforeTrailing: 4,
                    //       title: languages.lblDeleteAccount,
                    //       onTap: () {
                    //         showConfirmDialogCustom(
                    //           context,
                    //           negativeText: languages.lblCancel,
                    //           positiveText: languages.lblDelete,
                    //           onAccept: (_) {
                    //             ifNotTester(context, () {
                    //               appStorePro.setLoading(true);
                    //
                    //               deleteAccountCompletely().then((value) async {
                    //                 appStorePro.setLoading(true);
                    //
                    //                 await userService.removeDocument(appStorePro.uid);
                    //                 await userService.deleteUser();
                    //                 removeKey(IS_REMEMBERED);
                    //                 await clearPreferences();
                    //
                    //                 toast(value.message);
                    //
                    //                 appStorePro.setLoading(false);
                    //
                    //                 push(SignInScreen(), isNewTask: true);
                    //               }).catchError((e) {
                    //                 appStorePro.setLoading(false);
                    //                 toast(e.toString());
                    //               });
                    //             });
                    //           },
                    //           dialogType: DialogType.DELETE,
                    //           title: languages.lblDeleteAccountConformation,
                    //         );
                    //       },
                    //     ).paddingOnly(left: 4),
                    //   ],
                    // ),
                    SettingItemWidget(
                      leading: ic_delete_account.iconImage(
                          size: 20,
                          color: appStorePro.isDarkMode
                              ? white
                              : gray.withOpacity(0.8)),
                      paddingBeforeTrailing: 4,
                      title: languages.lblDeleteAccount,
                      onTap: () {
                        showConfirmDialogCustom(
                          context,
                          primaryColor: Colors.red,
                          customCenterWidget: Container(
                            color: redColor.withOpacity(.2),
                            child: Center(
                              child: Image.asset(
                                'assets/icons/bin.png',
                                width: 80,
                              ),
                            ),
                          ),
                          negativeText: languages.lblCancel,
                          positiveText: languages.lblDelete,
                          onAccept: (_) {
                            ifNotTester(context, () {
                              appStorePro.setLoading(true);

                              deleteAccountCompletely().then((value) async {
                                appStorePro.setLoading(true);

                                await userService
                                    .removeDocument(appStorePro.uid);
                                await userService.deleteUser();
                                removeKey(IS_REMEMBERED);
                                await clearPreferences();

                                toast(value.message);

                                appStorePro.setLoading(false);

                                // push(SignInScreen(), isNewTask: true);
                              }).catchError((e) {
                                appStorePro.setLoading(false);
                                toast(e.toString());
                              });
                            });
                          },
                          dialogType: DialogType.DELETE,
                          title: languages.lblDeleteAccountConformation,
                        );
                      },
                    ).paddingOnly(left: 4),
                    16.height,
                    TextButton(
                      child: Text(languages.logout,
                          style: boldTextStyle(
                              color:
                                  appStorePro.isDarkMode ? white : primaryColor,
                              size: 16)),
                      onPressed: () {
                        appStorePro.setLoading(false);
                        logout(context);
                      },
                    ).center().visible(appStore.isLoggedIn),
                    VersionInfoWidget(
                            prefixText: 'v', textStyle: secondaryTextStyle())
                        .center(),
                    60.height,
                  ],
                );
        },
      ),
    );
  }
}
