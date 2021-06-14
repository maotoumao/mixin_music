import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'package:mixinmusic/utils/adaption.dart';
import 'package:mixinmusic/components/cache_image.dart';

class Body extends StatelessWidget {
  final MediaItem mediaItem;

  Body({Key? key, required this.mediaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Center(
            child: CacheImage(
      url: mediaItem.artUri.toString(),
      width: 600.rpx,
      height: 600.rpx,
      borderRadius: 24.rpx,
    )));
  }
}
