import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CargoTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> shipment;

  const CargoTrackingScreen({super.key, required this.shipment});

  @override
  State<CargoTrackingScreen> createState() => _CargoTrackingScreenState();
}

class _CargoTrackingScreenState extends State<CargoTrackingScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await _supabase
          .from('cargo_events')
          .select()
          .eq('shipment_id', widget.shipment['id'])
          .order('timestamp', ascending: false);

      setState(() {
        _events = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tracking events: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track: ${widget.shipment['tracking_number']}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From: ${widget.shipment['pickup_address']}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('To: ${widget.shipment['delivery_address']}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Status: ${widget.shipment['status']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (widget.shipment['estimated_delivery_date'] != null)
                            Text('Est. Delivery: ${widget.shipment['estimated_delivery_date']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Tracking Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _events.isEmpty
                        ? const Center(child: Text('No tracking events yet.'))
                        : ListView.builder(
                            itemCount: _events.length,
                            itemBuilder: (context, index) {
                              final event = _events[index];
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: Colors.blue),
                                title: Text(event['event_type']),
                                subtitle: Text('${event['location']} • ${event['timestamp']}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}