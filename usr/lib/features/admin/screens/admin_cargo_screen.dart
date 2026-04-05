import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCargoScreen extends StatefulWidget {
  const AdminCargoScreen({super.key});

  @override
  State<AdminCargoScreen> createState() => _AdminCargoScreenState();
}

class _AdminCargoScreenState extends State<AdminCargoScreen> {
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
      final response = await _supabase
          .from('shipments')
          .select('*, users(full_name)')
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

  Future<void> _updateStatus(Map<String, dynamic> shipment) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Update Shipment Status'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'pending'),
            child: const Text('Pending'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'in_transit'),
            child: const Text('In Transit'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'delivered'),
            child: const Text('Delivered'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'cancelled'),
            child: const Text('Cancelled'),
          ),
        ],
      ),
    );

    if (newStatus != null && newStatus != shipment['status']) {
      try {
        await _supabase.from('shipments').update({'status': newStatus}).eq('id', shipment['id']);
        _fetchShipments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shipment status updated!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Cargo')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _shipments.length,
              itemBuilder: (context, index) {
                final shipment = _shipments[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${shipment['users']['full_name']} - ${shipment['tracking_number']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('From: ${shipment['pickup_address']}'),
                        Text('To: ${shipment['delivery_address']}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(shipment['status']),
                              backgroundColor: shipment['status'] == 'delivered' ? Colors.green[100] : Colors.orange[100],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _updateStatus(shipment),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}