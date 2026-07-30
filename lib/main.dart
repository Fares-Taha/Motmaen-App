// main.dart - Updated with responsive theme management
import 'package:flutter/material.dart';
import 'package:motmaen/screens/onboarding_screens.dart';
import 'package:motmaen/services/database_helper.dart';
import 'package:motmaen/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'package:motmaen/services/motmaen_theme.dart';

// Theme Provider for managing theme state across the app
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initDatabase();
  runApp(const MotmaenApp());
}

class MotmaenApp extends StatelessWidget {
  const MotmaenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Motmaen',
            theme: themeProvider.isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;
    final isLoggedIn = await _authService.isUserLoggedIn();

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isFirstLaunch = isFirstLaunch;
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return SplashScreen(isDarkMode: themeProvider.isDarkMode);
    }

    if (_isFirstLaunch) {
      return const OnboardingScreens();
    }

    return _isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}

class SplashScreen extends StatelessWidget {
  final bool isDarkMode;

  const SplashScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDarkMode 
        ? AppThemes.darkBackground 
        : Colors.white;
    final textColor = isDarkMode 
        ? Colors.white 
        : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash.png',
              width: 450,
              height: 300,
            ),
            Text(
              'Your smart companion for diabetes care',
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}