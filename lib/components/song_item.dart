import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mixinmusic/api/api.dart';
import 'package:mixinmusic/bloc/song_sheet/song_sheet_bloc.dart';
import 'package:mixinmusic/components/modal_function.dart';
import 'package:sprintf/sprintf.dart';
import 'package:mixinmusic/entity/modal_item.dart';
import 'package:mixinmusic/components/label.dart';

import 'package:mixinmusic/utils/audio_util.dart';
import 'package:mixinmusic/utils/common.dart';


// 歌曲item分为两种，一种在歌单内，一种是搜索结果中的
class SongItem extends StatelessWidget {
  final MediaItem mediaItem;
  final List<MediaItem>? updateQueue;
  final sheetIndex; // 在哪一个歌单内

  SongItem(
      {Key? key, required this.mediaItem, this.updateQueue, this.sheetIndex})
      : super(key: key);

  showSongOperation(BuildContext context) {
    final modalItems = [
      ModalItem(leading: Icons.playlist_add, content: '下一首播放', onTap: () async {
        await AudioService.addQueueItem(mediaItem);
        Navigator.pop(context);
        Fluttertoast.showToast(msg: '已添加到下一首播放');
      }),
      ModalItem(leading: Icons.album, content: '复制专辑名', onTap: (){CommonUtil.copyToClipboard(mediaItem.album);}),
      // 添加到我喜欢
      ModalItem(
          leading: Icons.favorite,
          content: '添加到我喜欢',
          onTap: () {
            BlocProvider.of<SongSheetBloc>(context)
                .add(AddSongsToSheet(songs: [mediaItem], sheetIndex: 0));
            Navigator.pop(context);
          }),
      // 添加到歌单
      ModalItem(
          leading: Icons.add,
          content: '添加到...',
          onTap: () {
            Navigator.pop(context);
            Modal.showAddToModal(context, [mediaItem]);
          }),
      if (sheetIndex != null)
        ModalItem(
            leading: Icons.delete,
            content: '删除',
            onTap: () {
              BlocProvider.of<SongSheetBloc>(context)
                  .add(RemoveSongsFromSheet(sheetIndex: sheetIndex, songs: [mediaItem]));
              Navigator.pop(context);
            }),
      ModalItem(
          leading: Icons.save_alt_rounded,
          content: '下载',
          onTap: () {
              AudioUtil.getDownloadAudioPath(mediaItem).then((value) {
                if(value == null) {
                  API.downloadAudio(mediaItem);
                } else {
                  Fluttertoast.showToast(msg: '已经下载过啦😊');
                }
              });
          }),

    ];

    Modal.showModalWithMediaHeader(context, mediaItem: mediaItem, modalItems: modalItems);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (updateQueue != null) {
          await AudioUtil.updateQueue(updateQueue!);
        }
        AudioUtil.playMediaItem(mediaItem);
      },
      child: Container(
          margin: EdgeInsets.fromLTRB(15, 5, 0, 5),
          height: 50,
          child: Row(
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Text(mediaItem.title,
                              overflow: TextOverflow.ellipsis)),
                      SizedBox(width: 10),
                      Label(label: mediaItem.genre as String, fontSize: 9)
                    ],
                  ),
                  Row(
                    children: [
                      FutureBuilder(
                          future: AudioUtil.getDownloadAudioPath(mediaItem),
                          builder: (context, snapshot) {
                            if(snapshot.data != null) {
                              return Icon(Icons.download_done_rounded);
                            }
                            return Container();
                          }
                      ),
                      Text(
                        sprintf('%s - %s', [mediaItem.artist ?? '', mediaItem.album]),
                        textScaleFactor: 0.8,
                        style: TextStyle(color: Color(0xff333333)),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )
                ],
              )),
              IconButton(
                  padding: EdgeInsets.all(15),
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    showSongOperation(context);
                  })
            ],
          )),
    );
  }
}
