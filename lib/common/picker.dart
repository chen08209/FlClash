import 'package:file_picker/file_picker.dart';
import 'package:fl_clash/common/common.dart';
import 'package:image_picker/image_picker.dart';

class Picker {
  Future<PlatformFile?> pickerConfigFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    return filePickerResult?.files.first;
  }

  Future<PlatformFile?> pickerGeoDataFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      withData: true,
      allowMultiple: false,
    );
    return filePickerResult?.files.first;
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
