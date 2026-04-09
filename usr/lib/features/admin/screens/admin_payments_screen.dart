import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    try {
      final response = await _supabase
          .from('payments')
          .select('*, users(full_name, email)')
          .order('created_at', ascending: false);

      setState(() {
        _payments = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payments: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Payments')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: payment['status'] == 'success' ? Colors.green[100] : Colors.red[100],
                      child: Icon(
                        payment['status'] == 'success' ? Icons.check : Icons.close,
                        color: payment['status'] == 'success' ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text('\$${payment['amount']} via ${payment['method']}'),
                    subtitle: Text('${payment['users']['full_name']}\nRef: ${payment['transaction_reference']}'),
                    isThreeLine: true,
                    trailing: Text(
                      payment['created_at'].toString().split('T')[0],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
