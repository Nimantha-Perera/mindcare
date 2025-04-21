import 'package:dartz/dartz.dart';
import 'package:mindcare/domain/entities/music.dart';
import '../failures/failures.dart';

abstract class MusicRepository {
  Future<Either<Failure, List<Music>>> getRelaxMusics();
  Future<Either<Failure, List<Music>>> searchMusics(String query);
  Future<Either<Failure, void>> playMusic(String musicId);
  Future<Either<Failure, void>> pauseMusic(String musicId);
}