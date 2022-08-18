import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/models/o_object_filter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class _CustomSelectionDialog extends StatefulWidget {
  final List<ObjectFilter> objects;
  final String? title;
  final String? description;
  final int selectedIndex;
  final bool enableObjectIcon;
  final bool enableScrollBar;
  final bool alwaysShowScrollBar;
  final String positiveText;

  const _CustomSelectionDialog(
    this.objects,
    this.title,
    this.description,
    this.selectedIndex,
    this.enableObjectIcon,
    this.enableScrollBar,
    this.alwaysShowScrollBar,
    this.positiveText,
  ) : assert(selectedIndex < objects.length);

  @override
  _CustomSelectionDialogState createState() => _CustomSelectionDialogState();
}

class _CustomSelectionDialogState extends State<_CustomSelectionDialog> {
  final double _radius = 7.0;
  final double _spacing = 15.0;
  final double _buttonHeight = 50.0;
  final ScrollController _scrollController = ScrollController();

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _renderRow(int index, bool isSelected) {
    ObjectFilter filterItem = widget.objects[index];
    return SizedBox(
      height: 50,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(0),
          splashFactory: InkRipple.splashFactory,
          textStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {
          _changeSelected(index);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  (widget.enableObjectIcon
                      ? Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: ImageCacheManager.getImage(
                            url: filterItem.iconURL,
                            width: filterItem.iconSize,
                            height: filterItem.iconSize,
                          ),
                        )
                      : Container()),
                  Expanded(
                    child: Text(
                      filterItem.name ?? "",
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 1.0,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (isSelected
                ? FaIcon(
                    FontAwesomeIcons.check,
                    size: 18,
                    color: GlobalManager.colors.majorColor(),
                  )
                : Container()),
          ],
        ),
      ),
    );
  }

  Widget _renderObjects() {
    int size = widget.objects.length;
    Widget _buildElement = ListView.builder(
      shrinkWrap: true,
      itemCount: size,
      physics: const NeverScrollableScrollPhysics(),
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
      ),
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _renderRow(index, _selectedIndex == index),
            (index < size - 1
                ? Divider(
                    color: GlobalManager.colors.grayABABAB,
                    height: 2,
                    thickness: 0.4,
                  )
                : Container()),
          ],
        );
      },
    );

    double extendRightPadding = 0;
    if (widget.enableScrollBar) {
      extendRightPadding = 4;
      _buildElement = CupertinoScrollbar(
        isAlwaysShown: widget.alwaysShowScrollBar,
        controller: _scrollController,
        child: _buildElement,
      );
    }

    return Container(
//      constraints: BoxConstraints(maxHeight: 250),
      padding: EdgeInsets.only(right: extendRightPadding),
      child: _buildElement,
    );
  }

  Widget _renderDescription() {
    if (checkStringNullOrEmpty(widget.description)) return Container();
    return Container(
      margin: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
        top: 10.0,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        widget.description ?? "",
        textScaleFactor: 1.0,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: GlobalManager.colors.gray586575,
        ),
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
        widget.title ?? "",
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
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(0),
                splashFactory: InkRipple.splashFactory,
                textStyle: const TextStyle(
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(_radius),
                  ),
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
              onPressed: () {
                int? selectedIndex;
                if (_selectedIndex != widget.selectedIndex) {
                  selectedIndex = _selectedIndex;
                }
                pop(context, object: selectedIndex);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(0),
                splashFactory: InkRipple.splashFactory,
                textStyle: const TextStyle(
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(_radius),
                  ),
                ),
              ),
              child: Text(
                widget.positiveText.toUpperCase(),
                textScaleFactor: 1.0,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: GlobalManager.colors.majorColor(),
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
      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 450),
      margin: EdgeInsets.only(
        left: _spacing,
        right: _spacing,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(_radius)),
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Title
                _renderTitle(),
                // Description
                _renderDescription(),
                const SizedBox(
                  height: 8,
                ),
                // Objects
                _renderObjects(),
                SizedBox(
                  height: _buttonHeight + 8,
                ),
                // Button
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: GlobalManager.colors.grayABABAB,
                  width: 0.8,
                ),
              ),
            ),
            child: _renderButton(),
          )
        ],
      ),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: _buildElement,
      onNotification: (overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
    );
  }
}

Future<T?> showCustomSelectionDialog<T>(
  BuildContext context,
  List<ObjectFilter> objectFilterList,
  int selectedIndex, {
  String? title,
  String? description,
  bool? enableObjectIcon = false,
  bool? enableScrollBar = false,
  bool? alwaysShowScrollBar = false,
  String? positiveButtonText,
}) async {
  enableObjectIcon ??= false;

  enableScrollBar ??= false;

  alwaysShowScrollBar ??= false;

  positiveButtonText ??= GlobalManager.strings.yes;

  return await showGeneralDialog<T>(
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
          child: _CustomSelectionDialog(
            objectFilterList,
            title,
            description,
            selectedIndex,
            enableObjectIcon!,
            enableScrollBar!,
            alwaysShowScrollBar!,
            positiveButtonText!,
          ),
        ),
      );
    },
  );
}
