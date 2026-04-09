import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'integrations/supabase.dart';
import 'core/theme/app_theme.dart';

// Auth
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';

// Dashboard
import 'features/dashboard/screens/main_dashboard.dart';

// Modules
import 'features/marketplace/screens/marketplace_screen.dart';
import 'features/cargo/screens/cargo_screen.dart';
import 'features/flights/screens/flight_screen.dart';
import 'features/visa/screens/visa_screen.dart';

// Payments & Tracking
import 'features/payments/screens/payment_history_screen.dart';
import 'features/hotels/screens/room_booking_screen.dart';
import 'features/hotels/screens/my_bookings_screen.dart';
import 'features/marketplace/screens/order_tracking_screen.dart';
import 'features/cargo/screens/cargo_tracking_screen.dart';

// Admin
import 'features/admin/screens/admin_dashboard.dart';
import 'features/admin/screens/admin_users_screen.dart';
import 'features/admin/screens/admin_bookings_screen.dart';
import 'features/admin/screens/admin_marketplace_screen.dart';
import 'features/admin/screens/admin_cargo_screen.dart';
import 'features/admin/screens/admin_flights_screen.dart';
import 'features/admin/screens/admin_visas_screen.dart';
import 'features/admin/screens/admin_payments_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom error widget to prevent blank screens on error
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.red.shade100,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              details.exceptionAsString(),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  };

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iskudan Cooperative',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const MainDashboard(),
        '/marketplace': (context) => const MarketplaceScreen(),
        '/cargo': (context) => const CargoScreen(),
        '/flights': (context) => const FlightScreen(),
        '/visa': (context) => const VisaScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/payment': (context) => const PaymentHistoryScreen(),
        '/room_booking': (context) => RoomBookingScreen(
            hotel: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
        '/my_bookings': (context) => const MyBookingsScreen(),
        '/order_tracking': (context) => const OrderTrackingScreen(),
        '/cargo_tracking': (context) => CargoTrackingScreen(
            shipment: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
        '/admin_users': (context) => const AdminUsersScreen(),
        '/admin_bookings': (context) => const AdminBookingsScreen(),
        '/admin_marketplace': (context) => const AdminMarketplaceScreen(),
        '/admin_cargo': (context) => const AdminCargoScreen(),
        '/admin_flights': (context) => const AdminFlightsScreen(),
        '/admin_visas': (context) => const AdminVisasScreen(),
        '/admin_payments': (context) => const AdminPaymentsScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final session = snapshot.data?.session;
        if (session != null) {
          return const MainDashboard();
        }
        return const LoginScreen();
      },
    );
  }
}
