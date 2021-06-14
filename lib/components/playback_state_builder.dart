import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

// 当前播放歌曲的信息
class PlaybackStateBuilder extends StatelessWidget {
  final Function(BuildContext, PlaybackState?) builder;


  PlaybackStateBuilder({Key? key, required this.builder}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AudioService.playbackStateStream,
        builder: (context, snapshot) {
          if(snapshot.data != null) {
            return builder(context, snapshot.data as PlaybackState);
          } else {
            return builder(context, null);
          }
        }
    );
  }


}