import 'package:flutter/material.dart';
import 'package:loure/consts/router_path.dart';
import 'package:loure/main.dart';
import 'package:loure/provider/contact_list_provider.dart';
import 'package:loure/util/router_util.dart';
import 'package:provider/provider.dart';

import 'package:loure/consts/base.dart';

class TagInfoComponent extends StatefulWidget {
  final String tag;

  final double height;

  bool jumpable;

  TagInfoComponent({super.key, 
    required this.tag,
    this.height = 80,
    this.jumpable = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _TagInfoComponent();
  }
}

class _TagInfoComponent extends State<TagInfoComponent> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    var bodyLargeFontSize = themeData.textTheme.bodyLarge!.fontSize;

    var main = Container(
      height: widget.height,
      color: cardColor,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "#${widget.tag}",
            style: TextStyle(
              fontSize: bodyLargeFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Selector<ContactListProvider, bool>(builder: (context, exist, child) {
            IconData iconData = Icons.star_border;
            Color? color;
            if (exist) {
              iconData = Icons.star;
              color = Colors.yellow;
            }
            return GestureDetector(
              onTap: () {
                if (exist) {
                  contactListProvider.removeTag(widget.tag);
                } else {
                  contactListProvider.addTag(widget.tag);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(left: Base.BASE_PADDING_HALF),
                child: Icon(
                  iconData,
                  color: color,
                ),
              ),
            );
          }, selector: (context, provider) {
            return provider.containTag(widget.tag);
          }),
        ],
      ),
    );

    if (widget.jumpable) {
      return GestureDetector(
        onTap: () {
          RouterUtil.router(context, RouterPath.TAG_DETAIL, widget.tag);
        },
        behavior: HitTestBehavior.translucent,
        child: main,
      );
    } else {
      return main;
    }
  }
}
