part of 'setting_bloc.dart';

@immutable
abstract class SettingState {
  final String? backgroundImgPath;

  const SettingState({this.backgroundImgPath});
}

class SettingInitial extends SettingState {
  SettingInitial(): super(backgroundImgPath: 'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Finews.gtimg.com%2Fnewsapp_bt%2F0%2F9955718202%2F1000.jpg&refer=http%3A%2F%2Finews.gtimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1619502843&t=2bef6f0ff6d9e252c9806846f28c42b2');
  // SettingInitial(): super(backgroundImgPath: 'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201510%2F02%2F20151002080410_W5KX2.thumb.700_0.jpeg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1620213893&t=2a5f5cbbd63071c3177eb3ab3ee0c2ff');
}



