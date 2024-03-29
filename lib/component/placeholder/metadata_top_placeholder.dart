import "package:flutter/material.dart";
import "package:flutter_placeholder_textlines/placeholder_lines.dart";

import "package:loure/consts/base.dart";
import "package:loure/main.dart";
import "package:loure/util/platform_util.dart";
import "package:loure/component/user/metadata_top_component.dart";

class MetadataTopPlaceholder extends StatelessWidget {
  const MetadataTopPlaceholder({super.key});
  static const double IMAGE_BORDER = 4;

  static const double IMAGE_WIDTH = 80;

  static const double HALF_IMAGE_WIDTH = 40;

  @override
  Widget build(final BuildContext context) {
    final themeData = Theme.of(context);
    final hintColor = themeData.hintColor;
    final scaffoldBackgroundColor = themeData.scaffoldBackgroundColor;
    final maxWidth = mediaDataCache.size.width;
    var bannerHeight = maxWidth / 3;
    if (PlatformUtil.isTableMode()) {
      bannerHeight =
          MetadataTopComponent.getPcBannerHeight(mediaDataCache.size.height);
    }
    final textSize = themeData.textTheme.bodyMedium!.fontSize;

    List<Widget> topBtnList = [
      Expanded(
        child: Container(),
      )
    ];
    topBtnList.add(Container(
      width: 140,
      margin: const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
      child: PlaceholderLines(
        count: 1,
        lineHeight: 30,
        color: hintColor,
        minWidth: 1,
      ),
    ));

    final Widget userNameComponent = Container(
      // height: 40,
      width: 120,
      margin: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
        // top: Base.BASE_PADDING_HALF,
        bottom: Base.BASE_PADDING_HALF,
      ),
      // color: Colors.green,
      child: PlaceholderLines(
        count: 1,
        lineHeight: 18,
        color: hintColor,
      ),
    );

    List<Widget> topList = [];
    topList.add(Container(
      width: maxWidth,
      height: bannerHeight,
      color: Colors.grey.withOpacity(0.5),
    ));
    topList.add(SizedBox(
      height: 50,
      // color: Colors.red,
      child: Row(
        children: topBtnList,
      ),
    ));
    topList.add(userNameComponent);

    topList.add(Container(
      margin: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
      ),
      width: maxWidth,
      child: PlaceholderLines(
        count: 1,
        lineHeight: textSize!,
        color: hintColor,
        minWidth: 1,
        maxWidth: 1,
      ),
    ));

    final Widget userImageWidget = Container(
      alignment: Alignment.center,
      height: IMAGE_WIDTH,
      width: IMAGE_WIDTH,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HALF_IMAGE_WIDTH),
        color: hintColor,
      ),
    );

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: topList,
        ),
        Positioned(
          left: Base.BASE_PADDING,
          top: bannerHeight - HALF_IMAGE_WIDTH,
          child: Container(
            height: IMAGE_WIDTH + IMAGE_BORDER * 2,
            width: IMAGE_WIDTH + IMAGE_BORDER * 2,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(HALF_IMAGE_WIDTH + IMAGE_BORDER),
              border: Border.all(
                width: IMAGE_BORDER,
                color: scaffoldBackgroundColor,
              ),
            ),
            child: userImageWidget,
          ),
        )
      ],
    );
  }
}
