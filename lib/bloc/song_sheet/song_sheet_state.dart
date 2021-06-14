part of 'song_sheet_bloc.dart';

@immutable
abstract class SongSheetState {
  final List songSheet;
  const SongSheetState(this.songSheet);

  List<Object> get props => [songSheet];

  @override
  String toString() {
    return jsonEncode(songSheet);
  }
}

class SongSheetInitial extends SongSheetState {
  // 这里不该用map 但是懒得改了
  SongSheetInitial(): super([
    {
      "name": "我喜欢",
      "cover": null,
      "songs": []
    }
  ]);
}

class NextSongSheet extends SongSheetState{
  const NextSongSheet(List songSheet): super(songSheet);
}

