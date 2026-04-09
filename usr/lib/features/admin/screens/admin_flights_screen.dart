import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminFlightsScreen extends StatefulWidget {
  const AdminFlightsScreen({super.key});

  @override
  State<AdminFlightsScreen> createState() => _AdminFlightsScreenState();
}

class _AdminFlightsScreenState extends State<AdminFlightsScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFlightBookings();
  }

  Future<void> _fetchFlightBookings() async {
    try {
      final response = await _supabase
          .from('flight_bookings')
          .select('*, users(full_name, email), flights(airline, flight_number, departure_date, arrival_date)')
          .order('created_at', ascending: false);

      setState(() {
        _bookings = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading flight bookings: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(Map<String, dynamic> booking) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Update Flight Status'),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(context, 'pending'), child: const Text('Pending')),
          SimpleDialogOption(onPressed: () => Navigator.pop(context, 'confirmed'), child: const Text('Confirmed')),
          SimpleDialogOption(onPressed: () => Navigator.pop(context, 'cancelled'), child: const Text('Cancelled')),
        ],
      ),
    );

    if (newStatus != null && newStatus != booking['booking_status']) {
      try {
        await _supabase.from('flight_bookings').update({'booking_status': newStatus}).eq('id', booking['id']);
        _fetchFlightBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Flight Bookings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${booking['users']['full_name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('PNR: ${booking['pnr']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${booking['flights']['airline']} - ${booking['flights']['flight_number']}'),
                        Text('Departs: ${booking['flights']['departure_date']}'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(booking['booking_status']),
                              backgroundColor: booking['booking_status'] == 'confirmed' ? Colors.green[100] : Colors.orange[100],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _updateStatus(booking),
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
