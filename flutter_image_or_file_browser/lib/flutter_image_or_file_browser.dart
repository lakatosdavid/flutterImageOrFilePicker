import 'package:flutter_image_or_file_browser/src/image_picker_utils.dart';

final picker = ImagePickerUtils(
  onError: (msg) async => print(msg),
);
