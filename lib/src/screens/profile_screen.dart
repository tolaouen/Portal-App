import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import 'info_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final isLoggedIn = controller.isLoggedIn;
    final user = controller.currentUser;
    final fullName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Guest User';
    final email = user?.email ?? 'Not signed in';

    return Scaffold(
      backgroundColor: AppTheme.dark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.engineering,
                      size: 38,
                      color: AppTheme.brand,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  children: [
                    _ProfileAction(
                      icon: Icons.receipt_long,
                      label: 'My Orders',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      ),
                    ),
                    _ProfileAction(
                      icon: Icons.location_on_outlined,
                      label: 'My Addresses',
                      onTap: () => _openInfo(
                        context,
                        'My Addresses',
                        controller.shippingAddress,
                      ),
                    ),
                    _ProfileAction(
                      icon: Icons.payments_outlined,
                      label: 'Payment Methods',
                      onTap: () => _openInfo(
                        context,
                        'Payment Methods',
                        'Cash on Delivery\nABA Bank\nWing\nCredit/Debit Card',
                      ),
                    ),
                    _ProfileAction(
                      icon: Icons.favorite_border,
                      label: 'Wishlist',
                      onTap: () => _openInfo(
                        context,
                        'Wishlist',
                        controller.wishlistProducts
                            .map((item) => item.name)
                            .join('\n'),
                      ),
                    ),
                    _ProfileAction(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () => _openInfo(
                        context,
                        'Settings',
                        'Notification, language, and theme settings can live here later.',
                      ),
                    ),
                    _ProfileAction(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      onTap: () => _openInfo(
                        context,
                        'Help & Support',
                        'Email: support@constructiontools.app\nPhone: +855 12 345 678',
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isLoggedIn)
                      ListTile(
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await controller.logout();
                          if (!context.mounted) {
                            return;
                          }
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Logged out successfully.')),
                          );
                        },
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        leading: const Icon(
                          Icons.login,
                          color: AppTheme.brand,
                        ),
                        title: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppTheme.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openInfo(BuildContext context, String title, String content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InfoScreen(title: title, content: content),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }
}
