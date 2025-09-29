import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/user_provider.dart';
import 'screens/user_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Flutter CRUD con ReqRes API',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue.shade700,

          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade700),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),

          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            elevation: 4,
          ),

          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        home: const UserListScreen(),
        routes: {
          '/users': (_) => const UserListScreen(),
        },

        onUnknownRoute: (_) {
          return MaterialPageRoute(
            builder: (_) => const UserListScreen(),
          );
        },
      ),
    );
  }
}
