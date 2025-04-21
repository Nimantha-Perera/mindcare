abstract class MusicEvent {}

class FetchRelaxMusics extends MusicEvent {}

class SearchRelaxMusics extends MusicEvent {
  final String query;

  SearchRelaxMusics(this.query);
}

class PlayMusic extends MusicEvent {
  final String musicId;

  PlayMusic(this.musicId);
}

class PauseMusic extends MusicEvent {
  final String musicId;

  PauseMusic(this.musicId);
}