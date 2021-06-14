import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mixinmusic/api/bilibili_api.dart';
import 'package:mixinmusic/components/song_item.dart';
import 'package:mixinmusic/utils/shared_pref_helper.dart';
import 'package:mixinmusic/api/api.dart';

// BV号搜索
class BVSearchResult extends StatelessWidget {
  final MediaItem mediaItem;

  BVSearchResult({Key? key, required this.mediaItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future childPages = BilibiliApi.getPages(mediaItem);
    return FutureBuilder(
        future: childPages,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('出错了');
          } else {
            if (snapshot.hasData) {
              final data = snapshot.data as List<MediaItem>;
              return SingleChildScrollView(
                  child: Column(
                    children: data.map((d) => SongItem(mediaItem: d, updateQueue: data, )).toList(),
                  ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        });
  }
}



// 搜索
class SearchBar extends SearchDelegate {
  @override
  String? get searchFieldLabel => '';

  // 右侧 清空
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  // 左侧 返回
  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  // 搜索
  @override
  Widget buildResults(BuildContext context) {
    Future<List> result;

    if (query.trim() == '') {
      return Container();
    }
    if (query.startsWith('BV')) {
      result = API.searchBV(query);
    } else {
      result = API.search(query);
    }

    SharedPrefHelper.addHistory(query);

    return FutureBuilder(
        future: result,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final List data = snapshot.data;
              if(query.startsWith('BV')) {
                if(data.isNotEmpty){
                  return BVSearchResult(mediaItem: data[0]);
                }
              }

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return SongItem(mediaItem: data[index]);
                },
              );
            } else {
              return Center(
                  child: Text('没搜到结果 再搜一次试试吧')
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Container(
      padding: EdgeInsets.all(15),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return FutureBuilder(
            future: SharedPrefHelper.getHistory(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.hasData){
                final List data = snapshot.data;
                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(data[index]),
                        trailing: GestureDetector(
                          child: Icon(Icons.delete),
                          onTap: () async{
                            await SharedPrefHelper.removeHistoryAt(index);
                            setState((){});
                          },
                        ),
                        onTap: (){
                          query = data[index];
                          showResults(context);
                        },
                      );
                    }
                );
              }else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}