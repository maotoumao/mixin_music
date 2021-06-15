import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:sprintf/sprintf.dart';

class BilibiliApi {
  static Future<List> search(query) async {
    final headers = {
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.63',
      'accept': 'application/json, text/plain, */*',
      "accept-encoding": "gzip, deflate, br",
      'origin': 'https://search.bilibili.com',
      'sec-fetch-site': 'same-site',
      'sec-fetch-mode': 'cors',
      'sec-fetch-dest': 'empty',
      'referer': 'https://search.bilibili.com/',
      'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    };
    final dio = Dio(BaseOptions(headers: headers));
    final data = {
      'context': '',
      'page': 1,
      'order': '',
      'keyword': query,
      'duration': '',
      'tids_1': '',
      'tids_2': '',
      '__refresh__': true,
      '_extra': '',
      'highlight': 1,
      'single_column': 0
    };
    try {
      // 很奇怪，用dio.get()，然后在4g环境下请求会有问题
      Response response = await dio.fetch(RequestOptions(
          path: 'https://api.bilibili.com/x/web-interface/search/all/v2',
          method: 'GET',
          queryParameters: data));
      final Map resultData = response.data;
      final List results = resultData['data']['result'];

      final List videos = results
          .firstWhere((element) => element['result_type'] == 'video')['data'];
      return videos.map((result) {
        MediaItem mi = MediaItem(
            id: result['bvid'] ?? result['aid'],
            album: result['bvid'] ?? result['aid'],
            //如果是空会有问题
            title: (result['title'] as String)
                .replaceAllMapped(RegExp(r'(<em.*?>)|(</em>)'), (m) => ''),
            artist: result['author'],
            duration: Duration(
                seconds: result['duration']
                    .split(':')
                    .map((String s) => int.parse(s))
                    .reduce((prev, curr) => prev * 60 + curr)),
            genre: 'bilibili',
            artUri: Uri.parse(sprintf('http:%s', [result['pic']])),
            extras: result);
        return mi;
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<MediaItem>> getPages(MediaItem mi) async {
    final data = mi.extras!;
    int aid = data['aid'];
    String? bvid = data['bvid'];
    String param = 'bvid=$bvid';

    if (bvid == null) {
      param = 'aid=$aid';
    }

    Dio dio = Dio(BaseOptions(headers: {
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.63',
      'accept': '*/*',
      "accept-encoding": "gzip, deflate, br",
      'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    }));
    // 获取cid
    Response cidRes = await dio.fetch(RequestOptions(
        path: sprintf(
            'https://api.bilibili.com/x/web-interface/view?%s', [param]),
        method: 'GET'));
    int cid = cidRes.data['data']['cid'];
    List pages = cidRes.data['data']['pages'];
    if (pages.length == 1) {
      Map<String, dynamic> extras = jsonDecode(jsonEncode(mi.extras));
      extras['cid'] = cid;
      return [mi.copyWith(extras: extras)];
    } else {
      return pages.map((p) {
        Map<String, dynamic> extras = jsonDecode(jsonEncode(mi.extras));
        extras['cid'] = p['cid'];
        return mi.copyWith(
            id: p['page'] == 1
                ? sprintf('%s', [mi.id])
                : sprintf('%s - P%d', [mi.id, p['page']]),
            title: p['part'],
            duration: Duration(seconds: p['duration']),
            extras: extras);
      }).toList();
    }
  }

  static Future<Map> getAudioUrl(data) async {
    print('getAudioUrl');
    int aid = data['aid'];
    String? bvid = data['bvid'];
    int? cid = data['cid'];
    String param = 'bvid=$bvid';

    if (bvid == null) {
      param = 'avid=$aid';
    }

    Dio dio = Dio(BaseOptions(headers: {
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.63',
      'accept': '*/*',
      "accept-encoding": "gzip, deflate, br",
      'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    }));
    if (cid == null) {
      // 获取cid
      Response cidRes = await dio.fetch(RequestOptions(
          method: 'GET',
          path: sprintf(
              'https://api.bilibili.com/x/web-interface/view?%s', [param])));
      cid = cidRes.data['data']['cid'];
    }

    print('cid');
    print(cid);
    // playurl
    Response playurlRes = await dio.fetch(RequestOptions(
        method: 'GET',
        path: sprintf(
            'https://api.bilibili.com/x/player/playurl?%s&cid=%i&fnval=16',
            [param, cid])));
    return {
      'url': playurlRes.data['data']['dash']['audio'][0]['baseUrl'],
      'backupUrl': playurlRes.data['data']['dash']['audio'][0]['backupUrl']
    };
  }
}
