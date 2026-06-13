import 'dart:async';

import 'package:flutter/material.dart';

import '../models/hero_slide.dart';
import '../models/product.dart';
import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/store_widgets.dart';
import 'catalog_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }
      final slides = StoreScope.of(context).heroSlides;
      if (slides.isEmpty) {
        return;
      }
      final nextPage = (_currentSlide + 1) % slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    final featured = controller.featuredProducts();
    final categories = controller.categories.take(4).toList();
    final slides = controller.heroSlides;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${controller.currentUser?.firstName ?? 'User'} 👋',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Find the best tools for your work',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: controller.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search tools, categories...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 18),
            _HeroBanner(
              slides: slides,
              currentIndex: _currentSlide,
              pageController: _pageController,
              onPageChanged: (index) => setState(() => _currentSlide = index),
              onTap: (slide) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(
                    product: controller.productById(slide.productId),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'Categories',
              actionLabel: 'See All',
              onTap: () => controller.setSelectedTab(1),
            ),
            const SizedBox(height: 12),
            if ((controller.isLoadingCategories ||
                    controller.isLoadingProducts) &&
                categories.isEmpty)
              const SizedBox(
                height: 138,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.categoryErrorMessage != null &&
                categories.isEmpty)
              const _CategoryStatusCard(
                message: 'Categories are not available right now.',
              )
            else if (categories.isEmpty)
              const _CategoryStatusCard(
                message: 'No categories available right now.',
              )
            else
              SizedBox(
                height: 138,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryChipCard(
                      category: category,
                      onTap: () =>
                          _openCatalog(context, category.id, category.name),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemCount: categories.length,
                ),
              ),
            const SizedBox(height: 22),
            SectionHeader(
              title: 'Popular Tools',
              actionLabel: 'See All',
              onTap: () => _openCatalog(context, 'all', 'All Tools'),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: featured.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.74,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final product = featured[index];
                return ProductTile(
                  product: product,
                  isFavorite: controller.isFavorite(product.id),
                  onFavoriteTap: () => controller.toggleFavorite(product.id),
                  onTap: () => _openDetail(context, product),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openCatalog(BuildContext context, String categoryId, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogScreen(categoryId: categoryId, title: title),
      ),
    );
  }

  void _openDetail(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }
}

class _CategoryStatusCard extends StatelessWidget {
  const _CategoryStatusCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 138,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.slides,
    required this.currentIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onTap,
  });

  final List<HeroSlide> slides;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<HeroSlide> onTap;

  @override
  Widget build(BuildContext context) {
    if (slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: pageController,
            itemCount: slides.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final slide = slides[index];
              final darkText =
                  slide.gradientColors.first.computeLuminance() > 0.6;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: InkWell(
                  onTap: () => onTap(slide),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: slide.gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slide.subtitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: darkText
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                slide.title,
                                style: TextStyle(
                                  fontSize: 30,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  color: darkText ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppTheme.dark,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    slide.ctaLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 76,
                            color: darkText ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < slides.length; index++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index ? AppTheme.dark : Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
