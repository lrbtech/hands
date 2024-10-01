import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class CustomStepperWidget extends StatelessWidget {
  const CustomStepperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Row(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                if (appStore.currentBookingStep != 0) {
                  appStore.currentBookingStep = 0;
                }
              },
              child: AnimatedContainer(
                  duration: 200.milliseconds,
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: appStore.currentBookingStep > 0 ? greenColor : primaryColor, borderRadius: BorderRadius.circular(50)),
                  child: appStore.currentBookingStep > 0
                      ? Checkbox(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          activeColor: greenColor,
                          value: true,
                          onChanged: (_) {},
                        )
                      : Text(
                          '1',
                          style: boldTextStyle(color: white),
                        )),
            ),
            5.height,
            Text(
              language.lblStep1,
              style: appStore.currentBookingStep == 0 ? boldTextStyle() : primaryTextStyle(),
            )
          ],
        ),
        Expanded(
            child: AnimatedContainer(
          duration: 200.milliseconds,
          color: lightGrey,
          margin: EdgeInsets.symmetric(vertical: 25),
          height: .5,
        ).paddingBottom(20).center()),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: 200.milliseconds,
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: appStore.currentBookingStep > 0 ? primaryColor : lightGrey, borderRadius: BorderRadius.circular(50)),
              child: Center(
                child: Text(
                  '2',
                  style: boldTextStyle(color: appStore.currentBookingStep > 0 ? white : primaryColor),
                ),
              ),
            ),
            5.height,
            Text(
              language.lblStep2,
              style: appStore.currentBookingStep == 1 ? boldTextStyle() : primaryTextStyle(),
            )
          ],
        ),
      ]).paddingSymmetric(horizontal: 20),
    );
  }
}
