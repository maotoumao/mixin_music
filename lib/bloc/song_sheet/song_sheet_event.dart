part of 'song_sheet_bloc.dart';

@immutable
abstract class SongSheetEvent {}

class LoadSongSheet extends SongSheetEvent {}

class CreateSongSheet extends SongSheetEvent {
  final String name;

  CreateSongSheet({required this.name});
}

class RemoveSongSheet extends SongSheetEvent {
  final int sheetIndex;

  RemoveSongSheet({required this.sheetIndex});
}

class RemoveSongsFromSheet extends SongSheetEvent {
  final int sheetIndex;
  final List<MediaItem> songs;
  RemoveSongsFromSheet({required this.sheetIndex, required this.songs});
}

class AddSongsToSheet extends SongSheetEvent {
  final List<MediaItem> songs;
  final int sheetIndex;

  AddSongsToSheet({required this.songs, required this.sheetIndex});
}