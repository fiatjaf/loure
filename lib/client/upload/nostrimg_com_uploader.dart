import 'package:dio/dio.dart';
import 'package:http_parser/src/media_type.dart';

import 'package:loure/consts/base64.dart';
import 'package:loure/client/upload/nostr_build_uploader.dart';
import 'package:loure/client/upload/uploader.dart';

class NostrimgComUploader {
  static const String UPLOAD_ACTION = "https://nostrimg.com/api/upload";

  static Future<String?> upload(String filePath, {String? fileName}) async {
    // final dio = Dio();
    // dio.interceptors.add(PrettyDioLogger(requestBody: true));
    var fileType = Uploader.getFileType(filePath);
    MultipartFile? multipartFile;
    if (BASE64.check(filePath)) {
      var bytes = BASE64.toData(filePath);
      multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: MediaType.parse(fileType),
      );
    } else {
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: MediaType.parse(fileType),
      );
    }

    var formData = FormData.fromMap({"image": multipartFile});
    var response =
        await NostrBuildUploader.dio.post(UPLOAD_ACTION, data: formData);
    var body = response.data;
    if (body is Map<String, dynamic>) {
      return body["data"]["link"];
    }
    return null;
  }
}
