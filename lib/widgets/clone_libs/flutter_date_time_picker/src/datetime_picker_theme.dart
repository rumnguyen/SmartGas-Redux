import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Migrate DiagnosticableMixin to Diagnosticable until
// https://github.com/flutter/flutter/pull/51495 makes it into stable (v1.15.21)
class DatePickerTheme with DiagnosticableTreeMixin {
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle cancelStyle;
  final TextStyle doneStyle;
  final TextStyle itemStyle;
  final Color? backgroundColor;
  final Color? headerColor;

  final double containerHeight;
  final double titleHeight;
  final double subTitleHeight;
  final double itemHeight;
  final double bottomActionsHeight = 48.0;
  final double bottomActionsSpacing = 24.0;

  final BoxDecoration? cancelButtonDecoration;
  final BoxDecoration? doneButtonDecoration;

  const DatePickerTheme({
    this.titleStyle = const TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    this.subtitleStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
    this.cancelStyle = const TextStyle(
      color: Color(0xFFF26522),
      fontSize: 16,
    ),
    this.doneStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    this.itemStyle = const TextStyle(
      color: Color(0xFF000046),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    this.backgroundColor = Colors.white,
    this.headerColor,
    this.containerHeight = 210.0,
    this.titleHeight = 44.0,
    this.subTitleHeight = 32.0,
    this.itemHeight = 40.0,
    this.cancelButtonDecoration,
    this.doneButtonDecoration,
  });
}
