// File: lib/domain/entities/music.dart

class Music {
  final String id;
  final String title;
  final String artistName;
  final String coverUrl;
  final String audioUrl;
  final bool isPlaying;

  Music({
    required this.id,
    required this.title,
    required this.artistName,
    required this.coverUrl,
    required this.audioUrl,
    this.isPlaying = false,
  });

  Music copyWith({
    String? id,
    String? title,
    String? artistName,
    String? coverUrl,
    String? audioUrl,
    bool? isPlaying,
  }) {
    return Music(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}