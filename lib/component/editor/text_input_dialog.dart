import "package:flutter/material.dart";

import "package:loure/consts/base.dart";
import "package:loure/util/router_util.dart";
import "package:loure/util/string_util.dart";
import "package:loure/component/editor/text_input_dialog_inner_component.dart";

class TextInputDialog extends StatefulWidget {
  TextInputDialog(
    this.title, {
    super.key,
    this.hintText,
    this.value,
    this.valueCheck,
  });
  String title;

  String? hintText;

  String? value;

  bool Function(BuildContext, String)? valueCheck;

  @override
  State<StatefulWidget> createState() {
    return _TextInputDialog();
  }

  static Future<String?> show(final BuildContext context, final String title,
      {final String? value,
      final String? hintText,
      final bool Function(BuildContext, String)? valueCheck}) async {
    return await showDialog<String>(
        context: context,
        builder: (final context) {
          return TextInputDialog(
            StringUtil.breakWord(title),
            hintText: hintText,
            value: value,
            valueCheck: valueCheck,
          );
        });
  }
}

class _TextInputDialog extends State<TextInputDialog> {
  @override
  Widget build(final BuildContext context) {
    final main = TextInputDialogInnerComponent(
      widget.title,
      hintText: widget.hintText,
      value: widget.value,
      valueCheck: widget.valueCheck,
    );

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.2),
      body: FocusScope(
        autofocus: true,
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
