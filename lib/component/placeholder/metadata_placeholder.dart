import "package:flutter/material.dart";
import "package:flutter_placeholder_textlines/placeholder_lines.dart";

import "package:loure/consts/base.dart";
import "package:loure/component/placeholder/metadata_top_placeholder.dart";

class MetadataPlaceholder extends StatelessWidget {
  const MetadataPlaceholder({super.key});

  @override
  Widget build(final BuildContext context) {
    final themeData = Theme.of(context);
    final hintColor = themeData.hintColor;
    final smallTextSize = themeData.textTheme.bodySmall!.fontSize;

    const textLineMagin = EdgeInsets.only(bottom: 6);

    List<Widget> mainList = [];

    mainList.add(const MetadataTopPlaceholder());

    mainList.add(
      Container(
        width: double.maxFinite,
        padding: const EdgeInsets.only(
          top: Base.BASE_PADDING_HALF,
          left: Base.BASE_PADDING,
          right: Base.BASE_PADDING,
          bottom: Base.BASE_PADDING,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: textLineMagin,
              child: PlaceholderLines(
                count: 1,
                lineHeight: smallTextSize!,
                color: hintColor,
              ),
            ),
            Container(
              width: 200,
              margin: textLineMagin,
              child: PlaceholderLines(
                count: 1,
                lineHeight: smallTextSize,
                color: hintColor,
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: mainList,
    );
  }
}
