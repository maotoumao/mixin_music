import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';

import 'package:sprintf/sprintf.dart';

class MiguApi {
  static Future<List> search(String query) async {
    final data = {'keyword': query, 'pgc': 1, 'type': 2, 'rows': 15};

    final headers = {
      'Accept': 'application/json, text/javascript, */*; q=0.01',
      'Accept-Encoding': 'gzip, deflate, br',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
      'Connection': 'keep-alive',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'Host': 'm.music.migu.cn',
      'Referer': sprintf('https://m.music.migu.cn/v3/search?keyword=%s',
          [Uri.encodeComponent(query)]),
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-origin',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 6.0.1; Moto G (4)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Mobile Safari/537.36 Edg/89.0.774.68',
      'X-Requested-With': 'XMLHttpRequest'
    };
    final dio = Dio(BaseOptions(headers: headers));

    try {
      Response response = await dio.get(
          'https://m.music.migu.cn/migu/remoting/scr_search_tag',
          queryParameters: data);
      List resultList = response.data['musics'] ?? [];

      return resultList.where((r) {
        return (r['auditionsFlag'] == null);
      }).map((result) {
        MediaItem mi = MediaItem(
            id: sprintf('migu-%s', [result['id']]),
            album: result['albumName'],
            title: result['songName'],
            artist: result['artist'],
            genre: '咪咕',
            artUri: Uri.parse(result['cover'] ?? ''),
            extras: result);
        return mi;
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
