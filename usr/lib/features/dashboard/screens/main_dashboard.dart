            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/payment');
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('My Bookings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my_bookings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Order Tracking'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/order_tracking');
              },
            ),
            if (_isAdmin) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.red),
                title: const Text('Manage Users', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_users');
                },
              ),
              ListTile(
                leading: const Icon(Icons.hotel, color: Colors.red),
                title: const Text('Manage Bookings', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_bookings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.red),
                title: const Text('Manage Marketplace', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_marketplace');
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping, color: Colors.red),
                title: const Text('Manage Cargo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin_cargo');
                },
              ),
            ],