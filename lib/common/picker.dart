import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Picker {
  Future<PlatformFile?> pickerFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
      initialDirectory: await appPath.downloadDirPath,
    );
    return filePickerResult?.files.first;
  }

  Future<String?> saveFile(String fileName, Uint8List bytes) async {
    final path = await FilePicker.platform.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.downloadDirPath,
      bytes: system.isAndroid ? bytes : null,
    );
    if (!system.isAndroid && path != null) {
      final file = await File(path).create(recursive: true);
      await file.writeAsBytes(bytes);
    }
    return path;
  }

  Future<String?> pickerConfigQRCode() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile == null) {
      return null;
    }
    final controller = MobileScannerController();
    final capture = await controller.analyzeImage(xFile.path, formats: [
      BarcodeFormat.qrCode,
    ]);
    final result = capture?.barcodes.first.rawValue;
    if (result == null || !result.isUrl) {
      throw appLocalizations.pleaseUploadValidQrcode;
    }
    return result;
  }
}

final picker = Picker();
