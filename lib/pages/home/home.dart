import 'package:flutter/material.dart';
import 'package:mixinmusic/components/play_bar.dart';
import 'package:mixinmusic/pages/home/header.dart';
import 'package:mixinmusic/pages/home/song_sheet.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

// 当前页面
class _HomePageState extends State<HomePage> {

  Widget build(BuildContext ctx) {

    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Header(),
          SongSheet(),
          PlayBar()
        ]));
  }
}
