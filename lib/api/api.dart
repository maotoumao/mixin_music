import 'dart:io';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mixinmusic/api/migu_api.dart';
import 'package:mixinmusic/api/netease_api.dart';
import 'package:mixinmusic/api/bilibili_api.dart';

import 'package:mixinmusic/entity/media_resource.dart';
import 'package:mixinmusic/utils/audio_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';

class API {
  static int _getScore(List keys, MediaItem r) {
    int score = 0;
    keys.forEach((element) {
      if ((r.title).contains(element)) {
        score += 2;
      } else if ((r.artist ?? '').contains(element)) {
        score += 10;
      } else if ((r.album).contains(element)) {
        score += 1;
      }
    });
    return score;
  }

  // 结果排序算法
  static List _merge(String query, List<List> searchResults) {
    List keys = query.split(' ');
    List result = [];
    int count = searchResults.expand((element) => element).length;

    if (keys.length == 1) {
      while (result.length != count) {
        searchResults.forEach((element) {
          if (element.length == 0) {
            return;
          }
          result.add(element[0]);
          element.removeAt(0);
        });
      }
      return result;
    }

    while (result.length != count) {
      List<int> scores = List.filled(4, 0);
      for (int i = 0; i < searchResults.length; ++i) {
        if (searchResults[i].length == 0) {
          scores[i] = -1;
          continue;
        } else {
          scores[i] = _getScore(keys, searchResults[i][0]);
        }
      }
      int index = scores.indexWhere((element) =>
          element == scores.reduce((value, element) => max(value, element)));
      result.add(searchResults[index][0]);
      searchResults[index].removeAt(0);
    }
    return result;
  }

  // 根据BV号搜, 可以分p
  static Future<List> searchBV(String query) {
    return BilibiliApi.search(query).then((value) => [value[0]].toList());
  }

  static Future<List> search(String query) {
    return Future.wait([
      NeteaseApi.search(query),
      MiguApi.search(query),
      BilibiliApi.search(query)
    ]).then((value) => _merge(query, value));
  }

  static Future<MediaResource> getAudioResource(MediaItem mediaItem) async {
    String? downloadPath = await AudioUtil.getDownloadAudioPath(mediaItem);
    if(downloadPath!=null) {
      return MediaResource(url: downloadPath, headers: {'#localFile': '#localFile'});
    }

    switch (mediaItem.genre) {
      case 'bilibili':
        {
          final String url;
          final List<String> backupUrl;
          if (mediaItem.extras?['audioUrl'] != null) {
            url = mediaItem.extras?['audioUrl'];
            backupUrl = mediaItem.extras?['backupUrl'] ?? [] ;
          } else {
            var res = await BilibiliApi.getAudioUrl(mediaItem.extras);
            url = res['url'];
            backupUrl = res['backupUrl'].cast<String>();
            mediaItem.extras?['audioUrl'] = url;
            mediaItem.extras?['backupUrl'] = backupUrl;
          }

          final Map<String, String> headers = {
            HttpHeaders.userAgentHeader:
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.63',
            HttpHeaders.acceptHeader: '*/*',
            HttpHeaders.hostHeader: 'upos-sz-mirrorcoso1.bilivideo.com',
            // TODO: 这里应该是根据url解析吧，先这样吧
            HttpHeaders.acceptEncodingHeader: 'gzip, deflate, br',
            HttpHeaders.connectionHeader: 'keep-alive',
            HttpHeaders.refererHeader: sprintf(
                'https://www.bilibili.com/video/%s',
                [mediaItem.extras?['bvid'] ?? mediaItem.extras!['aid']])
          };
          print('urlaaa');
          print(url);
          return MediaResource(
              url: url, headers: headers, backupUrl: backupUrl);
        }
      case '咪咕':
        {
          return MediaResource(url: mediaItem.extras?['mp3'] ?? '');
        }
      case '网易云':
        {
          return MediaResource(
              url: sprintf(
                  'https://music.163.com/song/media/outer/url?id=%d.mp3',
                  [mediaItem.extras!['id']]));
        }
      default:
        return MediaResource(url: '');
    }
  }

  static downloadAudio(MediaItem mediaItem) async {
    if ((await AudioUtil.getDownloadAudioPath(mediaItem)) != null) {
      return;
    }
    String path = Platform.isAndroid
        ? (await getExternalStorageDirectory())?.path ?? ''
        : (await getApplicationSupportDirectory()).path;
    path += '/music/';
    final dir = Directory(path);
    bool isExist = await dir.exists();
    if (!isExist) {
      dir.create(recursive: true);
    }
    path += sprintf('%s-%s-%s-%s.mp3',
        [mediaItem.title, mediaItem.artist, mediaItem.album, mediaItem.genre]);
    MediaResource mediaResource = await getAudioResource(mediaItem);
    Fluttertoast.showToast(msg: '开始下载');
    Dio()
        .download(mediaResource.url, path,
            options: Options(headers: mediaResource.headers))
        .then((value) {
      print(value);
    }).whenComplete(() {
      Fluttertoast.showToast(msg: '下载成功');
    });
  }
}
