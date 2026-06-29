import 'package:flutter/material.dart';

import '../state/store_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _SettingSwitchTile(
              title: 'Push Notifications',
              subtitle: 'Receive order updates and store announcements.',
              value: controller.pushNotificationsEnabled,
              onChanged: controller.setPushNotificationsEnabled,
            ),
            const SizedBox(height: 14),
            _SettingSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Switch Off for dark theme, switch On for light theme.',
              value: !controller.darkModeEnabled,
              onChanged: (value) => controller.setDarkModeEnabled(!value),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  const _SettingSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
