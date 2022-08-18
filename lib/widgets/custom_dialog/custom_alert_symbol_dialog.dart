import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:flutter/material.dart';

/*
  EXAMPLE HOW TO USE THIS DIALOG

  var dialogContext = navigatorKey.currentState.overlay.context;
  showCustomAlertSymbolDialog(
    dialogContext,
    title:
        "Thông báo Thông báo Thông báo Thông báo Thông báo Thông báo Thông báo Thông báo Thông báo",
    content:
        "Đã quá thời gian, phụ huynh của học sinh Nguyễn Sư Phước vẫn chưa xác nhận thông tin con về đến nhà. Vui lòng liên hệ lại để xác nhận",
    firstButtonText: "Gọi phụ huynh".toUpperCase(),
    firstButtonFunction: () => pop(dialogContext),
    secondButtonText: GlobalManager.strings.close.toUpperCase(),
    secondButtonFunction: () => pop(dialogContext),
    symbol: Container(
      width: 60,
      height: 60,
      margin: EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.all(
          Radius.circular(100),
        ),
      ),
    ),
    willPopScopeFunctionCallback: () async {
      return false;
    },
  );
*/

typedef CheckBoxOnChangedFunctionCallback = void Function(bool status);
typedef WillPopScopeFunctionCallback = Future<bool> Function();

class _CustomAlertSymbolDialog extends StatefulWidget {
  _CustomAlertSymbolDialog({
    Key? key,
    this.symbol,
    required this.title,
    required this.content,
    required this.firstButtonText,
    required this.firstButtonFunction,
    this.secondButtonText = "",
    this.secondButtonFunction,
    this.willPopScopeFunctionCallback,
    this.enableCheckBox = false,
    this.checkBoxValue = false,
    this.checkBoxTitle = "",
    this.checkBoxOnChanged,
  })  : assert(title != null &&
            content != null &&
            firstButtonText != null &&
            firstButtonFunction != null &&
            secondButtonText != null &&
            title.isNotEmpty &&
            content.isNotEmpty &&
            firstButtonText.isNotEmpty &&
            enableCheckBox != null &&
            checkBoxTitle != null),
        super(key: key);

  final Widget? symbol;
  final String? title;
  final String? content;
  final String? firstButtonText;
  final Function? firstButtonFunction;
  final String? secondButtonText;
  final Function? secondButtonFunction;
  final WillPopScopeFunctionCallback? willPopScopeFunctionCallback;

  final bool? enableCheckBox;
  final bool? checkBoxValue;
  final String? checkBoxTitle;
  final CheckBoxOnChangedFunctionCallback? checkBoxOnChanged;

  @override
  _CustomAlertSymbolDialogState createState() =>
      _CustomAlertSymbolDialogState();
}

class _CustomAlertSymbolDialogState extends State<_CustomAlertSymbolDialog> {
  final double _radius = 10;
  final double _spacing = 15.0;
  final double _bigSpacing = 20.0;
  final double _buttonHeight = 50.0;

  late bool _checkBoxValue;

  @override
  void initState() {
    super.initState();
    _checkBoxValue = widget.checkBoxValue!;
  }

  void _checkBoxOnChanged(status) {
    setState(() {
      _checkBoxValue = status;
    });

    if (widget.checkBoxOnChanged != null) {
      widget.checkBoxOnChanged!(status);
    }
  }

  Widget _renderTitle() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(
        _spacing,
        0,
        _spacing,
        _spacing,
      ),
      child: Text(
        widget.title ?? '',
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
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
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(
        _bigSpacing,
        0,
        _bigSpacing,
        _spacing,
      ),
      child: Text(
        widget.content ?? '',
        textScaleFactor: 1.0,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.justify,
        softWrap: true,
        maxLines: 100,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _renderCheckBox() {
    if (!widget.enableCheckBox!) {
      return Container();
    }

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(
        _bigSpacing,
        0,
        _bigSpacing,
        _spacing,
      ),
      child: GestureDetector(
        onTap: () {
          _checkBoxOnChanged(!_checkBoxValue);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 10),
              child: Checkbox(
                activeColor: GlobalManager.colors.colorAccent,
                checkColor: Colors.white,
                value: _checkBoxValue,
                onChanged: _checkBoxOnChanged,
              ),
            ),
            Text(
              widget.checkBoxTitle ?? '',
              textScaleFactor: 1.0,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              softWrap: true,
              maxLines: 2,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
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
                    onPressed: () => widget.secondButtonFunction!(),
                    style: GlobalManager.styles.defaultTextButtonStyleWithShape,
                    child: Text(
                      widget.secondButtonText ?? '',
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
              onPressed: () => widget.firstButtonFunction!(),
              style: TextButton.styleFrom(
                primary: GlobalManager.colors.majorColor(opacity: 0.1),
                textStyle: const TextStyle(color: Colors.white),
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: (!_existSecondButton
                        ? Radius.circular(_radius)
                        : const Radius.circular(0.0)),
                    bottomRight: Radius.circular(_radius),
                  ),
                ),
              ),
              child: Text(
                widget.firstButtonText ?? '',
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

  @override
  Widget build(BuildContext context) {
    bool _existSecondButton = false;
    if (widget.secondButtonText!.isNotEmpty &&
        widget.secondButtonFunction != null) {
      _existSecondButton = true;
    }

    Widget _buildElement = Container(
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(_radius),
        ),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Symbol
          widget.symbol!,
          // Title
          _renderTitle(),
          // Content
          _renderContent(),
          // Check box
          _renderCheckBox(),
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
      child: _buildElement,
      onWillPop: widget.willPopScopeFunctionCallback,
    );
  }
}

Future<T?> showCustomAlertSymbolDialog<T>(
  BuildContext context, {
  Key? key,
  Widget? symbol,
  required String? title,
  required String? content,
  required String? firstButtonText,
  required Function? firstButtonFunction,
  secondButtonText = "",
  secondButtonFunction,
  WillPopScopeFunctionCallback? willPopScopeFunctionCallback,
  bool enableCheckBox = false,
  bool checkBoxValue = false,
  String? checkBoxTitle = "",
  CheckBoxOnChangedFunctionCallback? checkBoxOnChanged,
}) async {
  symbol ??= Container();

  willPopScopeFunctionCallback ??= () async {
    return true;
  };

  return await showGeneralDialog(
    context: context,
    barrierLabel: "Label",
    barrierDismissible: true,
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
          child: _CustomAlertSymbolDialog(
            symbol: symbol,
            title: title,
            content: content,
            firstButtonText: firstButtonText,
            firstButtonFunction: firstButtonFunction,
            secondButtonText: secondButtonText,
            secondButtonFunction: secondButtonFunction,
            willPopScopeFunctionCallback: willPopScopeFunctionCallback,
            enableCheckBox: enableCheckBox,
            checkBoxValue: checkBoxValue,
            checkBoxTitle: checkBoxTitle,
            checkBoxOnChanged: checkBoxOnChanged,
          ),
        ),
      );
    },
  );
}
