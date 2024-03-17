import "dart:convert";

import "package:flutter/material.dart";
import "package:loure/main.dart";
import "package:loure/util/encrypt_util.dart";
import "package:loure/util/platform_util.dart";

import "package:loure/consts/base.dart";
import "package:loure/consts/base_consts.dart";
import "package:loure/consts/theme_style.dart";
import "package:loure/util/string_util.dart";
import "package:loure/provider/data_util.dart";

class SettingProvider extends ChangeNotifier {
  SettingData? _settingData;
  final Map<String, String> _privateKeyMap = {};

  Future<void> init() async {
    String? settingStr = sharedPreferences.getString(DataKey.SETTING);
    if (StringUtil.isNotBlank(settingStr)) {
      final jsonMap = json.decode(settingStr!);
      if (jsonMap != null) {
        final setting = SettingData.fromJson(jsonMap);
        _settingData = setting;
        _privateKeyMap.clear();

        // move privateKeyMap to encryptPrivateKeyMap since 1.2.0
        String? privateKeyMapText = _settingData!.encryptPrivateKeyMap;
        try {
          if (StringUtil.isNotBlank(privateKeyMapText)) {
            privateKeyMapText = EncryptUtil.aesDecrypt(
                privateKeyMapText!, Base.KEY_EKEY, Base.KEY_IV);
          } else if (StringUtil.isNotBlank(_settingData!.privateKeyMap) &&
              StringUtil.isBlank(_settingData!.encryptPrivateKeyMap)) {
            privateKeyMapText = _settingData!.privateKeyMap;
            _settingData!.encryptPrivateKeyMap = EncryptUtil.aesEncrypt(
                _settingData!.privateKeyMap!, Base.KEY_EKEY, Base.KEY_IV);
            _settingData!.privateKeyMap = null;
          }
        } catch (e) {
          print("settingProvider handle privateKey error $e");
        }

        if (StringUtil.isNotBlank(privateKeyMapText)) {
          try {
            final jsonKeyMap = jsonDecode(privateKeyMapText!);
            if (jsonKeyMap != null) {
              for (final entry
                  in (jsonKeyMap as Map<String, dynamic>).entries) {
                _privateKeyMap[entry.key] = entry.value;
              }
            }
          } catch (e) {
            print("_settingData!.privateKeyMap! jsonDecode error $e");
          }
        }
        return;
      }
    }

    _settingData = SettingData();
  }

  Future<void> reload() async {
    await init();
    this._reloadTranslateSourceArgs();
    notifyListeners();
  }

  Map<String, String> get privateKeyMap => _privateKeyMap;

  String? get privateKey {
    if (_settingData!.privateKeyIndex != null &&
        _settingData!.encryptPrivateKeyMap != null &&
        _privateKeyMap.isNotEmpty) {
      return _privateKeyMap[_settingData!.privateKeyIndex.toString()];
    }
    return null;
  }

  int addAndChangePrivateKey(final String sk, {final bool updateUI = false}) {
    int? findIndex;
    final entries = _privateKeyMap.entries;
    for (final entry in entries) {
      if (entry.value == sk) {
        findIndex = int.tryParse(entry.key);
        break;
      }
    }
    if (findIndex != null) {
      privateKeyIndex = findIndex;
      return findIndex;
    }

    for (var i = 0; i < 20; i++) {
      final index = i.toString();
      final pk0 = _privateKeyMap[index];
      if (pk0 == null) {
        _privateKeyMap[index] = sk;

        _settingData!.privateKeyIndex = i;

        // _settingData!.privateKeyMap = json.encode(_privateKeyMap);
        _encodePrivateKeyMap();
        saveAndNotifyListeners(updateUI: updateUI);

        return i;
      }
    }

    return -1;
  }

  void _encodePrivateKeyMap() {
    final privateKeyMap = json.encode(_privateKeyMap);
    _settingData!.encryptPrivateKeyMap =
        EncryptUtil.aesEncrypt(privateKeyMap, Base.KEY_EKEY, Base.KEY_IV);
  }

  void removeKey(final int index) {
    final indexStr = index.toString();
    _privateKeyMap.remove(indexStr);
    // _settingData!.privateKeyMap = json.encode(_privateKeyMap);
    _encodePrivateKeyMap();
    if (_settingData!.privateKeyIndex == index) {
      if (_privateKeyMap.isEmpty) {
        _settingData!.privateKeyIndex = null;
      } else {
        // find a index
        final keyIndex = _privateKeyMap.keys.first;
        _settingData!.privateKeyIndex = int.tryParse(keyIndex);
      }
    }

    saveAndNotifyListeners();
  }

  SettingData get settingData => _settingData!;

  int? get privateKeyIndex => _settingData!.privateKeyIndex;

  // String? get privateKeyMap => _settingData!.privateKeyMap;

  /// open lock
  int get lockOpen => _settingData!.lockOpen;

  int? get defaultIndex => _settingData!.defaultIndex;
  int? get defaultTab => _settingData!.defaultTab;

  int get linkPreview => _settingData!.linkPreview != null
      ? _settingData!.linkPreview!
      : OpenStatus.OPEN;

  int get videoPreviewInList => _settingData!.videoPreviewInList != null
      ? _settingData!.videoPreviewInList!
      : OpenStatus.CLOSE;

  String? get network => _settingData!.network;
  String? get imageService => _settingData!.imageService;
  int? get videoPreview => _settingData!.videoPreview;
  int? get imagePreview => _settingData!.imagePreview;

  /// image compress
  int get imgCompress => _settingData!.imgCompress;

  /// theme style
  int get themeStyle => _settingData!.themeStyle;

  /// theme color
  int? get themeColor => _settingData!.themeColor;

  /// fontFamily
  String? get fontFamily => _settingData!.fontFamily;

  int? get openTranslate => _settingData!.openTranslate;

  static const ALL_SUPPORT_LANGUAGES =
      "af,sq,ar,be,bn,bg,ca,zh,hr,cs,da,nl,en,eo,et,fi,fr,gl,ka,de,el,gu,ht,he,hi,hu,is,id,ga,it,ja,kn,ko,lv,lt,mk,ms,mt,mr,no,fa,pl,pt,ro,ru,sk,sl,es,sw,sv,tl,ta,te,th,tr,uk,ur,vi,cy";

  String? get translateSourceArgs {
    if (StringUtil.isNotBlank(_settingData!.translateSourceArgs)) {
      return _settingData!.translateSourceArgs!;
    }
    return null;
  }

  String? get translateTarget => _settingData!.translateTarget;

  final Map<String, int> _translateSourceArgsMap = {};

  void _reloadTranslateSourceArgs() {
    _translateSourceArgsMap.clear();
    final args = _settingData!.translateSourceArgs;
    if (StringUtil.isNotBlank(args)) {
      final argStrs = args!.split(",");
      for (final argStr in argStrs) {
        if (StringUtil.isNotBlank(argStr)) {
          _translateSourceArgsMap[argStr] = 1;
        }
      }
    }
  }

  bool translateSourceArgsCheck(final String str) {
    return _translateSourceArgsMap[str] != null;
  }

  int? get broadcaseWhenBoost =>
      _settingData!.broadcaseWhenBoost ?? OpenStatus.OPEN;

  double get fontSize =>
      _settingData!.fontSize ??
      (PlatformUtil.isTableMode()
          ? Base.BASE_FONT_SIZE_PC
          : Base.BASE_FONT_SIZE);

  int get webviewAppbarOpen => _settingData!.webviewAppbarOpen;

  int? get tableMode => _settingData!.tableMode;

  int? get autoOpenSensitive => _settingData!.autoOpenSensitive;

  int? get relayMode => _settingData!.relayMode;

  int? get eventSignCheck => _settingData!.eventSignCheck;

  int? get limitNoteHeight => _settingData!.limitNoteHeight;

  set settingData(final SettingData o) {
    _settingData = o;
    saveAndNotifyListeners();
  }

  set privateKeyIndex(final int? o) {
    _settingData!.privateKeyIndex = o;
    saveAndNotifyListeners();
  }

  // set privateKeyMap(String? o) {
  //   _settingData!.privateKeyMap = o;
  //   saveAndNotifyListeners();
  // }

  /// open lock
  set lockOpen(final int o) {
    _settingData!.lockOpen = o;
    saveAndNotifyListeners();
  }

  set defaultIndex(final int? o) {
    _settingData!.defaultIndex = o;
    saveAndNotifyListeners();
  }

  set defaultTab(final int? o) {
    _settingData!.defaultTab = o;
    saveAndNotifyListeners();
  }

  set linkPreview(final int o) {
    _settingData!.linkPreview = o;
    saveAndNotifyListeners();
  }

  set videoPreviewInList(final int o) {
    _settingData!.videoPreviewInList = o;
    saveAndNotifyListeners();
  }

  set network(final String? o) {
    _settingData!.network = o;
    saveAndNotifyListeners();
  }

  set imageService(final String? o) {
    _settingData!.imageService = o;
    saveAndNotifyListeners();
  }

  set videoPreview(final int? o) {
    _settingData!.videoPreview = o;
    saveAndNotifyListeners();
  }

  set imagePreview(final int? o) {
    _settingData!.imagePreview = o;
    saveAndNotifyListeners();
  }

  /// image compress
  set imgCompress(final int o) {
    _settingData!.imgCompress = o;
    saveAndNotifyListeners();
  }

  /// theme style
  set themeStyle(final int o) {
    _settingData!.themeStyle = o;
    saveAndNotifyListeners();
  }

  /// theme color
  set themeColor(final int? o) {
    _settingData!.themeColor = o;
    saveAndNotifyListeners();
  }

  /// fontFamily
  set fontFamily(final String? fontFamily) {
    _settingData!.fontFamily = fontFamily;
    saveAndNotifyListeners();
  }

  set openTranslate(final int? o) {
    _settingData!.openTranslate = o;
    saveAndNotifyListeners();
  }

  set translateSourceArgs(final String? o) {
    _settingData!.translateSourceArgs = o;
    saveAndNotifyListeners();
  }

  set translateTarget(final String? o) {
    _settingData!.translateTarget = o;
    saveAndNotifyListeners();
  }

  set broadcaseWhenBoost(final int? o) {
    _settingData!.broadcaseWhenBoost = o;
    saveAndNotifyListeners();
  }

  set fontSize(final double o) {
    _settingData!.fontSize = o;
    saveAndNotifyListeners();
  }

  set webviewAppbarOpen(final int o) {
    _settingData!.webviewAppbarOpen = o;
    saveAndNotifyListeners();
  }

  set tableMode(final int? o) {
    _settingData!.tableMode = o;
    saveAndNotifyListeners();
  }

  set autoOpenSensitive(final int? o) {
    _settingData!.autoOpenSensitive = o;
    saveAndNotifyListeners();
  }

  set relayMode(final int? o) {
    _settingData!.relayMode = o;
    saveAndNotifyListeners();
  }

  set eventSignCheck(final int? o) {
    _settingData!.eventSignCheck = o;
    saveAndNotifyListeners();
  }

  set limitNoteHeight(final int? o) {
    _settingData!.limitNoteHeight = o;
    saveAndNotifyListeners();
  }

  Future<void> saveAndNotifyListeners({final bool updateUI = true}) async {
    _settingData!.updatedTime = DateTime.now().millisecondsSinceEpoch;
    final m = _settingData!.toJson();
    final jsonStr = json.encode(m);
    // print(jsonStr);
    await sharedPreferences.setString(DataKey.SETTING, jsonStr);
    this._reloadTranslateSourceArgs();

    if (updateUI) {
      notifyListeners();
    }
  }
}

class SettingData {
  SettingData({
    this.privateKeyIndex,
    this.privateKeyMap,
    this.lockOpen = OpenStatus.CLOSE,
    this.defaultIndex,
    this.defaultTab,
    this.linkPreview,
    this.videoPreviewInList,
    this.network,
    this.imageService,
    this.videoPreview,
    this.imagePreview,
    this.imgCompress = 50,
    this.themeStyle = ThemeStyle.AUTO,
    this.themeColor,
    this.fontFamily,
    this.openTranslate,
    this.translateTarget,
    this.translateSourceArgs,
    this.broadcaseWhenBoost,
    this.fontSize,
    this.webviewAppbarOpen = OpenStatus.OPEN,
    this.tableMode,
    this.autoOpenSensitive,
    this.relayMode,
    this.eventSignCheck,
    this.limitNoteHeight,
    this.updatedTime = 0,
  });

  SettingData.fromJson(final Map<String, dynamic> json) {
    privateKeyIndex = json["privateKeyIndex"];
    privateKeyMap = json["privateKeyMap"];
    encryptPrivateKeyMap = json["encryptPrivateKeyMap"];
    if (json["lockOpen"] != null) {
      lockOpen = json["lockOpen"];
    } else {
      lockOpen = OpenStatus.CLOSE;
    }
    defaultIndex = json["defaultIndex"];
    defaultTab = json["defaultTab"];
    linkPreview = json["linkPreview"];
    videoPreviewInList = json["videoPreviewInList"];
    network = json["network"];
    imageService = json["imageService"];
    videoPreview = json["videoPreview"];
    imagePreview = json["imagePreview"];
    if (json["imgCompress"] != null) {
      imgCompress = json["imgCompress"];
    } else {
      imgCompress = 50;
    }
    if (json["themeStyle"] != null) {
      themeStyle = json["themeStyle"];
    } else {
      themeStyle = ThemeStyle.AUTO;
    }
    themeColor = json["themeColor"];
    openTranslate = json["openTranslate"];
    translateTarget = json["translateTarget"];
    translateSourceArgs = json["translateSourceArgs"];
    broadcaseWhenBoost = json["broadcaseWhenBoost"];
    fontSize = json["fontSize"];
    webviewAppbarOpen = json["webviewAppbarOpen"] ?? OpenStatus.OPEN;
    tableMode = json["tableMode"];
    autoOpenSensitive = json["autoOpenSensitive"];
    relayMode = json["relayMode"];
    eventSignCheck = json["eventSignCheck"];
    limitNoteHeight = json["limitNoteHeight"];
    if (json["updatedTime"] != null) {
      updatedTime = json["updatedTime"];
    } else {
      updatedTime = 0;
    }
  }
  int? privateKeyIndex;
  String? privateKeyMap;
  String? encryptPrivateKeyMap;

  /// open lock
  late int lockOpen;

  int? defaultIndex;
  int? defaultTab;
  int? linkPreview;
  int? videoPreviewInList;

  String? network;
  String? imageService;

  int? videoPreview;
  int? imagePreview;

  /// image compress
  late int imgCompress;

  /// theme style
  late int themeStyle;

  /// theme color
  int? themeColor;

  /// fontFamily
  String? fontFamily;

  int? openTranslate;
  String? translateTarget;
  String? translateSourceArgs;
  int? broadcaseWhenBoost;
  double? fontSize;

  late int webviewAppbarOpen;

  int? tableMode;
  int? autoOpenSensitive;
  int? relayMode;
  int? eventSignCheck;
  int? limitNoteHeight;

  /// updated time
  late int updatedTime;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["privateKeyIndex"] = privateKeyIndex;
    data["privateKeyMap"] = privateKeyMap;
    data["encryptPrivateKeyMap"] = encryptPrivateKeyMap;
    data["lockOpen"] = lockOpen;
    data["defaultIndex"] = defaultIndex;
    data["defaultTab"] = defaultTab;
    data["linkPreview"] = linkPreview;
    data["videoPreviewInList"] = videoPreviewInList;
    data["network"] = network;
    data["imageService"] = imageService;
    data["videoPreview"] = videoPreview;
    data["imagePreview"] = imagePreview;
    data["imgCompress"] = imgCompress;
    data["themeStyle"] = themeStyle;
    data["themeColor"] = themeColor;
    data["fontFamily"] = fontFamily;
    data["openTranslate"] = openTranslate;
    data["translateTarget"] = translateTarget;
    data["translateSourceArgs"] = translateSourceArgs;
    data["broadcaseWhenBoost"] = broadcaseWhenBoost;
    data["fontSize"] = fontSize;
    data["webviewAppbarOpen"] = webviewAppbarOpen;
    data["tableMode"] = tableMode;
    data["autoOpenSensitive"] = autoOpenSensitive;
    data["relayMode"] = relayMode;
    data["eventSignCheck"] = eventSignCheck;
    data["limitNoteHeight"] = limitNoteHeight;
    data["updatedTime"] = updatedTime;
    return data;
  }
}
