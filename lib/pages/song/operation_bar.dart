import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mixinmusic/api/api.dart';

import 'package:mixinmusic/bloc/song_sheet/song_sheet_bloc.dart';
import 'package:mixinmusic/components/media_state_builder.dart';
import 'package:mixinmusic/components/modal_function.dart';
import 'package:mixinmusic/components/playback_state_builder.dart';
import 'package:mixinmusic/entity/modal_item.dart';
import 'package:mixinmusic/utils/adaption.dart';
import 'package:mixinmusic/utils/audio_util.dart';
import 'package:mixinmusic/utils/common.dart';
import 'package:sprintf/sprintf.dart';

class OperationItem extends StatelessWidget {
  final IconData iconData;
  final Color? color;
  final double? size;
  final void Function()? onTap;

  OperationItem({Key? key,
    required this.iconData,
    this.color = const Color(0xffcccccc),
    this.size,
    this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        iconData,
        size: size ?? 64.rpx,
        color: color,
      ),
    );
  }
}

// 进度条上方的控制区
class AboveControlBar extends StatelessWidget {
  final MediaItem mediaItem;

  AboveControlBar({Key? key, required this.mediaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      BlocBuilder<SongSheetBloc, SongSheetState>(builder: (context, state) {
        final favList = state.songSheet[0] ?? [];
        if (favList['songs'].contains(mediaItem)) {
          return OperationItem(
              iconData: Icons.favorite,
              color: Colors.red,
              onTap: () {
                BlocProvider.of<SongSheetBloc>(context).add(
                    RemoveSongsFromSheet(songs: [mediaItem], sheetIndex: 0));
              });
        } else {
          return OperationItem(
              iconData: Icons.favorite_border,
              onTap: () {
                BlocProvider.of<SongSheetBloc>(context)
                    .add(AddSongsToSheet(songs: [mediaItem], sheetIndex: 0));
              });
        }
      }),
      FutureBuilder(
          future: AudioUtil.getDownloadAudioPath(mediaItem),
          builder: (context, snapshot) {
            Widget downloadIcon = OperationItem(
                iconData: Icons.save_alt_rounded, onTap: () {
              API.downloadAudio(mediaItem);
            });
            Widget doneIcon = OperationItem(iconData: Icons.download_done_rounded, onTap: (){
              Fluttertoast.showToast(msg: '已经下载过啦😊');
            },);
            if (snapshot.data != null) {
              return doneIcon;
            }
            return downloadIcon;
          }
      ),
//      OperationItem(iconData: Icons.notifications, onTap: () {
//      }), // 外部app打开
      OperationItem(iconData: Icons.more_vert, onTap: () {
        Modal.showModalWithMediaHeader(
            context, mediaItem: mediaItem, modalItems: [
          ModalItem(leading: Icons.music_note,
              content: sprintf('名称： %s', [mediaItem.title]),
              onTap: () {
                CommonUtil.copyToClipboard(mediaItem.title);
              }),
          ModalItem(leading: Icons.person,
              content: sprintf('歌手： %s', [mediaItem.artist]),
              onTap: () {
                CommonUtil.copyToClipboard(mediaItem.artist);
              }),
          ModalItem(leading: Icons.album,
              content: sprintf('专辑： %s', [mediaItem.album]),
              onTap: () {
                CommonUtil.copyToClipboard(mediaItem.album);
              }),
          ModalItem(leading: Icons.link,
              content: sprintf('来源： %s', [mediaItem.genre])),
          ModalItem(leading: Icons.add_to_photos, content: '添加到歌单', onTap: () {
            Modal.showAddToModal(context, [mediaItem]);
          })
        ]);
      },)
    ]);
  }
}

class SlideBar extends StatelessWidget {
  final MediaItem mediaItem;

  SlideBar({Key? key, required this.mediaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? newProgress;

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.rpx),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return MediaPositionBuilder(builder: (context, position) {
                return Row(children: [
                  Text(
                      (newProgress != null
                          ? Duration(seconds: newProgress!.toInt())
                          : position)
                          .toString()
                          .split('.')[0],
                      style: TextStyle(
                          color: Color(0xffcccccc), fontSize: 20.rpx)),
                  Expanded(child: Slider(
                    value: newProgress ?? position.inSeconds.toDouble(),
                    max: mediaItem.duration?.inSeconds.toDouble() ?? 1.0,
                    onChanged: (double value) {
                      setState(() => newProgress = value);
                    },
                    onChangeEnd: (double value) async {
                      await AudioService.seekTo(
                          Duration(seconds: value.toInt()));
                      setState(() {
                        newProgress = null;
                      });
                    },
                    activeColor: Color(0xffcccccc),
                    inactiveColor: Color(0xff999999),
                    semanticFormatterCallback: (value) {
                      return Duration(seconds: value.toInt()).toString();
                    },
                  )),
                  Text(mediaItem.duration.toString().split('.')[0],
                      style: TextStyle(
                          color: Color(0xffcccccc), fontSize: 20.rpx))
                ]);
              });
            }));
  }
}

// 进度条下方的控制区
class BottomControlBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlaybackStateBuilder(
        builder: (BuildContext context, PlaybackState? playbackState) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 播放模式
              playbackState?.repeatMode == AudioServiceRepeatMode.one
                  ? OperationItem(
                iconData: Icons.loop_rounded,
                onTap: () async {
                  await AudioService.setRepeatMode(
                      AudioServiceRepeatMode.none);
                },
              )
                  : (playbackState?.shuffleMode == AudioServiceShuffleMode.all
                  ? OperationItem(
                iconData: Icons.shuffle_rounded,
                onTap: () async {
                  await AudioService.setRepeatMode(
                      AudioServiceRepeatMode.one);
                },
              )
                  : OperationItem(
                iconData: Icons.repeat_rounded,
                onTap: () async {
                  await AudioService.setShuffleMode(
                      AudioServiceShuffleMode.all);
                },
              )),
              // 上一首歌
              OperationItem(
                iconData: Icons.skip_previous_rounded,
                onTap: () {
                  AudioService.skipToPrevious();
                },
              ),
              (playbackState?.playing ?? false)
                  ? OperationItem(
                iconData: Icons.pause_circle_outline,
                size: 96.rpx,
                onTap: () {
                  AudioService.pause();
                },
              )
                  : OperationItem(
                iconData: Icons.play_circle_outline,
                size: 96.rpx,
                onTap: () {
                  AudioService.play();
                },
              ),
              // 下一首歌
              OperationItem(
                iconData: Icons.skip_next_rounded,
                onTap: () {
                  AudioService.skipToNext();
                },
              ),
              OperationItem(
                  iconData: Icons.playlist_play_outlined,
                  onTap: () {
                    Modal.showPlayQueue(context);
                  })
            ],
          );
        });
  }
}

// 整个控制区域
class OperationBar extends StatelessWidget {
  final MediaItem mediaItem;

  OperationBar({Key? key, required this.mediaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 上方的控制组件

    return Container(
      height: 300.rpx,
      margin: EdgeInsets.symmetric(vertical: 48.rpx),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AboveControlBar(mediaItem: mediaItem),
          SlideBar(mediaItem: mediaItem),
          BottomControlBar()
        ],
      ),
    );
  }
}
