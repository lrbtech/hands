import 'package:flutter/widgets.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/model/category_model.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryData categoryData;
  final double? width;
  final bool? isFromCategory;

  CategoryWidget({required this.categoryData, this.width, this.isFromCategory = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? null,
      child: Container(
        child: categoryData.categoryImage.validate().endsWith('.svg')
            ? Container(
                // width: CATEGORY_ICON_SIZE,
                // height: CATEGORY_ICON_SIZE,
                // padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    SvgPicture.network(
                      categoryData.categoryImage.validate(),
                      height: CATEGORY_ICON_SIZE,
                      width: CATEGORY_ICON_SIZE,
                      fit: BoxFit.contain,
                      color: appStore.isDarkMode ? Colors.white : categoryData.color.validate(value: '000').toColor(),
                      placeholderBuilder: (context) => PlaceHolderWidget(
                        height: CATEGORY_ICON_SIZE,
                        width: CATEGORY_ICON_SIZE,
                        color: transparentColor,
                      ),
                    ).paddingAll(10),
                    4.height,
                    Marquee(
                      directionMarguee: DirectionMarguee.oneDirection,
                      child: Text(
                        '${categoryData.name.validate()}',
                        style: primaryTextStyle(size: 12),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isFromCategory == true
                    ? Column(
                        children: [
                          CachedImageWidget(
                            url: categoryData.categoryImage.validate(),
                            fit: BoxFit.contain,
                            width: 50,
                            height: 50,
                            circle: false,
                            placeHolderImage: '',
                          ),
                          10.height,
                          Flexible(
                            child: Marquee(
                              directionMarguee: DirectionMarguee.oneDirection,
                              child: Text(
                                appStore.selectedLanguageCode == 'en' ? '${categoryData.name.validate()}' : (['', null].contains(categoryData.nameAr) ? categoryData.name.validate() : categoryData.nameAr.validate()),
                                style: boldTextStyle(size: 14, color: Color(0xFF2E3234)),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CachedImageWidget(
                            url: categoryData.categoryImage.validate(),
                            fit: BoxFit.contain,
                            width: 50,
                            height: 50,
                            circle: false,
                            placeHolderImage: '',
                          ),
                          10.width,
                          Flexible(
                            child: Marquee(
                              directionMarguee: DirectionMarguee.oneDirection,
                              child: Text(
                                appStore.selectedLanguageCode == 'en' ? '${categoryData.name.validate()}' : (['', null].contains(categoryData.nameAr) ? categoryData.name.validate() : categoryData.nameAr.validate()),
                                style: boldTextStyle(size: 14, color: Color(0xFF2E3234)),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
      ),
    );
  }
}
