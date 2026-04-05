import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VisaScreen extends StatefulWidget {
  const VisaScreen({super.key});

  @override
  State<VisaScreen> createState() => _VisaScreenState();
}

class _VisaScreenState extends State<VisaScreen> {
  final _supabase = Supabase.instance.client;
  final _countryController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _myVisas = [];

  @override
  void initState() {
    super.initState();
    _fetchVisas();
  }

  Future<void> _fetchVisas() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase.from('visa').select().eq('user_id', userId);
      setState(() {
        _myVisas = response;
      });
    } catch (e) {
      debugPrint('Error fetching visas: $e');
    }
  }

  Future<void> _applyForVisa() async {
    if (_countryController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('visa').insert({
        'user_id': userId,
        'country': _countryController.text,
        'visa_number': 'V-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
      });

      _countryController.clear();
      await _fetchVisas();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visa application submitted!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visa Application')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apply for New Visa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Destination Country',
                prefixIcon: Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _applyForVisa,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Application'),
              ),
            ),
            const SizedBox(height: 32),
            const Text('My Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: _myVisas.isEmpty
                  ? const Center(child: Text('No applications yet.'))
                  : ListView.builder(
                      itemCount: _myVisas.length,
                      itemBuilder: (context, index) {
                        final visa = _myVisas[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.document_scanner, color: Colors.blue),
                            title: Text(visa['country']),
                            subtitle: Text('Visa No: ${visa['visa_number']}'),
                            trailing: Chip(
                              label: Text(visa['status']),
                              backgroundColor: visa['status'] == 'approved' ? Colors.green[100] : Colors.orange[100],
                            ),
                          ),
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
