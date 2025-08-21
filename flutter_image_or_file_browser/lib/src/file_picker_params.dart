import 'package:file_picker/file_picker.dart';

class FilePickerParams {
  bool allowMultiple;
  FileType type;
  List<String> allowedExtensions;
  int? maxFileSize;

  FilePickerParams({this.allowMultiple = false, this.type = FileType.any, this.allowedExtensions = const [], this.maxFileSize});
}
