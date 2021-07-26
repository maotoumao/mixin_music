import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mixinmusic/bloc/setting/setting_bloc.dart';

class BackgroundStack extends StatelessWidget {
  final Widget child;

  BackgroundStack({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return BlocBuilder<SettingBloc, SettingState>(builder: (context, state) {
      Decoration? decoration;
      final url = state.backgroundImgPath;
      if (url == null) {
        decoration = BoxDecoration(color: Color(0xffaaaaaa));
      } else if (url.startsWith('http')) {
        decoration = BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.cover,
          ),
        );
      } else if (url.startsWith('assets:')) {
        decoration = BoxDecoration(
          image: DecorationImage(
            image: AssetImage(url.substring(7)),
            fit: BoxFit.cover,
          ),
        );

      }
      return Stack(
        children: [
          // 背景图
          Container(decoration: decoration),
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey.shade500),
                ),
              )),
          // 子组件
          SafeArea(child: child)
        ],
      );
    });
  }
}