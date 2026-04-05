import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _supabase = Supabase.instance.client;
  Map<String, int> _stats = {
    'users': 0,
    'bookings': 0,
    'orders': 0,
    'shipments': 0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final users = await _supabase.from('users').select('id').count(CountOption.exact);
      final bookings = await _supabase.from('bookings').select('id').count(CountOption.exact);
      final orders = await _supabase.from('orders').select('id').count(CountOption.exact);
      final shipments = await _supabase.from('shipments').select('id').count(CountOption.exact);

      setState(() {
        _stats = {
          'users': users.count ?? 0,
          'bookings': bookings.count ?? 0,
          'orders': orders.count ?? 0,
          'shipments': shipments.count ?? 0,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Admin stats error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard('Total Users', _stats['users'].toString(), Icons.people, Colors.blue),
                _buildStatCard('Hotel Bookings', _stats['bookings'].toString(), Icons.hotel, Colors.purple),
                _buildStatCard('Market Orders', _stats['orders'].toString(), Icons.shopping_cart, Colors.orange),
                _buildStatCard('Cargo Shipments', _stats['shipments'].toString(), Icons.local_shipping, Colors.green),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
