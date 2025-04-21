import 'package:dartz/dartz.dart';
import '../failures/failures.dart';
import '../repositories/music_repository.dart';

class PauseMusicUseCase {
  final MusicRepository repository;

  PauseMusicUseCase(this.repository);

  Future<Either<Failure, void>> call(String musicId) async {
    return await repository.pauseMusic(musicId);
  }
}