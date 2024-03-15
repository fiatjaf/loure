import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:loure/component/lightning_qrcode_dialog.dart';
import 'package:loure/util/platform_util.dart';

class CashuUtil {
  static Future<void> goTo(BuildContext context, String cashuStr) async {
    var link = 'cashu:$cashuStr';
    if (PlatformUtil.isPC() || PlatformUtil.isWeb()) {
      await LightningQrcodeDialog.show(context, link, title: "");
    } else {
      var url = Uri.parse(link);
      launchUrl(url);
    }
  }
}
