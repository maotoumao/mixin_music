import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String label;
  final double fontSize;
  final int color;
  final int backgroundColor;

  Label(
      {Key? key,
      this.label = '',
      this.fontSize = 14,
      this.color = 0xffffffff,
      this.backgroundColor = 0xff000000})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ClipRRect(
        borderRadius: BorderRadius.circular(2 * fontSize),
        child: Container(
            color: Color(backgroundColor),
            padding: EdgeInsets.symmetric(
                vertical: fontSize * 0.25, horizontal: fontSize * 0.5),
            child: Text(
              label,
              style: TextStyle(color: Color(color), fontSize: fontSize),
            )));
  }
}
