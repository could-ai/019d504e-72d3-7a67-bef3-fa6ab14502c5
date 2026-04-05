import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomBookingScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;

  const RoomBookingScreen({super.key, required this.hotel});

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _rooms = [];
  bool _isLoading = true;
  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('*, beds(*)')
          .eq('hotel_id', widget.hotel['id']);

      setState(() {
        _rooms = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading rooms: $e')),
        );
      }
    }
  }

  Future<void> _bookRoom(Map<String, dynamic> room, Map<String, dynamic> bed) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Create booking
      await _supabase.from('bookings').insert({
        'user_id': userId,
        'hotel_id': widget.hotel['id'],
        'room_id': room['id'],
        'bed_id': bed['id'],
        'check_in_date': _checkIn.toIso8601String(),
        'check_out_date': _checkOut.toIso8601String(),
        'booking_status': 'confirmed',
        'qr_code': 'QR-${DateTime.now().millisecondsSinceEpoch}',
      });

      // Update bed assignment
      await _supabase.from('beds').update({'assigned_user_id': userId}).eq('id', bed['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book at ${widget.hotel['name']}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date Selection
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker('Check-in', _checkIn, (date) => setState(() => _checkIn = date)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker('Check-out', _checkOut, (date) => setState(() => _checkOut = date)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      final beds = room['beds'] as List<dynamic>;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Room ${room['room_number']} - ${room['room_type']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('Capacity: ${room['capacity']} • Special Needs: ${room['special_needs'] ? 'Yes' : 'No'}'),
                              const SizedBox(height: 16),
                              const Text('Available Beds:', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: beds.map<Widget>((bed) {
                                  final isOccupied = bed['assigned_user_id'] != null;
                                  return ElevatedButton(
                                    onPressed: isOccupied ? null : () => _bookRoom(room, bed),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isOccupied ? Colors.grey : Theme.of(context).colorScheme.primary,
                                    ),
                                    child: Text('Bed ${bed['bed_number']}'),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text('${date.day}/${date.month}/${date.year}'),
      ),
    );
  }
}