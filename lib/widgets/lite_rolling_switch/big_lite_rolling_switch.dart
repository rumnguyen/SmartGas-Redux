import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

class BigLiteRollingSwitch extends StatefulWidget {
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

  const BigLiteRollingSwitch({
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
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _BigRollingSwitchState createState() => _BigRollingSwitchState();
}

class _BigRollingSwitchState extends State<BigLiteRollingSwitch>
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
        width: 60, // Raw: 130 -> New value: 60
        decoration: BoxDecoration(
            color: transitionColor, borderRadius: BorderRadius.circular(50)),
        child: Stack(
          children: <Widget>[
            Transform.translate(
              offset: Offset(10 * value, 0), //original
              child: Opacity(
                opacity: (1 - value).clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.only(right: 5), // Raw: right5
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
                  padding: const EdgeInsets.only(/*top: 10,*/ left: 5),
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
              offset: Offset((58 / 1.95).roundToDouble() * value, 0),
              // Raw: 80 * value -> New value: (58/1.95).roundToDouble()
              child: Transform.rotate(
                angle: lerpDouble(0, 2 * pi, value)!,
                child: Container(
                  height: 20,
                  // Raw: 40 -> New value: 20
                  width: 20,
                  // Raw: 40 -> New value: 20
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
                            size: 16,
                            color: transitionColor,
                          ),
                        ),
                      ),
                      Center(
                          child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: Icon(
                                widget.iconOn,
                                size: 16,
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
