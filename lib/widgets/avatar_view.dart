import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:flutter/material.dart';

class AvatarView extends StatelessWidget {
  final String? avatarImageURL;
  final double? avatarImageSize;
  final int? avatarCacheSize;
  final BoxShadow? avatarBoxShadow;
  final BoxBorder? avatarBoxBorder;
  final bool? enableSquareAvatarImage;
  final double? avatarSquareWidth;
  final double? avatarSquareHeight;
  final double? radiusSquareBorder;
  final int? avatarSquareCacheWidth;
  final int? avatarSquareCacheHeight;
  final Function? pressAvatarImage;
  final String? supportImageURL;

  AvatarView({
    @required this.avatarImageURL,
    this.avatarImageSize = 0.0,
    this.avatarCacheSize = 120,
    this.avatarBoxShadow,
    this.avatarBoxBorder,
    this.enableSquareAvatarImage = false,
    this.avatarSquareWidth = 0.0,
    this.avatarSquareHeight = 0.0,
    this.radiusSquareBorder = 5,
    this.avatarSquareCacheWidth,
    this.avatarSquareCacheHeight,
    this.pressAvatarImage,
    this.supportImageURL,
  }) : assert(avatarImageSize != null &&
            avatarImageSize >= 0.0 &&
            avatarSquareWidth != null &&
            avatarSquareWidth >= 0.0 &&
            avatarSquareHeight != null &&
            avatarSquareHeight >= 0.0);

  @override
  Widget build(BuildContext context) {
    double? _supportImageSize = avatarImageSize! / 4;
    double? avatarWidth = avatarImageSize;
    double? avatarHeight = avatarImageSize;
    int? cacheWidth = avatarCacheSize;
    int? cacheHeight = avatarCacheSize;
    if (enableSquareAvatarImage!) {
      if (avatarSquareWidth != 0.0) avatarWidth = avatarSquareWidth;
      if (avatarSquareHeight != 0.0) avatarHeight = avatarSquareHeight;
      cacheWidth = avatarSquareCacheWidth;
      cacheHeight = avatarSquareCacheHeight;
    }

    return Container(
      width: avatarWidth,
      height: avatarHeight,
      decoration: BoxDecoration(
        borderRadius: (enableSquareAvatarImage!
            ? BorderRadius.all(
                Radius.circular(radiusSquareBorder!),
              )
            : BorderRadius.all(
                Radius.circular(avatarImageSize! / 2),
              )),
        border: avatarBoxBorder,
        boxShadow: (avatarBoxShadow != null
            ? [
                avatarBoxShadow!,
              ]
            : null),
      ),
      child: GestureDetector(
        onTap: () {
          if (pressAvatarImage != null) {
            pressAvatarImage!();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ClipRRect(
              borderRadius: (enableSquareAvatarImage!
                  ? BorderRadius.all(
                      Radius.circular(radiusSquareBorder!),
                    )
                  : BorderRadius.all(
                      Radius.circular(avatarImageSize! / 2),
                    )),
              child: ImageCacheManager.getImage(
                url: avatarImageURL,
                height: avatarHeight,
                width: avatarWidth,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: (supportImageURL == null ||
                      supportImageURL!.isEmpty
                  ? null
                  : ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(_supportImageSize / 2),
                      ),
                      child: ImageCacheManager.getImage(
                        url: supportImageURL,
                        height: _supportImageSize,
                        width: _supportImageSize,
                        fit: BoxFit.cover,
                      ),
                    )),
            ),
          ],
        ),
      ),
    );
  }
}
