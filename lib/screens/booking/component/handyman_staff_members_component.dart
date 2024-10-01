import 'package:hands_user_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/flutter_image_stack_widget.dart';
import '../../../main.dart';
import '../../../model/user_data_model.dart';
import '../../../utils/constant.dart';
import 'handyman_list_component.dart';

class HandymanStaffMembersComponent extends StatelessWidget {
  final List<String> images;
  final List<UserData> handymanList;

  HandymanStaffMembersComponent({required this.images, required this.handymanList});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.team, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        FlutterImageStack(
          imageList: images,
          totalCount: images.length,
          itemCount: 6,
          showTotalCount: true,
          itemRadius: 50,
          itemBorderWidth: 2,
          itemBorderColor: primaryColor,
          onCallBack: () {
            HandymanListComponent(handymanList: handymanList.validate()).launch(context);
          },
        ),
      ],
    );
  }
}
