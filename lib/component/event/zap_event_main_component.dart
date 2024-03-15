import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:loure/client/event.dart';
import 'package:loure/client/zap/zap_num_util.dart';
import 'package:loure/util/number_format_util.dart';
import 'package:loure/util/spider_util.dart';
import 'package:loure/util/string_util.dart';
import 'package:loure/component/event/reaction_event_item_component.dart';

// ignore: must_be_immutable
class ZapEventMainComponent extends StatefulWidget {
  Event event;
  ZapEventMainComponent({super.key, required this.event});

  @override
  State<StatefulWidget> createState() {
    return _ZapEventMainComponent();
  }
}

class _ZapEventMainComponent extends State<ZapEventMainComponent> {
  String? senderPubkey;
  late String eventId;

  @override
  void initState() {
    super.initState();

    eventId = widget.event.id;
    parseSenderPubkey();
  }

  void parseSenderPubkey() {
    String? zapRequestEventStr;
    for (var tag in widget.event.tags) {
      if (tag.length > 1) {
        var key = tag[0];
        if (key == "description") {
          zapRequestEventStr = tag[1];
        }
      }
    }

    if (StringUtil.isNotBlank(zapRequestEventStr)) {
      try {
        var eventJson = jsonDecode(zapRequestEventStr!);
        var zapRequestEvent = Event.fromJson(eventJson);
        senderPubkey = zapRequestEvent.pubKey;
      } catch (e) {
        log("jsonDecode zapRequest error ${e.toString()}");
        senderPubkey =
            SpiderUtil.subUntil(zapRequestEventStr!, "pubkey\":\"", "\"");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (StringUtil.isBlank(senderPubkey)) {
      return Container();
    }

    if (eventId != widget.event.id) {
      parseSenderPubkey();
    }

    var zapNum = ZapNumUtil.getNumFromZapEvent(widget.event);
    String zapNumStr = NumberFormatUtil.format(zapNum);

    var text = "zaped $zapNumStr sats";

    return ReactionEventItemComponent(
        pubkey: senderPubkey!, text: text, createdAt: widget.event.createdAt);
  }
}
