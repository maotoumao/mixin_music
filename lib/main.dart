import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mixinmusic/bloc/bloc.dart';
import 'package:mixinmusic/pages/container.dart';


checkPermission() async {
  var storageStatus = await Permission.storage.status;
  print('权限：');
  print(storageStatus);
  if (!storageStatus.isGranted) {
    await Permission.storage.request();
  }
}

void main() {
  runApp(MyApp());
  // 顶部导航栏透明
  if (Platform.isAndroid) {
    SystemUiOverlayStyle suos =
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle((suos));
  }
  checkPermission();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocComponent(
        child: MaterialApp(
          title: '谧音',
          theme: ThemeData(
            primarySwatch: Colors.grey,
            // This makes the visual density adapt to the platform that you run
            // the app on. For desktop platforms, the controls will be smaller and
            // closer together (more dense) than on mobile platforms.
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: AudioServiceWidget(child: ContainerPage()),
        )
    );
  }
}
