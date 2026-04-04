import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CooperativeScreen extends StatefulWidget {
  const CooperativeScreen({super.key});

  @override
  State<CooperativeScreen> createState() => _CooperativeScreenState();
}

class _CooperativeScreenState extends State<CooperativeScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _memberData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  Future<void> _fetchMemberData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('cooperative_members')
          .select()
          .eq('user_id', userId)
          .single();

      setState(() {
        _memberData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cooperative'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabase.auth.signOut();
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Balance Card
              Card(
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Contributions',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${_memberData?['contributions'] ?? '0.00'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dividends', style: TextStyle(color: Colors.white70)),
                              Text('+\$${_memberData?['dividends'] ?? '0.00'}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text('ID: ${_memberData?['member_id'] ?? 'Pending'}', style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionBtn(context, Icons.add_circle_outline, 'Contribute'),
                  _buildActionBtn(context, Icons.account_balance, 'Withdraw'),
                  _buildActionBtn(context, Icons.history, 'History'),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Transactions (Placeholder until payments table is populated)
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('No recent transactions found.', style: TextStyle(color: Colors.grey))),
            ],
          ),
    );
  }

  Widget _buildActionBtn(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
