import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:loure/component/content/content_lnbc_component.dart';

import 'package:loure/component/editor/cust_embed_types.dart';

class LnbcEmbedBuilder extends EmbedBuilder {
  @override
  Widget build(BuildContext context, QuillController controller, Embed node,
      bool readOnly, bool inline, TextStyle textStyle) {
    var lnbcStr = node.value.data;
    return AbsorbPointer(
      child: ContentLnbcComponent(lnbc: lnbcStr),
    );
  }

  @override
  String get key => CustEmbedTypes.lnbc;
}
