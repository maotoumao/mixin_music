import 'package:flutter/material.dart';
import 'package:mixinmusic/pages/song/song.dart';
import 'package:mixinmusic/pages/song_sheet_detail/song_sheet_detail.dart';

class RouterController {
  static navigateToSongSheetDetailPage(BuildContext context, {required int index}) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context){
          return SongSheetDetailPage(sheetIndex: index);
        }
    ));
  }

  static navigateToSongPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context){
          return SongPage();
        }
    ));
  }
}
