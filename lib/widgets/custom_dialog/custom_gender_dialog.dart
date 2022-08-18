import 'package:anpha_petrol_smartgas/core/enum_definition.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef SelectedGenderFunction = void Function(GenderType selectedGender);

class _CustomGenderDialog extends StatefulWidget {
  final SelectedGenderFunction selectedGender;
  final GenderType initialGender;

  _CustomGenderDialog({
    required this.selectedGender,
    required this.initialGender,
  });

  @override
  _CustomGenderDialogState createState() => _CustomGenderDialogState();
}

class _CustomGenderDialogState extends State<_CustomGenderDialog> {
  final double _radius = 7.0;
  final double _spacing = 15.0;
  final double _buttonHeight = 50.0;

  /*
    Gender:
      + 0: Unknown (N/A)
      + 1: Male
      + 2: Female
  */
  late GenderType _genderType;

  @override
  void initState() {
    super.initState();
    _genderType = widget.initialGender;
  }

  void _changeGenderType(int index) {
    if (index < 0 || index > 2) index = 0;
    setState(() {
      _genderType = getGenderType(index);
    });
  }

  Widget _renderRow(int genderIndex) {
    String content = genderEnum2String(genderIndex);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          content,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: 1.0,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        (genderIndex == _genderType.index
            ? FaIcon(
                FontAwesomeIcons.check,
                size: 18,
                color: GlobalManager.colors.colorAccent,
              )
            : Container()),
      ],
    );
  }

  Widget _renderGenders() {
    return Padding(
      padding: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Unknown
          SizedBox(
            height: 50,
            child: TextButton(
              style: GlobalManager.styles.defaultTextButtonStyle,
              onPressed: () {
                _changeGenderType(0);
              },
              child: _renderRow(0),
            ),
          ),
          Divider(
            color: GlobalManager.colors.grayABABAB,
            height: 2,
            thickness: 0.4,
          ),
          // Male
          SizedBox(
            height: 50,
            child: TextButton(
              style: GlobalManager.styles.defaultTextButtonStyle,
              onPressed: () {
                _changeGenderType(1);
              },
              child: _renderRow(1),
            ),
          ),
          Divider(
            color: GlobalManager.colors.grayABABAB,
            height: 2,
            thickness: 0.4,
          ),
          // Female
          SizedBox(
            height: 50,
            child: TextButton(
              style: GlobalManager.styles.defaultTextButtonStyle,
              onPressed: () {
                _changeGenderType(2);
              },
              child: _renderRow(2),
            ),
          ),
        ],
      ),
    );
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
      child: Text(
        GlobalManager.strings.chooseGenderTitle!,
        textScaleFactor: 1.0,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _renderDescription() {
    return Container(
      margin: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
        top: 10.0,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        GlobalManager.strings.chooseGenderDescription!,
        textScaleFactor: 1.0,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.justify,
        maxLines: 2,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
          color: Colors.black,
        ),
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
              onPressed: () => pop(context),
              style: GlobalManager.styles.defaultTextButtonStyle,
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
              onPressed: () {
                widget.selectedGender(_genderType);
              },
              style: GlobalManager.styles.defaultTextButtonStyle,
              child: Text(
                GlobalManager.strings.yes!.toUpperCase(),
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      margin: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
      ),
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
          // Description
          _renderDescription(),
          // Genders
          _renderGenders(),
          // Horizontal divider
          Divider(
            color: GlobalManager.colors.grayABABAB,
            height: 1,
            thickness: 1.0,
          ),
          // Button
          _renderButton()
        ],
      ),
    );
  }
}

Future<T?> showCustomGenderDialog<T>(
  BuildContext context, {
  required GenderType initialGender,
  required SelectedGenderFunction selectedGender,
}) async {
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
          child: _CustomGenderDialog(
            selectedGender: selectedGender,
            initialGender: initialGender,
          ),
        ),
      );
    },
  );
}
