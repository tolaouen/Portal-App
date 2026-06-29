import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/store_scope.dart';
import '../widgets/store_widgets.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _queryController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final normalizedQuery = _query.trim().toLowerCase();
    final matchedProducts = _filterProducts(
      controller.products,
      normalizedQuery,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _queryController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _queryController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (normalizedQuery.isEmpty)
              const SizedBox.shrink()
            else if (matchedProducts.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No product',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    SectionHeader(
                      title: 'Products',
                      actionLabel: '${matchedProducts.length}',
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: matchedProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.79,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemBuilder: (context, index) {
                        final product = matchedProducts[index];
                        return ProductTile(
                          product: product,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
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
    );
  }

  List<Product> _filterProducts(List<Product> products, String query) {
    if (query.isEmpty) {
      return products;
    }
    return products.where((product) {
      final source = [
        product.name,
        product.description,
        product.categoryName ?? '',
        product.categoryDescription ?? '',
      ].join(' ').toLowerCase();
      return source.contains(query);
    }).toList();
  }
}
