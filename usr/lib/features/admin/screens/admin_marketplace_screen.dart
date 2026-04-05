import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMarketplaceScreen extends StatefulWidget {
  const AdminMarketplaceScreen({super.key});

  @override
  State<AdminMarketplaceScreen> createState() => _AdminMarketplaceScreenState();
}

class _AdminMarketplaceScreenState extends State<AdminMarketplaceScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await _supabase.from('products').select('*, categories(name)').order('created_at', ascending: false);
      setState(() {
        _products = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  Future<void> _approveProduct(Map<String, dynamic> product) async {
    try {
      await _supabase.from('products').update({'approved': true}).eq('id', product['id']);
      _fetchProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product approved!')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Marketplace')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: Text(product['name']),
                    subtitle: Text('Category: ${product['categories']['name']} • Stock: ${product['stock_quantity']} • $${product['price']}'),
                    trailing: product['approved'] == true
                        ? const Chip(label: Text('Approved'), backgroundColor: Colors.green[100])
                        : ElevatedButton(
                            onPressed: () => _approveProduct(product),
                            child: const Text('Approve'),
                          ),
                  ),
                );
              },
            ),
    );
  }
}