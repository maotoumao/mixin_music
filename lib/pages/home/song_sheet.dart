import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mixinmusic/bloc/song_sheet/song_sheet_bloc.dart';
import 'package:mixinmusic/router/router.dart';
import 'package:mixinmusic/utils/consts.dart';
import 'package:sprintf/sprintf.dart';
import 'package:mixinmusic/components/song_sheet_item.dart';

class SongSheet extends StatefulWidget {
  @override
  _SongSheetState createState() => _SongSheetState();
}

// 歌单
class _SongSheetState extends State<SongSheet> {
  String newSheetName = '';

  createSongSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Container(
                  color: Color(Consts.BOTTOM_SHEET_BG_COLOR),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('取消')),
                          TextButton(
                              onPressed: () {
                                if (newSheetName != '') {
                                  BlocProvider.of<SongSheetBloc>(context)
                                      .add(CreateSongSheet(name: newSheetName));
                                }
                                newSheetName = '';
                                Navigator.pop(context);
                              },
                              child: Text('完成'))
                        ],
                      ),
                      TextField(
                        decoration: InputDecoration(hintText: '新建歌单'),
                        onChanged: (c) {
                          newSheetName = c;
                        },
                      )
                    ],
                  )),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongSheetBloc, SongSheetState>(
        builder: (context, state) {
      return Expanded(
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: DecoratedBox(
                          decoration: BoxDecoration(color: Color(0x66666666)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(sprintf('我的歌单(%i个)',
                                              [state.songSheet.length]))),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          createSongSheet(context);
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      )
                                    ],
                                  ),
                                  Divider(color: Color(0xff666666)),
                                  Column(
                                      children: state.songSheet
                                          .asMap()
                                          .entries
                                          .map((ssd) => SongSheetItem(
                                                index: ssd.key,
                                                name:
                                                    ssd.value['name'] as String,
                                                songNum: ssd.value['songs']
                                                    .length as int,
                                                cover: ssd.value['cover']
                                                    as String?,
                                                onTap: () {
                                                  RouterController
                                                      .navigateToSongSheetDetailPage(
                                                          context,
                                                          index: ssd.key);
                                                },
                                                onLongPress: () {
                                                  print('long-press');
                                                  print(ssd.key);
                                                  if (ssd.key == 0) {
                                                    return null;
                                                  } else {

                                                    showDialog(context: context, builder: (context) {
                                                      return AlertDialog(
                                                        title: Text('是否删除歌单?'),
                                                        content: Text(ssd.value['name']),
                                                        backgroundColor: Color(0xbbffffff),
                                                        actions: [
                                                          TextButton(onPressed:(){
                                                            BlocProvider.of<SongSheetBloc>(context).add(
                                                                RemoveSongSheet(sheetIndex: ssd.key));
                                                            Navigator.of(context).pop();
                                                          } , child: Text('确定'))
                                                        ],
                                                      );
                                                    });
                                                  }
                                                },
                                              ))
                                          .toList()),
                                ]),
                          ))))));
    });
  }
}
