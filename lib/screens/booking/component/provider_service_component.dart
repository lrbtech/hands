import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/image_border_component.dart';
import '../../../component/price_widget.dart';
import '../../../main.dart';
import '../../../model/package_data_model.dart';
import '../../../model/service_data_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import '../../service/service_detail_screen.dart';
import '../provider_info_screen.dart';

class ProviderServiceComponent extends StatefulWidget {
  final ServiceData? serviceData;
  final BookingPackage? selectedPackage;
  final bool? isBorderEnabled;
  final VoidCallback? onUpdate;
  final bool isFavouriteService;
  final bool isFromProviderInfo;

  ProviderServiceComponent({
    this.serviceData,
    this.selectedPackage,
    this.isBorderEnabled,
    this.onUpdate,
    this.isFavouriteService = false,
    this.isFromProviderInfo = false,
  });

  @override
  _ProviderServiceComponentState createState() => _ProviderServiceComponentState();
}

class _ProviderServiceComponentState extends State<ProviderServiceComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        ServiceDetailScreen(serviceId: widget.isFavouriteService ? widget.serviceData!.serviceId.validate().toInt() : widget.serviceData!.id.validate()).launch(context).then((value) {
          setStatusBarColor(context.primaryColor);
        });
      },
      child: Container(
        width: context.width(),
        padding: EdgeInsets.only(left: 16, top: 16, bottom: 16),
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(),
          backgroundColor: context.cardColor,
          border: widget.isBorderEnabled.validate(value: false)
              ? appStore.isDarkMode
                  ? Border.all(color: context.dividerColor)
                  : null
              : null,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CachedImageWidget(
                      url: widget.isFavouriteService
                          ? widget.serviceData!.serviceAttachments.validate().isNotEmpty
                              ? widget.serviceData!.serviceAttachments!.first.validate()
                              : ''
                          : widget.serviceData!.attachments.validate().isNotEmpty
                              ? widget.serviceData!.attachments!.first.validate()
                              : '',
                      fit: BoxFit.cover,
                      height: 85,
                      circle: false,
                      radius: defaultRadius,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                        constraints: BoxConstraints(maxWidth: context.width() * 0.1),
                        decoration: boxDecorationWithShadow(
                          backgroundColor: context.cardColor.withOpacity(0.9),
                          borderRadius: radius(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ic_star_fill.iconImage(color: getRatingBarColor(widget.serviceData!.totalRating.validate().toInt()), size: 11),
                            Text(" ${widget.serviceData!.totalRating.validate().toStringAsPrecision(2)}", style: secondaryTextStyle(size: 10, weight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                12.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceData!.name.validate(),
                          style: boldTextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).expand(),
                        6.width,
                        if (widget.serviceData!.isOnlineService) Icon(Icons.circle, color: Colors.green, size: 12),
                      ],
                    ),
                    6.height,
                    Text(
                      "${widget.serviceData!.subCategoryName.validate().isNotEmpty ? widget.serviceData!.subCategoryName.validate() : widget.serviceData!.categoryName.validate()}",
                      style: boldTextStyle(color: appStore.isDarkMode ? white : primaryColor, size: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.height,
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: boxDecorationWithShadow(
                            backgroundColor: primaryColor,
                            borderRadius: radius(24),
                            border: Border.all(color: context.cardColor, width: 2),
                          ),
                          child: PriceWidget(
                            price: widget.serviceData!.price.validate(),
                            isHourlyService: widget.serviceData!.isHourlyService,
                            color: Colors.white,
                            hourlyTextColor: Colors.white,
                            size: 14,
                            isFreeService: widget.serviceData!.type.validate() == SERVICE_TYPE_FREE,
                          ),
                        ).scale(scale: 0.92),
                        8.width,
                        if (!widget.isFromProviderInfo)
                          Row(
                            children: [
                              ImageBorder(src: widget.serviceData!.providerImage.validate(), height: 20),
                              8.width,
                              if (widget.serviceData!.providerName.validate().isNotEmpty)
                                Marquee(
                                  child: Text(
                                    widget.serviceData!.providerName.validate(),
                                    style: secondaryTextStyle(size: 12, color: appStore.isDarkMode ? Colors.white : appTextSecondaryColor),
                                  ),
                                ).expand()
                            ],
                          )
                              .onTap(() async {
                                if (widget.serviceData!.providerId != appStore.userId.validate()) {
                                  await ProviderInfoScreen(providerId: widget.serviceData!.providerId.validate()).launch(context);
                                  setStatusBarColor(Colors.transparent);
                                }
                              })
                              .paddingBottom(4)
                              .expand(),
                      ],
                    ),
                  ],
                ).expand(),
                8.width,
                if (widget.isFavouriteService)
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
                    child: widget.serviceData!.isFavourite == 0 ? ic_fill_heart.iconImage(color: favouriteColor, size: 18) : ic_heart.iconImage(color: unFavouriteColor, size: 18),
                  ).onTap(() async {
                    if (widget.serviceData!.isFavourite == 0) {
                      widget.serviceData!.isFavourite = 1;
                      setState(() {});

                      await removeToWishList(serviceId: widget.serviceData!.serviceId.validate().toInt()).then((value) {
                        if (!value) {
                          widget.serviceData!.isFavourite = 0;
                          setState(() {});
                        }
                      });
                    } else {
                      widget.serviceData!.isFavourite = 0;
                      setState(() {});

                      await addToWishList(serviceId: widget.serviceData!.serviceId.validate().toInt()).then((value) {
                        if (!value) {
                          widget.serviceData!.isFavourite = 1;
                          setState(() {});
                        }
                      });
                    }
                    widget.onUpdate?.call();
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
