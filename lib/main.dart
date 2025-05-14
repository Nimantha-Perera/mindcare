import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindcare/presentation/pages/home/home_page.dart';
import 'package:mindcare/presentation/pages/mood_detector/mood_detecter.dart';
import 'package:mindcare/presentation/pages/relax_musics/bloc/music/music_bloc.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MusicBloc>(  // Changed from Provider to ChangeNotifierProvider
      create: (_) => MusicBloc(),
      child: MaterialApp(
        title: 'MindCare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: HomePage(),
      ),
    );
  }
}