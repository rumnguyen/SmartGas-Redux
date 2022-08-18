import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:flutter/material.dart';

class _CustomLoadingDialog extends StatelessWidget {
  final double _radius = 7.0;
  final double _spacing = 15.0;
  final double _dialogWidth = 220;
  final double _dialogHeight = 120;
  final String? text;

  _CustomLoadingDialog({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildElement = Container(
      width: _dialogWidth,
      height: _dialogHeight,
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
          ImageCacheManager.getImage(
            url: GlobalManager.images.gifLoading,
            width: 120,
            height: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            text ?? '',
            textScaleFactor: 1.0,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: _buildElement,
    );
  }
}

Future<T?> showCustomLoadingDialog<T>(BuildContext context,
    {String? text = ""}) async {
  if (text == null || text.isEmpty) {
    text = GlobalManager.strings.loading;
  }

  return await showGeneralDialog<T>(
    context: context,
    barrierLabel: "Label",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 500),
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
          child: _CustomLoadingDialog(text: text),
        ),
      );
    },
  );
}
