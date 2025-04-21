import 'package:dartz/dartz.dart';
import 'package:mindcare/domain/entities/music.dart';
import '../failures/failures.dart';
import '../repositories/music_repository.dart';

class SearchMusics {
  final MusicRepository repository;

  SearchMusics(this.repository);

  Future<Either<Failure, List<Music>>> call(String query) async {
    return await repository.searchMusics(query);
  }
}