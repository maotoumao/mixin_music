import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:mixinmusic/components/background_image.dart';
import 'package:mixinmusic/components/media_state_builder.dart';

import 'package:mixinmusic/pages/song/header.dart';
import 'package:mixinmusic/pages/song/body.dart';
import 'package:mixinmusic/pages/song/operation_bar.dart';


class SongPage extends StatelessWidget {

  SongPage({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      body: CurrentMediaBuilder(
          builder: (BuildContext context, MediaItem? mediaItem) {
            if(mediaItem == null){
              return Container();
            }

            return BackgroundImage(
              url: mediaItem.artUri.toString(),
              blur: 25,
              shadeLevel: 9,
              child: Column(
                children: [
                  Header(mediaItem: mediaItem),
                  Body(mediaItem: mediaItem),
                  OperationBar(mediaItem: mediaItem)
                ],
              ),
            );
          }
      ),
    );
  }

}


