import 'package:flutter/material.dart';

import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final screens = const [
      HomeScreen(),
      CategoriesScreen(),
      CartScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: controller.selectedTab, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.selectedTab,
        height: 78,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.brand,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppTheme.brand
                : AppTheme.dark,
            fontWeight: FontWeight.w700,
          );
        }),
        onDestinationSelected: (index) {
          if ((index == 2 || index == 3) && !controller.isLoggedIn) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
            return;
          }
          controller.setSelectedTab(index);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            selectedIcon: Icon(Icons.widgets),
            label: 'Product',
          ),
          NavigationDestination(
            icon: _CartNavIcon(
              count: controller.cartCount(),
              icon: Icons.shopping_cart_outlined,
            ),
            selectedIcon: _CartNavIcon(
              count: controller.cartCount(),
              icon: Icons.shopping_cart,
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Order',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  const _CartNavIcon({required this.count, required this.icon});

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      alignment: Alignment.topRight,
      offset: const Offset(-2, 2),
      largeSize: 16,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      label: Text(
        '$count',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
      child: Icon(icon, size: 20),
    );
  }
}
