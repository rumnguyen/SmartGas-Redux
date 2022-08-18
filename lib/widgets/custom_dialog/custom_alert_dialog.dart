import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class _CustomAlertDialog extends StatelessWidget {
  const _CustomAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.firstButtonText,
    required this.firstButtonFunction,
    this.secondButtonText = "",
    this.secondButtonFunction,
    this.titleAlign = TextAlign.center,
    this.contentAlign = TextAlign.center,
    this.allowPopScope = true,
    this.iconUrl,
    this.highlightContent,
    this.isHtmlContent = false,
  }) : super(key: key);

  final String title;
  final String content;
  final String? highlightContent;
  final String firstButtonText;
  final Function firstButtonFunction;
  final String secondButtonText;
  final Function? secondButtonFunction;

  final double _radius = 7;
  final double _spacing = 15.0;
  final double _buttonHeight = 50.0;
  final TextAlign titleAlign;
  final TextAlign contentAlign;
  final bool allowPopScope;
  final bool isHtmlContent;
  final String? iconUrl;

  Widget _renderTitle() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
        ),
        color: GlobalManager.colors.grayF0F0F0,
      ),
      child: Text(
        title,
        textScaleFactor: 1.0,
        textAlign: titleAlign,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _renderContent() {
    Widget _contentWidget;
    if (isHtmlContent) {
      _contentWidget = HtmlWidget(
        content,
        textStyle: const TextStyle(
          color: Colors.black,
        ),
      );
    } else if (!checkStringNullOrEmpty(highlightContent)) {
      _contentWidget = RichText(
        textScaleFactor: 1.0,
        textAlign: contentAlign,
        text: TextSpan(
          text: '$content ',
          style: TextStyle(
            color: GlobalManager.colors.black3D4B5E,
            fontWeight: FontWeight.w400,
            fontSize: 15,
            height: 1.3,
          ),
          children: [
            TextSpan(
              text: highlightContent,
              style: TextStyle(
                color: GlobalManager.colors.blue4178D4,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    } else {
      _contentWidget = Text(
        content,
        textScaleFactor: 1.0,
        overflow: TextOverflow.ellipsis,
        textAlign: contentAlign,
        softWrap: true,
        maxLines: 100,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
          color: Colors.black,
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(
        left: _spacing + 5,
        right: _spacing + 5,
        top: _spacing,
        bottom: _spacing,
      ),
      child: _contentWidget,
    );
  }

  Widget _renderButton(bool _existSecondButton) {
    return Row(
      children: <Widget>[
        // Second button
        (_existSecondButton
            ? Expanded(
                child: Container(
                  height: _buttonHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(_radius),
                    ),
                    color: Colors.white,
                  ),
                  child: TextButton(
                    onPressed: () {
                      secondButtonFunction!.call();
                    },
                    style: TextButton.styleFrom(
                        primary: GlobalManager.colors.majorColor(opacity: 0.1),
                        textStyle: const TextStyle(color: Colors.white)),
                    child: Text(
                      secondButtonText,
                      textScaleFactor: 1.0,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
            : Container()),
        // Vertical Divider
        (_existSecondButton
            ? SizedBox(
                width: 1,
                height: _buttonHeight,
                child: VerticalDivider(
                  color: GlobalManager.colors.grayE5E5E5,
                  thickness: 1.0,
                ),
              )
            : Container()),
        // First button
        Expanded(
          child: Container(
            height: _buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: (!_existSecondButton
                    ? Radius.circular(_radius)
                    : const Radius.circular(0.0)),
                bottomRight: Radius.circular(_radius),
              ),
              color: Colors.white,
            ),
            child: TextButton(
              onPressed: () => firstButtonFunction(),
              style: TextButton.styleFrom(
                  primary: GlobalManager.colors.majorColor(opacity: 0.1),
                  textStyle: const TextStyle(color: Colors.white)),
              child: Text(
                firstButtonText,
                textScaleFactor: 1.0,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: GlobalManager.colors.colorAccent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderIcon() {
    if (checkStringNullOrEmpty(iconUrl)) return const SizedBox();
    return Container(
      width: 25,
      height: 25,
      margin: EdgeInsets.only(top: _spacing),
      child: ImageCacheManager.getImage(url: iconUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _existSecondButton = false;
    if (secondButtonText.isNotEmpty && secondButtonFunction != null) {
      _existSecondButton = true;
    }

    Widget element = Container(
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Title
          _renderTitle(),
          // Icon
          _renderIcon(),
          // Content
          _renderContent(),
          // Horizontal divider
          Divider(
            color: GlobalManager.colors.grayE5E5E5,
            height: 1,
            thickness: 1.0,
          ),
          // Button
          _renderButton(_existSecondButton),
        ],
      ),
    );
    return WillPopScope(
      onWillPop: () {
        return Future.value(allowPopScope);
      },
      child: element,
    );
  }
}

Future<T?> showCustomAlertDialog<T>(
  BuildContext context, {
  Key? key,
  required title,
  required content,
  required firstButtonText,
  required firstButtonFunction,
  secondButtonText = "",
  secondButtonFunction,
  TextAlign titleAlign = TextAlign.center,
  TextAlign contentAlign = TextAlign.center,
  bool barrierDismissible = true,
  bool allowPopScope = true,
  String? iconUrl,
  String? highlightContent,
  bool isHtmlContent = false,
}) async {
  return await showGeneralDialog(
    context: context,
    barrierLabel: "Label",
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: anim1,
            curve: Curves.fastOutSlowIn,
          ),
        ),
        child: child,
      );
    },
    pageBuilder: (context, anim1, anim2) {
      return Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.center,
          child: _CustomAlertDialog(
            isHtmlContent: isHtmlContent,
            title: title,
            content: content,
            firstButtonText: firstButtonText,
            firstButtonFunction: firstButtonFunction,
            secondButtonText: secondButtonText,
            secondButtonFunction: secondButtonFunction,
            titleAlign: titleAlign,
            contentAlign: contentAlign,
            allowPopScope: allowPopScope,
            highlightContent: highlightContent,
            iconUrl: iconUrl,
          ),
        ),
      );
    },
  );
}
