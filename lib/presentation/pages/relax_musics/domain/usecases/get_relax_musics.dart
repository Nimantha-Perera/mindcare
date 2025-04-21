import 'package:dartz/dartz.dart';
import 'package:mindcare/domain/entities/music.dart';
import '../failures/failures.dart';
import '../repositories/music_repository.dart';

class GetRelaxMusics {
  final MusicRepository repository;

  GetRelaxMusics(this.repository);

  Future<Either<Failure, List<Music>>> call() async {
    return await repository.getRelaxMusics();
  }
}
