import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheImage extends StatelessWidget {
  final String url;
  final Widget? defaultWidget;
  final double? borderRadius;
  final double? width;
  final double? height;
  final BoxFit? fit;

  CacheImage(
      {Key? key,
      required this.url,
      this.defaultWidget,
      this.borderRadius,
      this.width,
      this.height,
      this.fit = BoxFit.cover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius == null
          ? BorderRadius.zero
          : BorderRadius.circular(borderRadius!),
      child: StreamBuilder(
          stream: DefaultCacheManager().getImageFile(url),
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return defaultWidget == null
                  ? Container(
                      color: Color(0xff71706b),
                      width: width,
                      height: height,
                    )
                  : defaultWidget!;
            } else {
              FileInfo fr = snapshot.data as FileInfo;
              return Image.file(
                fr.file,
                width: width,
                height: height,
                fit: fit,
              );
            }
          }),
    );
  }
}
