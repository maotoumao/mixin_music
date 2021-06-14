import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mixinmusic/utils/shared_pref_helper.dart';

part 'song_sheet_event.dart';
part 'song_sheet_state.dart';

class SongSheetBloc extends Bloc<SongSheetEvent, SongSheetState> {
  SongSheetBloc() : super(SongSheetInitial());

  @override
  Stream<SongSheetState> mapEventToState(
    SongSheetEvent event,
  ) async* {
    if (event is LoadSongSheet) {
      List songSheet = await SharedPrefHelper.loadSongSheet();
      yield NextSongSheet(songSheet);
    }

    if(event is CreateSongSheet) {
      List sheet = state.songSheet;
      sheet.add({
        "name": event.name,
        "cover": null,
        "songs": []
      });
      await SharedPrefHelper.saveSongSheet(sheet);
      final nextState = NextSongSheet(sheet);
      yield nextState;
    }

    if (event is AddSongsToSheet) {
      List allSheet = state.songSheet;
      int sheetIndex = event.sheetIndex;
      List<MediaItem> songs = event.songs;
      allSheet[sheetIndex]['songs'].insertAll(0, songs);
      allSheet[sheetIndex]['songs'] = Set.from(allSheet[sheetIndex]['songs']).toList();
      allSheet[sheetIndex]['cover'] = allSheet[sheetIndex]['songs'][0]?.artUri?.toString();
      await SharedPrefHelper.saveSongSheet(allSheet);
      yield NextSongSheet(allSheet);
    }
    
    if(event is RemoveSongSheet){
      List allSheet = state.songSheet;
      int sheetIndex = event.sheetIndex;
      allSheet.removeAt(sheetIndex);
      await SharedPrefHelper.saveSongSheet(allSheet);
      yield NextSongSheet(allSheet);
    }
    
    if(event is RemoveSongsFromSheet) {
      final sheet = state.songSheet[event.sheetIndex];
      sheet['songs'].removeWhere((element) => event.songs.contains(element));
      await SharedPrefHelper.saveSongSheet(state.songSheet);
      yield NextSongSheet(state.songSheet);
    }
  }
}
