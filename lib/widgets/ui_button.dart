import 'package:flutter/material.dart';

class UIButton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color color;
  final String text;
  final Color textColor;
  final double textSize;
  final bool enable;
  final Border? border;
  final FontWeight fontWeight;
  final bool enableShadow;
  final BoxShadow? boxShadow;

  UIButton({
    this.width = double.maxFinite,
    this.height = 55,
    this.radius = 5,
    this.onTap,
    this.gradient,
    this.color = Colors.white,
    this.text = "",
    this.textColor = Colors.white,
    this.textSize = 16,
    this.enable = true,
    this.border,
    this.fontWeight = FontWeight.w500,
    this.enableShadow = true,
    this.boxShadow,
  });

  Widget _renderButton() {
    return TextButton(
      onPressed: (this.enable && this.onTap != null) ? this.onTap : () {},
      style: TextButton.styleFrom(
        primary: Color.fromRGBO(0, 0, 0, 0.1),
        padding: EdgeInsets.all(0.0),
        backgroundColor: Colors.transparent,
      ),
      child: Center(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          textScaleFactor: 1.0,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: this.textSize,
            color: this.textColor,
            fontWeight: this.fontWeight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Gradient? gr;
    Color cl;
    if (this.enable) {
      cl = this.color;
      gr = this.gradient;
    } else {
      gr = null;
      cl = Color(0xFFABABAB);
    }

    return Container(
      width: this.width,
      height: this.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cl,
        gradient: gr,
        borderRadius: BorderRadius.circular(this.radius),
        border: this.border,
        boxShadow: (this.enableShadow
            ? [
                this.boxShadow ??
                    BoxShadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 2.0,
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                    )
              ]
            : null),
      ),
      child: _renderButton(),
    );
  }
}

class UIImageButton extends StatelessWidget {
  final Image image;
  final double width;
  final double height;
  final GestureTapCallback? onTap;

  UIImageButton({
    required this.image,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        width: this.width,
        height: this.height,
        child: this.image,
      ),
    );
  }
}
