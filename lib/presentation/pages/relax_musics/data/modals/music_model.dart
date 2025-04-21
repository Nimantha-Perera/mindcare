// File: lib/data/models/music_model.dart

import 'package:mindcare/domain/entities/music.dart';



class MusicModel extends Music {
  MusicModel({
    required String id,
    required String title,
    required String audioUrl,
    String artistName = '',
    String coverUrl = '',
    bool isPlaying = false,
  }) : super(
          id: id,
          title: title,
          artistName: artistName,
          coverUrl: coverUrl,
          audioUrl: audioUrl,
          isPlaying: isPlaying,
        );

  // Updated fromJson method to match the API response format
  factory MusicModel.fromJson(Map<String, dynamic> json) {
    return MusicModel(
      // Using name as both id and title since the API doesn't provide an id
      id: json['name'],
      title: json['name'],
      // Using the URL directly from the API
      audioUrl: json['url'],
      // Default values for fields not provided by the API
      artistName: 'Relaxation Music',
      coverUrl: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': title,
      'url': audioUrl,
    };
  }
}