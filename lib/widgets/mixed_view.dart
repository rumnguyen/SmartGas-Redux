import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MixedView extends StatefulWidget {
  final String? textHint;
  final String? text;
  final Widget? leftIcon;
  final bool? isJustForViewing;
  final TextInputFormatter? formatter;
  final Function()? onPressed;
  final FocusNode? focusNode;
  final Function? onChangedDataCallback;
  final Function? onSubmittedFunction;
  final bool? autoChangeHeightByMultiline;
  final TextEditingController? textController;
  final bool? enableSuffixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final double? borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final EdgeInsets? viewPadding;
  final EdgeInsets? textPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final double? height;
  final double? width;
  final TextAlign? textAlign;
  final BorderRadiusGeometry? borderRadius;
  final BoxShadow? boxShadow;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final bool? autoFocus;
  final bool? obscureText;

  MixedView({
    this.text,
    this.textHint,
    this.leftIcon,
    this.isJustForViewing = false,
    this.formatter,
    this.onPressed,
    this.focusNode,
    this.onChangedDataCallback,
    this.onSubmittedFunction,
    this.autoChangeHeightByMultiline = false,
    this.textController,
    this.enableSuffixIcon = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines = 1,
    this.borderWidth = 1,
    this.borderColor,
    this.backgroundColor,
    this.margin = const EdgeInsets.all(0),
    this.viewPadding = const EdgeInsets.only(
      left: 10,
      right: 10,
    ),
    this.textPadding = const EdgeInsets.all(0),
    this.textStyle,
    this.hintStyle,
    this.height,
    this.width,
    this.textAlign = TextAlign.left,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(5.0),
    ),
    this.boxShadow,
    this.textInputType = TextInputType.text,
    this.textInputAction,
    this.autoFocus = false,
    this.obscureText = false,
  });

  @override
  _MixedViewState createState() => _MixedViewState();
}

class _MixedViewState extends State<MixedView> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  FocusNode? _focusNode;
  double? _height;

  @override
  void initState() {
    super.initState();
    _initPrivateData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initPrivateData() {
    // Common variables
    _height = widget.height;

    // FocusNode
    _focusNode = widget.focusNode;
    _focusNode ??= FocusNode();

    // Text & TextController
    if (!checkStringNullOrEmpty(widget.text)) {
      if (widget.textController == null) {
        _textController = TextEditingController();
      } else {
        _textController = widget.textController!;
      }
      _textController.text = widget.text!;
    }
  }

  void _onChangedDataFunction(String data) async {
    if (widget.onChangedDataCallback != null) {
      widget.onChangedDataCallback!(data);
    }

    if (widget.height != null && widget.autoChangeHeightByMultiline!) {
      if (data.contains("\n") && _height != null) {
        setState(() {
          _height = null;
        });
      } else if (!data.contains("\n") && _height == null) {
        setState(() {
          _height = widget.height;
        });
      }
    }
  }

  void _onSubmittedFunction(String data) async {
    if (widget.onSubmittedFunction != null) {
      widget.onSubmittedFunction!(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color grayCCCCCC = GlobalManager.colors.grayCCCCCC;
    Color grayF1F1F1 = GlobalManager.colors.grayF1F1F1;
    Color gray808080 = GlobalManager.colors.gray808080;
    Color majorColor = GlobalManager.colors.majorColor();
    Color bgColor;
    if (widget.backgroundColor != null) {
      bgColor = widget.backgroundColor!;
    } else if (widget.isJustForViewing! && widget.onPressed == null) {
      bgColor = grayF1F1F1;
    } else {
      bgColor = Colors.transparent;
    }

    return Container(
      height: _height,
      width: widget.width,
      margin: widget.margin,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: (widget.borderColor != null
              ? widget.borderColor!
              : (widget.isJustForViewing! && widget.onPressed == null)
                  ? Colors.transparent
                  : grayCCCCCC),
          width: widget.borderWidth!,
        ),
        color: bgColor,
        boxShadow: widget.boxShadow != null ? [widget.boxShadow!] : null,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: widget.viewPadding,
          primary: majorColor.withOpacity(0.1),
          textStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius!,
          ),
        ),
        onPressed: widget.onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (widget.leftIcon != null) ? widget.leftIcon! : Container(),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: (widget.leftIcon != null ? 8 : 0),
                  right: (widget.enableSuffixIcon! && widget.suffixIcon != null
                      ? 5
                      : 0),
                ),
                child: TextField(
                  key: _globalKey,
                  obscureText: widget.obscureText ?? false,
                  autofocus: widget.autoFocus!,
                  controller: widget.textController,
                  enabled: !widget.isJustForViewing!,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: widget.textInputAction,
                  keyboardType: widget.textInputType ?? TextInputType.text,
                  textAlign: widget.textAlign!,
                  style: widget.textStyle ??
                      const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                  cursorColor: gray808080,
                  inputFormatters:
                      (widget.formatter == null ? [] : [widget.formatter!]),
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  onChanged: (data) => _onChangedDataFunction(data),
                  onSubmitted: (data) => _onSubmittedFunction(data),
                  decoration: InputDecoration(
                    isDense: true,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    hintText: widget.textHint,
                    contentPadding: widget.textPadding,
                    hintStyle: widget.hintStyle ??
                        const TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                        ),
                  ),
                ),
              ),
            ),
            (widget.enableSuffixIcon! && widget.suffixIcon != null
                ? widget.suffixIcon!
                : Container()),
          ],
        ),
      ),
    );
  }
}
