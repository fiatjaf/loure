import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:loure/client/relay/relay.dart';
import 'package:loure/client/nip19/nip19_tlv.dart';
import 'package:loure/consts/router_path.dart';
import 'package:loure/main.dart';
import 'package:loure/util/router_util.dart';
import 'package:loure/consts/base.dart';

// ignore: must_be_immutable
class RelaysItemComponent extends StatelessWidget {
  String addr;
  RelayStatus relayStatus;
  RelaysItemComponent(
      {super.key, required this.addr, required this.relayStatus});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var cardColor = themeData.cardColor;
    Color borderLeftColor = Colors.green;
    if (relayStatus.connected == ConnState.UN_CONNECT) {
      borderLeftColor = Colors.red;
    } else if (relayStatus.connected == ConnState.CONNECTING) {
      borderLeftColor = Colors.yellow;
    }

    return GestureDetector(
      onTap: () {
        RouterUtil.router(context, RouterPath.RELAY_INFO, addr);
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: Base.BASE_PADDING,
          left: Base.BASE_PADDING,
          right: Base.BASE_PADDING,
        ),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: Base.BASE_PADDING_HALF,
            bottom: Base.BASE_PADDING_HALF,
            left: Base.BASE_PADDING,
            right: Base.BASE_PADDING,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(
              left: BorderSide(
                width: 6,
                color: borderLeftColor,
              ),
            ),
            // borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      child: Text(addr),
                    ),
                    Row(
                      children: [
                        Container(
                          margin:
                              const EdgeInsets.only(right: Base.BASE_PADDING),
                          child: RelaysItemNumComponent(
                            iconData: Icons.mail,
                            num: relayStatus.noteReceived,
                          ),
                        ),
                        RelaysItemNumComponent(
                          iconColor: Colors.red,
                          iconData: Icons.error,
                          num: relayStatus.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  var text = NIP19Tlv.encodeNrelay(Nrelay(addr));
                  Clipboard.setData(ClipboardData(text: text)).then((_) {
                    BotToast.showText(text: "Copy_success");
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: Base.BASE_PADDING),
                  child: const Icon(
                    Icons.copy,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  removeRelay(addr);
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void removeRelay(String addr) {
    nostr.relayList.remove(addr);
  }
}

// ignore: must_be_immutable
class RelaysItemNumComponent extends StatelessWidget {
  Color? iconColor;
  IconData iconData;
  int num;

  RelaysItemNumComponent({
    super.key,
    this.iconColor,
    required this.iconData,
    required this.num,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var smallFontSize = themeData.textTheme.bodySmall!.fontSize;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(right: Base.BASE_PADDING_HALF),
          child: Icon(
            iconData,
            color: iconColor,
            size: smallFontSize,
          ),
        ),
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: smallFontSize,
          ),
        ),
      ],
    );
  }
}
