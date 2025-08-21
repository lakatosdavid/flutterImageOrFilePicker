import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_or_file_browser/src/shared_function.dart';
import 'package:flutter_image_or_file_browser/src/types.dart';

import 'file_picker_params.dart';

class FilePickerUtils with SharedFunctions {
  final FilePickerErrorHandler? onError;

  FilePickerUtils(this.onError);

  Future<File?> pickSingleFile(FilePickerParams filePickerParams) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: filePickerParams.allowMultiple,
      type: filePickerParams.type,
      allowedExtensions: filePickerParams.allowedExtensions,
    );
    if (result != null && result.files.single.path != null) {
      final retFile = File(result.files.single.path!);
      final size = await getFileSizeInMB(retFile);
      if (filePickerParams.maxFileSize != null && filePickerParams.maxFileSize! < size) {
        /*await bottomSheetService.showCustomSheet(
            elevation: 0,
            isScrollControlled: true,
            variant: BottomSheetType.errorBottom,
            description: localization.image_upload_max_file_size_error_title(
                filePickerParams.maxFileSize!),
            barrierDismissible: false);*/

        if (onError != null) {
          await onError!("File is too large. Max size: ${filePickerParams.maxFileSize} MB, selected: ${size.toStringAsFixed(2)} MB");
        }
      } else {
        return retFile;
      }
    }

    return null;
  }
}
