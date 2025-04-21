// File: lib/presentation/widgets/music_list_item.dart

import 'package:flutter/material.dart';
import 'package:mindcare/domain/entities/music.dart';


class MusicListItem extends StatelessWidget {
  final Music music;
  final VoidCallback onPlay;

  const MusicListItem({
    Key? key,
    required this.music,
    required this.onPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    music.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Line divider
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Play button
            GestureDetector(
              onTap: onPlay,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF00875A), // Green color for play button
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    music.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}