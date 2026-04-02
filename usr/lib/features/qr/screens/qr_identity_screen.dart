import 'package:flutter/material.dart';

class QrIdentityScreen extends StatelessWidget {
  const QrIdentityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Identity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your Official Iskudan Pass',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            
            // QR Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    // Mock QR Code
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.qr_code_2, size: 150, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ahmed Ali',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Passport: P12345678',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const Divider(height: 32),
                    
                    // Booking Details
                    _buildDetailRow('Visa Status', 'Approved', Colors.green),
                    const SizedBox(height: 12),
                    _buildDetailRow('Hotel', 'Al Safwah Royale', Colors.black87),
                    const SizedBox(height: 12),
                    _buildDetailRow('Room / Bed', 'Room 402 / Bed B', Colors.black87),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.security),
              label: const Text('Generate New OTP for Access'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}
