import "dart:convert";

import "package:flutter/material.dart";

import "package:loure/component/cust_state.dart";
import "package:loure/consts/base.dart";
import "package:loure/util/dio_util.dart";
import "package:loure/util/router_util.dart";
import "package:loure/util/string_util.dart";
import "package:loure/router/web_utils/web_util_item_component.dart";

class WebUtilsRouter extends StatefulWidget {
  const WebUtilsRouter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WebUtilsRouter();
  }
}

class _WebUtilsRouter extends CustState<WebUtilsRouter> {
  @override
  Widget doBuild(final BuildContext context) {
    final themeData = Theme.of(context);
    final titleFontSize = themeData.textTheme.bodyLarge!.fontSize;

    List<Widget> list = [
      // WebUtilItemComponent(
      //   link: "https://nostr.band/",
      //   des:
      //       "Nostr.Band is a collection of services for this new emerging network. It has a full-text search, a NIP-05 names provider, and more stuff coming soon.",
      // ),
      // WebUtilItemComponent(
      //   link: "https://kind3.xyz/",
      //   des:
      //       "This is a tool to change your Nostr follow list.It's an experiment to help you peak out of your echo chamber.",
      // ),
      // WebUtilItemComponent(
      //   link: "https://heguro.github.io/nostr-following-list-util/",
      //   des:
      //       "Nostr Following List Util: Tools to collect and resend following lists from relays.",
      // ),
      // WebUtilItemComponent(
      //   link: "https://badges.page/",
      //   des: "A tool for Manage Nostr Badges.",
      // ),
      // WebUtilItemComponent(
      //   link: "https://nostr.directory/",
      //   des: "Verify NIP-05 with your twitter.",
      // ),
      // WebUtilItemComponent(
      //   link: "https://metadata.nostr.com/",
      //   des: "Nostr Profile Manager. Backup / Refine / Restore profile events.",
      // ),
      // WebUtilItemComponent(
      //   link: "https://snowcait.github.io/nostr-playground/",
      //   des: "A Nostr playground.",
      // ),
      // WebUtilItemComponent(
      //   link: "https://flycat.club/",
      //   des: "Blogging on Nostr right away and it is a nostr client too.",
      // ),
    ];

    for (final item in webUtils) {
      list.add(WebUtilItemComponent(link: item.link, des: item.des));
    }

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            RouterUtil.back(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: themeData.appBarTheme.titleTextStyle!.color,
          ),
        ),
        title: Text(
          "Web Utils",
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        ),
      ),
    );
  }

  @override
  Future<void> onReady(final BuildContext context) async {
    load();
  }

  List<WebUtilItem> webUtils = [];

  Future<void> load() async {
    final str = await DioUtil.getStr(Base.WEB_TOOLS);
    if (StringUtil.isNotBlank(str)) {
      final itfs = jsonDecode(str!);
      webUtils = [];
      for (final itf in itfs) {
        if (itf is Map) {
          webUtils.add(WebUtilItem(itf["link"], itf["des"]));
        }
      }
      setState(() {});
    }
  }
}

class WebUtilItem {
  WebUtilItem(this.link, this.des);
  String link;
  String des;
}
