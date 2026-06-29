import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../state/store_scope.dart';
import '../widgets/store_widgets.dart';
import 'edit_profile_screen.dart';
import 'info_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'settings_screen.dart';

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
    final profileImageBytes = _decodeProfileImage(
      controller.profileImageBase64,
    );

    return Scaffold(
      backgroundColor: AppTheme.mist,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: profileImageBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              profileImageBytes,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.engineering,
                            size: 34,
                            color: AppTheme.brand,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $fullName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        if (isLoggedIn) ...[
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: AppTheme.brand,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  children: [
                    _ProfileAction(
                      icon: Icons.receipt_long_outlined,
                      label: 'My Orders',
                      onTap: () {
                        if (!controller.isLoggedIn) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OrdersScreen(),
                          ),
                        );
                      },
                    ),
                    _ProfileAction(
                      icon: Icons.location_on_outlined,
                      label: 'My Address',
                      onTap: () => _openInfo(
                        context,
                        'My Address',
                        controller.shippingAddress,
                      ),
                    ),
                    _ProfileAction(
                      icon: Icons.payment_outlined,
                      label: 'Payment Methods',
                      onTap: () => _openInfo(
                        context,
                        'Payment Methods',
                        'Cash on Delivery\nABA Bank\nWing\nCredit/Debit Card',
                      ),
                    ),
                    _ProfileAction(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    _ProfileAction(
                      icon: Icons.info_outline,
                      label: 'Help & Support',
                      onTap: () => _openInfo(
                        context,
                        'Help & Support',
                        'Email: support@constructiontools.app\nPhone: +855 12 345 678',
                      ),
                    ),
                    const SizedBox(height: 34),
                    if (isLoggedIn)
                      SizedBox(
                        height: 62,
                        child: FilledButton.icon(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await controller.logout();
                            if (!context.mounted) {
                              return;
                            }
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Logged out successfully.'),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3B3B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.logout, size: 24),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else
                      PrimaryButton(
                        label: 'Sign In',
                        icon: Icons.login,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
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

  Uint8List? _decodeProfileImage(String? rawImage) {
    if (rawImage == null || rawImage.isEmpty) {
      return null;
    }
    try {
      return base64Decode(rawImage);
    } catch (_) {
      return null;
    }
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 2),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 29),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 28),
          ],
        ),
      ),
    );
  }
}
