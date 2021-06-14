import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mixinmusic/bloc/song_sheet/song_sheet_bloc.dart';
import 'package:mixinmusic/utils/adaption.dart';
import 'package:mixinmusic/components/background_image.dart';
import 'package:mixinmusic/pages/home/home.dart';
import 'package:mixinmusic/background//background_task.dart';
import 'package:mixinmusic/utils/shared_pref_helper.dart';
import 'package:url_launcher/url_launcher.dart';

_backgroundTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

/// 包装类，用来把页面组装起来
/// 除此之外，存放着全局的一些状态

class ContainerPage extends StatefulWidget {
  @override
  _GlobalState createState() => new _GlobalState();
}

class _GlobalState extends State<ContainerPage> {
  void init() async {
    Map<String, dynamic> params;

    params = await SharedPrefHelper.restoreSongStatus();

    // 初始化service
    await AudioService.connect();

    AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
        androidNotificationChannelName: 'MixinMusic',
        androidNotificationOngoing: true,
        params: params,
        androidNotificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/icon',
        androidEnableQueue: true);
  }

  void reload(BuildContext context) {
    // 加载歌单
    BlocProvider.of<SongSheetBloc>(context).add(LoadSongSheet());
  }

  @override
  void initState() {
    super.initState();
    // 初始化
    init();
  }

  @override
  Widget build(BuildContext ctx) {
    reload(ctx);
    Adaption.init(ctx);

    return Scaffold(
        drawer: SideDrawer(),
        body: BackgroundImage(
          url:
              'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Finews.gtimg.com%2Fnewsapp_bt%2F0%2F9955718202%2F1000.jpg&refer=http%3A%2F%2Finews.gtimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1619502843&t=2bef6f0ff6d9e252c9806846f28c42b2',
          child: HomePage(),
        ));
  }
}

class SideDrawer extends StatelessWidget {
  const SideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return Drawer(
        child: BackgroundImage(
            url:
                'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Finews.gtimg.com%2Fnewsapp_bt%2F0%2F9955718202%2F1000.jpg&refer=http%3A%2F%2Finews.gtimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1619502843&t=2bef6f0ff6d9e252c9806846f28c42b2',
            child: Column(
              children: [
                TextButton(
                  child: Text('还没做，但是你可以点下试试'),
                  onPressed: () {
                    launch('http://blog.maotoumao.xyz');
                  },
                ),
                Text('长按可以删除歌单或者歌曲 默认歌单删不了'),
                Text('如果需要b站分p的视频，直接搜bv号，要不然只能默认播放第1p'),
                TextButton(onPressed: (){

                }, child: Text('导出'))
              ],
            )));
  }
}
