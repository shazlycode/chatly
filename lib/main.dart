import 'package:firebase_core/firebase_core.dart';
import 'package:schooler_chat/screens/chat_screen.dart';

import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:schooler_chat/main_screen.dart';
import 'package:schooler_chat/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
      initialRoute: MainScreen.id,
      routes: {
        MainScreen.id: (context) => MainScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
