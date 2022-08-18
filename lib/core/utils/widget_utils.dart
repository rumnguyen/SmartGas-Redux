import 'package:anpha_petrol_smartgas/animations/fade_page_route.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/widgets/image_gallery.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';

class WidgetUtils {
  static Widget renderRichInfo({
    required String title,
    required String data,
    Color titleColor = Colors.black,
    Color dataColor = Colors.blue,
    FontWeight titleWeight = FontWeight.normal,
    FontWeight dataWeight = FontWeight.w500,
    double titleSize = 14,
    double dataSize = 14,
    int maxLines = 2,
    bool hasColon = true,
  }) {
    String separator = hasColon ? ":" : "";
    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textScaleFactor: 1.0,
      textAlign: TextAlign.left,
      text: TextSpan(
        text: "$title$separator ",
        style: TextStyle(
          color: titleColor,
          fontWeight: titleWeight,
          fontSize: titleSize,
        ),
        children: [
          TextSpan(
            text: "$data ",
            style: TextStyle(
              color: dataColor,
              fontWeight: dataWeight,
              fontSize: dataSize,
            ),
          ),
        ],
      ),
    );
  }

  static Widget renderEmptyData({
    String? content,
    String? imgUrl,
    double height = 100,
    Color? color,
  }) {
    if (!checkStringNullOrEmpty(imgUrl)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageCacheManager.getCachedImage03(url: imgUrl, height: height),
            const SizedBox(
              height: 16.0,
            ),
            Text(
              content ?? GlobalManager.strings.noData!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: color ?? GlobalManager.colors.gray808080,
              ),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Text(
        content ?? GlobalManager.strings.noData!,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: color ?? GlobalManager.colors.gray808080,
        ),
      ),
    );
  }

  static void openImageFromHtml(
      BuildContext context, ImageMetadata imageMetaData) {
    var _images = imageMetaData.sources.toList();
    if (checkListIsNullOrEmpty(_images)) return;
    var _url = _images[0].url;
    pushPageWithRoute(
      context,
      FadePageRoute(
        page: ImageGalleryScreen(
          items: [_url],
        ),
      ),
    );
  }

  static Widget simpleTextSpan(
    String title,
    String content, {
    EdgeInsets? padding,
    bool reverseBold = false,
    bool canNull = true,
    Color titleColor = Colors.black,
    Color contentColor = Colors.black,
    double titleTextSize = 14,
    double contentTextSize = 14,
  }) {
    if (!canNull && checkStringNullOrEmpty(content)) return Container();
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: titleTextSize,
            color: titleColor,
            height: 1.3,
            fontWeight: reverseBold ? FontWeight.bold : FontWeight.normal,
          ),
          text: title + ' ',
          children: [
            TextSpan(
              text: checkStringNullOrEmpty(content)
                  ? GlobalManager.strings.na
                  : content,
              style: TextStyle(
                fontSize: contentTextSize,
                fontWeight: reverseBold ? FontWeight.normal : FontWeight.bold,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Standard size (360, 732) - VSmart Active 3
  ///
  static double calculateScalableSize(
    double standardSize, {
    double standardWidth = 360.0,
    double standardHeight = 732.0,
    required bool isHeight,
  }) {
    if (isHeight) {
      return standardSize *
          GlobalManager.appRatio.deviceHeight! /
          standardHeight;
    }
    return standardSize * GlobalManager.appRatio.deviceWidth! / standardWidth;
  }
}
