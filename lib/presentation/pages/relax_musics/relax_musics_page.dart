// File: lib/presentation/pages/relax_musics_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindcare/presentation/pages/relax_musics/bloc/music/music_bloc.dart';
import 'package:mindcare/presentation/pages/relax_musics/bloc/music/music_event.dart';
import 'package:mindcare/presentation/pages/relax_musics/bloc/music/music_state.dart';
import 'package:mindcare/presentation/pages/relax_musics/widgets/music_list_item.dart';
import 'package:provider/provider.dart';


class RelaxMusicsPage extends StatefulWidget {
  const RelaxMusicsPage({Key? key}) : super(key: key);

  @override
  State<RelaxMusicsPage> createState() => _RelaxMusicsPageState();
}

class _RelaxMusicsPageState extends State<RelaxMusicsPage> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    context.read<MusicBloc>().add(FetchRelaxMusics());
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Search bar
              Container(
                decoration: BoxDecoration(
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      context.read<MusicBloc>().add(SearchRelaxMusics(query) as FetchRelaxMusics);
                    } else {
                      context.read<MusicBloc>().add(FetchRelaxMusics());
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Music list
              Expanded(
                child: BlocBuilder<MusicBloc, MusicState>(
                  builder: (context, state) {
                    if (state is MusicLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is MusicLoaded) {
                      return ListView.builder(
                        itemCount: state.musics.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: MusicListItem(
                              music: state.musics[index],
                              onPlay: () {
                                context.read<MusicBloc>().add(
                                  PlayMusic(state.musics[index].id)
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else if (state is MusicError) {
                      return Center(
                        child: Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return const Center(child: Text('No music available'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}