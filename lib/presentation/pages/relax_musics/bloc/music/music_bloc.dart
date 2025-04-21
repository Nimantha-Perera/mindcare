import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindcare/domain/entities/music.dart';
import 'package:mindcare/presentation/pages/relax_musics/domain/usecases/get_relax_musics.dart';
import 'package:mindcare/presentation/pages/relax_musics/domain/usecases/play_music.dart';
import 'package:mindcare/presentation/pages/relax_musics/domain/usecases/search_musics.dart';

import 'music_event.dart';
import 'music_state.dart';

class MusicBloc extends Bloc<MusicEvent, MusicState> {
  final GetRelaxMusics getRelaxMusics;
  final SearchMusics searchMusics;
  final PlayMusicUseCase playMusicUseCase;
  List<Music> _currentMusics = [];

  MusicBloc({
    required this.getRelaxMusics,
    required this.searchMusics,
    required this.playMusicUseCase,
  }) : super(MusicInitial()) {
    on<FetchRelaxMusics>(_onFetchRelaxMusics);
    on<SearchRelaxMusics>(_onSearchRelaxMusics);
    on<PlayMusic>(_onPlayMusic);
    on<PauseMusic>(_onPauseMusic);
  }

  Future<void> _onFetchRelaxMusics(
    FetchRelaxMusics event,
    Emitter<MusicState> emit,
  ) async {
    emit(MusicLoading());
    try {
      final result = await getRelaxMusics();
      result.fold(
        (failure) => emit(MusicError(failure.message)),
        (musics) {
          _currentMusics = musics;
          emit(MusicLoaded(musics));
        },
      );
    } catch (e) {
      emit(MusicError(e.toString()));
    }
  }

  Future<void> _onSearchRelaxMusics(
    SearchRelaxMusics event,
    Emitter<MusicState> emit,
  ) async {
    emit(MusicLoading());
    try {
      final result = await searchMusics(event.query);
      result.fold(
        (failure) => emit(MusicError(failure.message)),
        (musics) {
          _currentMusics = musics;
          emit(MusicLoaded(musics));
        },
      );
    } catch (e) {
      emit(MusicError(e.toString()));
    }
  }

  Future<void> _onPlayMusic(
    PlayMusic event,
    Emitter<MusicState> emit,
  ) async {
    try {
      final result = await playMusicUseCase(event.musicId);
      result.fold(
        (failure) => emit(MusicError(failure.message)),
        (_) {
          // Update the currently playing music in the list
          final updatedMusics = _currentMusics.map((music) {
            if (music.id == event.musicId) {
              return music.copyWith(isPlaying: true);
            } else {
              return music.copyWith(isPlaying: false);
            }
          }).toList();
          
          _currentMusics = updatedMusics;
          emit(MusicLoaded(updatedMusics));
        },
      );
    } catch (e) {
      emit(MusicError(e.toString()));
    }
  }

  Future<void> _onPauseMusic(
    PauseMusic event,
    Emitter<MusicState> emit,
  ) async {
    try {
      // Update the music item to show it's not playing
      final updatedMusics = _currentMusics.map((music) {
        if (music.id == event.musicId) {
          return music.copyWith(isPlaying: false);
        }
        return music;
      }).toList();
      
      _currentMusics = updatedMusics;
      emit(MusicLoaded(updatedMusics));
    } catch (e) {
      emit(MusicError(e.toString()));
    }
  }


}