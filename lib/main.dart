import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/player_provider.dart';
import 'screens/home_screen.dart';
import 'screens/deck_builder_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    // Ignore error if .env file is missing (e.g. in production or if using dart-define)
    debugPrint("Note: .env file not found or could not be loaded. Using environment variables or defaults.");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerProvider(),
      child: MaterialApp(
        title: 'Clash Royale Stats & Roast',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF8A2BE2),
          scaffoldBackgroundColor: const Color(0xFF0F1419),
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8A2BE2),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/deck-builder': (context) => const DeckBuilderScreen(),
        },
      ),
    );
  }
}
