import 'package:flutter/material.dart';

import 'package:audio_service/audio_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marquee/marquee.dart';
import 'package:mixinmusic/components/label.dart';

import 'package:mixinmusic/utils/adaption.dart';

class Header extends StatelessWidget {
  final MediaItem mediaItem;

  Header({Key? key, required this.mediaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.rpx,
      margin: EdgeInsets.only(top: 24.rpx, left: 24.rpx, right: 24.rpx),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 回退
          GestureDetector(
            child: Icon(
              Icons.arrow_back,
              size: 48.rpx,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          // 标题
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.rpx),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                mediaItem.title.length < 15
                    ? Text(mediaItem.title, style: TextStyle(fontSize: 36.rpx, color: Colors.white,))
                    : Expanded(
                        child: Marquee(
                            text: mediaItem.title,
                            blankSpace: 200,
                            style: TextStyle(fontSize: 36.rpx, color: Colors.white,))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mediaItem.artist ?? '',
                        style:
                        TextStyle(fontSize: 24.rpx, color: Color(0xffcccccc))),
                    SizedBox(
                      width: 24.rpx,
                    ),
                    Label(label: mediaItem.genre!, fontSize: 18.rpx,)
                  ],
                )
              ],
            ),

          )),
          // 分享
          GestureDetector(
            child: Icon(
              Icons.share,
              size: 48.rpx,
              color: Colors.white,
            ),
            onTap: () {
              Fluttertoast.showToast(msg: '还没做呢');
            },
          ),
        ],
      ),
    );
  }
}
