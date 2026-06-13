import 'package:flutter/material.dart';

import 'auth/repositories/api_auth_repository.dart';
import 'data/api_category_repository.dart';
import 'data/api_order_repository.dart';
import 'data/api_product_repository.dart';
import 'data/mock_store_repository.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'state/store_controller.dart';
import 'state/store_scope.dart';
import 'theme/app_theme.dart';

void runConstructionApp() {
  final controller = StoreController(
    repository: MockStoreRepository(),
    authRepository: ApiAuthRepository(),
    categoryRepository: ApiCategoryRepository(),
    productRepository: ApiProductRepository(),
    orderRepository: ApiOrderRepository(),
  );
  runApp(ConstructionApp(controller: controller));
}

class ConstructionApp extends StatefulWidget {
  const ConstructionApp({super.key, required this.controller});

  final StoreController controller;

  @override
  State<ConstructionApp> createState() => _ConstructionAppState();
}

class _ConstructionAppState extends State<ConstructionApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      controller: widget.controller,
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Construction Tools',
            theme: AppTheme.lightTheme,
            home: _resolveHome(widget.controller),
          );
        },
      ),
    );
  }

  Widget _resolveHome(StoreController controller) {
    if (!controller.isReady) {
      return const SplashScreen();
    }
    return const MainShell();
  }
}
