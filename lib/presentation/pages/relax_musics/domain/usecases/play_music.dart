import 'package:dartz/dartz.dart';
import '../failures/failures.dart';
import '../repositories/music_repository.dart';

class PlayMusicUseCase {
  final MusicRepository repository;

  PlayMusicUseCase(this.repository);

  Future<Either<Failure, void>> call(String musicId) async {
    return await repository.playMusic(musicId);
  }
}