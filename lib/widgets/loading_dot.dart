import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/widgets/nuts_activity_indicator.dart';
import 'package:flutter/material.dart';

class LoadingDot extends StatelessWidget {
  const LoadingDot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: GlobalManager.colors.majorColor(),
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final bool? isCenter;
  final double? radius;
  final Color? color;

  const LoadingIndicator({
    this.isCenter = true,
    this.radius = 15.0,
    this.color = const Color(0xFF223771),
    Key? key,
  }) : assert(isCenter != null), super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget indicator = NutsActivityIndicator(
      activeColor: color ?? GlobalManager.colors.majorColor(),
      inactiveColor: color?.withOpacity(0.6) ?? GlobalManager.colors.majorColor(opacity: 0.6),
      tickCount: 12,
      relativeWidth: 0.8,
      radius: radius!,
    );

    if (isCenter == true) {
      return Center(
        child: indicator,
      );
    }

    return indicator;
  }
}
