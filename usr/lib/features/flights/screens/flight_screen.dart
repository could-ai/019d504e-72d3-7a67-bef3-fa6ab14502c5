import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlightScreen extends StatefulWidget {
  const FlightScreen({super.key});

  @override
  State<FlightScreen> createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _flights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  Future<void> _fetchFlights() async {
    try {
      final response = await _supabase.from('flights').select();
      setState(() {
        _flights = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading flights: $e')),
        );
      }
    }
  }

  Future<void> _bookFlight(Map<String, dynamic> flight) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('flight_bookings').insert({
        'user_id': userId,
        'flight_id': flight['id'],
        'seat_number': 'TBD',
        'pnr': 'PNR${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        'booking_status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flight booked successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book flight: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Booking')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flights.isEmpty
              ? const Center(child: Text('No flights available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _flights.length,
                  itemBuilder: (context, index) {
                    final flight = _flights[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  flight['airline'] ?? 'Unknown Airline',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  flight['flight_number'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Departure: ${flight['departure_date']}'),
                            Text('Arrival: ${flight['arrival_date']}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${flight['seats_available']} seats left', style: const TextStyle(color: Colors.green)),
                                ElevatedButton(
                                  onPressed: () => _bookFlight(flight),
                                  child: const Text('Book Now'),
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
