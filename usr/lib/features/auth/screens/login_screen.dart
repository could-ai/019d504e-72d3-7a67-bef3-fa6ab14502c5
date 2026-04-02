import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPhoneLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Placeholder
                Icon(
                  Icons.handshake_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Iskudan Cooperative',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Travel, Commerce & Finance Ecosystem',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),

                // Toggle Login Method
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Phone OTP'),
                      selected: _isPhoneLogin,
                      onSelected: (val) => setState(() => _isPhoneLogin = true),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('Email'),
                      selected: !_isPhoneLogin,
                      onSelected: (val) => setState(() => _isPhoneLogin = false),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Input Fields
                if (_isPhoneLogin)
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      hintText: '+252 ...',
                    ),
                    keyboardType: TextInputType.phone,
                  )
                else ...[
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                ],

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement actual Supabase Auth
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  child: Text(_isPhoneLogin ? 'Send OTP' : 'Login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to Registration
                  },
                  child: const Text('New to Iskudan? Join the Cooperative'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
