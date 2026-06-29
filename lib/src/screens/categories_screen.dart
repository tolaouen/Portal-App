import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../auth/models/auth_user.dart';
import '../models/product.dart';
import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/store_widgets.dart';
import 'product_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedCategoryId = 'all';

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final categories = controller.categories;
    final products = _selectedCategoryId == 'all'
        ? controller.products
        : controller.productsByCategory(_selectedCategoryId);

    return Scaffold(
      backgroundColor: AppTheme.mist,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshCatalogData();
            if (_selectedCategoryId != 'all') {
              await controller.ensureProductsLoadedForCategory(
                _selectedCategoryId,
              );
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ProductHeaderProfile(
                      user: controller.currentUser,
                      profileImageBase64: controller.profileImageBase64,
                      onTap: () => controller.setSelectedTab(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.black87,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _FilterChip(
                        label: 'All',
                        selected: _selectedCategoryId == 'all',
                        onTap: () => setState(() => _selectedCategoryId = 'all'),
                      );
                    }
                    final category = categories[index - 1];
                    return _FilterChip(
                      label: category.name,
                      selected: _selectedCategoryId == category.id,
                      onTap: () async {
                        setState(() => _selectedCategoryId = category.id);
                        await controller.ensureProductsLoadedForCategory(
                          category.id,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'All product',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.dark,
                ),
              ),
              const SizedBox(height: 16),
              if ((controller.isLoadingProducts ||
                      controller.isLoadingCategories) &&
                  products.isEmpty)
                const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (products.isEmpty)
                const _ProductMessage(
                  title: 'No products found',
                  message: 'Products from the API will appear here.',
                )
              else
                GridView.builder(
                  itemCount: products.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.79,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductTile(
                      product: product,
                      onTap: () => _openDetail(context, product),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }
}

class _ProductHeaderProfile extends StatelessWidget {
  const _ProductHeaderProfile({
    required this.user,
    required this.profileImageBase64,
    required this.onTap,
  });

  final AuthUser? user;
  final String? profileImageBase64;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = _displayName(user);
    final avatarBytes = _decodeAvatar(profileImageBase64);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: avatarBytes != null ? MemoryImage(avatarBytes) : null,
              child: avatarBytes == null
                  ? const Icon(
                      Icons.person_rounded,
                      color: Colors.black54,
                      size: 30,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $name',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user?.email ?? 'Welcome back',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayName(AuthUser? user) {
    if (user == null) {
      return 'User';
    }
    final fullName = user.fullName.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    if (user.username.trim().isNotEmpty) {
      return user.username.trim();
    }
    return 'User';
  }

  Uint8List? _decodeAvatar(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 82),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4F8BF0) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F8BF0).withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.dark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProductMessage extends StatelessWidget {
  const _ProductMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }
}
