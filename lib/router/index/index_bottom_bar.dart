import 'package:flutter/material.dart';
import 'package:loure/provider/index_provider.dart';
import 'package:provider/provider.dart';

import 'package:loure/main.dart';

class IndexBottomBar extends StatefulWidget {
  static const double HEIGHT = 50;

  const IndexBottomBar({super.key});

  @override
  State<StatefulWidget> createState() {
    return _IndexBottomBar();
  }
}

class _IndexBottomBar extends State<IndexBottomBar> {
  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var indexProvider = Provider.of<IndexProvider>(context);
    var currentTap = indexProvider.currentTap;

    List<Widget> list = [];

    int current = 0;

    list.add(IndexBottomBarButton(
      iconData: Icons.home,
      index: current,
      selected: current == currentTap,
      onDoubleTap: () {
        indexProvider.followScrollToTop();
      },
    ));
    current++;

    list.add(IndexBottomBarButton(
      iconData: Icons.public, // notifications_active
      index: current,
      selected: current == currentTap,
      onDoubleTap: () {
        indexProvider.globalScrollToTop();
      },
    ));
    current++;

    list.add(Expanded(
        child: Container(
      height: IndexBottomBar.HEIGHT,
    )));

    list.add(IndexBottomBarButton(
      iconData: Icons.search,
      index: current,
      selected: current == currentTap,
    ));
    current++;

    list.add(IndexBottomBarButton(
      iconData: Icons.mail,
      index: current,
      selected: current == currentTap,
    ));
    current++;

    // return Container(
    //   width: double.infinity,
    //   child: Row(
    //     children: list,
    //   ),
    // );
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          offset: const Offset(-6, 0),
          color: themeData.shadowColor,
          spreadRadius: 2,
          blurRadius: 8,
        )
      ]),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: themeData.cardColor,
        surfaceTintColor: themeData.cardColor,
        shadowColor: themeData.shadowColor,
        height: IndexBottomBar.HEIGHT,
        padding: EdgeInsets.zero,
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          child: Row(
            children: list,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> onReady(BuildContext context) async {}
}

class IndexBottomBarButton extends StatelessWidget {
  final IconData iconData;
  final int index;
  final bool selected;
  final Function(int)? onTap;
  Function? onDoubleTap;

  IndexBottomBarButton({super.key, 
    required this.iconData,
    required this.index,
    required this.selected,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    var mainColor = themeData.primaryColor;
    // var settingProvider = Provider.of<SettingProvider>(context);
    // var bottomIconColor = settingProvider.bottomIconColor;

    Color? selectedColor = mainColor;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(index);
          } else {
            indexProvider.setCurrentTap(index);
          }
        },
        onDoubleTap: () {
          if (onDoubleTap != null) {
            onDoubleTap!();
          }
        },
        child: SizedBox(
          height: IndexBottomBar.HEIGHT,
          child: Icon(
            iconData,
            color: selected ? selectedColor : null,
          ),
        ),
      ),
    );
  }
}
