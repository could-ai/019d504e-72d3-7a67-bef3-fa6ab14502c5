import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../cooperative/screens/cooperative_screen.dart';
import '../../hotel/screens/hotel_search_screen.dart';
import '../../qr/screens/qr_identity_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  final _supabase = Supabase.instance.client;
  bool _isAdmin = false;
  String _userName = '';

  final List<Widget> _screens = [
    const CooperativeScreen(),
    const HotelSearchScreen(),
    const QrIdentityScreen(),
    const Center(child: Text('Profile & Settings')),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('users')
          .select('role, full_name')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _isAdmin = response['role'] == 'admin';
          _userName = response['full_name'] ?? 'User';
        });
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iskudan Cooperative'),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userName),
              accountEmail: Text(_supabase.auth.currentUser?.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF004D40)),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF004D40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
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
              title: const Text('Flight Booking'),
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
            if (_isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                title: const Text('Admin Dashboard', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await _supabase.auth.signOut();
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Co-op',
          ),
          NavigationDestination(
            icon: Icon(Icons.hotel_outlined),
            selectedIcon: Icon(Icons.hotel),
            label: 'Hotels',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'My QR',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
