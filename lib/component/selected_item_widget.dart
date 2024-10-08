import 'package:hands_user_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:hands_user_app/main.dart';

// ignore: must_be_immutable
class SelectedItemWidget extends StatelessWidget {
  Decoration? decoration;
  double itemSize;
  bool isSelected;

  SelectedItemWidget({this.decoration, this.itemSize = 12.0, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      height: 18,
      width: 18,
      decoration: decoration ??
          boxDecorationDefault(
            color: appStore.isDarkMode ? Color(0xFF000C2C) : Color(0xFFFAF9F6),
            border: Border.all(color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C) ),
            shape: BoxShape.circle,
          ),
      child: isSelected ? Icon(Icons.check, color: appStore.isDarkMode ?  Color(0xFFFAF9F6) : Color(0xFF000C2C), size: itemSize) : Offstage(),
    );
  }
}
