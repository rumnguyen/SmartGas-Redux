import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/toast_utils.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

typedef SubmitNoteFunctionCallback = Future<void> Function(String);

class _CustomNoteDialog extends StatefulWidget {
  final SubmitNoteFunctionCallback? submitFunction;
  final String? title;
  final String? hint;
  final int maxLines;
  final String positiveText;
  final String? errorEmptyText;

  const _CustomNoteDialog({
    this.submitFunction,
    required this.title,
    required this.hint,
    this.maxLines = 1,
    required this.positiveText,
    this.errorEmptyText,
  });

  @override
  _CustomNoteDialogState createState() => _CustomNoteDialogState();
}

class _CustomNoteDialogState extends State<_CustomNoteDialog> {
  final double _radius = 7.0;
  final double _spacing = 15.0;
  final double _buttonHeight = 50;
  final TextEditingController _contentTextController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  void _submitDialog() {
    FocusScope.of(context).unfocus();

    String content = _contentTextController.text;
    if (content.isEmpty) {
      String? text = widget.errorEmptyText;
      if (checkStringNullOrEmpty(text)) {
        text = widget.title != null
            ? widget.title! + ' ' + GlobalManager.strings.doNotEmpty!
            : GlobalManager.strings.feedbackSubjectOrContentIsEmpty!;
      }
      showToastDefault(
        msg: text!,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (widget.submitFunction != null) {
      widget.submitFunction!(content);
    }
  }

  Widget _renderTitle() {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_radius),
          topRight: Radius.circular(_radius),
        ),
        color: GlobalManager.colors.grayF0F0F0,
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
          text: widget.title ?? GlobalManager.strings.note!,
          children: [
            TextSpan(
              text:' *',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: GlobalManager.colors.redEC1E37,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderContentTextArea() {
    return Container(
      margin: EdgeInsets.only(
        top: _spacing,
        left: _spacing,
        right: _spacing,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              SystemChannels.textInput.invokeMethod('TextInput.show');
              _contentFocusNode.requestFocus();
            },
            child: Container(
              height: _buttonHeight * 1.5,
              width: double.infinity,
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 7.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(
                  width: 1.0,
                  color: GlobalManager.colors.grayCCCCCC,
                ),
              ),
              child: TextField(
                controller: _contentTextController,
                focusNode: _contentFocusNode,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                textCapitalization: TextCapitalization.sentences,
                cursorColor: GlobalManager.colors.gray808080,
                maxLines: null,
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: widget.hint ?? GlobalManager.strings.noteHint!,
                  contentPadding: const EdgeInsets.only(bottom: 0),
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderButton() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: _buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_radius),
              ),
              color: Colors.white,
            ),
            child: TextButton(
              onPressed: () => pop(context, object: null),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(0),
                splashFactory: InkRipple.splashFactory,
                textStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),
              child: Text(
                GlobalManager.strings.cancel!.toUpperCase(),
                textScaleFactor: 1.0,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 1,
          height: _buttonHeight,
          child: VerticalDivider(
            color: GlobalManager.colors.grayABABAB,
            thickness: 1.0,
          ),
        ),
        Expanded(
          child: Container(
            height: _buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(_radius),
              ),
              color: Colors.white,
            ),
            child: TextButton(
              onPressed: () => _submitDialog(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(0),
                splashFactory: InkRipple.splashFactory,
                textStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),
              child: Text(
                widget.positiveText.toUpperCase(),
                textScaleFactor: 1.0,
                style: TextStyle(
                  fontSize: 14,
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
    Widget _buildElement = Container(
      constraints: const BoxConstraints(maxWidth: 320),
      margin: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title
            _renderTitle(),
            // Content
            _renderContentTextArea(),
            // Spacing
            const SizedBox(height: 15.0),
            // Horizontal divider
            Divider(
              color: GlobalManager.colors.grayABABAB,
              height: 1,
              thickness: 1.0,
            ),
            // Button
            _renderButton(),
          ],
        ),
      ),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
        child: _buildElement,
        onNotification: (overScroll) {
          overScroll.disallowIndicator();
          return false;
        });
  }
}

Future<T?> showCustomNoteDialog<T>(
  BuildContext context, {
  String? title,
  String? hint,
  String? errorEmptyText,
  int maxLines = 1,
  SubmitNoteFunctionCallback? submitFunction,
  bool barrierDismissible = true,
  String? positiveText,
}) async {
  if (checkStringNullOrEmpty(positiveText)) {
    positiveText = GlobalManager.strings.yes;
  }
  return await showGeneralDialog(
    context: context,
    barrierLabel: "Label",
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(anim1),
        child: child,
      );
    },
    pageBuilder: (context, anim1, anim2) {
      return Material(
        type: MaterialType.transparency,
        child: Container(
          alignment: Alignment.center,
          margin: MediaQuery.of(context).viewInsets,
          child: _CustomNoteDialog(
            submitFunction: submitFunction,
            title: title,
            hint: hint,
            maxLines: maxLines,
            positiveText: positiveText!,
            errorEmptyText: errorEmptyText,
          ),
        ),
      );
    },
  );
}
