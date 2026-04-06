import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../cooperative/screens/cooperative_screen.dart';
import '../hotels/screens/hotel_search_screen.dart';
import '../qr/screens/qr_identity_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  bool _isAdmin = false;
  final _supabase = Supabase.instance.client;

  final List<Widget> _screens = [
    const CooperativeScreen(),
    const HotelSearchScreen(),
    const QrIdentityScreen(),
    const Center(child: Text('Profile Settings')),
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _supabase.from('users').select('role').eq('id', userId).single();
        if (mounted) {
          setState(() {
            _isAdmin = response['role'] == 'admin';
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking admin status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.handshake, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text('Iskudan Cooperative', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Marketplace'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/marketplace');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Cargo Delivery'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cargo');
              },
            ),
            ListTile(
              leading: const Icon(Icons.flight),
              title: const Text('Flights'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/flights');
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Visa Application'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/visa');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/payment');
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('My Bookings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my_bookings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Order Tracking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/order_tracking');
              },
            ),
            if (_isAdmin) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text('ADMINISTRATION', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.red),
                title: const Text('Admin Dashboard', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.red),
                title: const Text('Manage Users', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_users');
                },
              ),
              ListTile(
                leading: const Icon(Icons.hotel, color: Colors.red),
                title: const Text('Manage Bookings', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_bookings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.red),
                title: const Text('Manage Marketplace', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_marketplace');
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping, color: Colors.red),
                title: const Text('Manage Cargo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_cargo');
                },
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Cooperative'),
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Hotels'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Identity'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
