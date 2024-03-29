import "package:cached_network_image/cached_network_image.dart";
import "package:easy_image_viewer/easy_image_viewer.dart";
import "package:flutter/material.dart";

import "package:loure/consts/base.dart";
import "package:loure/component/image_component.dart";
import "package:loure/component/image_preview_dialog.dart";

class ContentImageComponent extends StatelessWidget {
  ContentImageComponent({
    required this.imageUrl,
    super.key,
    this.imageList,
    this.imageIndex = 0,
    this.width,
    this.height,
    this.imageBoxFix = BoxFit.cover,
  });
  String imageUrl;

  List<String>? imageList;

  int imageIndex;

  double? width;

  double? height;

  BoxFit imageBoxFix;

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(
        top: Base.BASE_PADDING_HALF / 2,
        bottom: Base.BASE_PADDING_HALF / 2,
      ),
      child: GestureDetector(
        onTap: () {
          previewImages(context);
        },
        child: Center(
          child: ImageComponent(
            imageUrl: imageUrl,
            fit: imageBoxFix,
            width: width,
            height: height,
            // placeholder: (context, url) => CircularProgressIndicator(),
            placeholder: (final context, final url) => Container(),
          ),
        ),
      ),
    );
  }

  void previewImages(final context) {
    if (imageList == null || imageList!.isEmpty) {
      imageList = [imageUrl];
    }

    List<ImageProvider> imageProviders = [];
    for (final imageUrl in imageList!) {
      imageProviders.add(CachedNetworkImageProvider(imageUrl));
    }

    final MultiImageProvider multiImageProvider =
        MultiImageProvider(imageProviders, initialIndex: imageIndex);

    ImagePreviewDialog.show(context, multiImageProvider,
        doubleTapZoomable: true, swipeDismissible: true);
  }
}
