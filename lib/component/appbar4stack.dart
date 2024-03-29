import "package:flutter/material.dart";

import "package:loure/util/router_util.dart";

class Appbar4Stack extends StatefulWidget {
  Appbar4Stack({
    super.key,
    this.title,
    this.backgroundColor,
    this.action,
  });
  Widget? title;

  Color? backgroundColor;

  Widget? action;

  @override
  State<StatefulWidget> createState() {
    return _Appbar4Stack();
  }
}

class _Appbar4Stack extends State<Appbar4Stack> {
  double height = 46;

  @override
  Widget build(final BuildContext context) {
    final themeData = Theme.of(context);
    var backgroundColor = widget.backgroundColor;
    backgroundColor ??= themeData.appBarTheme.backgroundColor;

    List<Widget> list = [
      GestureDetector(
        child: Container(
          alignment: Alignment.center,
          width: height,
          child: const Icon(Icons.arrow_back_ios_new),
        ),
        onTap: () {
          RouterUtil.back(context);
        },
      )
    ];

    if (widget.title != null) {
      list.add(Expanded(child: widget.title!));
    } else {
      list.add(Expanded(child: Container()));
    }

    if (widget.action != null) {
      list.add(Container(
        child: widget.action,
      ));
    } else {
      list.add(Container(
        width: height,
      ));
    }

    return Container(
      height: height,
      color: backgroundColor,
      // color: Colors.red,
      child: Row(
        children: list,
      ),
    );
  }
}
