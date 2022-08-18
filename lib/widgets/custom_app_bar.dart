import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final int maxLines;
  final TextStyle? titleStyle;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Brightness brightness;
  final bool automaticallyImplyLeading;
  final bool enableLeadingIcon;
  final bool centerTitle;
  final Widget? leadingWidget;
  final Function()? leadingFunction;
  final String leadingIconUrl;
  final Color leadingIconColor;
  final double elevation;
  final Color? backgroundColor;

  CustomAppBar({
    this.title = "",
    this.maxLines = 1,
    this.titleStyle,
    this.titleWidget,
    this.actions,
    this.brightness = Brightness.dark,
    this.automaticallyImplyLeading = false,
    this.enableLeadingIcon = true,
    this.centerTitle = true,
    this.leadingWidget,
    this.leadingFunction,
    this.leadingIconUrl = "",
    this.leadingIconColor = Colors.white,
    this.elevation = 3,
    this.backgroundColor,
  });

  Widget? _renderAppBarTitle() {
    if (titleWidget != null) {
      return titleWidget!;
    }

    if (title == null) {
      return null;
    }

    return Text(
      title!,
      overflow: TextOverflow.ellipsis,
      textScaleFactor: 1.0,
      maxLines: maxLines,
      style: titleStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget? _renderLeadingIcon(BuildContext context, Color color) {
    if (!enableLeadingIcon) {
      return null;
    }

    if (leadingWidget != null) {
      return leadingWidget;
    }

    return TextButton(
      onPressed: () {
        if (leadingFunction != null) {
          leadingFunction!();
        } else {
          pop(context);
        }
      },
      child: (leadingIconUrl.isEmpty
          ? FaIcon(
              FontAwesomeIcons.solidCircleLeft,
              size: 20,
              color: leadingIconColor,
            )
          : ImageCacheManager.getImage(
              url: leadingIconUrl,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            )),
    );
  }

  Widget _renderColorAppBar(BuildContext context) {
    Color majorColor = GlobalManager.colors.majorColor();
    Color backgroundColor = majorColor;
    if (this.backgroundColor != null) {
      backgroundColor = backgroundColor;
    }

    return AppBar(
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      titleSpacing: 0,
      title: _renderAppBarTitle(),
      actions: actions,
      elevation: elevation,
      leading: _renderLeadingIcon(context, majorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _renderColorAppBar(context);
  }

  @override
  Size get preferredSize => Size.fromHeight(
        GlobalManager.appRatio.appBarHeight!,
      );
}
