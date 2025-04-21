import 'package:dartz/dartz.dart';
import 'package:mindcare/domain/entities/music.dart';
import 'package:mindcare/presentation/pages/relax_musics/core/error/error.dart';
import '../../domain/failures/failures.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/music_remote_data_source.dart';


class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteDataSource remoteDataSource;

  MusicRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Music>>> getRelaxMusics() async {
    try {
      final result = await remoteDataSource.getRelaxMusics();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Music>>> searchMusics(String query) async {
    try {
      final result = await remoteDataSource.searchMusics(query);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> playMusic(String musicId) async {
    try {
      await remoteDataSource.playMusic(musicId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> pauseMusic(String musicId) async {
    try {
      await remoteDataSource.pauseMusic(musicId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unknown error occurred: ${e.toString()}'));
    }
  }
}