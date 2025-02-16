import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prontin/pages/login_page.dart';
import 'package:prontin/pages/main_page.dart';
import 'package:prontin/services/boards_services.dart';
import 'package:prontin/services/lists_services.dart';
import 'package:prontin/services/notepads_services.dart';
import 'package:prontin/services/tasks_services.dart';
import 'package:prontin/services/users_services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var options = const FirebaseOptions(
      apiKey: "AIzaSyAmX4xh6Ot-82I6FVnd4CLkZ05VYMD6Z1E",
      projectId: "prontin-b4b5f",
      messagingSenderId: "79635579998",
      appId: "1:79635579998:web:78203e29103871b7d4a0cf");

  if (kIsWeb) {
    await Firebase.initializeApp(options: options);
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsersServices>(
          create: (_) => UsersServices(),
          lazy: false,
        ),
        ChangeNotifierProvider<NotepadsServices>(
          create: (_) => NotepadsServices(),
        ),
        ChangeNotifierProvider<BoardsServices>(
          create: (_) => BoardsServices(),
        ),
        ChangeNotifierProvider<ListsServices>(
          create: (_) => ListsServices(),
        ),
        ChangeNotifierProvider<TasksServices>(
          create: (_) => TasksServices(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Prontin',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 30, 137, 137),
          fontFamily: 'Questrial',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            bodySmall: TextStyle(color: Colors.white),
          ),
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 111, 190, 190)),
          useMaterial3: true,
        ),
        home:
            LoginPage(), // 🔥 Agora usamos o MainPage para decidir a tela inicial
      ),
    );
  }
}
