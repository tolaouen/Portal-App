import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/store_scope.dart';
import '../widgets/store_widgets.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  final String categoryId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final products = controller.productsByCategory(categoryId);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.tune))],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshCatalogData,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Builder(
            builder: (context) {
              if (controller.isLoadingProducts && products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.productErrorMessage != null && products.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _CatalogMessage(
                      title: 'Unable to load products',
                      message: controller.productErrorMessage!,
                    ),
                  ],
                );
              }

              if (products.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _CatalogMessage(
                      title: 'No products found',
                      message: 'There are no products in $title yet.',
                    ),
                  ],
                );
              }

              return GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductTile(
                    product: product,
                    isFavorite: controller.isFavorite(product.id),
                    onFavoriteTap: () => controller.toggleFavorite(product.id),
                    onTap: () => _openDetail(context, product),
                  );
                },
              );
            },
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

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
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
