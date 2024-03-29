import "package:flutter/material.dart";
import "package:get_time_ago/get_time_ago.dart";
import "package:loure/provider/notice_provider.dart";

import "package:loure/consts/base.dart";
import "package:loure/util/string_util.dart";

class NoticeListItemComponent extends StatelessWidget {
  NoticeListItemComponent({required this.notice, super.key});
  NoticeData notice;

  @override
  Widget build(final BuildContext context) {
    final themeData = Theme.of(context);
    final hintColor = themeData.hintColor;
    final smallTextSize = themeData.textTheme.bodySmall!.fontSize;

    return Container(
      padding: const EdgeInsets.all(Base.BASE_PADDING),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 1,
        color: hintColor,
      ))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                notice.url,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    GetTimeAgo.parse(DateTime.fromMillisecondsSinceEpoch(
                        notice.dateTime.millisecondsSinceEpoch)),
                    style: TextStyle(
                      fontSize: smallTextSize,
                      color: themeData.hintColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Text(
              StringUtil.breakWord(notice.content),
              style: TextStyle(
                fontSize: smallTextSize,
                color: themeData.hintColor,
                // overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
