import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('orders')
          .select('*, order_items(*, products(name))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _orders = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final items = order['order_items'] as List<dynamic>;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order #${order['id']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Chip(
                                  label: Text(order['order_status']),
                                  backgroundColor: order['order_status'] == 'delivered' ? Colors.green[100] : Colors.orange[100],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Total: \$${order['total_amount']}'),
                            const SizedBox(height: 8),
                            const Text('Items:', style: TextStyle(fontWeight: FontWeight.w500)),
                            ...items.map<Widget>((item) => Text('• ${item['products']['name']} (x${item['quantity']})')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
