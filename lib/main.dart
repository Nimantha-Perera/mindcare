import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindcare/firebase_options.dart';
import 'package:mindcare/presentation/pages/authentications/login.dart';
import 'package:mindcare/presentation/pages/home/home_page.dart';
import 'package:mindcare/presentation/pages/mood_detector/mood_detecter.dart';
import 'package:mindcare/presentation/pages/relax_musics/bloc/music/music_bloc.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MusicBloc>(
      create: (_) => MusicBloc(),
      child: MaterialApp(
        title: 'MindCare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
