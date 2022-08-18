import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class SmallLiteRollingSwitch extends StatefulWidget {
  final bool? value;
  final Function(bool)? onChanged;
  final String? textOff;
  final String? textOn;
  final Color? colorOn;
  final Color? colorOff;
  final double? textSize;
  final Duration? animationDuration;
  final IconData? iconOn;
  final IconData? iconOff;
  final Function? onTap;
  final Function? onDoubleTap;
  final Function? onSwipe;

  const SmallLiteRollingSwitch({
    this.value = false,
    this.textOff = "Off",
    this.textOn = "On",
    this.textSize = 14.0,
    this.colorOn = Colors.green,
    this.colorOff = Colors.red,
    this.iconOff = Icons.flag,
    this.iconOn = Icons.check,
    this.animationDuration = const Duration(milliseconds: 350),
    this.onTap,
    this.onDoubleTap,
    this.onSwipe,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _SmallRollingSwitchState createState() => _SmallRollingSwitchState();
}

class _SmallRollingSwitchState extends State<SmallLiteRollingSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  double value = 0.0;

  late bool turnState;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this,
        lowerBound: 0.0,
        upperBound: 1.0,
        duration: widget.animationDuration);
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
    animationController.addListener(() {
      setState(() {
        value = animation.value;
      });
    });
    turnState = widget.value!;
    _determine();
  }

  @override
  Widget build(BuildContext context) {
    Color? transitionColor = Color.lerp(widget.colorOff, widget.colorOn, value);

    return GestureDetector(
      onDoubleTap: () {
        _action();
        if (widget.onDoubleTap != null) widget.onDoubleTap!();
      },
      onTap: () {
        _action();
        if (widget.onTap != null) widget.onTap!();
      },
      onPanEnd: (details) {
        _action();
        if (widget.onSwipe != null) widget.onSwipe!();
        //widget.onSwipe();
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 45,
        // Raw: 130 -> New value: 45
        height: 25,
        decoration: BoxDecoration(
            color: transitionColor, borderRadius: BorderRadius.circular(50)),
        child: Stack(
          children: <Widget>[
            Transform.translate(
              offset: Offset(10 * value, 0), //original
              child: Opacity(
                opacity: (1 - value).clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.only(right: 2), // Raw: right5
                  alignment: Alignment.centerRight,
                  height: 20, // Raw: 40 -> New value: 20
                  child: Text(
                    widget.textOff!,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.textSize),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(10 * (1 - value), 0), //original
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.only(/*top: 10,*/ left: 2),
                  alignment: Alignment.centerLeft,
                  height: 20, // Raw: 40 -> New value: 20
                  child: Text(
                    widget.textOn!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.textSize,
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset((40 / 2.0).roundToDouble() * value, 0),
              // Raw: 80 * value -> New value: (40/2.0).roundToDouble()
              child: Transform.rotate(
                angle: lerpDouble(0, 2 * pi, value)!,
                child: Container(
                  height: 15,
                  // Raw: 40 -> New value: 15
                  width: 15,
                  // Raw: 40 -> New value: 15
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Opacity(
                          opacity: (1 - value).clamp(0.0, 1.0),
                          child: Icon(
                            widget.iconOff,
                            size: 14, // Icon size
                            color: transitionColor,
                          ),
                        ),
                      ),
                      Center(
                          child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: Icon(
                                widget.iconOn,
                                size: 14, // Icon size
                                color: transitionColor,
                              ))),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _action() {
    _determine(changeState: true);
  }

  _determine({bool changeState = false}) {
    setState(() {
      if (changeState) turnState = !turnState;
      (turnState)
          ? animationController.forward()
          : animationController.reverse();

      widget.onChanged!(turnState);
    });
  }
}
