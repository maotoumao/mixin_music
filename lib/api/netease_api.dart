import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:math';

import 'package:sprintf/sprintf.dart';

class NeteaseApi {
  // a函数
  static String _a() {
    String b = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    String result = '';
    final random = Random();
    for (int i = 0; i < 16; ++i) {
      result += b[random.nextInt(b.length)];
    }
    return result;
  }

  // b函数, aescbc
  static String _b(String text, key) {
    text = text + String.fromCharCode(2) * (16 - text.length % 16);
    final iv = IV.fromUtf8('0102030405060708');
    final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
    return encrypter.encrypt(text, iv: iv).base64;
  }

  static String _c(String text) {
    text = text.split('').reversed.join();
    final String d = '010001';
    final String e =
        '00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7';
    String hexText = text.codeUnits.map((c) => c.toRadixString(16)).join();
    final BigInt resultNum = BigInt.parse(hexText, radix: 16)
        .modPow(BigInt.parse(d, radix: 16), BigInt.parse(e, radix: 16));
    return resultNum.toRadixString(16);
  }

  static Map<String, String> _getParamsAndEnc(text) {
    // params
    final first = _b(text, '0CoJUm6Qyw8W8jud');
    final rand = _a();
    final params = _b(first, rand);

    // enc
    final _encSecKey = _c(rand);
    final encSecKey =
        ('0' * (256 - _encSecKey.length)) + _encSecKey; // 位数不足则补充0
    return {'params': params, 'encSecKey': encSecKey};
  }

  static Future<List> search(String query) async {
    final data = {
      's': query,
      'limit': 30,
      'type': 1,
      'offset': 0,
      'csrf_token': ''
    };

    String dtStr = jsonEncode(data);
    final pae = _getParamsAndEnc(dtStr);
    final headers = {
      'authority': 'music.163.com',
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.135 Safari/537.36',
      'content-type': 'application/x-www-form-urlencoded',
      'accept': '*/*',
      'origin': 'https://music.163.com',
      'sec-fetch-site': 'same-origin',
      'sec-fetch-mode': 'cors',
      'sec-fetch-dest': 'empty',
      'referer': 'https://music.163.com/search/',
      'accept-language': 'zh-CN,zh;q=0.9',
    };
    final dio = Dio();
    try {
      Response response = await dio.post(
          'https://music.163.com/weapi/cloudsearch/get/web?csrf_token=',
          data: pae,
          options: Options(headers: headers));
      List resultList = jsonDecode(response.data)['result']['songs'];
      return resultList.where((r) {
        return (r['fee'] == 0 || r['fee'] == 8) && (r['privilege']['st'] >= 0);
      }).map((result) {
        MediaItem mi = MediaItem(
            id: sprintf('netease-%s', [result['id']]),
            album: result['al']['name'],
            title: result['name'],
            artist: result['ar'].map((aut) => aut['name']).join(','),
            duration: Duration(milliseconds: result['dt']),
            genre: '网易云',
            artUri: Uri.parse(result['al']['picUrl']),
            extras: result);
        return mi;
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
