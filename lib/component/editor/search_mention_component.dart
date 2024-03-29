import "package:flutter/material.dart";

import "package:loure/util/string_util.dart";
import "package:loure/util/when_stop_function.dart";

typedef ResultBuildFunc = Widget Function();
typedef HandleSearchFunc = void Function(String);

class SearchMentionComponent extends StatefulWidget {
  const SearchMentionComponent({
    required this.resultBuildFunc,
    required this.handleSearchFunc,
    super.key,
  });
  final ResultBuildFunc resultBuildFunc;
  final HandleSearchFunc handleSearchFunc;

  @override
  State<StatefulWidget> createState() {
    return SearchMentionComponentState();
  }
}

class SearchMentionComponentState extends State<SearchMentionComponent>
    with WhenStopFunction {
  TextEditingController controller = TextEditingController();

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      final hasText = StringUtil.isNotBlank(controller.text);
      if (!showSuffix && hasText) {
        setState(() {
          showSuffix = true;
        });
        return;
      } else if (showSuffix && !hasText) {
        setState(() {
          showSuffix = false;
        });
      }

      whenStop(checkInput);
    });
  }

  bool showSuffix = false;

  @override
  Widget build(final BuildContext context) {
    final themeData = Theme.of(context);
    final backgroundColor = themeData.scaffoldBackgroundColor;
    List<Widget> list = [];

    Widget? suffixWidget;
    if (showSuffix) {
      suffixWidget = GestureDetector(
        onTap: () {
          controller.text = "";
        },
        child: const Icon(Icons.close),
      );
    }
    list.add(
      TextField(
        autofocus: true,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Please input search content",
          suffixIcon: suffixWidget,
        ),
        onEditingComplete: checkInput,
      ),
    );

    list.add(Expanded(
      child: Container(
        color: backgroundColor,
        child: widget.resultBuildFunc(),
      ),
    ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: list,
    );
  }

  checkInput() {
    final text = controller.text;
    widget.handleSearchFunc(text);
  }
}
