import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class Music {
  final String name;
  final String url;

  Music({required this.name, required this.url});

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class MusicBloc with ChangeNotifier {
  List<Music> _allMusics = [];
  List<Music> _filteredMusics = [];
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String _searchQuery = '';

  // Replace this with your actual API endpoint
  final String apiUrl = 'https://backend-m4yq.vercel.app/api/musics';

  List<Music> get allMusics => _allMusics;
  List<Music> get filteredMusics => _filteredMusics;
  int? get currentlyPlayingIndex => _currentlyPlayingIndex;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  AudioPlayer get audioPlayer => _audioPlayer;
  String get searchQuery => _searchQuery;

  MusicBloc() {
    _initialize();

    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = _duration;
        notifyListeners();
      }
    });
  }

  void _initialize() {
    loadMusics();
  }

  Future<void> loadMusics() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> musicsJson = jsonData['musics'] ?? [];
        _allMusics = musicsJson.map((data) => Music.fromJson(data)).toList();
        _filteredMusics = List.from(_allMusics);
        notifyListeners();
      } else {
        throw Exception('Failed to load musics: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to load musics: $e');
    }
  }
  Future<void> refreshMusics() async {
  // Option 1: If you're loading from a local list
  filterMusics(_searchQuery);

  // Option 2: If you're fetching from a remote source
  // _allMusics = await YourMusicRepository().fetchMusics();
  // filterMusics(_searchQuery);
  notifyListeners();
}


  void filterMusics(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredMusics = List.from(_allMusics);
    } else {
      _filteredMusics = _allMusics
          .where((music) => music.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> togglePlay(int index) async {
    final music = _filteredMusics[index];

    if (_currentlyPlayingIndex == index) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      _isPlaying = !_isPlaying;
      notifyListeners();
    } else {
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      _position = Duration.zero;
      _duration = Duration.zero;
      notifyListeners();

      try {
        await _audioPlayer.setUrl(music.url);
        await _audioPlayer.play();
        _currentlyPlayingIndex = index;
        _isPlaying = true;
        notifyListeners();
      } catch (e) {
        print('Error playing music: $e');
      }
    }
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    _position = position;
    notifyListeners();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String formatMusicName(String name) {
    final formattedName = name.replaceAll('_', ' ').replaceAll('-', ' ');
    return formattedName
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase() 
            : '')
        .join(' ');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
