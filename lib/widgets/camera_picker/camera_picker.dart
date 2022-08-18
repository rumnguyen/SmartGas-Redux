import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/widgets/camera_picker/image_gallery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/*
  ======================================
             CONFIGURATIONS
  ======================================
  <I> Add library to pubspec.yaml:
  + image_picker: ^0.6.7+4
  + image_cropper: ^1.2.3

  <II> Android
  + File name: AndroidManifest.xml
  + Add information to the "<application>" tag:
    android:requestLegacyExternalStorage="true"
  + Add "UCropActivity" into your AndroidManifest.xml:
    <activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>

  <III> IOS
    + Path: <project root>/ios/Runner/Info.plist
    + Add information (Choose "keys" you need to add):
      <key>NSPhotoLibraryUsageDescription</key>
      <string>Application needs photo library accessing permission to upload your own photo</string>
      <key>NSCameraUsageDescription</key>
      <string>Application needs camera usage accessing permission to take a photo</string>
      <key>NSMicrophoneUsageDescription</key>
      <string>Application needs microphone usage accessing permisstion to record videos</string>

  <IV> References:
    + image_picker: https://pub.dev/packages/image_picker/install
    + image_cropper: https://pub.dev/packages/image_cropper

  <V> How to use?:
    + 3 values of <result> variable below:
      - True: Take a photo or Open photo library successfully
      - False: Photo file has been cleared/removed
      - Null: Close action sheet

  void _doSomething() async {
    final CameraPicker _selectedCameraFile = CameraPicker();

    bool result =
        await _selectedCameraFile.showCameraPickerActionSheet(context, <Optional params>);
    if (result == null || !result) return;

    result = await _selectedCameraFile.cropImage(<Optional params>);
    if (!result) return;

    setState(() {});
  }
*/

enum CameraFileState {
  FREE,
  PICKED,
  CROPPED,
}

class CameraPicker {
  CameraFileState _cameraFileState = CameraFileState.FREE;
  PickedFile? _file;
  final ImagePicker _picker = ImagePicker();

  ImagePicker get picker => _picker;

  PickedFile? get file => _file;

  CameraFileState get cameraFileState => _cameraFileState;

  CameraPicker({
    PickedFile? file,
  }) {
    if (file != null) {
      _file = file;
      _cameraFileState = CameraFileState.PICKED;
    }
  }

  Future<String> toBase64() async {
    if (_file == null) return Future.value("");
    Uint8List data = await _file!.readAsBytes();
    return base64Encode(data);
  }

  Future<PickedFile?> showImagePicker({
    ImageSource imageSource = ImageSource.gallery,
    double maxWidth = 1920,
    double maxHeight = 1080,
    int imageQuality = 100,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    if (imageQuality < 0) imageQuality = 0;
    if (imageQuality > 100) imageQuality = 100;

    _file = await _picker.getImage(
      source: imageSource,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );

    return _file;
  }

  Future<T?> showCameraPickerActionSheet<T>(
    BuildContext context, {
    double maxWidth = 1920,
    double maxHeight = 1080,
    int imageQuality = 100,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool enableClearSelectedFile = true,
    String? currentImage,
  }) {
    String takeAPhoto = GlobalManager.strings.takeAPhoto!;
    String clearSelectedFile = GlobalManager.strings.clearSelectedFile!;
    String close = GlobalManager.strings.close!;
    String openPhotoLibrary = GlobalManager.strings.openPhotoLibrary!;
    String viewPhoto = GlobalManager.strings.viewPhoto!;

    const double _spacing = 15.0;
    const double _radius = 7.0;
    const double _btnHeight = 50.0;

    Widget _renderButton({
      String? text,
      Function()? func,
      OutlinedBorder? shapeBorder,
    }) {
      return SizedBox(
        height: _btnHeight,
        child: TextButton(
          onPressed: func,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0),
            primary: const Color.fromRGBO(13, 125, 251, 0.1),
            backgroundColor: Colors.white,
            textStyle: const TextStyle(color: Colors.white),
            shape: shapeBorder ??
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius),
                ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text ?? '',
              textScaleFactor: 1.0,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF0D7DFB),
              ),
            ),
          ),
        ),
      );
    }

    return showCupertinoModalPopup<T>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(_spacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(_radius),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    // Take a photo
                    _renderButton(
                      text: takeAPhoto,
                      func: () async {
                        final result = await showImagePicker(
                          imageSource: ImageSource.camera,
                          maxWidth: maxWidth,
                          maxHeight: maxHeight,
                          imageQuality: imageQuality,
                          preferredCameraDevice: preferredCameraDevice,
                        );

                        if (result == null) {
                          _cameraFileState = CameraFileState.FREE;
                        } else {
                          _cameraFileState = CameraFileState.PICKED;
                        }

                        pop(context, object: true);
                      },
                      shapeBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(_radius),
                          topRight: Radius.circular(_radius),
                        ),
                      ),
                    ),
                    // Horizontal divider
                    const Divider(
                      color: Color(0xFFABABAB),
                      height: 1,
                      thickness: 0.4,
                    ),
                    // Open photo library
                    _renderButton(
                      text: openPhotoLibrary,
                      func: () async {
                        final result = await showImagePicker(
                          imageSource: ImageSource.gallery,
                          maxWidth: maxWidth,
                          maxHeight: maxHeight,
                          imageQuality: imageQuality,
                          preferredCameraDevice: preferredCameraDevice,
                        );

                        if (result == null) {
                          _cameraFileState = CameraFileState.FREE;
                          pop(context, object: false);
                        } else {
                          _cameraFileState = CameraFileState.PICKED;
                          pop(context, object: true);
                        }
                      },
                      shapeBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(0),
                        ),
                      ),
                    ),
                    // Horizontal divider
                    const Divider(
                      color: Color(0xFFABABAB),
                      height: 1,
                      thickness: 0.4,
                    ),
                    _renderButton(
                      text: viewPhoto,
                      func: () {
                        if (currentImage == null || currentImage.isEmpty) {
                          pop(context, object: null);
                          return;
                        }

                        List<String> imageUrls = [currentImage];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ImageGalleryScreen(items: imageUrls),
                          ),
                        );
                      },
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: (enableClearSelectedFile
                            ? const BorderRadius.all(
                                Radius.circular(0),
                              )
                            : const BorderRadius.only(
                                bottomLeft: Radius.circular(_radius),
                                bottomRight: Radius.circular(_radius),
                              )),
                      ),
                    ),
                    // Horizontal divider
                    const Divider(
                      color: Color(0xFFABABAB),
                      height: 1,
                      thickness: 0.4,
                    ),
                    // Clear selected photo
                    (enableClearSelectedFile
                        ? _renderButton(
                            text: clearSelectedFile,
                            func: () {
                              _cameraFileState = CameraFileState.FREE;
                              _file = null;
                              pop(context, object: false);
                            },
                            shapeBorder: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(_radius),
                                bottomRight: Radius.circular(_radius),
                              ),
                            ),
                          )
                        : Container()),
                  ],
                ),
              ),
              const SizedBox(height: _spacing),
              _renderButton(
                text: close,
                func: () => pop(context, object: null),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> cropImage({
    AndroidUiSettings? androidUiSettings,
    IOSUiSettings? iosUiSettings,
    List<CropAspectRatioPreset>? aspectRatioPresets,
    int? maxWidth,
    int? maxHeight,
    CropAspectRatio? aspectRatio,
    CropStyle cropStyle = CropStyle.rectangle,
    ImageCompressFormat compressFormat = ImageCompressFormat.jpg,
    int compressQuality = 90,
  }) async {
    assert(maxWidth == null || maxWidth > 0);
    assert(maxHeight == null || maxHeight > 0);
    assert(compressQuality >= 0 && compressQuality <= 100);

    if (_file == null) {
      return false;
    }

    if (aspectRatioPresets == null || aspectRatioPresets.isEmpty) {
      aspectRatioPresets = [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9,
      ];
    }

    Color majorColor = GlobalManager.colors.majorColor();
    Color grayColor = GlobalManager.colors.grayABABAB;

    File? croppedFile = await ImageCropper().cropImage(
      sourcePath: _file!.path,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      aspectRatio: aspectRatio,
      compressFormat: compressFormat,
      compressQuality: compressQuality,
      cropStyle: cropStyle,
      aspectRatioPresets: aspectRatioPresets,
      androidUiSettings: androidUiSettings ??
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.white,
            toolbarWidgetColor: majorColor,
            activeControlsWidgetColor: majorColor,
            cropGridColor: grayColor,
            cropFrameColor: grayColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
      iosUiSettings: iosUiSettings ??
          IOSUiSettings(
            title: 'Cropper',
          ),
    );

    if (croppedFile != null) {
      _cameraFileState = CameraFileState.CROPPED;
      _file = PickedFile(croppedFile.path);
      return true;
    }

    return false;
  }
}
