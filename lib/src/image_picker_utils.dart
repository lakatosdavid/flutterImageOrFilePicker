// This is the image picker
import 'dart:io';

import 'package:flutter_image_or_file_browser/src/shared_function.dart';
import 'package:flutter_image_or_file_browser/src/types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class ImagePickerUtils with SharedFunctions {
  final ImagePickerPlatform _picker = ImagePickerPlatform.instance;
  final FilePickerErrorHandler? onError;

  ImagePickerUtils({this.onError});

  Future<File?> takeImage({int? imageQuality = 100, int? maxFileSize}) async {
    final XFile? pickedImage = await _picker.getImageFromSource(
      source: ImageSource.camera,
      options: ImagePickerOptions(imageQuality: imageQuality),
    );
    if (pickedImage != null) {
      // final size = await getFileSize(pickedImage.path, 1);
      var selectedImage = File(pickedImage.path);
      final size = await getFileSizeInMB(selectedImage);
      if (maxFileSize != null && maxFileSize < size) {
        /*await bottomSheetService.showCustomSheet(
            elevation: 0,
            isScrollControlled: true,
            variant: BottomSheetType.errorBottom,
            description: localization
                .image_upload_max_file_size_error_title(maxFileSize),
            barrierDismissible: false);*/

        if (onError != null) {
          await onError!("File is too large. Max size: $maxFileSize MB, selected: ${size.toStringAsFixed(2)} MB");
        }
        return null;
      } else {
        return selectedImage;
      }
    }
    return null;
  }

  /// ezt az ios-hez használom
  /// de az android-ot is tudja, viszont nem az újabb fajta imagePicker-rel
  Future<File?> pickImage({int? imageQuality = 100, int? maxFileSize}) async {
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: imageQuality);
    // final size = await getFileSize(pickedImage!.path, 1);
    if (pickedImage != null) {
      var selectedImage = File(pickedImage.path);
      final size = await getFileSizeInMB(selectedImage);
      if (maxFileSize != null && maxFileSize < size) {
        /*await bottomSheetService.showCustomSheet(
            elevation: 0,
            isScrollControlled: true,
            variant: BottomSheetType.errorBottom,
            description: localization
                .image_upload_max_file_size_error_title(maxFileSize),
            barrierDismissible: false);*/

        if (onError != null) {
          await onError!("File is too large. Max size: $maxFileSize MB, selected: ${size.toStringAsFixed(2)} MB");
        }
      } else {
        return selectedImage;
      }
    }
    return null;
  }
}
