import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_or_file_browser/text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/gen/module_a_localizations.dart';
import 'file_picker_params.dart';
import 'file_picker_utils.dart';
import 'image_picker_utils.dart';

/*
// Fő widgetben vagy ahol először kell
final manager = ImageFilePickerManager.init(context);

// Később bárhol
ImageFilePickerManager.instance.pickSomething();
 */
class ImageFilePickerManager {
  final BuildContext context;

  // Privát konstruktor
  ImageFilePickerManager._internal(this.context);

  static ImageFilePickerManager? _instance;

  // Inicializálás contexttel
  static ImageFilePickerManager init(BuildContext context) {
    _instance ??= ImageFilePickerManager._internal(context);
    return _instance!;
  }

  // Getter
  static ImageFilePickerManager get instance {
    if (_instance == null) {
      throw Exception('ImageFilePickerManager is not initialized. Call init(context) first.');
    }
    return _instance!;
  }

  final _filePickerParam = FilePickerParams(allowMultiple: false, type: FileType.custom, allowedExtensions: ['pdf'], maxFileSize: 5);

  showPicker() async {
    if (Platform.isIOS) {
      return await _showCupertinoActionSheet();
    }
    return await _showAndroidBottomSheet();
  }

  Future<void> _showCupertinoActionSheet() async {
    return await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(ModuleALocalizations.of(context).image_upload_dialog_description),
        // message: const Text('Message'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            // isDefaultAction: true,
            onPressed: () async {
              return _pickImageFromGallery();
            },
            child: Text(ModuleALocalizations.of(context).image_upload_dialog_first_option, style: AppTextStyles.actionSheetItem(context)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              _takeImage();
            },
            child: Text(ModuleALocalizations.of(context).image_upload_dialog_second_option, style: AppTextStyles.actionSheetItem(context)),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              _pickFile();
            },
            child: Text(ModuleALocalizations.of(context).file_upload_dialog_second_option, style: AppTextStyles.actionSheetItem(context)),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              // TODO navigationService.back();
            },
            child: Text(ModuleALocalizations.of(context).image_upload_dialog_cancel_option),
          ),
        ],
      ),
    );
  }

  Future<void> _showAndroidBottomSheet() async {
    return await showModalBottomSheet<void>(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                child: Text(ModuleALocalizations.of(context).image_upload_dialog_description, style: AppTextStyles.headline4(context)),
              ),
              InkWell(
                onTap: () async => await _pickImageFromGallery(),
                child: ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(
                    ModuleALocalizations.of(context).image_upload_dialog_first_option,
                    style: AppTextStyles.actionSheetItem(context),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _takeImage(),
                child: ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(
                    ModuleALocalizations.of(context).image_upload_dialog_second_option,
                    style: AppTextStyles.actionSheetItem(context),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _pickFile(),
                child: ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: Text(
                    ModuleALocalizations.of(context).file_upload_dialog_second_option,
                    style: AppTextStyles.actionSheetItem(context),
                  ),
                ),
              ),
              InkWell(
               // TODO onTap: () => navigationService.back(),
                child: ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(
                    ModuleALocalizations.of(context).image_upload_dialog_cancel_option,
                    style: AppTextStyles.actionSheetItem(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _pickImageFromGallery() async {
    // check permission - csak IOS- en kell, az android photo picker-nek nincs zsüksége ilyen engedélyre
    // azért kell mert ha elutasítjuk utána az imagePicker library nem figyeli és nem történik semmi (a user nem tudja miért nem történik semmi a gombra kattintásnál)
    var galleryAccessStatus = PermissionStatus.granted;

    if (Platform.isIOS) {
      galleryAccessStatus = await Permission.photos.status;
    }

    if ([PermissionStatus.granted, PermissionStatus.limited].contains(galleryAccessStatus) == false) {
      var status = await Permission.photos.request();

      if (status != PermissionStatus.granted) {
        // beállítások változtatásánál az ios kényszerítve újraindítja az alkalmazást
        final response = await _showPermissionOpenSettingsAppDialog(ModuleALocalizations.of(context).app_need_permission_title_photos);

        if (response == true) {
          await openAppSettings();
        }
      }
    } else {
      var response = await ImagePickerUtils().pickImage(imageQuality: 25, maxFileSize: 5);
      // TODO navigationService.back(
      //   result: SheetResponse(confirmed: response != null, data: response),
      // );
    }
  }

  Future<void> _takeImage() async {
    // check permission - csak IOS- en kell, az android photo picker-nek nincs zsüksége ilyen engedélyre
    // azért kell mert ha elutasítjuk utána az imagePicker library nem figyeli és nem történik semmi (a user nem tudja miért nem történik semmi a gombra kattintásnál)
    var cameraAccessStatus = PermissionStatus.granted;

    if (Platform.isIOS) {
      cameraAccessStatus = await Permission.camera.status;
    }

    if ([PermissionStatus.granted, PermissionStatus.limited].contains(cameraAccessStatus) == false) {
      var status = await Permission.camera.request();

      if (status != PermissionStatus.granted) {
        // beállítások változtatásánál az ios kényszerítve újraindítja az alkalmazást
        final response = await _showPermissionOpenSettingsAppDialog(ModuleALocalizations.of(context).app_need_permission_title_camera);

        if (response == true) {
          await openAppSettings();
        }
      }
    } else {
      var response = await ImagePickerUtils().takeImage(imageQuality: 25, maxFileSize: 5);
      /* TODO navigationService.back(
        result: SheetResponse(confirmed: response != null, data: response),
      );*/
    }
  }

  Future<void> _pickFile() async {
    // check permission
    // azért kell mert ha elutasítjuk utána az imagePicker library nem figyeli és nem történik semmi (a user nem tudja miért nem történik semmi a gombra kattintásnál)

   // TODO var response = await FilePickerUtils().pickSingleFile(_filePickerParam);
   /* TODO navigationService.back(
      result: SheetResponse(confirmed: response != null, data: response),
    );*/
  }

  Future<bool> _showPermissionOpenSettingsAppDialog(String type) async {
    /* TODO final response = await dialogService.showConfirmationDialog(
      title: ModuleALocalizations.of(context).app_need_permission_title(type),
      description: ModuleALocalizations.of(context).app_need_permissions_message,
      confirmationTitle: ModuleALocalizations.of(context).go_to_settings_button_title,
      cancelTitle: ModuleALocalizations.of(context).go_to_settings_button_cancel_title,
    );
    return response?.confirmed == true;*/

    return true;
  }
}
