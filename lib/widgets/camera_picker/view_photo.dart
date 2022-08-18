import 'dart:io';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';

class ViewPhoto extends StatefulWidget {
  final String photoUrl;
  final bool enableBackButton;
  final bool enableDeleteButton;
  final VoidCallback? deleteFunction;

  ViewPhoto({Key? key,
    required this.photoUrl,
    this.enableBackButton = true,
    this.enableDeleteButton = false,
    this.deleteFunction,
  }) : assert(photoUrl.isNotEmpty), super(key: key);

  @override
  _ViewPhotoState createState() => _ViewPhotoState();
}

class _ViewPhotoState extends State<ViewPhoto> {
  Widget _renderButton({
    required bool enabled,
    required Widget child,
    VoidCallback? function,
    EdgeInsets margin = const EdgeInsets.all(0),
  }) {
    if (enabled == false) {
      return Container();
    }

    return Container(
      width: 36,
      height: 36,
      margin: margin,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            offset: Offset(0.0, 0.0),
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          if (function != null) {
            function();
          }
        },
        style: TextButton.styleFrom(
          primary: Colors.black.withOpacity(0.1),
          padding: const EdgeInsets.all(0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _renderButtonList() {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        top: statusBarHeight + 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          _renderButton(
            enabled: widget.enableBackButton,
            child: const Padding(
              padding: EdgeInsets.only(right: 2),
              child: FaIcon(
                FontAwesomeIcons.chevronLeft,
                size: 16,
                color: Colors.black,
              ),
            ),
            function: () {
              pop(context);
            },
          ),
          // Delete button
          _renderButton(
            enabled: widget.enableDeleteButton,
            margin: const EdgeInsets.only(left: 20),
            child: const FaIcon(
              FontAwesomeIcons.trash,
              size: 14,
              color: Colors.red,
            ),
            function: () {
              if (widget.deleteFunction != null) {
                widget.deleteFunction!();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _renderPhotoView() {
    var fileImage;
    if (widget.photoUrl.startsWith("http://") ||
        widget.photoUrl.startsWith("https://")) {
      fileImage = ImageCacheManager.getImageProvider(url: widget.photoUrl);
    } else {
      fileImage = FileImage(File(widget.photoUrl));
    }

    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        // Photo
        PhotoView(
          imageProvider: fileImage,
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained * 1.0,
          maxScale: PhotoViewComputedScale.covered * 5.0,
        ),
        // Back button
        _renderButtonList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _renderPhotoView();
  }
}
