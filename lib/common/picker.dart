import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Picker {
  Future<PlatformFile?> pickerFile() async {
    return FilePicker.pickFile(initialDirectory: await appPath.downloadDirPath);
  }

  Future<String?> saveFile(String fileName, Uint8List bytes) async {
    final path = await FilePicker.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.downloadDirPath,
      bytes: bytes,
    );
    if (!system.isAndroid && path != null) {
      final file = File(path);
      await file.safeWriteAsBytes(bytes);
    }
    return path;
  }

  Future<String?> saveFileWithPath(String fileName, String localPath) async {
    final localFile = File(localPath);
    if (!await localFile.exists()) {
      await localFile.create(recursive: true);
    }
    final bytes = await localFile.readAsBytes();
    final path = await FilePicker.saveFile(
      fileName: fileName,
      initialDirectory: await appPath.downloadDirPath,
      bytes: bytes,
    );
    await localFile.safeDelete();
    return path;
  }

  Future<String?> pickerConfigQRCode() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (xFile == null) {
      return null;
    }
    final controller = MobileScannerController();
    final capture = await controller.analyzeImage(
      xFile.path,
      formats: [BarcodeFormat.qrCode],
    );
    final result = capture?.barcodes.first.rawValue;
    if (result == null || !result.isUrl) {
      throw currentAppLocalizations.pleaseUploadValidQrcode;
    }
    return result;
  }
}

extension PlatformFileExt on PlatformFile {
  Future<Uint8List> readBytes() {
    return readAsBytes();
  }
}

final picker = Picker();
