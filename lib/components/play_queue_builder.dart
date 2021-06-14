import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';

// 当前播放队列的信息
class PlayQueueBuilder extends StatelessWidget {
  final Function(BuildContext, List<MediaItem>) builder;


  PlayQueueBuilder({Key? key, required this.builder}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AudioService.queueStream,
        builder: (context, snapshot) {
          if(snapshot.data != null) {
            return builder(context, snapshot.data as List<MediaItem>);
          } else {
            return builder(context, []);
          }
        }
    );
  }


}