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

          // Paleta personalizada
          primaryColor: const Color(0xFF2C3E50), // Un azul grisáceo profundo
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2C3E50),
            primary: const Color(0xFF2C3E50),
            secondary: const Color(0xFF16A085), // Verde azulado
          ),

          // AppBar con estilo menos genérico
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2C3E50),
            foregroundColor: Colors.white,
            elevation: 1.5,
            centerTitle: false, // más natural sin centrar
            titleTextStyle: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          // Botones elevados con colores y paddings únicos
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A085),
              foregroundColor: Colors.white,
              elevation: 1.5,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // no 8
              ),
            ),
          ),

          // Campos de texto con bordes y paddings personalizados
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFBFC9CA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF16A085)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
          ),

          // FAB más discreto
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF16A085),
            foregroundColor: Colors.white,
            elevation: 3,
          ),

          // Snackbars con estilo más simple
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.fixed, // en vez de floating
            backgroundColor: Colors.grey[850],
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
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
