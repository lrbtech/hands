import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hands_user_app/component/cached_image_widget.dart';
import 'package:hands_user_app/main.dart';
import 'package:hands_user_app/utils/common.dart';
import 'package:hands_user_app/utils/constant.dart';
import 'package:hands_user_app/utils/images.dart';
import 'package:hands_user_app/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

class CustomImagePicker extends StatefulWidget {
  final Function(List<File> files) onFileSelected;
  final Function(String value)? onRemoveClick;
  final List<String>? selectedImages;

  CustomImagePicker({Key? key, required this.onFileSelected, this.selectedImages, this.onRemoveClick}) : super(key: key);

  @override
  _CustomImagePickerState createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  List<File> imageFiles = [];

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  void init() async {
    if (widget.selectedImages.validate().isNotEmpty) {
      widget.selectedImages.validate().forEach((element) {
        if (element.validate().contains("http")) {
          imageFiles.add(File(element.validate()));
        } else {
          imageFiles.add(File(element.validate()));
          widget.onFileSelected.call(imageFiles);
        }
      });
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: widget.key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            await showInDialog(
              context,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
              title: Text(language.chooseMediaSource, style: boldTextStyle()),
              builder: (p0) {
                return FilePickerDialog(isSelected: (false));
              },
            ).then((file) async {
              if (file != null) {
                if (file == GalleryFileTypes.CAMERA) {
                  await getCameraImage().then((value) {
                    if (imageFiles.validate().isNotEmpty) {
                      imageFiles.insert(0, value);
                    } else {
                      imageFiles.add(value);
                    }
                    setState(() {});
                  });
                } else if (file == GalleryFileTypes.GALLERY) {
                  await getMultipleImageSource().then((value) {
                    if (imageFiles.validate().isNotEmpty) {
                      value.forEach((element) {
                        imageFiles.add(element);
                      });
                    } else {
                      imageFiles = value;
                    }
                    setState(() {});
                  });
                }
                widget.onFileSelected.call(imageFiles);
              }
            });
          },
          child: DottedBorderWidget(
            color: transparentColor,
            radius: defaultRadius,
            child: Container(
              padding: EdgeInsets.all(26),
              alignment: Alignment.center,
              decoration: boxDecorationWithShadow(blurRadius: 0, backgroundColor: context.cardColor, borderRadius: radius()),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.uploadImagesTitle, style: boldTextStyle()),
                        10.height,
                        Text(
                          language.uploadImagesDescription,
                          style: secondaryTextStyle(color: lightSlateGrey),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: boxDecorationWithShadow(
                      blurRadius: 0,
                      backgroundColor: white,
                      borderRadius: radius(),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 3),
                          color: black.withOpacity(0.25),
                          blurRadius: 1.6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Image.asset("assets/images/browse_images.png"),
                        10.height,
                        Text(
                          language.browseImages,
                          style: secondaryTextStyle(
                            color: black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ic_no_photo.iconImage(size: 46),
                  // 8.height,
                  // Text(language.chooseImages, style: secondaryTextStyle()),
                ],
              ),
            ),
          ),
        ),
        // 16.height,
        // Text(language., style: secondaryTextStyle(size: 10)),
        8.height,
        if (imageFiles.isNotEmpty)
          HorizontalList(
            itemCount: imageFiles.length,
            spacing: 16,
            itemBuilder: (context, index) {
              bool isNetworkImage = imageFiles[index].path.contains("http");
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  if (isNetworkImage)
                    CachedImageWidget(
                      url: imageFiles[index].path,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      radius: defaultRadius,
                    )
                  else
                    Image.file(
                      File(imageFiles[index].path),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return PlaceHolderWidget(height: 80, alignment: Alignment.center);
                      },
                    ).cornerRadiusWithClipRRect(defaultRadius),
                  Positioned.directional(
                    textDirection: appStore.isArabic ? TextDirection.rtl : TextDirection.ltr,
                    top: -10,
                    start: -10,
                    child: IconButton(
                      onPressed: () {
                        widget.onRemoveClick!.call(imageFiles[index].path);
                      },
                      icon: Icon(Icons.dangerous_outlined, color: Colors.red),
                    ),
                  )
                ],
              );
            },
          ),
      ],
    );
  }
}

class FilePickerDialog extends StatelessWidget {
  final bool isSelected;

  FilePickerDialog({this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingItemWidget(
            title: language.remove,
            titleTextStyle: primaryTextStyle(),
            leading: Icon(Icons.close, color: context.iconColor),
            onTap: () {
              finish(context, GalleryFileTypes.CANCEL);
            },
          ).visible(isSelected),
          SettingItemWidget(
            title: language.camera,
            titleTextStyle: primaryTextStyle(),
            leading: Icon(LineIcons.camera, color: context.iconColor),
            onTap: () {
              finish(context, GalleryFileTypes.CAMERA);
            },
          ).visible(!isWeb),
          SettingItemWidget(
            title: language.lblGallery,
            titleTextStyle: primaryTextStyle(),
            leading: Icon(LineIcons.image_1, color: context.iconColor),
            onTap: () {
              finish(context, GalleryFileTypes.GALLERY);
            },
          ),
        ],
      ),
    );
  }
}
