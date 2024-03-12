import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nostrmo/client/nip07/kind_descriptions.dart';
import 'package:nostrmo/client/nip07/nip07_methods.dart';
import 'package:nostrmo/main.dart';
import 'package:nostrmo/util/string_util.dart';

import '../consts/base.dart';
import '../util/router_util.dart';

// ignore: must_be_immutable
class NIP07Dialog extends StatefulWidget {
  String method;

  String? content;

  NIP07Dialog({
    super.key,
    required this.method,
    this.content,
  });

  static Future<bool?> show(BuildContext context, String method,
      {String? content}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return NIP07Dialog(
          method: method,
          content: content,
        );
      },
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _NIP07Dialog();
  }
}

class _NIP07Dialog extends State<NIP07Dialog> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    // var mainColor = themeData.primaryColor;
    var titleFontSize = themeData.textTheme.bodyLarge!.fontSize;
    Color cardColor = themeData.cardColor;
    var hintColor = themeData.hintColor;

    List<Widget> list = [];
    list.add(
      Text(
        "NIP-07 ${"Confirm"}",
        style: TextStyle(
          fontSize: titleFontSize! + 4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    list.add(const Divider());

    list.add(Container(
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      child: Row(
        children: [
          const Text("${"Method"}:  "),
          Text(widget.method),
        ],
      ),
    ));

    String methodDesc = "Get Public Key";
    if (widget.method == NIP07Methods.getRelays) {
      methodDesc = "Get Relays";
    } else if (widget.method == NIP07Methods.nip04_encrypt) {
      methodDesc = "Encrypt";
    } else if (widget.method == NIP07Methods.nip04_decrypt) {
      methodDesc = "Decrypt";
    } else if (widget.method == NIP07Methods.signEvent) {
      methodDesc = "Sign Event";
      try {
        if (StringUtil.isNotBlank(widget.content)) {
          var jsonObj = jsonDecode(widget.content!);
          var eventKind = jsonObj["kind"];
          var kindDesc = KindDescriptions.getDes(eventKind);
          methodDesc += ": $kindDesc";
        }
      } catch (e) {}
    } else if (widget.method == NIP07Methods.lightning) {
      methodDesc = "Lightning payment";
    }
    list.add(Container(
      margin: const EdgeInsets.only(bottom: Base.BASE_PADDING_HALF),
      child: Row(
        children: [
          Text(methodDesc),
        ],
      ),
    ));

    if (StringUtil.isNotBlank(widget.content)) {
      list.add(Container(
        child: const Text("${"Content"}:"),
      ));
      list.add(Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(Base.BASE_PADDING_HALF),
        decoration: BoxDecoration(
          color: hintColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        margin: const EdgeInsets.only(
          bottom: Base.BASE_PADDING_HALF,
          top: Base.BASE_PADDING_HALF,
        ),
        child: SelectableText(widget.content!),
      ));
    }

    list.add(Container(
      margin: const EdgeInsets.only(top: Base.BASE_PADDING_HALF),
      child: Row(children: [
        Expanded(
            child: InkWell(
          onTap: () {
            RouterUtil.back(context, false);
          },
          child: Container(
            height: 36,
            color: hintColor.withOpacity(0.3),
            alignment: Alignment.center,
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),
        Container(
          width: Base.BASE_PADDING,
        ),
        Expanded(
            child: InkWell(
          onTap: () {
            RouterUtil.back(context, true);
          },
          child: Container(
            height: 36,
            color: hintColor.withOpacity(0.3),
            alignment: Alignment.center,
            child: Text(
              "Confirm",
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),
      ]),
    ));

    var main = Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(maxHeight: mediaDataCache.size.height * 0.85),
      decoration: BoxDecoration(
        color: cardColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: list,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: FocusScope(
        // autofocus: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            RouterUtil.back(context);
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.only(
              left: Base.BASE_PADDING,
              right: Base.BASE_PADDING,
            ),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {},
              child: main,
            ),
          ),
        ),
      ),
    );
  }
}
