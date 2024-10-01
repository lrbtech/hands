import 'package:flutter/material.dart';
import 'package:hands_user_app/component/spin_kit_chasing_dots.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:super_circle/super_circle.dart';

class LoaderWidget extends StatefulWidget {
  @override
  _LoaderWidgetState createState() => _LoaderWidgetState();
}

class _LoaderWidgetState extends State<LoaderWidget> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 1 == 1
        ? Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/ic_app_logo.png',
                      width: 80,
                    ).center(),
                    LoadingAnimationWidget.threeArchedCircle(
                      color: primaryColor,
                      size: 100,
                    ).center()
                  ],
                ),
              ),
            ),
          )
        : SpinKitChasingDots(color: primaryColor);
  }
}

// class LoaderWidget extends StatelessWidget {
//   final double? size;

//   LoaderWidget({this.size});

//   @override
//   Widget build(BuildContext context) {
//     // return SpinKitChasingDots(color: primaryColor, size: size ?? 50);
//     return Center(
//       child: SuperCircle(
//         size: 150,
//         rotateBegin: 1.0,
//         rotateEnd: 0.0,
//         backgroundCircleColor: Colors.transparent,
//         speedRotateCircle: 6000,
//         speedChangeShadowColorInner: 2000,
//         speedChangeShadowColorOuter: 2000,
//         child: Container(
//           width: 100,
//           height: 100,
//           color: Colors.transparent,
//           child: Image.asset(
//             'assets/ic_app_logo.png',
//             width: 100,
//             height: 100,
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     );
//   }
// }
