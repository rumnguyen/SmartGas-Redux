import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/models/o_custom_cell_suffix_actions.dart';
import 'package:anpha_petrol_smartgas/models/o_custom_cell_text_item.dart';
import 'package:anpha_petrol_smartgas/widgets/avatar_view.dart';
import 'package:flutter/material.dart';

class CustomTextCell extends StatelessWidget {
  // Text list
  final List<CustomCellTextItem> textItems;

  // Avatar view
  final AvatarView? avatarView;

  // Avatar alignment
  final Alignment? avatarAlignment;

  // Avatar padding
  final EdgeInsets? avatarPadding;

  // CustomCell is pressed
  final Function()? onPressed;

  // Suffix actions
  final List<CustomCellSuffixActions>? suffixActions;

  // Bottom divider
  final bool? fullBottomDivider;

  // Padding cell
  final EdgeInsets? padding;

  // ShapeBorder for FlatButton in CustomTextCell
  final OutlinedBorder? outlinedBorder;

  // Enable splash color of widget
  final bool? enableSplashColor;

  const CustomTextCell({
    required this.textItems,
    this.avatarView,
    this.avatarPadding = const EdgeInsets.only(right: 15),
    this.avatarAlignment = Alignment.center,
    this.onPressed,
    this.suffixActions,
    this.fullBottomDivider = false,
    this.padding = const EdgeInsets.all(0),
    this.outlinedBorder,
    this.enableSplashColor = true,
    Key? key,
  })  : assert(textItems.length != 0 &&
            avatarPadding != null &&
            avatarAlignment != null &&
            fullBottomDivider != null &&
            padding != null &&
            enableSplashColor != null),
        super(key: key);

  Widget _renderSuffixActions() {
    if (suffixActions == null || suffixActions!.isEmpty) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suffixActions!.map((action) {
        if (!action.enable!) {
          return Container();
        } else {
          return Align(
            alignment: action.alignment!,
            child: action.widget,
          );
        }
      }).toList(),
    );
  }

  Widget _renderRichTextInfo(
    CustomCellTextItem item,
  ) {
    TextStyle styleContent = item.style!.copyWith(
      color: GlobalManager.colors.colorAccent,
    );

    return RichText(
      maxLines: item.maxLines,
      overflow: TextOverflow.ellipsis,
      textScaleFactor: 1.0,
      textAlign: TextAlign.right,
      text: TextSpan(
        text: "${item.textTitle ?? ""} ",
        style: item.style,
        children: [
          TextSpan(
            text: "                              ${item.textContent ?? ""} ",
            style: styleContent,
          ),
        ],
      ),
    );
  }

  Widget _renderTextInfo(CustomCellTextItem item) {
    if (item.shouldUseRichText! && !checkStringNullOrEmpty(item.textContent)) {
      return _renderRichTextInfo(item);
    }
    return Text(
      item.text ?? "",
      maxLines: item.maxLines,
      overflow: item.overflow,
      textScaleFactor: 1.0,
      textAlign: item.textAlign,
      softWrap: item.softWrap,
      textDirection: item.textDirection,
      locale: item.locale,
      style: item.style,
    );
  }

  Widget _renderAllTitles() {
    List<Widget> widgets = textItems.map((item) {
      return Padding(
        padding: item.padding!,
        child: _renderTextInfo(item),
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _renderAvatarView() {
    if (avatarView != null) {
      return Container(
        alignment: avatarAlignment,
        margin: avatarPadding,
        child: avatarView,
      );
    } else {
      return Container();
    }
  }

  Widget _wrapWidgetForDivider(Widget? element) {
    if (element == null) {
      return Container();
    } else {
      Widget myDivider = Divider(
        color: GlobalManager.colors.grayABABAB,
        height: 1,
        thickness: 0.4,
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Element
          element,
          // Divider
          myDivider
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget smallElement = Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(child: _renderAllTitles()),
          _renderSuffixActions(),
        ],
      ),
    );

    Widget bigElement = Padding(
      padding: padding!,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Avatar view
            _renderAvatarView(),
            // All titles && Suffix actions
            smallElement,
          ],
        ),
      ),
    );

    return TextButton(
      style: TextButton.styleFrom(
        primary: (enableSplashColor!
            ? GlobalManager.colors.majorColor(opacity: 0.1)
            : Colors.transparent),
        textStyle: TextStyle(
            color: (enableSplashColor! ? Colors.white : Colors.transparent)),
        shape: outlinedBorder,
        padding: const EdgeInsets.all(0),
      ),
      onPressed: onPressed,
      child:
          (fullBottomDivider! ? _wrapWidgetForDivider(bigElement) : bigElement),
    );
  }
}
