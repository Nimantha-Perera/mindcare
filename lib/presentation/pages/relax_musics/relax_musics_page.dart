import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bloc/music/music_bloc.dart';

class RelaxMusicsPage extends StatefulWidget {
  const RelaxMusicsPage({Key? key}) : super(key: key);

  @override
  State<RelaxMusicsPage> createState() => _RelaxMusicsPageState();
}

class _RelaxMusicsPageState extends State<RelaxMusicsPage> {
  final TextEditingController _searchController = TextEditingController();
  late MusicBloc _musicBloc;

  final Color primaryColor = const Color(0xFF00846A);
  final Color lightGrey = Colors.grey.shade300;

  @override
  void initState() {
    super.initState();
    
    _musicBloc = Provider.of<MusicBloc>(context, listen: false);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _musicBloc.filterMusics(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildNowPlayingCard(),
              const SizedBox(height: 16),
              _buildMusicList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: lightGrey),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for music',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildNowPlayingCard() {
    return Consumer<MusicBloc>(
      builder: (context, musicBloc, _) {
        final index = musicBloc.currentlyPlayingIndex;
        if (index == null) return const SizedBox();

        final currentMusic = musicBloc.filteredMusics[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Now Playing: ${musicBloc.formatMusicName(currentMusic.name)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(musicBloc.formatDuration(musicBloc.position)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: lightGrey,
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: musicBloc.position.inMilliseconds.toDouble().clamp(
                              0,
                              musicBloc.duration.inMilliseconds.toDouble() > 0
                                  ? musicBloc.duration.inMilliseconds.toDouble()
                                  : 1,
                            ),
                        min: 0,
                        max: musicBloc.duration.inMilliseconds.toDouble() > 0
                            ? musicBloc.duration.inMilliseconds.toDouble()
                            : 1,
                        onChanged: (value) {
                          musicBloc.seekTo(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                  ),
                  Text(musicBloc.formatDuration(musicBloc.duration)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, size: 32),
                    color: primaryColor,
                    onPressed: () {
                      musicBloc.seekTo(Duration(
                          milliseconds: (musicBloc.position.inMilliseconds - 10000)
                              .clamp(0, musicBloc.duration.inMilliseconds)));
                    },
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => musicBloc.togglePlay(index),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                      child: Icon(
                        musicBloc.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.forward_10, size: 32),
                    color: primaryColor,
                    onPressed: () {
                      musicBloc.seekTo(Duration(
                          milliseconds: (musicBloc.position.inMilliseconds + 10000)
                              .clamp(0, musicBloc.duration.inMilliseconds)));
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

Widget _buildMusicList() {
  return Expanded(
    child: Consumer<MusicBloc>(
      builder: (context, musicBloc, _) {
        if (musicBloc.filteredMusics.isEmpty && musicBloc.allMusics.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (musicBloc.filteredMusics.isEmpty) {
          return const Center(child: Text('No music found'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await musicBloc.refreshMusics(); // Add this method to MusicBloc
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(), // important
            itemCount: musicBloc.filteredMusics.length,
            itemBuilder: (context, index) {
              final music = musicBloc.filteredMusics[index];
              final isCurrent = musicBloc.currentlyPlayingIndex == index;
              final isPlaying = isCurrent && musicBloc.isPlaying;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: isCurrent ? primaryColor : lightGrey,
                      width: isCurrent ? 2 : 1,
                    ),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              musicBloc.formatMusicName(music.name),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                color: isCurrent ? primaryColor : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(height: 1, color: lightGrey),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => musicBloc.togglePlay(index),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

}
