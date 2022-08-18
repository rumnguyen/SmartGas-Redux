import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:flutter/cupertino.dart';

class ActiveDot extends StatelessWidget {
  final EdgeInsets? padding;
  final double? dotSize;
  final Color? color;

  const ActiveDot({
    this.padding = const EdgeInsets.all(0.0),
    this.dotSize = 8,
    this.color,
    Key? key,
  }) : assert(padding != null && dotSize != null && dotSize > 0), super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? dotColor = color ?? GlobalManager.colors.colorAccent;

    return Container(
      width: dotSize,
      height: dotSize,
      margin: padding,
      decoration: BoxDecoration(
        color: dotColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: dotColor,
            offset: const Offset(0.0, 2.0),
            blurRadius: 1.0,
          ),
        ],
      ),
    );
  }
}
