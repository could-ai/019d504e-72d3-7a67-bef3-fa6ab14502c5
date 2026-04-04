import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    try {
      final response = await _supabase.from('hotels').select();
      setState(() {
        _hotels = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading hotels: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Accommodation'),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search hotels in Makkah, Madinah...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('Makkah', false),
                _buildFilterChip('Madinah', false),
                _buildFilterChip('Shared Rooms', false),
                _buildFilterChip('Special Needs', false),
              ],
            ),
          ),

          // Hotel List from Database
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _hotels.isEmpty 
                ? const Center(child: Text('No hotels found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _hotels.length,
                    itemBuilder: (context, index) {
                      final hotel = _hotels[index];
                      return _buildHotelCard(
                        context,
                        hotel['name'] ?? 'Unknown Hotel',
                        hotel['address'] ?? 'Unknown Location',
                        (hotel['rating'] ?? 0).toDouble(),
                        hotel['image_url'],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, String name, String location, double rating, String? imageUrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: imageUrl != null 
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 50, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(' $rating', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(location, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text('View Rooms'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
