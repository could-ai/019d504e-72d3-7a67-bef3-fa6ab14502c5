import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/main_dashboard.dart';

void main() {
  // Ensure bindings are initialized before runApp, which helps prevent blank screens on web
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IskudanApp());
}

class IskudanApp extends StatelessWidget {
  const IskudanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iskudan Cooperative',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const MainDashboard(),
      },
      // This builder catches any rendering errors and displays them on screen
      // instead of showing a completely blank white screen.
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Render Error: ${errorDetails.exceptionAsString()}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        };
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
