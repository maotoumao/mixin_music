import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mixinmusic/bloc/song_sheet/song_sheet_bloc.dart';
import 'package:mixinmusic/components/cache_image.dart';
import 'package:mixinmusic/components/playback_state_builder.dart';
import 'package:mixinmusic/components/song_sheet_item.dart';
import 'package:mixinmusic/entity/modal_item.dart';
import 'package:sprintf/sprintf.dart';
import 'package:mixinmusic/components/play_queue_builder.dart';
import 'package:mixinmusic/utils/adaption.dart';

const int BOTTOM_SHEET_BG_COLOR = 0xfae1d2c3;

class Modal {
  static showBottomModalCustomize(BuildContext context,
      {Widget? header, required Widget body}) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            //圆角
            child: Container(
              color: Color(BOTTOM_SHEET_BG_COLOR),
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Column(
                children: [
                  if (header != null)
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: header,
                    ),
                  if (header != null) Divider(),
                  Expanded(child: body)
                ],
              ),
            ),
          );
        });
  }

// 底部模态框，内容是静态的
  static showBottomModal(BuildContext context,
      {required Widget header, required List<ModalItem> modalItems}) {
    return showBottomModalCustomize(context,
        header: header,
        body: ListView.builder(
            shrinkWrap: true,
            itemCount: modalItems.length,
            itemBuilder: (context, index) {
              ModalItem item = modalItems[index];
              return GestureDetector(
                  onTap: () {
                    if (item.onTap != null) {
                      item.onTap!();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        20.rpx, 20.rpx, 20.rpx, 20.rpx),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (item.leading != null)
                          Padding(
                              padding: EdgeInsets.only(right: 12.rpx),
                              child: Icon(item.leading)),
                        // 内容
                        Expanded(
                            child: Text(
                              item.content,
                              overflow: TextOverflow.ellipsis,
                            )),
                        if (item.tail != null)
                          GestureDetector(
                            child: Icon(item.tail),
                            onTap: () {
                              if (item.onTailTap != null) {
                                item.onTailTap!();
                              }
                            },
                          )
                      ],
                    ),
                  ));
            }));
  }

  // 将歌曲添加到列表
  static showAddToModal(BuildContext context, songs) {
    return showBottomModalCustomize(context,
        header: Text(
          '添加到...',
          style: TextStyle(fontSize: 32.rpx),
        ), body: BlocBuilder<SongSheetBloc, SongSheetState>(
            builder: (context, state) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.songSheet.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SongSheetItem(
                      index: index,
                      name: state.songSheet[index]['name'],
                      songNum: state.songSheet[index]['songs'].length,
                      cover: state.songSheet[index]['cover'],
                      onTap: () {
                        BlocProvider.of<SongSheetBloc>(context)
                            .add(
                            AddSongsToSheet(songs: songs, sheetIndex: index));
                        Navigator.of(context).pop(true);
                        Fluttertoast.showToast(msg: '添加成功');
                      },
                      onLongPress: () {},
                    );
                  });
            }));
  }

  // 播放队列
  static showPlayQueue(BuildContext context) {
    return showBottomModalCustomize(context,
        body: PlayQueueBuilder(builder: (context, queue) {
          return Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.rpx),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sprintf('播放列表 - %d首', [queue.length]),
                        style: TextStyle(fontSize: 32.rpx),
                      ),
                      PlaybackStateBuilder(builder: (context, playbackState) {
                        if (playbackState == null) {
                          return Container();
                        }
                        if (playbackState.repeatMode ==
                            AudioServiceRepeatMode.one) {
                          return TextButton(
                              onPressed: () async {
                                await AudioService.setRepeatMode(
                                    AudioServiceRepeatMode.none); //下一个状态: 顺序
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.loop_rounded),
                                  Text('单曲循环')
                                ],
                              ));
                        }
                        if (playbackState.shuffleMode ==
                            AudioServiceShuffleMode.all) {
                          return TextButton(
                              onPressed: () async {
                                await AudioService.setRepeatMode(
                                    AudioServiceRepeatMode.one); //下一个状态: 单曲循环
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.shuffle_rounded),
                                  Text('随机播放')
                                ],
                              ));
                        }

                        return TextButton(
                            onPressed: () async {
                              await AudioService.setShuffleMode(
                                  AudioServiceShuffleMode.all); //下一个状态: 随机播放
                            },
                            child: Row(
                              children: [
                                Icon(Icons.repeat_rounded),
                                Text('顺序播放')
                              ],
                            ));
                      }),
                      TextButton(
                        onPressed: () {
                          Modal.showAddToModal(context, queue);
                        },
                        child: Row(
                          children: [Icon(Icons.add_to_photos), Text('添加到')],
                        ),
                      )
                    ],
                  )),
              Divider(),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: queue.length,
                    itemBuilder: (context, index) =>
                        GestureDetector(
                          child: Padding(
                            padding:
                            EdgeInsets.fromLTRB(30.rpx, 20.rpx, 30.rpx, 20.rpx),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                          text: queue[index].title,
                                          style: TextStyle(
                                              color: Color(0xff000000)),
                                          children: [
                                            TextSpan(
                                              text: sprintf(
                                                  ' - %s',
                                                  [queue[index].artist]),
                                              style: TextStyle(
                                                  color: Color(0xff666666),
                                                  fontSize: 24.rpx),
                                            ),
                                          ]),
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                GestureDetector(
                                  child: Icon(Icons.clear),
                                  onTap: () {
                                    AudioService.removeQueueItem(queue[index]);
                                  },
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            AudioService.playMediaItem(queue[index]);
                          },
                        )),
              )
            ],
          );
        }));
  }

// 有固定标题的模态框
  static showModalWithMediaHeader(BuildContext context,
      {required MediaItem mediaItem, required List<ModalItem> modalItems}) {
    return showBottomModal(context,
        header: Row(
          children: [
            CacheImage(
              url: mediaItem.artUri.toString(),
              width: 100.rpx,
              height: 100.rpx,
              borderRadius: 20.rpx,
            ),
            Expanded(
                child: Container(
                  height: 100.rpx,
                  padding: EdgeInsets.only(left: 28.rpx),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mediaItem.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        sprintf(
                            '%s - %s',
                            [mediaItem.artist ?? '', mediaItem.album]),
                        style: TextStyle(
                            color: Color(0xff333333), fontSize: 22.rpx),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ))
          ],
        ),
        modalItems: modalItems);
  }
}
