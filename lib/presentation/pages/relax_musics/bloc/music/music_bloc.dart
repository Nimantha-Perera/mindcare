import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';

class Music {
  final String name;
  final String url;

  Music({required this.name, required this.url});
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
    loadMusicsFromFirebase();
  }

  Future<void> loadMusicsFromFirebase() async {
    try {
      final ListResult result =
          await FirebaseStorage.instance.ref('musics').listAll();

      List<Music> musics = [];

      for (Reference ref in result.items) {
        final String url = await ref.getDownloadURL();
        final String name = ref.name;

        musics.add(Music(name: name, url: url));
      }

      _allMusics = musics;
      _filteredMusics = List.from(_allMusics);
      notifyListeners();
    } catch (e) {
      print('Failed to load musics from Firebase: $e');
    }
  }

  Future<void> refreshMusics() async {
    filterMusics(_searchQuery);
    notifyListeners();
  }

  void filterMusics(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredMusics = List.from(_allMusics);
    } else {
      _filteredMusics = _allMusics
          .where((music) =>
              music.name.toLowerCase().contains(query.toLowerCase()))
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
    final formattedName =
        name.replaceAll('_', ' ').replaceAll('-', ' ').replaceAll('.mp3', '');
    return formattedName
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
