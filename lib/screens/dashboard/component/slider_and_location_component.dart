import 'dart:async';

import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/dashboard_model.dart';
import 'package:hands_user_app/screens/notification/notification_screen.dart';
import 'package:hands_user_app/screens/service/service_detail_screen.dart';
import 'package:hands_user_app/utils/colors.dart';
import 'package:hands_user_app/utils/configs.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/service_data_model.dart';
import '../../../utils/common.dart';
import '../../service/search_service_screen.dart';

class SliderLocationComponent extends StatefulWidget {
  final List<SliderModel> sliderList;
  final List<ServiceData>? featuredList;
  final VoidCallback? callback;

  SliderLocationComponent(
      {required this.sliderList, this.callback, this.featuredList});

  @override
  State<SliderLocationComponent> createState() =>
      _SliderLocationComponentState();
}

class _SliderLocationComponentState extends State<SliderLocationComponent> {
  PageController sliderPageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (getBoolAsync(AUTO_SLIDER_STATUS, defaultValue: true) &&
        widget.sliderList.length >= 2) {
      _timer = Timer.periodic(Duration(seconds: DASHBOARD_AUTO_SLIDER_SECOND),
          (Timer timer) {
        if (_currentPage < widget.sliderList.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        sliderPageController.animateToPage(_currentPage,
            duration: Duration(milliseconds: 950), curve: Curves.easeOutQuart);
      });

      sliderPageController.addListener(() {
        _currentPage = sliderPageController.page!.toInt();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    sliderPageController.dispose();
  }

  Widget getSliderWidget() {
    return SizedBox(
      height: 140,
      width: context.width(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            widget.sliderList.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: PageView(
                      controller: sliderPageController,
                      children: List.generate(
                        widget.sliderList.length,
                        (index) {
                          SliderModel data = widget.sliderList[index];
                          return GestureDetector(
                            onTap: () {
                              if (data.type == SERVICE) {
                                ServiceDetailScreen(
                                        serviceId:
                                            data.typeId.validate().toInt())
                                    .launch(context,
                                        pageRouteAnimation:
                                            PageRouteAnimation.Fade);
                              } else {
                                String temp =
                                    parseHtmlString(data.url.validate());
                                if (temp.startsWith("https") ||
                                    temp.startsWith("http")) {
                                  // launchUrlCustomTab(temp.validate());
                                  commonLaunchUrl(
                                    temp,
                                    launchMode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  toast(language.invalidLink);
                                }
                              }
                            },
                            child: CachedImageWidget(
                              url: data.sliderImage.validate(),
                              height: 140,
                              width: context.width(),
                              fit: BoxFit.cover,
                              radius: 0,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : 1 == 1
                    ? Offstage()
                    : CachedImageWidget(
                        url: '', height: 250, width: context.width()),
            if (widget.sliderList.length.validate() > 1)
              Positioned(
                bottom: 34,
                left: 0,
                right: 0,
                child: DotIndicator(
                  pageController: sliderPageController,
                  pages: widget.sliderList,
                  indicatorColor: white,
                  unselectedIndicatorColor: white,
                  currentBoxShape: BoxShape.rectangle,
                  boxShape: BoxShape.rectangle,
                  borderRadius: radius(2),
                  currentBorderRadius: radius(3),
                  currentDotSize: 18,
                  currentDotWidth: 6,
                  dotSize: 6,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Decoration get commonDecoration {
    return boxDecorationDefault(
      color: context.cardColor,
      boxShadow: [
        BoxShadow(color: shadowColorGlobal, offset: Offset(1, 0)),
        BoxShadow(color: shadowColorGlobal, offset: Offset(0, 1)),
        BoxShadow(color: shadowColorGlobal, offset: Offset(-1, 0)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.sliderList.isNotEmpty) getSliderWidget(),
        10.height,
      ],
    );
  }
}
