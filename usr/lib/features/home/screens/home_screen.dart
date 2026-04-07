import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late TabController _tabController;
  List<dynamic> _featuredPackages = [];
  List<dynamic> _featuredHotels = [];
  List<dynamic> _featuredFlights = [];
  List<dynamic> _featuredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchFeaturedData();
  }

  Future<void> _fetchFeaturedData() async {
    try {
      final packages = await _supabase.from('travel_packages').select('*, hotels(name)').limit(4);
      final hotels = await _supabase.from('hotels').select().limit(4);
      final flights = await _supabase.from('flights').select().limit(4);
      final products = await _supabase.from('products').select('*, categories(name)').limit(8);

      setState(() {
        _featuredPackages = packages;
        _featuredHotels = hotels;
        _featuredFlights = flights;
        _featuredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching featured data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section with Search Tabs
                  _buildHeroSection(),
                  const SizedBox(height: 32),

                  // Featured Packages
                  _buildSection('Featured Hajj & Umrah Packages', _featuredPackages, _buildPackageCard, '/travel'),
                  const SizedBox(height: 32),

                  // Featured Hotels
                  _buildSection('Top Hotels', _featuredHotels, _buildHotelCard, '/hotels'),
                  const SizedBox(height: 32),

                  // Featured Flights
                  _buildSection('Popular Flights', _featuredFlights, _buildFlightCard, '/flights'),
                  const SizedBox(height: 32),

                  // Featured Products
                  _buildSection('Marketplace Products', _featuredProducts, _buildProductCard, '/marketplace'),
                  const SizedBox(height: 32),

                  // App Download Section
                  _buildAppDownloadSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.handshake, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Iskudan Cooperative',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Global Travel & Commerce Partner',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            // Search Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(icon: Icon(Icons.flight), text: 'Flights'),
                      Tab(icon: Icon(Icons.hotel), text: 'Hotels'),
                      Tab(icon: Icon(Icons.mosque), text: 'Hajj & Umrah'),
                      Tab(icon: Icon(Icons.document_scanner), text: 'Visa'),
                    ],
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                  SizedBox(
                    height: 120,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSearchTab('Search Flights', Icons.flight, '/flight_search'),
                        _buildSearchTab('Search Hotels', Icons.hotel, '/hotel_search'),
                        _buildSearchTab('Browse Packages', Icons.mosque, '/travel'),
                        _buildSearchTab('Apply for Visa', Icons.document_scanner, '/visa'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> items, Widget Function(dynamic) builder, String viewAllRoute) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, viewAllRoute),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: builder(items[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(dynamic package) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.mosque, size: 48)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(package['name'] ?? 'Package', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${package['duration_days']} days • \$${package['price']}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelCard(dynamic hotel) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.hotel, size: 48)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel['name'] ?? 'Hotel', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(hotel['address'] ?? '', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightCard(dynamic flight) {
    return Card(
      child: SizedBox(
        width: 250,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(flight['airline'] ?? 'Airline', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Flight: ${flight['flight_number']}', style: const TextStyle(fontSize: 14)),
              Text('${flight['seats_available']} seats available', style: const TextStyle(fontSize: 12, color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.shopping_bag, size: 40)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Product',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('\$${product['price']}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDownloadSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.phone_android, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'Download Our Mobile App',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Available on iOS and Android',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDownloadButton('App Store', Icons.apple),
              const SizedBox(width: 16),
              _buildDownloadButton('Google Play', Icons.android),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(String store, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(store),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade900,
      ),
    );
  }
}
