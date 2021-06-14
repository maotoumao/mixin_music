import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mixinmusic/components/modal_function.dart';
import 'package:mixinmusic/components/playback_state_builder.dart';
import 'package:mixinmusic/router/router.dart';
import 'package:mixinmusic/utils/adaption.dart';
import 'package:sprintf/sprintf.dart';
import 'package:mixinmusic/components/media_state_builder.dart';

class PlayBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () {
      RouterController.navigateToSongPage(context);
    }, child: CurrentMediaBuilder(builder: (context, mediaItem) {
      if (mediaItem == null) {
        return Container();
      }
      return Container(
          height: 125.rpx,
          color: Color(0x66c1b2a3),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.rpx),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: RichText(
                  text: TextSpan(
                      text: mediaItem.title,
                      style: TextStyle(color: Color(0xff000000)),
                      children: [
                        TextSpan(
                          text: sprintf(' - %s', [mediaItem.artist]),
                          style: TextStyle(
                              color: Color(0xff666666), fontSize: 24.rpx),
                        ),
                      ]),
                  overflow: TextOverflow.ellipsis,
                )),
                PlaybackStateBuilder(builder: (context, playbackState) {
                  final bool playing = playbackState?.playing ?? false;
                  IconData icon;
                  if (playing) {
                    icon = Icons.pause;
                  } else {
                    icon = Icons.play_arrow;
                  }
                  return GestureDetector(
                      onTap: () {
                        if (playing) {
                          AudioService.pause();
                        } else {
                          AudioService.play();
                        }
                      },
                      child: Icon(
                        icon,
                        size: 36,
                      ));
                }),
                SizedBox(
                  width: 32.rpx,
                ),
                GestureDetector(
                  onTap: () {
                    Modal.showPlayQueue(context);
                  },
                  child: Icon(
                    Icons.playlist_play,
                    size: 75.rpx,
                  ),
                ),
              ],
            ),
          ));
    }));
  }
}

//class PlayBar extends StatelessWidget {
//  Stream<MediaState> get _mediaStateStream =>
//      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
//          AudioService.currentMediaItemStream,
//          AudioService.positionStream,
//          (mediaItem, position) => MediaState(mediaItem, position));
//
//  @override
//  Widget build(BuildContext context) {
//    return GestureDetector(
//      onTap: () {
//        RouterController.navigateToSongPage(context);
//      },
//      child: StreamBuilder(
//        stream: _mediaStateStream,
//        builder: (context, snapshot) {
//          if (snapshot.hasData) {
//            final data = snapshot.data as MediaState;
//            final MediaItem? mediaItem = data.mediaItem;
//
//            if (mediaItem != null) {
//              return Container(
//                  height: 60,
//                  color: Color(0x66c1b2a3),
//                  child: Padding(
//                    padding: EdgeInsets.symmetric(horizontal: 15),
//                    child: Row(
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      children: [
//                        Expanded(
//                            child: RichText(
//                          text: TextSpan(
//                              text: mediaItem.title,
//                              style: TextStyle(color: Color(0xff000000)),
//                              children: [
//                                TextSpan(
//                                  text: sprintf(' - %s', [mediaItem.artist]),
//                                  style: TextStyle(
//                                      color: Color(0xff666666), fontSize: 12),
//                                ),
//                              ]),
//                          overflow: TextOverflow.ellipsis,
//                        )),
//                        GestureDetector(
//                            onTap: () {
//                              print('按钮');
//                            },
//                            onTapCancel: () {
//                              print('canceled');
//                            },
//                            child: StreamBuilder(
//                              stream: AudioService.playbackStateStream
//                                  .map((state) => state.playing)
//                                  .distinct(),
//                              builder: (context, snapshot) {
//                                final playing =
//                                    (snapshot.data ?? false) as bool;
//                                IconData icon;
//                                if (playing) {
//                                  icon = Icons.pause;
//                                } else {
//                                  icon = Icons.play_arrow;
//                                }
//                                return GestureDetector(
//                                    onTap: () {
//                                      if (playing) {
//                                        AudioService.pause();
//                                      } else {
//                                        AudioService.play();
//                                      }
//                                    },
//                                    child: Icon(
//                                      icon,
//                                      size: 36,
//                                    ));
//                              },
//                            )),
//                        SizedBox(
//                          width: 15,
//                        ),
//                        GestureDetector(
//                          onTap: () {
//                            Modal.showPlayQueue(context);
//                          },
//                          child: Icon(
//                            Icons.playlist_play,
//                            size: 36,
//                          ),
//                        ),
//                      ],
//                    ),
//                  ));
//            }
//          }
//          return Container();
//        },
//      ),
//    );
//  }
//}
