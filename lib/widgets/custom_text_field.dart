import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  String hintText;
  TextInputType textInputType;
  bool protectPassword;
  Color borderTextFormFieldColor;
  double textSize = 14.0;
  Widget? suffixIcon;
  BoxConstraints? suffixIconConstraints;
  Widget? prefixIcon;
  TextEditingController textController;
  FocusNode? focusNode;
  Function(String?)? onFieldSubmitted;
  TextInputAction? textInputAction;
  double verticalPadding;
  double horizontalPadding;
  double? height;
  double radius;
  BoxShadow? boxShadow;
  BorderRadiusGeometry? borderRadius;
  Color bgColor;
  bool enable;
  TextAlign textAlign;
  Color textColor;
  VoidCallback? onTap;

  CustomTextField({
    Key? key,
    required this.hintText,
    required this.textController,
    this.textInputType = TextInputType.none,
    this.protectPassword = false,
    this.borderTextFormFieldColor = const Color(0xFFC7C7CC),
    this.textSize = 15.0,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixIconConstraints,
    this.focusNode,
    this.onFieldSubmitted,
    this.textInputAction,
    this.verticalPadding = 16.0,
    this.horizontalPadding = 16.0,
    this.radius = 12,
    this.height,
    this.boxShadow,
    this.borderRadius,
    this.onTap,
    this.bgColor = Colors.white,
    this.enable = true,
    this.textAlign = TextAlign.start,
    this.textColor = const Color(0xFFB5B4B4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget textFieldWidget = TextFormField(
      obscureText: protectPassword,
      keyboardType: textInputType,
      controller: textController,
      focusNode: focusNode,
      enabled: enable,
      onTap: onTap,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      textAlign: textAlign,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        hintStyle: TextStyle(
          color: textColor,
          fontSize: textSize,
          fontWeight: FontWeight.w400,
        ),
        suffixIconConstraints: suffixIconConstraints,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderTextFormFieldColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderTextFormFieldColor),
        ),
      ),
    );

    if (height != null && height! > 0) {
      textFieldWidget = SizedBox(
        height: height,
        child: textFieldWidget,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow != null ? [boxShadow!] : null,
        color: bgColor,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: textFieldWidget,
    );
  }
}
