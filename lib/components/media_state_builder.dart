import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

// 当前播放歌曲的信息
class MediaPositionBuilder extends StatelessWidget {
  final Function(BuildContext, Duration) builder;

  MediaPositionBuilder({Key? key, required this.builder}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AudioService.positionStream,
        builder: (context, snapshot) {
          if(snapshot.data != null) {
            return builder(context, snapshot.data as Duration);
          } else {
            return builder(context,  Duration.zero);
          }
        }
    );
  }


}


// 当前播放歌曲的信息
class CurrentMediaBuilder extends StatelessWidget {
  final Function(BuildContext, MediaItem?) builder;


  CurrentMediaBuilder({Key? key, required this.builder}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AudioService.currentMediaItemStream,
        builder: (context, snapshot) {
          if(snapshot.data != null) {
            return builder(context, snapshot.data as MediaItem);
          } else {
            return builder(context, null);
          }
        }
    );
  }


}