import 'package:flutter/material.dart';

import '../state/store_scope.dart';
import 'catalog_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final categories = controller.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadCategories,
          child: Builder(
            builder: (context) {
              if ((controller.isLoadingCategories ||
                      controller.isLoadingProducts) &&
                  categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.categoryErrorMessage != null &&
                  categories.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 120),
                  children: const [
                    _CategoriesMessage(
                      title: 'Categories unavailable',
                      message: 'Please check again later.',
                    ),
                  ],
                );
              }

              if (categories.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 120),
                  children: const [
                    _CategoriesMessage(
                      title: 'No categories yet',
                      message: 'Categories from the API will appear here.',
                    ),
                  ],
                );
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFFF4CC),
                      child: Icon(category.icon, color: Colors.black87),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text('${category.itemCount} items'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CatalogScreen(
                            categoryId: category.id,
                            title: category.name,
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemCount: categories.length,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoriesMessage extends StatelessWidget {
  const _CategoriesMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
