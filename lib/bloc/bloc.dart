import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mixinmusic/bloc/setting/setting_bloc.dart';
import 'package:mixinmusic/bloc/song_sheet/song_sheet_bloc.dart';

class BlocComponent extends StatelessWidget {
  final Widget child;

  BlocComponent({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MultiBlocProvider(providers: [
      BlocProvider<SongSheetBloc>(create: (_) => SongSheetBloc()),
      BlocProvider<SettingBloc>(create: (_) => SettingBloc()),
    ], child: child);
  }
}
