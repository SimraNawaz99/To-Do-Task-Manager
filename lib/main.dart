import 'package:flutter/material.dart';
import 'splash.dart';
import 'login.dart';
import 'signup.dart';
import 'forgot_password.dart';
import 'home.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'settings.dart';
import 'categories.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final ValueNotifier<ThemeMode> appThemeMode =
ValueNotifier<ThemeMode>(ThemeMode.light);

void goToRoute(String routeName) {
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    routeName,
        (route) => false,
  );
}

void openRoute(String routeName) {
  navigatorKey.currentState?.pushNamed(routeName);
}

void main() {
  runApp(const TaskFlowApp());
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'To-Do Task Manager',

          themeMode: currentThemeMode,

          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFFF7F2FF),

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 3,
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
                size: 26,
              ),
            ),

            drawerTheme: const DrawerThemeData(
              backgroundColor: Colors.white,
            ),

            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.deepPurple,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              iconSize: 30,
              elevation: 6,
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
              ),
            ),

            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                side: const BorderSide(
                  color: Colors.deepPurple,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              labelStyle: const TextStyle(
                color: Colors.deepPurple,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: const TextStyle(
                color: Colors.deepPurple,
                fontSize: 16,
              ),
              prefixIconColor: Colors.deepPurple,
              suffixIconColor: Colors.deepPurple,
            ),

            cardTheme: CardThemeData(
              elevation: 4,
              color: Colors.white,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: const EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 3,
              ),
            ),

            listTileTheme: const ListTileThemeData(
              iconColor: Colors.deepPurple,
              selectedColor: Colors.deepPurple,
              selectedTileColor: Color(0xFFEDE7F6),
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              subtitleTextStyle: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),

            dropdownMenuTheme: const DropdownMenuThemeData(
              textStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            dividerTheme: const DividerThemeData(
              color: Color(0xFFE0E0E0),
              thickness: 1,
            ),

            snackBarTheme: SnackBarThemeData(
              backgroundColor: Colors.deepPurple,
              contentTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              behavior: SnackBarBehavior.floating,
            ),

            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              headlineMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              headlineSmall: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              titleLarge: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              titleMedium: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              titleSmall: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              bodyLarge: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              bodyMedium: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              bodySmall: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              labelLarge: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              labelMedium: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              labelSmall: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: const Color(0xFF121212),

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 3,
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
                size: 26,
              ),
            ),

            drawerTheme: const DrawerThemeData(
              backgroundColor: Color(0xFF1E1E1E),
            ),

            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Colors.deepPurpleAccent,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              iconSize: 30,
              elevation: 6,
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 14,
                ),
              ),
            ),

            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurpleAccent,
                side: const BorderSide(
                  color: Colors.deepPurpleAccent,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurpleAccent,
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.deepPurpleAccent,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.deepPurpleAccent,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              labelStyle: const TextStyle(
                color: Colors.deepPurpleAccent,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              prefixIconColor: Colors.deepPurpleAccent,
              suffixIconColor: Colors.deepPurpleAccent,
            ),

            cardTheme: CardThemeData(
              elevation: 4,
              color: const Color(0xFF1E1E1E),
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: const EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 3,
              ),
            ),

            listTileTheme: const ListTileThemeData(
              iconColor: Colors.deepPurpleAccent,
              selectedColor: Colors.deepPurpleAccent,
              selectedTileColor: Color(0xFF2A2140),
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              subtitleTextStyle: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            dropdownMenuTheme: const DropdownMenuThemeData(
              textStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),

            dividerTheme: const DividerThemeData(
              color: Color(0xFF333333),
              thickness: 1,
            ),

            snackBarTheme: SnackBarThemeData(
              backgroundColor: Colors.deepPurple,
              contentTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              behavior: SnackBarBehavior.floating,
            ),

            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              headlineMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              headlineSmall: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              titleLarge: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              titleMedium: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              titleSmall: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              bodyLarge: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              bodyMedium: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              bodySmall: TextStyle(
                fontSize: 14,
                color: Colors.white60,
              ),
              labelLarge: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              labelMedium: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              labelSmall: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),

          initialRoute: '/splash',

          routes: {
            '/splash': (context) => const SplashScreen(),
            '/signup': (context) => SignupScreen(),
            '/login': (context) => const LoginScreen(),
            '/forgot_password': (context) => ForgotPasswordScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/home': (context) => const HomeScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/categories': (context) => const CategoriesScreen(),
          },
        );
      },
    );
  }
}