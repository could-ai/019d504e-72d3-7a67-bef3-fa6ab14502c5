import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String description;

  const PaymentScreen({super.key, required this.amount, required this.description});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _supabase = Supabase.instance.client;
  String _selectedMethod = 'EVC Plus';
  bool _isProcessing = false;

  final List<String> _paymentMethods = ['EVC Plus', 'Zaad', 'Sahal', 'Waafi Pay', 'Edahab', 'Bank', 'Card'];

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Insert payment record
      await _supabase.from('payments').insert({
        'user_id': userId,
        'amount': widget.amount,
        'currency': 'USD',
        'method': _selectedMethod,
        'status': 'success',
        'transaction_reference': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Complete Your Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount: $${widget.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.description),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) => setState(() => _selectedMethod = value!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}