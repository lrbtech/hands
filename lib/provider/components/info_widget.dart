import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class InfoWidget extends StatelessWidget {
  final String info;

  const InfoWidget({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          color: textSecondaryColor,
          size: 17,
        ),
        5.width,
        Text(
          info,
          style: secondaryTextStyle(),
        ).expand(),
      ],
    );
  }
}
