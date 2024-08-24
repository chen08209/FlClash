import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/common.dart';
import 'package:image_picker/image_picker.dart';

class Picker {
  Future<PlatformFile?> pickerFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
      initialDirectory: await appPath.getDownloadDirPath(),
    );
    return filePickerResult?.files.first;
  }

  Future<String?> saveFile(String fileName, Uint8List bytes) async {
    final path = await FilePicker.platform.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.getDownloadDirPath(),
      bytes: Platform.isAndroid ? bytes : null,
    );
    if (!Platform.isAndroid && path != null) {
      final file = await File(path).create(recursive: true);
      await file.writeAsBytes(bytes);
    }
    return path;
  }

  Future<String?> pickerConfigQRCode() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    final bytes = await xFile?.readAsBytes();
    if (bytes == null) return null;
    final result = await other.parseQRCode(bytes);
    if (result == null || !result.isUrl) {
      throw appLocalizations.pleaseUploadValidQrcode;
    }
    return result;
  }
}

final picker = Picker();
