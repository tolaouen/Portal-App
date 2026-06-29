import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/store_scope.dart';
import '../widgets/store_widgets.dart';
import 'product_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    required this.categoryId,
    required this.title,
    this.popularOnly = false,
  });

  final String categoryId;
  final String title;
  final bool popularOnly;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      StoreScope.of(
        context,
      ).ensureProductsLoadedForCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final products = widget.popularOnly
        ? controller.popularProducts()
        : controller.productsByCategory(widget.categoryId);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.tune))],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshCatalogData();
          if (mounted) {
            await controller.ensureProductsLoadedForCategory(widget.categoryId);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Builder(
            builder: (context) {
              if (controller.isLoadingProducts && products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (products.isEmpty) {
                final message = controller.productErrorMessage;
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _CatalogMessage(
                      title: message == null
                          ? 'No products found'
                          : 'Unable to load products',
                      message:
                          message ??
                          'There are no products in ${widget.title} yet.',
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 18),
                      Center(
                        child: FilledButton(
                          onPressed: () => controller.ensureProductsLoadedForCategory(
                            widget.categoryId,
                          ),
                          child: const Text('Try Again'),
                        ),
                      ),
                    ],
                  ],
                );
              }

              return GridView.builder(
                itemCount: products.length,
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
