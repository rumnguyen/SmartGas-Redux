import 'package:flutter/material.dart';

import 'radio_button.dart';
import 'radio_button_builder.dart';
import 'radio_button_text_position.dart';

class RadioGroup<T> extends StatelessWidget {
  /// Creates a [RadioButton] group
  ///
  /// The [groupValue] is the selected value.
  /// The [items] are elements to contruct the group
  /// [onChanged] will called every time a radio is selected. The clouser return the selected item.
  /// [direction] most be horizontal or vertial.
  /// [spacebetween] works only when [direction] is [Axis.vertical] and ignored when [Axis.horizontal].
  /// and represent the space between elements
  /// [horizontalAlignment] works only when [direction] is [Axis.horizontal] and ignored when [Axis.vertical].
  final T groupValue;
  final List<T> items;
  final RadioButtonBuilder Function(T value) itemBuilder;
  final void Function(T?)? onChanged;
  final Axis direction;
  final double spacebetween;
  final MainAxisAlignment horizontalAlignment;
  final Color? activeColor;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final double borderRadius;
  final double marginVertical;
  final double marginHorizontal;
  final bool enableShadow;

  const RadioGroup.builder({
    required this.groupValue,
    required this.onChanged,
    required this.items,
    required this.itemBuilder,
    this.direction = Axis.vertical,
    this.spacebetween = 30,
    this.horizontalAlignment = MainAxisAlignment.spaceBetween,
    this.activeColor,
    this.textStyle,
    this.backgroundColor,
    this.borderRadius = 0,
    this.marginVertical = 0,
    this.marginHorizontal = 0,
    this.enableShadow = false,
  });

  List<Widget> get _group => this.items.map(
        (item) {
          final radioButtonBuilder = this.itemBuilder(item);

          return Container(
              height: this.direction == Axis.vertical ? spacebetween : 40.0,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                boxShadow: enableShadow
                    ? [
                        BoxShadow(
                          offset: Offset(0.0, 0.0),
                          blurRadius: 3.0,
                          color: Color.fromRGBO(33, 57, 112, 0.15),
                        ),
                      ]
                    : null,
              ),
              padding: EdgeInsets.symmetric(vertical: 8.0),
              margin: EdgeInsets.symmetric(
                horizontal: marginHorizontal,
                vertical: marginVertical,
              ),
              child: RadioButton(
                description: radioButtonBuilder.description,
                value: item,
                groupValue: this.groupValue,
                onChanged: this.onChanged,
                textStyle: textStyle,
                textPosition: radioButtonBuilder.textPosition ??
                    RadioButtonTextPosition.right,
                activeColor: activeColor,
                bgColor: backgroundColor,
              ));
        },
      ).toList();

  @override
  Widget build(BuildContext context) => this.direction == Axis.vertical
      ? Column(
          children: _group,
        )
      : Row(
          mainAxisAlignment: this.horizontalAlignment,
          children: _group,
        );
}
