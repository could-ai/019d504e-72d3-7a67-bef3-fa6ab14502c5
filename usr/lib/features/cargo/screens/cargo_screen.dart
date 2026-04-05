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

  Future<void> _createShipment() async {
    final pickupController = TextEditingController();
    final deliveryController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Cargo Shipment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pickupController,
              decoration: const InputDecoration(labelText: 'Pickup Address'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deliveryController,
              decoration: const InputDecoration(labelText: 'Delivery Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final userId = _supabase.auth.currentUser?.id;
                await _supabase.from('shipments').insert({
                  'user_id': userId,
                  'tracking_number': 'TRK-${DateTime.now().millisecondsSinceEpoch}',
                  'pickup_address': pickupController.text,
                  'delivery_address': deliveryController.text,
                  'status': 'pending',
                });
                if (mounted) {
                  Navigator.pop(context);
                  _fetchShipments();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shipment created successfully!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cargo Delivery')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createShipment,
        child: const Icon(Icons.add),
      ),
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
                        subtitle: Text('To: ${shipment['delivery_address']}\nStatus: ${shipment['status']}'),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
    );
  }
}
