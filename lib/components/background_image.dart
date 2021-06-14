import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mixinmusic/components/cache_image.dart';

class BackgroundImage extends StatelessWidget {
  final String? url;
  final Widget child;
  final int shadeLevel; // 1-9
  final double blur;
  final double opacity;

  BackgroundImage(
      {Key? key,
      this.url,
      required this.child,
      this.shadeLevel = 5,
      this.blur = 5,
      this.opacity = 0.6})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景图
        ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration:
              BoxDecoration(color: Colors.grey[this.shadeLevel * 100]),
              child: Opacity(
                opacity: opacity,
                child: CacheImage(url: url ?? '', width: double.infinity, height: double.infinity,),
              ),
            )),
        // 子组件
        SafeArea(child: child)
      ],
    );
  }
}
