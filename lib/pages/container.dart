import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mixinmusic/bloc/song_sheet/song_sheet_bloc.dart';
import 'package:mixinmusic/components/background_stack.dart';
import 'package:mixinmusic/utils/adaption.dart';
import 'package:mixinmusic/components/background_image.dart';
import 'package:mixinmusic/pages/home/home.dart';
import 'package:mixinmusic/background//background_task.dart';
import 'package:mixinmusic/utils/consts.dart';
import 'package:mixinmusic/utils/shared_pref_helper.dart';
import 'package:sprintf/sprintf.dart';
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

    // TODO: 想让它重新打开的时候回复状态但是好像不是这么写的啊
    params = await SharedPrefHelper.restoreSongStatus();

    // 初始化service
    await AudioService.connect();
    AudioService.start(
        backgroundTaskEntrypoint: _backgroundTaskEntrypoint,
        androidNotificationChannelName: 'MixinMusic',
        androidNotificationOngoing: true,
        params: params,
        androidNotificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/icon_transparent',
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
        drawer: SideDrawer(
          refresh: () {
            setState(() {});
          },
        ),
        body: BackgroundStack(
          child: HomePage(),
        ));
  }
}

class SideDrawer extends StatelessWidget {
  final Function refresh;

  const SideDrawer({Key? key, required this.refresh}) : super(key: key);

  restoreSongSheet(BuildContext context, bool appendMode) {
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
                  child: StatefulBuilder(
                    builder: (context, setState){
                      String sheetData = '';
                      return Column(
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
                                  onPressed: () async {
                                    if (sheetData != '') {
                                      bool result = await SharedPrefHelper.restoreSongSheetString(sheetData, appendMode: appendMode);
                                      if(result){
                                        Fluttertoast.showToast(msg: '恢复成功😊');
                                      } else {
                                        Fluttertoast.showToast(msg: '恢复失败，数据有错😢');
                                      }
                                      sheetData = '';
                                      Navigator.pop(context);
                                    }

                                  },
                                  child: Text('完成'))
                            ],
                          ),
                          TextField(
                            decoration: InputDecoration(hintText: sprintf('%s %s', [appendMode? '[追加模式]':'[覆盖模式]', '把备份的歌单粘贴到这里'])),
                            onChanged: (c) {
                              sheetData = c;
                            },
                          )
                        ],
                      );
                    },
                  )
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext ctx) {
    return Drawer(
        child: BackgroundStack(
            child: SingleChildScrollView(
                child: Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: DecoratedBox(
                            decoration: BoxDecoration(color: Color(0x66666666)),
                            child: Column(
                              children: [
                                SideBarMenuItem(
                                    child: Text('备份歌单'),
                                    onTap: () async {
                                      await Clipboard.setData(ClipboardData(
                                          text: await SharedPrefHelper
                                              .backupSongSheetString()));
                                      Fluttertoast.showToast(msg: '已复制到剪切板😊');
                                    }),
                                SideBarMenuItem(
                                    child: Text('恢复歌单(追加到末尾)'),
                                    onTap: () {
                                      restoreSongSheet(ctx, true);
                                    }),
                                SideBarMenuItem(
                                    child: Text('恢复歌单(覆盖原歌单)'),
                                    onTap: () {
                                      restoreSongSheet(ctx, false);
                                    }),
                                SideBarMenuItem(
                                    child: Text('使用说明'),
                                    onTap: () {
                                      launch('https://gitee.com/maotoumao/mixin_music#git-readme');
                                    }),
                                SideBarMenuItem(
                                    child: Text('github源码链接(求个star)'),
                                    onTap: () {
                                      launch('https://github.com/maotoumao/mixin_music');
                                    }),
                                SideBarMenuItem(
                                    child: Text('gitee源码链接(求个star)'),
                                    onTap: () {
                                      launch('https://gitee.com/maotoumao/mixin_music');
                                    }),
                                SideBarMenuItem(
                                    child: Text('我猜你不想点这个'),
                                    onTap: () async {
                                      if (await canLaunch(
                                          'mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3DTgOv-QFkGzgI6DiqcEn-6XIVuOK9wVK7')) {
                                        await launch(
                                            'mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3DTgOv-QFkGzgI6DiqcEn-6XIVuOK9wVK7');
                                      }
                                    })
                              ],
                            )))))));
  }
}

class SideBarMenuItem extends StatelessWidget {
  final Widget child;
  final void Function() onTap;

  SideBarMenuItem({Key? key, required this.child, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          // 很奇怪呀，不加的话点击时间就只是child的范围
          height: 50,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Center(
            child: child,
          ),
        ));
  }
}
