import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select('*, users(full_name), hotels(name), rooms(room_number), beds(bed_number)')
          .order('created_at', ascending: false);

      setState(() {
        _bookings = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
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
                        Text('${booking['users']['full_name']} - ${booking['hotels']['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Room ${booking['rooms']['room_number']} • Bed ${booking['beds']['bed_number']}'),
                        Text('Dates: ${booking['check_in_date']} to ${booking['check_out_date']}'),
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

  Future<void> _updateStatus(Map<String, dynamic> booking) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Update Booking Status'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'pending'),
            child: const Text('Pending'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'confirmed'),
            child: const Text('Confirmed'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'cancelled'),
            child: const Text('Cancelled'),
          ),
        ],
      ),
    );

    if (newStatus != null && newStatus != booking['booking_status']) {
      try {
        await _supabase.from('bookings').update({'booking_status': newStatus}).eq('id', booking['id']);
        _fetchBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking status updated!')),
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
}