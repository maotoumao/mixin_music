import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  // 清空搜索历史
  static clearHistory() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setStringList('history', []);
  }

  static addHistory(String query) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> history = sp.getStringList('history') ?? [];
    history.insert(0, query);
    sp.setStringList('history', Set<String>.from(history).toList());
  }

  static removeHistoryAt(int index) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> history = sp.getStringList('history') ?? [];
    history.removeAt(index);
    sp.setStringList('history', history);
  }

  static Future<List> getHistory() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> history = sp.getStringList('history') ?? [];
    return history;
  }


  static saveSongSheet(List songSheets) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    // 将所有歌曲转化为kv
    List<Map> mapSheet = songSheets.map((ss) =>
    ({
      "name": ss['name'],
      "cover": ss['cover'],
      "songs": ss['songs'].map((mi) => mi.toJson()).toList()
    })).toList();
    sp.setString('song-sheet', jsonEncode(mapSheet));
  }

  static Future<List> loadSongSheet() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? str = sp.getString('song-sheet');
    if (str == null) {
      return [{
        "name": "我喜欢",
        "cover": null,
        "songs": []
      }
      ];
    } else {
      List mapSheet = jsonDecode(str);
      mapSheet.forEach((element) {
        element['songs'] =
            element['songs'].map((m) => MediaItem.fromJson(m)).toList();
      });
      return mapSheet;
    }
  }

  static Future<String> backupSongSheetString() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? str = sp.getString('song-sheet');
    if (str == null) {
      return [{
        "name": "我喜欢",
        "cover": null,
        "songs": []
      }
      ].toString();
    }
    return str;
  }

  // 默认是覆盖的
  static Future<bool> restoreSongSheetString(String str,
      {bool appendMode = false}) async {
    try {
      List mapSheet;
      if (str == '') {
        return false;
      } else {
        mapSheet = jsonDecode(str);
      }
      mapSheet.forEach((element) {
        element['songs'] =
            element['songs'].map((m) => MediaItem.fromJson(m)).toList();
      });

      if (appendMode) {
        mapSheet = [...(await loadSongSheet()), ...mapSheet];
      } else {
        // 是不是哪个小坏蛋把默认歌单删了
        if (-1 == mapSheet.indexWhere((element) => element['name'] == '我喜欢')) {
          mapSheet = [{
            "name": "我喜欢",
            "cover": null,
            "songs": []
          }, ...mapSheet];
        }
      }

      await saveSongSheet(mapSheet);

      return true;
    }
    catch (e) {
      print(e);
      return false;
    }
  }


  static restoreSongStatus() async {
    // 还原歌单
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? playQueueString = sharedPreferences.getStringList(
        'play-queue');
    print(playQueueString);
    int playProgress = sharedPreferences.getInt('play-progress') ?? 0;
    int playIndex = sharedPreferences.getInt('play-index') ?? -1;
    List<MediaItem> playQueue = [];
    if (playQueueString != null) {
      playQueue.addAll(playQueueString
          .map<MediaItem>((pq) => MediaItem.fromJson(jsonDecode(pq))));
    }

    return {
      'playQueue': playQueue,
      'playProgress': playProgress,
      'playIndex': playIndex
    };
  }

  static saveSongStatus(int playIndex, List<MediaItem> queue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setInt('play-index', playIndex);
    await sharedPreferences.setStringList(
        'play-queue', queue.map((q) => jsonEncode(q.toJson())).toList());
  }


}
