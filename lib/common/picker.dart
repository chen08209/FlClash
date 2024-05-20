import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_clash/models/models.dart';

class Picker {
  Future<Result<PlatformFile>> pickerConfigFile() async {
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
      return Result.error(appLocalizations.pleaseUploadFile);
    }
    return Result.success(file);
  }

  Future<Result<String>> pickerConfigQRCode() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    final bytes = await xFile?.readAsBytes();
    if (bytes == null) return Result.error();
    final result = await other.parseQRCode(bytes);
    if (result == null || !result.isUrl) {
      return Result.error(appLocalizations.pleaseUploadValidQrcode);
    }
    return Result.success(result);
  }
}

final picker = Picker();
