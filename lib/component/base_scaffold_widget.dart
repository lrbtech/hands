import 'package:hands_user_app/component/back_widget.dart';
import 'package:hands_user_app/component/base_scaffold_body.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constant.dart';

class AppScaffold extends StatelessWidget {
  final String? appBarTitle;
  final List<Widget>? actions;

  final Widget child;
  final Color? scaffoldBackgroundColor;
  final Widget? bottomNavigationBar;
  final bool showLoader;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showBackButton;
  final bool centerTitle;

  AppScaffold(
      {this.appBarTitle,
      required this.child,
      this.actions,
      this.scaffoldBackgroundColor,
      this.showBackButton = true,
      this.bottomNavigationBar,
      this.showLoader = true,
      this.floatingActionButton,
      this.floatingActionButtonLocation,
      this.centerTitle = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTitle != null
          ? appBarWidget(appBarTitle.validate(),
              // textColor: white,
              textSize: APP_BAR_TEXT_SIZE,
              elevation: 0.0,
              color: context.scaffoldBackgroundColor,
              backWidget: showBackButton ? BackWidget() : SizedBox.shrink(),
              actions: actions,
              center: centerTitle)
          : null,
      backgroundColor: scaffoldBackgroundColor,
      body: Body(child: child, showLoader: showLoader),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
