import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mixinmusic/bloc/song_sheet/song_sheet_bloc.dart';
import 'package:mixinmusic/components/background_stack.dart';
import 'package:mixinmusic/components/play_bar.dart';
import 'package:mixinmusic/components/song_item.dart';
import 'package:mixinmusic/pages/song_sheet_detail/header.dart';

/// 查看歌单

class SongSheetDetailPage extends StatelessWidget {
  final int sheetIndex;

  SongSheetDetailPage({Key? key, required this.sheetIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BackgroundStack(
      child:
          BlocBuilder<SongSheetBloc, SongSheetState>(builder: (context, state) {
        final List<MediaItem> songsList =
            List<MediaItem>.from(state.songSheet[sheetIndex]['songs']);
        return Column(
          children: [
            Expanded(
                child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0x66666666)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Header(
                      cover: state.songSheet[sheetIndex]['cover'],
                      name: state.songSheet[sheetIndex]['name'],
                      songNum:
                          state.songSheet[sheetIndex]['songs'].length as int,
                    ),
                    Divider(color: Color(0xff666666)),
                    Expanded(
                        child: ListView.builder(
                            itemCount: songsList.length,
                            itemBuilder: (BuildContext context, int songIndex) {
                              return SongItem(
                                mediaItem: songsList[songIndex],
                                updateQueue: songsList,
                                sheetIndex: sheetIndex,
                              );
                            }))
                  ]),
            )),
            PlayBar()
          ],
        );
      }),
    ));
  }
}
