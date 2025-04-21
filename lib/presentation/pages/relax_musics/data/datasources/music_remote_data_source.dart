// File: lib/data/datasources/music_remote_data_source.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mindcare/presentation/pages/relax_musics/core/error/error.dart';
import 'package:mindcare/presentation/pages/relax_musics/data/modals/music_model.dart';


abstract class MusicRemoteDataSource {
  Future<List<MusicModel>> getRelaxMusics();
  Future<List<MusicModel>> searchMusics(String query);
  Future<void> playMusic(String musicId);
  Future<void> pauseMusic(String musicId);
}

class MusicRemoteDataSourceImpl implements MusicRemoteDataSource {
  final http.Client client;
  // Use the provided localhost endpoint
  final String baseUrl = 'http://localhost:3000/api';

  MusicRemoteDataSourceImpl({
    required this.client,
  });

  @override
  Future<List<MusicModel>> getRelaxMusics() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/musics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> musicsData = json.decode(response.body);
        return musicsData
            .map((musicData) => MusicModel.fromJson(musicData))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch musics: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MusicModel>> searchMusics(String query) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/musics?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> musicsData = json.decode(response.body);
        return musicsData
            .map((musicData) => MusicModel.fromJson(musicData))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to search musics: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> playMusic(String musicId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/musics/$musicId/play'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to play music: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> pauseMusic(String musicId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/musics/$musicId/pause'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to pause music: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}