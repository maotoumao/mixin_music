import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:mixinmusic/components/cache_image.dart';
import 'package:mixinmusic/utils/adaption.dart';


// item
class SongSheetItem extends StatelessWidget {
  SongSheetItem(
      {Key? key, required this.index, required this.name, required this.songNum, this.cover, required this.onTap, required this.onLongPress})
      : super(key: key);

  final int index;
  final String name;
  final int songNum;
  final String? cover;
  final Function() onTap;
  final Function() onLongPress;

  @override
  Widget build(BuildContext context) {

    return InkWell(
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CacheImage(url: cover?? '', width: 100.rpx, height: 100.rpx, borderRadius: 20.rpx, defaultWidget: Image.asset(
                'images/default_song_sheet_cover.jpg',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )),
              Expanded(
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          textScaleFactor: 1.1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          sprintf('%i首', [songNum]),
                          style: TextStyle(color: Color(0xff333333)),
                          textScaleFactor: 0.9,
                        )
                      ],
                    ),
                  ))
            ],
          )),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
