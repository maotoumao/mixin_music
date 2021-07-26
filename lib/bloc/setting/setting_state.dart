part of 'setting_bloc.dart';

@immutable
abstract class SettingState {
  final String? backgroundImgPath;

  const SettingState({this.backgroundImgPath});
}

class SettingInitial extends SettingState {
  SettingInitial(): super(backgroundImgPath: 'assets:images/background.jfif');
}



