import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:anpha_petrol_smartgas/widgets/clone_libs/flutter_date_time_picker/src/date_format.dart';
import 'package:anpha_petrol_smartgas/widgets/clone_libs/flutter_date_time_picker/src/date_model.dart';
import 'package:anpha_petrol_smartgas/widgets/clone_libs/flutter_date_time_picker/src/datetime_picker_theme.dart';
import 'package:anpha_petrol_smartgas/widgets/clone_libs/flutter_date_time_picker/src/i18n_model.dart';

typedef DateChangedCallback = Function(DateTime time);
typedef ListDateChangedCallback = Function(List<DateTime> times);
typedef DateCancelledCallback = Function();
typedef StringAtIndexCallBack = String? Function(int index);

class DatePicker {
  ///
  /// Display date picker bottom sheet.
  ///
  static Future<DateTime?> showDatePicker(
    BuildContext context, {
    String? title,
    bool showSubtitle = false,
    bool showTitleActions = true,
    bool showDaysColumns = true,
    DateTime? minTime,
    DateTime? maxTime,
    DateChangedCallback? onChanged,
    required DateChangedCallback onConfirm,
    DateCancelledCallback? onCancel,
    locale = LocaleType.en,
    DateTime? currentTime,
    DatePickerTheme? theme,
    bool? limitChildren,
    int? childCount,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        title: title ?? i18nObjInLocale(locale)!['titlePickDate'].toString(),
        showTitleActions: showTitleActions,
        showSubtitle: showSubtitle,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: DatePickerModel(
          currentTime: currentTime,
          maxTime: maxTime,
          minTime: minTime,
          locale: locale,
          showDaysColumns: showDaysColumns,
          limitChildren: limitChildren,
          childCountParam: childCount,
        ),
      ),
    );
  }

  ///
  /// Display time picker bottom sheet.
  ///
  static Future<DateTime?> showTimePicker(
    BuildContext context, {
    String? title,
    bool showSubtitle = false,
    bool showTitleActions = true,
    bool showSecondsColumn = true,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale = LocaleType.en,
    required DateTime currentTime,
    DatePickerTheme? theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        title: title ??
            i18nObjInLocale(locale)!['titlePickTime']?.toString() ??
            "",
        showTitleActions: showTitleActions,
        showSubtitle: showSubtitle,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: TimePickerModel(
          currentTime: currentTime,
          locale: locale,
          showSecondsColumn: showSecondsColumn,
        ),
      ),
    );
  }

  ///
  /// Display time picker bottom sheet with AM/PM.
  ///
  static Future<DateTime?> showTime12hPicker(
    BuildContext context, {
    String? title,
    bool showSubtitle = false,
    bool showTitleActions = true,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale: LocaleType.en,
    required DateTime currentTime,
    DatePickerTheme? theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        title: title ??
            i18nObjInLocale(locale)!['titlePickTime']?.toString() ??
            "",
        showTitleActions: showTitleActions,
        showSubtitle: showSubtitle,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: Time12hPickerModel(
          currentTime: currentTime,
          locale: locale,
        ),
      ),
    );
  }

  ///
  /// Display date&time picker bottom sheet.
  ///
  static Future<DateTime?> showDateTimePicker(
    BuildContext context, {
    String? title,
    bool showSubtitle = false,
    bool showTitleActions = true,
    DateTime? minTime,
    DateTime? maxTime,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale: LocaleType.en,
    DateTime? currentTime,
    DatePickerTheme? theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        title: title ??
            (i18nObjInLocale(locale)!['titlePickDateTime'] as String?) ??
            "",
        showTitleActions: showTitleActions,
        showSubtitle: showSubtitle,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: DateTimePickerModel(
          currentTime: currentTime,
          minTime: minTime,
          maxTime: maxTime,
          locale: locale,
        ),
      ),
    );
  }

  ///
  /// Display range data picker bottom sheet.
  ///
  static Future<DateTime?> showRangeDatePicker(
    BuildContext context, {
    String? title,
    bool showTitleActions = true,
    DateTime? minTime,
    DateTime? maxTime,
    ListDateChangedCallback? onChanged,
    ListDateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale: LocaleType.en,
    DateTime? currentStartTime,
    DateTime? currentEndTime,
    DatePickerTheme? theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        title: title ??
            (i18nObjInLocale(locale)!['titlePickRangeDate'] as String?) ??
            "",
        showTitleActions: showTitleActions,
        showSubtitle: false,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: RangeDatePickerModel(
          currentStartTime: currentStartTime,
          currentEndTime: currentEndTime,
          minTime: minTime,
          maxTime: maxTime,
          locale: locale,
        ),
      ),
    );
  }

  ///
  /// Display date picker bottom sheet witch custom picker model.
  ///
  static Future<DateTime?> showPicker(
    BuildContext context, {
    String? title,
    bool showTitleActions = true,
    DateChangedCallback? onChanged,
    DateChangedCallback? onConfirm,
    DateCancelledCallback? onCancel,
    locale: LocaleType.en,
    required BasePickerModel pickerModel,
    DatePickerTheme? theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        title: title ??
            (i18nObjInLocale(locale)!['titlePickDateTime'] as String?) ??
            "",
        showTitleActions: showTitleActions,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pickerModel: pickerModel,
      ),
    );
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    this.title = "",
    this.showTitleActions = true,
    this.showSubtitle = false,
    this.onChanged,
    this.onConfirm,
    this.onCancel,
    theme,
    this.barrierLabel = "",
    this.locale = LocaleType.vi,
    RouteSettings? settings,
    pickerModel,
  })  : pickerModel = pickerModel ?? DatePickerModel(),
        theme = theme ?? const DatePickerTheme(),
        super(settings: settings);

  final String title;
  final bool showTitleActions;
  final bool showSubtitle;
  final Function? onChanged;
  final Function? onConfirm;
  final DateCancelledCallback? onCancel;
  final DatePickerTheme theme;
  final LocaleType locale;
  final BasePickerModel pickerModel;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  late AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DatePickerComponent(
        title: title,
        onChanged: onChanged,
        locale: this.locale,
        route: this,
        pickerModel: pickerModel,
      ),
    );
    return InheritedTheme.captureAll(context, bottomSheet);
  }
}

class _DatePickerComponent extends StatefulWidget {
  _DatePickerComponent({
    Key? key,
    required this.route,
    this.title = "",
    this.onChanged,
    this.locale = LocaleType.vi,
    required this.pickerModel,
  }) : super(key: key);

  final String title;

  final Function? onChanged;

  final _DatePickerRoute route;

  final LocaleType locale;

  final BasePickerModel pickerModel;

  @override
  State<StatefulWidget> createState() {
    return _DatePickerState();
  }
}

class _DatePickerState extends State<_DatePickerComponent> {
  late FixedExtentScrollController leftScrollCtrl,
      middleScrollCtrl,
      rightScrollCtrl;

  @override
  void initState() {
    super.initState();
    refreshScrollOffset();
  }

  void refreshScrollOffset() {
    leftScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentLeftIndex());
    middleScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentMiddleIndex());
    rightScrollCtrl = FixedExtentScrollController(
        initialItem: widget.pickerModel.currentRightIndex());
  }

  @override
  Widget build(BuildContext context) {
    DatePickerTheme theme = widget.route.theme;
    return GestureDetector(
      child: AnimatedBuilder(
        animation: widget.route.animation!,
        builder: (BuildContext context, Widget? child) {
          final double bottomPadding = MediaQuery.of(context).padding.bottom;
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(
                widget.route.animation!.value,
                theme,
                showTitleActions: widget.route.showTitleActions,
                showSubtitle: widget.route.showSubtitle,
                bottomPadding: bottomPadding,
              ),
              child: GestureDetector(
                child: Material(
                  color: theme.backgroundColor ?? Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
                  child: _renderPickerView(theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _notifyDateChanged() {
    if (widget.onChanged != null) {
      if (widget.pickerModel.finalTime() != null) {
        widget.onChanged!(widget.pickerModel.finalTime());
      } else if (widget.pickerModel.finalListTime() != null) {
        widget.onChanged!(widget.pickerModel.finalListTime());
      }
    }
  }

  Widget _renderPickerView(DatePickerTheme theme) {
    return Column(
      children: <Widget>[
        if (widget.route.showTitleActions) ...[
          _renderPickerTitle(theme),
        ],
        if (widget.route.showSubtitle) ...[
          _renderPickerSubTitle(theme),
        ],
        _renderItemView(theme),
        _renderBottomActionsView(theme),
      ],
    );
  }

  Widget _renderColumnView(
    ValueKey key,
    DatePickerTheme theme,
    StringAtIndexCallBack? stringAtIndexCB,
    ScrollController? scrollController,
    int layoutProportion,
    ValueChanged<int>? selectedChangedWhenScrolling,
    ValueChanged<int>? selectedChangedWhenScrollEnd,
  ) {
    int? childCount;
    if (widget.pickerModel is DatePickerModel) {
      childCount = (widget.pickerModel as DatePickerModel).childCount;
    }
    return Expanded(
      flex: layoutProportion,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        height: theme.containerHeight,
        decoration: BoxDecoration(color: theme.backgroundColor ?? Colors.white),
        child: NotificationListener(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0 &&
                selectedChangedWhenScrollEnd != null &&
                notification is ScrollEndNotification &&
                notification.metrics is FixedExtentMetrics) {
              final FixedExtentMetrics metrics =
                  notification.metrics as FixedExtentMetrics;
              final int currentItemIndex = metrics.itemIndex;
              selectedChangedWhenScrollEnd(currentItemIndex);
            }
            return false;
          },
          child: Theme(
            data: ThemeData(brightness: Brightness.dark),
            child: ScrollConfiguration(
              behavior: ScrollBehavior().copyWith(overscroll: false),
              child: CupertinoPicker.builder(
                key: key,
                backgroundColor: theme.backgroundColor ?? Colors.white,
                scrollController:
                    scrollController as FixedExtentScrollController?,
                itemExtent: theme.itemHeight,
                onSelectedItemChanged: (int index) {
                  if (selectedChangedWhenScrolling != null) {
                    selectedChangedWhenScrolling(index);
                  }
                },
                useMagnifier: true,
                magnification: 1.1,
                childCount: childCount,
                itemBuilder: (BuildContext context, int index) {
                  if (stringAtIndexCB == null) return null;
                  final content = stringAtIndexCB(index);
                  if (content == null) {
                    return null;
                  }
                  return Container(
                    height: theme.itemHeight,
                    alignment: Alignment.center,
                    child: Text(
                      content,
                      style: theme.itemStyle,
                      textAlign: TextAlign.start,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Title
  Widget _renderPickerTitle(DatePickerTheme theme) {
    return Container(
      height: theme.titleHeight,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: theme.headerColor ?? theme.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      child: Text(
        widget.title,
        style: theme.titleStyle,
      ),
    );
  }

  // Subtitle
  Widget _renderPickerSubTitle(DatePickerTheme theme) {
    return Container(
      height: theme.subTitleHeight,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: theme.headerColor ?? theme.backgroundColor ?? Colors.white,
      ),
      child: Text(
        formatDate(
          widget.pickerModel.finalTime(),
          [DD, ', ', dd, ' ', MM, ' ', yyyy],
          widget.locale,
        ),
        style: theme.subtitleStyle,
      ),
    );
  }

  Widget _renderItemView(DatePickerTheme theme) {
    return Container(
      color: theme.backgroundColor ?? Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: widget.pickerModel.layoutProportions()[0] > 0
                ? _renderColumnView(
                    ValueKey(widget.pickerModel.currentLeftIndex()),
                    theme,
                    widget.pickerModel.leftStringAtIndex,
                    leftScrollCtrl,
                    widget.pickerModel.layoutProportions()[0], (index) {
                    widget.pickerModel.setLeftIndex(index);
                  }, (index) {
                    setState(() {
                      refreshScrollOffset();
                      _notifyDateChanged();
                    });
                  })
                : null,
          ),
          Text(
            widget.pickerModel.leftDivider(),
            style: theme.itemStyle,
          ),
          Container(
            child: widget.pickerModel.layoutProportions()[1] > 0
                ? _renderColumnView(
                    ValueKey(widget.pickerModel.currentLeftIndex()),
                    theme,
                    widget.pickerModel.middleStringAtIndex,
                    middleScrollCtrl,
                    widget.pickerModel.layoutProportions()[1], (index) {
                    widget.pickerModel.setMiddleIndex(index);
                  }, (index) {
                    setState(() {
                      refreshScrollOffset();
                      _notifyDateChanged();
                    });
                  })
                : null,
          ),
          Text(
            widget.pickerModel.rightDivider(),
            style: theme.itemStyle,
          ),
          Container(
            child: widget.pickerModel.layoutProportions()[2] > 0
                ? _renderColumnView(
                    ValueKey(widget.pickerModel.currentMiddleIndex() * 100 +
                        widget.pickerModel.currentLeftIndex()),
                    theme,
                    widget.pickerModel.rightStringAtIndex,
                    rightScrollCtrl,
                    widget.pickerModel.layoutProportions()[2], (index) {
                    widget.pickerModel.setRightIndex(index);
                  }, (index) {
                    setState(() {
                      refreshScrollOffset();
                      _notifyDateChanged();
                    });
                  })
                : null,
          ),
        ],
      ),
    );
  }

  // Bottom View
  Widget _renderBottomActionsView(DatePickerTheme theme) {
    final done = _localeDone();
    final cancel = _localeCancel();
    final _buttonTheme = ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: theme.doneButtonDecoration?.borderRadius ??
            BorderRadius.circular(8.0),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.headerColor ?? theme.backgroundColor ?? Colors.white,
      ),
      margin: EdgeInsets.only(top: 0.5 * theme.bottomActionsSpacing),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: theme.bottomActionsHeight,
              decoration: theme.cancelButtonDecoration ??
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFF26522)),
                  ),
              margin: EdgeInsets.only(left: theme.bottomActionsSpacing),
              child: Theme(
                data: ThemeData(
                  buttonTheme: _buttonTheme,
                  splashFactory: InkRipple.splashFactory,
                ),
                child: MaterialButton(
                  child: Text(
                    '$cancel',
                    style: theme.cancelStyle,
                  ),
                  splashColor: (theme.cancelButtonDecoration?.color ??
                          const Color(0xFFF26522))
                      .withOpacity(0.1),
                  highlightColor: (theme.cancelButtonDecoration?.color ??
                          const Color(0xFFF26522))
                      .withOpacity(0.05),
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.route.onCancel != null) {
                      widget.route.onCancel!();
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: theme.bottomActionsSpacing),
          Expanded(
            child: Container(
              height: theme.bottomActionsHeight,
              margin: EdgeInsets.only(right: theme.bottomActionsSpacing),
              child: Theme(
                data: ThemeData(
                  buttonTheme: _buttonTheme,
                  splashFactory: InkRipple.splashFactory,
                ),
                child: MaterialButton(
                  child: Text(
                    done,
                    style: theme.doneStyle,
                  ),
                  color: theme.doneButtonDecoration?.color ??
                      const Color(0xFFF26522),
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.05),
                  elevation: 0.0,
                  highlightElevation: 0.0,
                  onPressed: () {
                    Navigator.pop(context, widget.pickerModel.finalTime());
                    if (widget.route.onConfirm != null) {
                      if (widget.pickerModel.finalTime() != null) {
                        widget.route.onConfirm!(widget.pickerModel.finalTime());
                      } else if (widget.pickerModel.finalListTime() != null) {
                        widget.route
                            .onConfirm!(widget.pickerModel.finalListTime());
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localeDone() {
    return i18nObjInLocale(widget.locale)!['done']?.toString() ?? "Done";
  }

  String? _localeCancel() {
    return i18nObjInLocale(widget.locale)!['cancel']?.toString() ?? "Cancel";
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(
    this.progress,
    this.theme, {
    this.itemCount,
    this.showTitleActions = true,
    this.showSubtitle = true,
    this.bottomPadding = 0,
  });

  final double progress;
  final int? itemCount;
  final bool showTitleActions;
  final bool showSubtitle;
  final DatePickerTheme theme;
  final double bottomPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = theme.containerHeight +
        theme.bottomActionsHeight +
        1.5 * theme.bottomActionsSpacing;

    if (showTitleActions) {
      maxHeight += theme.titleHeight;
    }

    if (showSubtitle) {
      maxHeight += theme.subTitleHeight;
    }

    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: maxHeight + bottomPadding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
