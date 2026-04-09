import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _supabase = Supabase.instance.client;
  
  Map<String, dynamic> _stats = {
    'users': 0,
    'bookings': 0,
    'orders': 0,
    'shipments': 0,
    'visas': 0,
    'revenue': 0.0,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      // Fetch counts concurrently. Grouping similar return types (Future<int>) 
      // avoids the List<Object> type inference error in Future.wait.
      final counts = await Future.wait([
        _supabase.from('users').count(CountOption.exact),
        _supabase.from('bookings').count(CountOption.exact),
        _supabase.from('orders').count(CountOption.exact),
        _supabase.from('shipments').count(CountOption.exact),
        _supabase.from('visa').count(CountOption.exact),
      ]);

      // Fetch payments separately since it returns a List<Map<String, dynamic>>
      final payments = await _supabase.from('payments').select('amount').eq('status', 'success');

      double totalRevenue = 0;
      for (var p in payments) {
        totalRevenue += (p['amount'] as num).toDouble();
      }

      if (mounted) {
        setState(() {
          _stats = {
            'users': counts[0],
            'bookings': counts[1],
            'orders': counts[2],
            'shipments': counts[3],
            'visas': counts[4],
            'revenue': totalRevenue,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading admin stats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Control Center'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchStats,
              child: CustomScrollView(
                slivers: [
                  // Top Stats Overview
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.red[800],
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Platform Overview',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildTopStatCard('Total Revenue', '\$${_stats['revenue'].toStringAsFixed(2)}', Icons.attach_money)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTopStatCard('Total Users', _stats['users'].toString(), Icons.people)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Secondary Stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSmallStat('Bookings', _stats['bookings'].toString(), Icons.hotel, Colors.purple),
                          _buildSmallStat('Orders', _stats['orders'].toString(), Icons.shopping_cart, Colors.orange),
                          _buildSmallStat('Cargo', _stats['shipments'].toString(), Icons.local_shipping, Colors.blue),
                          _buildSmallStat('Visas', _stats['visas'].toString(), Icons.document_scanner, Colors.teal),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        'Management Modules',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Management Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      delegate: SliverChildListDelegate([
                        _buildModuleCard(context, 'Users & Roles', Icons.manage_accounts, Colors.blue, '/admin_users'),
                        _buildModuleCard(context, 'Hotel Bookings', Icons.hotel, Colors.purple, '/admin_bookings'),
                        _buildModuleCard(context, 'Marketplace', Icons.storefront, Colors.orange, '/admin_marketplace'),
                        _buildModuleCard(context, 'Cargo & Logistics', Icons.local_shipping, Colors.green, '/admin_cargo'),
                        _buildModuleCard(context, 'Flight Bookings', Icons.flight, Colors.lightBlue, '/admin_flights'),
                        _buildModuleCard(context, 'Visa Applications', Icons.document_scanner, Colors.teal, '/admin_visas'),
                        _buildModuleCard(context, 'Payments & Finance', Icons.payments, Colors.amber, '/admin_payments'),
                        _buildModuleCard(context, 'System Analytics', Icons.analytics, Colors.indigo, null), // Placeholder for future
                      ]),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }

  Widget _buildTopStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 24,
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, IconData icon, Color color, String? route) {
    return InkWell(
      onTap: route != null ? () => Navigator.pushNamed(context, route) : () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Module coming soon')));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
