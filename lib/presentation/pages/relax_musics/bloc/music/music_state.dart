

import 'package:mindcare/domain/entities/music.dart';

abstract class MusicState {}

class MusicInitial extends MusicState {}

class MusicLoading extends MusicState {}

class MusicLoaded extends MusicState {
  final List<Music> musics;

  MusicLoaded(this.musics);
}

class MusicError extends MusicState {
  final String message;

  MusicError(this.message);
}