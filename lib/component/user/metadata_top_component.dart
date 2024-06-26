import "package:bot_toast/bot_toast.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:easy_image_viewer/easy_image_viewer.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "package:loure/client/nip02/contact_list.dart";
import "package:loure/component/nip05_valid_component.dart";
import "package:loure/component/qrcode_dialog.dart";
import "package:loure/component/webview_router.dart";
import "package:loure/router/routes.dart";
import "package:loure/main.dart";
import "package:loure/provider/contact_list_provider.dart";
import "package:loure/router/search/search_router.dart";
import "package:loure/util/platform_util.dart";
import "package:loure/util/router_util.dart";
import "package:loure/client/nip19/nip19.dart";
import "package:loure/consts/base.dart";
import "package:loure/client/metadata.dart";
import "package:loure/util/string_util.dart";
import "package:loure/component/image_component.dart";
import "package:loure/component/image_preview_dialog.dart";

class MetadataTopComponent extends StatefulWidget {
  const MetadataTopComponent({
    required this.pubkey,
    required this.metadata,
    super.key,
    this.isLocal = false,
    this.jumpable = false,
    this.userPicturePreview = false,
  });

  static double getPcBannerHeight(final double maxHeight) {
    final height = maxHeight * 0.2;
    if (height > 200) {
      return 200;
    }

    return height;
  }

  final String pubkey;
  final Metadata metadata;

  // is local user
  final bool isLocal;
  final bool jumpable;
  final bool userPicturePreview;

  @override
  State<StatefulWidget> createState() {
    return MetadataTopComponentState();
  }
}

class MetadataTopComponentState extends State<MetadataTopComponent> {
  static const double IMAGE_BORDER = 4;
  static const double IMAGE_WIDTH = 80;
  static const double HALF_IMAGE_WIDTH = 40;
  late String nip19PubKey;

  @override
  void initState() {
    super.initState();

    nip19PubKey = NIP19.encodePubKey(widget.pubkey);
  }

  @override
  Widget build(final BuildContext context) {
    final themeData = Theme.of(context);
    final mainColor = themeData.primaryColor;
    final scaffoldBackgroundColor = themeData.scaffoldBackgroundColor;
    final maxWidth = mediaDataCache.size.width;
    final largeFontSize = themeData.textTheme.bodyLarge!.fontSize;
    var bannerHeight = maxWidth / 3;
    if (PlatformUtil.isTableMode()) {
      bannerHeight =
          MetadataTopComponent.getPcBannerHeight(mediaDataCache.size.height);
    }

    Widget? imageWidget;
    if (StringUtil.isNotBlank(widget.metadata.picture)) {
      imageWidget = ImageComponent(
        imageUrl: widget.metadata.picture!,
        width: IMAGE_WIDTH,
        height: IMAGE_WIDTH,
        fit: BoxFit.cover,
        placeholder: (final context, final url) =>
            const CircularProgressIndicator(),
      );
    }
    Widget? bannerImage;
    if (StringUtil.isNotBlank(widget.metadata.banner)) {
      bannerImage = ImageComponent(
        imageUrl: widget.metadata.banner!,
        width: maxWidth,
        height: bannerHeight,
        fit: BoxFit.cover,
      );
    }

    List<Widget> topBtnList = [
      Expanded(
        child: Container(),
      )
    ];

    if (!PlatformUtil.isTableMode() && widget.pubkey == nostr.publicKey) {
      // is phont and local
      topBtnList.add(wrapBtn(MetadataIconBtn(
        iconData: Icons.qr_code_scanner,
        onTap: handleScanner,
      )));
    }

    topBtnList.add(wrapBtn(MetadataIconBtn(
      iconData: Icons.qr_code,
      onTap: () {
        QrcodeDialog.show(context, widget.pubkey);
      },
    )));

    if (!widget.isLocal) {
      topBtnList.add(Selector<ContactListProvider, Contact?>(
        builder: (final context, final contact, final child) {
          if (contact == null) {
            return wrapBtn(MetadataTextBtn(
              text: "Follow",
              borderColor: mainColor,
              onTap: () {
                contactListProvider.addContact(Contact(pubkey: widget.pubkey));
              },
            ));
          } else {
            return wrapBtn(MetadataTextBtn(
              text: "Unfollow",
              onTap: () {
                contactListProvider.removeContact(widget.pubkey);
              },
            ));
          }
        },
        selector: (final context, final provider) {
          return provider.getContact(widget.pubkey);
        },
      ));
    }

    Widget userNameComponent = Container(
      // height: 40,
      width: double.maxFinite,
      margin: const EdgeInsets.only(
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
        // top: Base.BASE_PADDING_HALF,
        bottom: Base.BASE_PADDING_HALF,
      ),
      // color: Colors.green,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: widget.metadata.shortName(),
              style: TextStyle(
                fontSize: largeFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    if (widget.jumpable) {
      userNameComponent = GestureDetector(
        onTap: jumpToUserRouter,
        child: userNameComponent,
      );
    }

    List<Widget> topList = [];
    topList.add(Container(
      width: maxWidth,
      height: bannerHeight,
      color: Colors.grey.withOpacity(0.5),
      child: bannerImage,
    ));
    topList.add(SizedBox(
      height: 50,
      // color: Colors.red,
      child: Row(
        children: topBtnList,
      ),
    ));
    topList.add(userNameComponent);
    topList.add(MetadataIconDataComp(
      iconData: Icons.key,
      text: nip19PubKey,
      textBG: true,
      onTap: copyPubKey,
    ));
    if (StringUtil.isNotBlank(widget.metadata.nip05)) {
      topList.add(MetadataIconDataComp(
        text: widget.metadata.nip05!,
        leftWidget: Nip05ValidComponent(metadata: widget.metadata),
      ));
    }
    if (StringUtil.isNotBlank(widget.metadata.website)) {
      topList.add(MetadataIconDataComp(
        iconData: Icons.link,
        text: widget.metadata.website!,
        onTap: () {
          WebViewRouter.open(context, widget.metadata.website!);
        },
      ));
    }
    if (StringUtil.isNotBlank(widget.metadata.lud16)) {
      topList.add(MetadataIconDataComp(
        iconData: Icons.bolt,
        iconColor: Colors.orange,
        text: widget.metadata.lud16!,
      ));
    }

    Widget userImageWidget = Container(
      alignment: Alignment.center,
      height: IMAGE_WIDTH,
      width: IMAGE_WIDTH,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HALF_IMAGE_WIDTH),
        color: Colors.grey,
      ),
      child: imageWidget,
    );
    if (widget.userPicturePreview) {
      userImageWidget = GestureDetector(
        onTap: userPicturePreview,
        child: userImageWidget,
      );
    } else if (widget.jumpable) {
      userImageWidget = GestureDetector(
        onTap: jumpToUserRouter,
        child: userImageWidget,
      );
    }

    return Stack(
      children: [
        Column(
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

  Widget wrapBtn(final Widget child) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: child,
    );
  }

  copyPubKey() {
    Clipboard.setData(ClipboardData(text: nip19PubKey)).then((final _) {
      BotToast.showText(text: "key_has_been_copy");
    });
  }

  void jumpToUserRouter() {
    RouterUtil.router(context, RouterPath.USER, widget.pubkey);
  }

  Future<void> handleScanner() async {
    final result =
        (await RouterUtil.router(context, RouterPath.QRSCANNER)) as String;

    RouterUtil.push(context, SearchRouter(query: result));
  }

  void userPicturePreview() {
    if (StringUtil.isNotBlank(widget.metadata.picture)) {
      List<ImageProvider> imageProviders = [];
      imageProviders.add(CachedNetworkImageProvider(widget.metadata.picture!));

      final MultiImageProvider multiImageProvider =
          MultiImageProvider(imageProviders, initialIndex: 0);

      ImagePreviewDialog.show(context, multiImageProvider,
          doubleTapZoomable: true, swipeDismissible: true);
    }
  }
}

class MetadataIconBtn extends StatelessWidget {
  const MetadataIconBtn(
      {required this.iconData, super.key, this.onTap, this.onLongPress});

  final void Function()? onTap;
  final void Function()? onLongPress;
  final IconData iconData;

  @override
  Widget build(final BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(width: 1),
    );
    final main = SizedBox(
      height: 28,
      width: 28,
      child: Icon(
        iconData,
        size: 18,
      ),
    );

    if (onTap != null || onLongPress != null) {
      // return Ink(
      //   decoration: decoration,
      //   child: InkWell(
      //     onTap: onTap,
      //     onLongPress: onLongPress,
      //     child: main,
      //   ),
      // );
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: decoration,
          child: main,
        ),
      );
    } else {
      return Container(
        decoration: decoration,
        child: main,
      );
    }
  }
}

class MetadataTextBtn extends StatelessWidget {
  const MetadataTextBtn({
    required this.text,
    required this.onTap,
    super.key,
    this.borderColor,
  });

  final void Function() onTap;
  final String text;
  final Color? borderColor;

  @override
  Widget build(final BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: borderColor != null
            ? Border.all(width: 1, color: borderColor!)
            : Border.all(width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.only(left: 8, right: 8),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
        ),
      ),
    );
  }
}

class MetadataIconDataComp extends StatelessWidget {
  const MetadataIconDataComp({
    required this.text,
    super.key,
    this.iconData,
    this.leftWidget,
    this.iconColor,
    this.textBG = false,
    this.onTap,
  });

  final String text;
  final IconData? iconData;
  final Color? iconColor;
  final bool textBG;
  final Function? onTap;
  final Widget? leftWidget;

  @override
  Widget build(final BuildContext context) {
    final themeData = Theme.of(context);
    Color? cardColor = themeData.cardColor;
    if (cardColor == Colors.white) {
      cardColor = Colors.grey[300];
    }

    final iconData = this.iconData ?? Icons.circle;

    return Container(
      padding: const EdgeInsets.only(
        bottom: Base.BASE_PADDING_HALF,
        left: Base.BASE_PADDING,
        right: Base.BASE_PADDING,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(
                right: Base.BASE_PADDING_HALF,
              ),
              child: leftWidget ??
                  Icon(
                    iconData,
                    color: iconColor,
                    size: 16,
                  ),
            ),
            Expanded(
              child: Container(
                padding: textBG
                    ? const EdgeInsets.only(
                        left: Base.BASE_PADDING_HALF,
                        right: Base.BASE_PADDING_HALF,
                        top: 4,
                        bottom: 4,
                      )
                    : null,
                decoration: BoxDecoration(
                  color: textBG ? cardColor : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
