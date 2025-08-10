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
  final Color cardColor = const Color(0xFFF8F9FA);

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 768;
    final isMobile = screenWidth <= 480;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(screenWidth, isMobile),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32.0 : 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    _buildSearchBar(screenWidth, isMobile),
                    SizedBox(height: isMobile ? 16 : 24),
                    _buildNowPlayingCard(screenWidth, isMobile, isTablet),
                    SizedBox(height: isMobile ? 12 : 16),
                    _buildMusicList(screenWidth, isMobile, isTablet),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
       
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.music_note_rounded,
            color: primaryColor,
            size: isMobile ? 24 : 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Relax Music',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey.shade600,
            ),
            onPressed: () {
              // Add menu functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth, bool isMobile) {
    return Container(
      height: isMobile ? 48 : 56,
      constraints: BoxConstraints(
        maxWidth: screenWidth > 768 ? 600 : double.infinity,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 24 : 28),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: isMobile ? 14 : 16),
        decoration: InputDecoration(
          hintText: 'Search for music...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: isMobile ? 14 : 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade500,
            size: isMobile ? 20 : 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade500,
                    size: isMobile ? 20 : 24,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _musicBloc.filterMusics('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: isMobile ? 12 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildNowPlayingCard(double screenWidth, bool isMobile, bool isTablet) {
    return Consumer<MusicBloc>(
      builder: (context, musicBloc, _) {
        final index = musicBloc.currentlyPlayingIndex;
        if (index == null) return const SizedBox();

        final currentMusic = musicBloc.filteredMusics[index];

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.music_note,
                    color: primaryColor,
                    size: isMobile ? 20 : 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Now Playing",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                musicBloc.formatMusicName(currentMusic.name),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey.shade800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 16 : 20),
              
              // Progress bar
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        musicBloc.formatDuration(musicBloc.position),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        musicBloc.formatDuration(musicBloc.duration),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: isMobile ? 3 : 4,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: isMobile ? 6 : 8,
                      ),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: isMobile ? 12 : 16,
                      ),
                      activeTrackColor: primaryColor,
                      inactiveTrackColor: Colors.grey.shade300,
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
                ],
              ),
              
              SizedBox(height: isMobile ? 12 : 16),
              
              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    Icons.replay_10,
                    isMobile ? 28 : 32,
                    () {
                      musicBloc.seekTo(Duration(
                          milliseconds: (musicBloc.position.inMilliseconds - 10000)
                              .clamp(0, musicBloc.duration.inMilliseconds)));
                    },
                    isMobile,
                  ),
                  SizedBox(width: isMobile ? 20 : 24),
                  _buildPlayPauseButton(
                    musicBloc.isPlaying ? Icons.pause : Icons.play_arrow,
                    () => musicBloc.togglePlay(index),
                    isMobile,
                  ),
                  SizedBox(width: isMobile ? 20 : 24),
                  _buildControlButton(
                    Icons.forward_10,
                    isMobile ? 28 : 32,
                    () {
                      musicBloc.seekTo(Duration(
                          milliseconds: (musicBloc.position.inMilliseconds + 10000)
                              .clamp(0, musicBloc.duration.inMilliseconds)));
                    },
                    isMobile,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButton(IconData icon, double size, VoidCallback onPressed, bool isMobile) {
    return Container(
      width: isMobile ? 44 : 52,
      height: isMobile ? 44 : 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: size),
        color: primaryColor,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPlayPauseButton(IconData icon, VoidCallback onPressed, bool isMobile) {
    return Container(
      width: isMobile ? 56 : 64,
      height: isMobile ? 56 : 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: isMobile ? 28 : 32),
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildMusicList(double screenWidth, bool isMobile, bool isTablet) {
    return Expanded(
      child: Consumer<MusicBloc>(
        builder: (context, musicBloc, _) {
          if (musicBloc.filteredMusics.isEmpty && musicBloc.allMusics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note_outlined,
                    size: isMobile ? 48 : 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading music...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                ],
              ),
            );
          } else if (musicBloc.filteredMusics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: isMobile ? 48 : 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No music found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await musicBloc.refreshMusics();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 8),
              itemCount: musicBloc.filteredMusics.length,
              itemBuilder: (context, index) {
                final music = musicBloc.filteredMusics[index];
                final isCurrent = musicBloc.currentlyPlayingIndex == index;
                final isPlaying = isCurrent && musicBloc.isPlaying;

                return Padding(
                  padding: EdgeInsets.only(bottom: isMobile ? 8.0 : 12.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 800 : double.infinity,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                      border: Border.all(
                        color: isCurrent ? primaryColor : Colors.grey.shade300,
                        width: isCurrent ? 2 : 1,
                      ),
                      color: isCurrent ? primaryColor.withOpacity(0.05) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: isCurrent 
                              ? primaryColor.withOpacity(0.1)
                              : Colors.grey.shade200,
                          blurRadius: isCurrent ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                        onTap: () => musicBloc.togglePlay(index),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                          child: Row(
                            children: [
                              // Music icon
                              Container(
                                width: isMobile ? 40 : 48,
                                height: isMobile ? 40 : 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrent 
                                      ? primaryColor.withOpacity(0.1)
                                      : Colors.grey.shade100,
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  color: isCurrent ? primaryColor : Colors.grey.shade600,
                                  size: isMobile ? 20 : 24,
                                ),
                              ),
                              
                              SizedBox(width: isMobile ? 12 : 16),
                              
                              // Music name
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      musicBloc.formatMusicName(music.name),
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                        color: isCurrent ? primaryColor : Colors.grey.shade800,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        isPlaying ? 'Now playing' : 'Paused',
                                        style: TextStyle(
                                          fontSize: isMobile ? 12 : 14,
                                          color: primaryColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              // Play/pause button
                              Container(
                                width: isMobile ? 44 : 52,
                                height: isMobile ? 44 : 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: isMobile ? 24 : 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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