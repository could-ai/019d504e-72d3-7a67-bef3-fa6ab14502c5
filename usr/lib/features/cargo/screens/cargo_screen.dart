import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CargoScreen extends StatefulWidget {
  const CargoScreen({super.key});

  @override
  State<CargoScreen> createState() => _CargoScreenState();
}

class _CargoScreenState extends State<CargoScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _shipments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShipments();
  }

  Future<void> _fetchShipments() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('shipments')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _shipments = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading shipments: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargo Delivery')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shipments.isEmpty
              ? const Center(child: Text('No shipments found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _shipments.length,
                  itemBuilder: (context, index) {
                    final shipment = _shipments[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping, color: Colors.blue),
                        title: Text('Tracking: ${shipment['tracking_number']}'),
                        subtitle: Text('Status: ${shipment['status']}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pushNamed(context, '/cargo_tracking', arguments: shipment);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create shipment coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
