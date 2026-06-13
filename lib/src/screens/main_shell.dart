import 'package:flutter/material.dart';

import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
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
        height: 74,
        backgroundColor: AppTheme.dark,
        indicatorColor: AppTheme.brand,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppTheme.brand
                : Colors.white70,
            fontWeight: FontWeight.w700,
          );
        }),
        onDestinationSelected: controller.setSelectedTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.widgets_outlined),
            selectedIcon: Icon(Icons.widgets),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: controller.cartCount() > 0,
              label: Text('${controller.cartCount()}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
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
