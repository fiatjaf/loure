import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:mime/mime.dart";
import "package:loure/client/upload/void_cat.dart";
import "package:loure/util/platform_util.dart";
import "package:loure/util/string_util.dart";
import "package:wechat_assets_picker/wechat_assets_picker.dart";

import "package:loure/consts/base64.dart";
import "package:loure/consts/image_services.dart";
import "package:loure/client/upload/nostr_build_uploader.dart";
import "package:loure/client/upload/nostrfiles_dev_uploader.dart";
import "package:loure/client/upload/nostrimg_com_uploader.dart";
import "package:loure/client/upload/pomf2_lain_la.dart";

class Uploader {
  // static Future<String?> pickAndUpload(BuildContext context) async {
  //   var assets = await AssetPicker.pickAssets(
  //     context,
  //     pickerConfig: const AssetPickerConfig(maxAssets: 1),
  //   );

  //   if (assets != null && assets.isNotEmpty) {
  //     for (var asset in assets) {
  //       var file = await asset.file;
  //       return await NostrBuildUploader.upload(file!.path);
  //     }
  //   }

  //   return null;
  // }

  static String getFileType(final String filePath) {
    var fileType = lookupMimeType(filePath);
    if (StringUtil.isBlank(fileType)) {
      fileType = "image/jpeg";
    }

    return fileType!;
  }

  static Future<void> pickAndUpload(final BuildContext context) async {
    final filePath = await pick(context);
    if (StringUtil.isNotBlank(filePath)) {
      final result = await Pomf2LainLa.upload(filePath!);
      print("result $result");
    }
  }

  static Future<String?> pick(final BuildContext context) async {
    if (PlatformUtil.isPC() || PlatformUtil.isWeb()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        if (PlatformUtil.isWeb() && result.files.single.bytes != null) {
          return BASE64.toBase64(result.files.single.bytes!);
        }

        return result.files.single.path;
      }

      return null;
    }
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(maxAssets: 1),
    );

    if (assets != null && assets.isNotEmpty) {
      final file = await assets[0].file;
      return file!.path;
    }

    return null;
  }

  static Future<String?> upload(final String localPath,
      {final String? imageService}) async {
    if (imageService == ImageServices.NOSTRIMG_COM) {
      return await NostrimgComUploader.upload(localPath);
    } else if (imageService == ImageServices.POMF2_LAIN_LA) {
      return await Pomf2LainLa.upload(localPath);
    } else if (imageService == ImageServices.VOID_CAT) {
      return await VoidCatUploader.upload(localPath);
    } else if (imageService == ImageServices.NOSTRFILES_DEV) {
      return await NostrfilesDevUploader.upload(localPath);
    } else if (imageService == ImageServices.NOSTR_BUILD) {
      return await NostrBuildUploader.upload(localPath);
    }
    return await NostrimgComUploader.upload(localPath);
  }
}
