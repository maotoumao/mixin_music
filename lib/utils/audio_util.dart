import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:mixinmusic/utils/shared_pref_helper.dart';
import 'package:mixinmusic/background/background_task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';

_backgroundTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

// 音频相关
class AudioUtil {
  // 开启任务
  static start() async {
    Map<String, dynamic> params = await SharedPrefHelper.restoreSongStatus();
    // 初始化service
    await AudioService.connect();
    await AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
        androidNotificationChannelName: 'MixinMusic',
        androidNotificationOngoing: true,
        params: params,
        androidNotificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidEnableQueue: true);
  }

  // 如果出错，重新连接
  static _safeMethod(Function() func) async {
    try {
      await func();
    } catch (e) {
      if (!AudioService.running) {
        await start();
        await func();
      }
    }
  }

  // 播放
  static play() async {
    _safeMethod(AudioService.play);
  }

  // 暂停
  static pause() async {
    _safeMethod(AudioService.pause);
  }

  // 播放
  static playMediaItem(MediaItem mediaItem) async {
    _safeMethod(() async{
      print('play!!!!!00');
      await AudioService.playMediaItem(mediaItem);
    });
  }

  // 更新队列
  static updateQueue(List<MediaItem> queue) async {
    _safeMethod(() async{
      await AudioService.updateQueue(queue);
    });
  }

  static Future<String?> getDownloadAudioPath(MediaItem mediaItem) async {
//    print('wtf');
//    try{
//      print((await getExternalStorageDirectory())!.path);
//    } catch(e){
//      print('err');
//      print(e);
//    }

    String path = Platform.isAndroid
        ? (await getExternalStorageDirectory())?.path ?? ''
        : (await getApplicationSupportDirectory()).path;
    path += '/music/';
    final dir = Directory(path);
    bool isExist = await dir.exists();
    if (!isExist) {
      return null;
    }
    var list = dir.listSync();
    List<String> fileNames = list.map<String>((f) => f.path).toList();
    final targetPath = path + sprintf(
        '%s-%s-%s-%s.mp3', [mediaItem.title, mediaItem.artist, mediaItem.album, mediaItem.genre]);
    if(fileNames.contains(targetPath)) {
      return targetPath;
    }
    return null;
  }


}
