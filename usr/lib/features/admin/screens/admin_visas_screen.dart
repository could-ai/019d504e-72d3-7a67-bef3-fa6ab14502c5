import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVisasScreen extends StatefulWidget {
  const AdminVisasScreen({super.key});

  @override
  State<AdminVisasScreen> createState() => _AdminVisasScreenState();
}

class _AdminVisasScreenState extends State<AdminVisasScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _visas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVisas();
  }

  Future<void> _fetchVisas() async {
    try {
      final response = await _supabase
          .from('visa')
          .select('*, users(full_name, passport_number, nationality)')
          .order('created_at', ascending: false);

      setState(() {
        _visas = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading visas: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(Map<String, dynamic> visa) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Update Visa Status'),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(context, 'pending'), child: const Text('Pending')),
          SimpleDialogOption(onPressed: () => Navigator.pop(context, 'approved'), child: const Text('Approved')),
          SimpleDialogOption(onPressed: () => Navigator.pop(context, 'rejected'), child: const Text('Rejected')),
        ],
      ),
    );

    if (newStatus != null && newStatus != visa['status']) {
      try {
        await _supabase.from('visa').update({'status': newStatus}).eq('id', visa['id']);
        _fetchVisas();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visa status updated!')));
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
      appBar: AppBar(title: const Text('Manage Visa Applications')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _visas.length,
              itemBuilder: (context, index) {
                final visa = _visas[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${visa['users']['full_name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('${visa['visa_number']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Destination: ${visa['country']}'),
                        Text('Passport: ${visa['users']['passport_number']} (${visa['users']['nationality']})'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(visa['status']),
                              backgroundColor: visa['status'] == 'approved' ? Colors.green[100] : (visa['status'] == 'rejected' ? Colors.red[100] : Colors.orange[100]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _updateStatus(visa),
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
