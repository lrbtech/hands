import 'package:hands_user_app/component/base_scaffold_widget.dart';
import 'package:hands_user_app/component/theme_selection_dialog.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/network/rest_apis.dart';
import 'package:hands_user_app/screens/dashboard/dashboard_screen.dart';
import 'package:hands_user_app/screens/language_screen.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'auth/change_password_screen.dart';
import 'package:hands_user_app/component/custom_confirmation_dialog.dart';

class SettingScreen extends StatefulWidget {
  SettingScreen({this.showBack = true});
  final bool? showBack;

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();

    LiveStream().on('language_change', (p0) {
      print("Language changed.");
      setState(() {});
    });
  }

  @override
  void dispose() {
    LiveStream().dispose('language_change');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.lblAppSetting,
      showBackButton: widget.showBack == true,
      child: AnimatedScrollView(
        padding: EdgeInsets.symmetric(vertical: 8),
        listAnimationType: ListAnimationType.FadeIn,
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        children: [
          if (isLoginTypeUser)
            SettingItemWidget(
              leading: ic_lock.iconImage(size: SETTING_ICON_SIZE),
              title: language.changePassword,
              trailing: trailing,
              onTap: () {
                doIfLoggedIn(context, () {
                  ChangePasswordScreen().launch(context);
                });
              },
            ),
          SettingItemWidget(
            leading: ic_language.iconImage(size: 17).paddingOnly(left: 2),
            paddingAfterLeading: 16,
            title: language.language,
            trailing: trailing,
            onTap: () {
              LanguagesScreen().launch(context).then((value) {});
            },
          ),
          SettingItemWidget(
            leading: ic_delete_account.iconImage(size: SETTING_ICON_SIZE),
            paddingBeforeTrailing: 4,
            title: language.lblDeleteAccount,
            trailing: trailing,
            onTap: () {
              showCustomConfirmDialog(
                context,
                negativeText: language.lblCancel,
                positiveText: language.lblDelete,
                onAccept: (_) {
                  ifNotTester(() {
                    appStore.setLoading(true);

                    deleteAccountCompletely().then((value) async {
                      await userService.removeDocument(appStore.uid);
                      await userService.deleteUser();
                      setValue(IS_REMEMBERED, false);
                      await clearPreferences();
                      appStore.setLoading(false);
                      toast(value.message);

                      push(DashboardScreen(),
                          isNewTask: true,
                          pageRouteAnimation: PageRouteAnimation.Fade);
                    }).catchError((e) {
                      appStore.setLoading(false);
                      toast(e.toString());
                    });
                  });
                },
                dialogType: DialogType.DELETE,
                title: language.lblDeleteAccountConformation,
              );
            },
          ).paddingOnly(left: 4),
          SettingItemWidget(
            leading: ic_dark_mode.iconImage(size: 22),
            title: language.appTheme,
            paddingAfterLeading: 12,
            trailing: trailing,
            onTap: () async {
              await showInDialog(
                context,
                builder: (context) => ThemeSelectionDaiLog(),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
          // SettingItemWidget(
          //   leading: ic_slider_status.iconImage(size: SETTING_ICON_SIZE),
          //   title: language.lblAutoSliderStatus,
          //   trailing: Transform.scale(
          //     scale: 0.8,
          //     child: Switch.adaptive(
          //       value: getBoolAsync(AUTO_SLIDER_STATUS, defaultValue: true),
          //       onChanged: (v) {
          //         setValue(AUTO_SLIDER_STATUS, v);
          //         setState(() {});
          //       },
          //     ).withHeight(24),
          //   ),
          // ),
          // SettingItemWidget(
          //   leading: ic_check_update.iconImage(size: SETTING_ICON_SIZE),
          //   title: language.lblOptionalUpdateNotify,
          //   trailing: Transform.scale(
          //     scale: 0.8,
          //     child: Switch.adaptive(
          //       value: getBoolAsync(UPDATE_NOTIFY, defaultValue: true),
          //       onChanged: (v) {
          //         setValue(UPDATE_NOTIFY, v);
          //         setState(() {});
          //       },
          //     ).withHeight(24),
          //   ),
          // ),
          // SnapHelperWidget<bool>(
          //   future: isAndroid12Above(),
          //   onSuccess: (data) {
          //     if (data) {
          //       return SettingItemWidget(
          //         leading: ic_android_12.iconImage(size: SETTING_ICON_SIZE),
          //         title: language.lblMaterialTheme,
          //         trailing: Transform.scale(
          //           scale: 0.8,
          //           child: Switch.adaptive(
          //             value: appStore.useMaterialYouTheme,
          //             onChanged: (v) {
          //               showCustomConfirmDialog(
          //                 context,
          //                 onAccept: (_) {
          //                   appStore.setUseMaterialYouTheme(v.validate());

          //                   RestartAppWidget.init(context);
          //                 },
          //                 title: language.lblAndroid12Support,
          //                 primaryColor: context.primaryColor,
          //                 positiveText: language.lblYes,
          //                 negativeText: language.lblCancel,
          //               );
          //             },
          //           ).withHeight(24),
          //         ),
          //         onTap: null,
          //       );
          //     }
          //     return Offstage();
          //   },
          // ),
        ],
      ),
    );
  }
}
