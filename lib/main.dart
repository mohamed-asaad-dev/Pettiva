import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pettiva_v2/screens/auth.dart';
import 'package:pettiva_v2/screens/fleet_screen.dart';
import 'home.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

final kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 212, 219, 221),
  primary: const Color.fromARGB(255, 0, 23, 41),
  secondary: const Color.fromARGB(255, 255, 255, 255),
);

Future<String> getUserType(String userId) async {
  final response = await FirebaseFirestore.instance
      .collection('users')
      .where('userId', isEqualTo: userId)
      .limit(1)
      .get();

  if (response.docs.isEmpty) {
    return 'client';
  }

  return response.docs.first.data()['userType'] as String;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData) {
            return const AuthScreen();
          }

          final user = snapshot.data!;

          return FutureBuilder<String>(
            future: getUserType(user.uid),
            builder: (context, userTypeSnapshot) {
              if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final userType = userTypeSnapshot.data ?? 'client';

              if (userType == 'fleet') {
                return FleetScreen();
              }

              return const Home();
            },
          );
        },
      ),
      theme: ThemeData(
        colorScheme: kColorScheme,
        cardTheme: CardThemeData().copyWith(color: kColorScheme.primaryFixed),
        textTheme: GoogleFonts.makoTextTheme(ThemeData().textTheme).copyWith(
          titleLarge: GoogleFonts.mako(
            color: kColorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          bodyMedium: GoogleFonts.mako(
            color: kColorScheme.secondary,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
