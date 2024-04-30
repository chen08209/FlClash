import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/models/models.dart';

class FileUtil {
  static Future<Result<PlatformFile>> pickerConfig() async {
    FilePickerResult? filePickerResult;
    if (Platform.isAndroid) {
      filePickerResult = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['txt', 'conf'],
      );
    } else {
      filePickerResult = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['yaml', 'txt', 'conf'],
      );
    }
    final file = filePickerResult?.files.first;
    if (file == null) {
      return Result.error(message: appLocalizations.pleaseUploadFile);
    }
    return Result.success(data: file);
  }
}
