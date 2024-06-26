import "package:flutter/material.dart";

import "package:loure/consts/index_taps.dart";

class IndexProvider extends ChangeNotifier {
  IndexProvider({final int? indexTap}) {
    if (indexTap != null) {
      _currentTap = indexTap;
    }
  }

  int _currentTap = IndexTaps.FOLLOW;
  int get currentTap => _currentTap;

  void setCurrentTap(final int v) {
    _currentTap = v;
    notifyListeners();
  }

  TabController? _followTabController;

  void setFollowTabController(final TabController? followTabController) {
    _followTabController = followTabController;
  }

  ScrollController? _followPostsScrollController;

  void setFollowPostsScrollController(
      final ScrollController? followPostsScrollController) {
    _followPostsScrollController = followPostsScrollController;
  }

  ScrollController? _followScrollController;

  void setFollowScrollController(
      final ScrollController? followScrollController) {
    _followScrollController = followScrollController;
  }

  ScrollController? _inboxScrollController;

  void setInboxScrollController(final ScrollController? inboxScrollController) {
    _inboxScrollController = inboxScrollController;
  }

  void followScrollToTop() {
    if (_followTabController != null) {
      if (_followTabController!.index == 0 &&
          _followPostsScrollController != null) {
        _followPostsScrollController!.jumpTo(0);
      } else if (_followTabController!.index == 1 &&
          _followScrollController != null) {
        _followScrollController!.jumpTo(0);
      } else if (_followTabController!.index == 2 &&
          _inboxScrollController != null) {
        _inboxScrollController!.jumpTo(0);
      }
    }
  }

  TabController? _globalTabController;

  void setGlobalTabController(final TabController? globalTabController) {
    _globalTabController = globalTabController;
  }

  ScrollController? _eventScrollController;

  void setEventScrollController(final ScrollController? eventScrollController) {
    _eventScrollController = eventScrollController;
  }

  ScrollController? _userScrollController;

  void setUserScrollController(final ScrollController? userScrollController) {
    _userScrollController = userScrollController;
  }

  void globalScrollToTop() {
    if (_globalTabController != null) {
      if (_globalTabController!.index == 0 && _eventScrollController != null) {
        _eventScrollController!.jumpTo(0);
      } else if (_globalTabController!.index == 1 &&
          _userScrollController != null) {
        _userScrollController!.jumpTo(0);
      }
    }
  }
}
