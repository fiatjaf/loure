import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'package:loure/client/upload/uploader.dart';
import 'package:loure/util/string_util.dart';

import 'package:loure/consts/base64.dart';
import 'package:loure/client/upload/nostr_build_uploader.dart';

class VoidCatUploader {
  static const String UPLOAD_ACTION = "https://void.cat/upload?cli=true";

  static Future<String?> upload(String filePath, {String? fileName}) async {
    Uint8List? bytes;
    if (BASE64.check(filePath)) {
      bytes = BASE64.toData(filePath);
    } else {
      var tempFile = File(filePath);
      bytes = await tempFile.readAsBytes();
    }

    var digest = sha256.convert(bytes);
    var fileHex = hex.encode(digest.bytes);

    Map<String, dynamic> headers = {};
    headers["content-type"] = "application/octet-stream";
    headers["v-full-digest"] = fileHex;

    var fileType = Uploader.getFileType(filePath);
    headers["v-content-type"] = fileType;
    if (StringUtil.isNotBlank(fileName)) {
      headers["V-Filename"] = fileName;
    }

    var response = await NostrBuildUploader.dio.post<String>(
      UPLOAD_ACTION,
      data: Stream.fromIterable(bytes.map((e) => [e])),
      options: Options(
        headers: headers,
      ),
    );
    var body = response.data;

    return body;
  }
}
