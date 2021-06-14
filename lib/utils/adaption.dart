import 'package:flutter/material.dart';

class Adaption {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double rpx; // 1rpx
  static late double vw;
  static late double vh;

  // 这里参考了别人的写法
  static void init(BuildContext context, {double designWidth = 750}) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    rpx = screenWidth / designWidth;
    vw = screenWidth / 100;
    vh = screenHeight / 100;
  }
}

extension IntAdaption on int {
  double get rpx => Adaption.rpx * this.toDouble();

  double get vw => Adaption.vw * this.toDouble();

  double get vh => Adaption.vh * this.toDouble();
}


extension DoubleAdaption on double {
  double get rpx => Adaption.rpx * this;

  double get vw => Adaption.vw * this;

  double get vh => Adaption.vh * this;
}
