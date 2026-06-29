import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../auth/models/auth_user.dart';
import '../models/hero_slide.dart';
import '../models/product.dart';
import '../state/store_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/store_widgets.dart';
import 'catalog_screen.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

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
    final featured = controller.popularProducts(limit: 6);
    final categories = controller.categories.toList();
    final slides = controller.heroSlides;
    final currentUser = controller.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.mist,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _HomeHeaderProfile(
                      user: currentUser,
                      profileImageBase64: controller.profileImageBase64,
                      onTap: () => controller.setSelectedTab(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _HeaderActionButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                readOnly: true,
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
                decoration: InputDecoration(
                  hintText: 'Find the product if you want........',
                  prefixIcon: const Icon(Icons.search, size: 30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.78),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppTheme.brand),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (controller.isLoadingBanners && slides.isEmpty)
                Container(
                  height: 228,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else
                _HeroBanner(
                  slides: slides,
                  currentIndex: _currentSlide,
                  pageController: _pageController,
                  onPageChanged: (index) => setState(() => _currentSlide = index),
                  onTap: (slide) {
                    final productId = slide.productId;
                    if (productId == null || productId.isEmpty) {
                      return;
                    }
                    final product = controller.productByIdOrNull(productId);
                    if (product == null) {
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 8),
              SectionHeader(
                title: 'Category',
                actionLabel: 'See All',
                onTap: () => controller.setSelectedTab(1),
              ),
              const SizedBox(height: 1),
              if (controller.isLoadingCategories && categories.isEmpty)
                const SizedBox(
                  height: 10,
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      for (var index = 0; index < categories.length; index++) ...[
                        if (index > 0) const SizedBox(width: 10),
                        CategoryChipCard(
                          category: categories[index],
                          onTap: () => _openCatalog(
                            context,
                            categories[index].id,
                            categories[index].name,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              SectionHeader(
                title: 'Popular Product',
                actionLabel: 'See All',
                onTap: () => _openCatalog(
                  context,
                  'all',
                  'Popular Product',
                  popularOnly: true,
                ),
              ),
              const SizedBox(height: 6),
              if (controller.isLoadingProducts && featured.isEmpty)
                const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (featured.isNotEmpty)
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: featured.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.79,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final product = featured[index];
                    return ProductTile(
                      product: product,
                      onTap: () => _openDetail(context, product),
                    );
                  },
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  void _openCatalog(
    BuildContext context,
    String categoryId,
    String title, {
    bool popularOnly = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CatalogScreen(
          categoryId: categoryId,
          title: title,
          popularOnly: popularOnly,
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

class _HomeHeaderProfile extends StatelessWidget {
  const _HomeHeaderProfile({
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

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black87, size: 28),
    );
  }
}

class _CategoryStatusCard extends StatelessWidget {
  const _CategoryStatusCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          height: 228,
          child: PageView.builder(
            controller: pageController,
            itemCount: slides.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: InkWell(
                  onTap: () => onTap(slide),
                  borderRadius: BorderRadius.circular(24),
                  child: _BannerSlideCard(slide: slide),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var index = 0; index < slides.length; index++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 24 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: currentIndex == index ? Colors.white : Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BannerSlideCard extends StatelessWidget {
  const _BannerSlideCard({required this.slide});

  final HeroSlide slide;

  @override
  Widget build(BuildContext context) {
    final imageBytes = _decodeImage(slide.backgroundImage);
    final imageUrl = _normalizeImageUrl(slide.backgroundImage);
    final hasBannerImage =
        slide.backgroundAssetPath != null ||
        imageBytes != null ||
        imageUrl != null;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: hasBannerImage ? Colors.black : const Color(0xFFF3F4F6),
        gradient: hasBannerImage
            ? null
            : LinearGradient(
                colors: [
                  slide.gradientColors.first,
                  slide.gradientColors[1],
                  const Color(0xFF0F1D30),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (slide.backgroundAssetPath case final assetPath?)
            Image.asset(assetPath, fit: BoxFit.cover)
          else if (imageBytes case final imageData?)
            Image.memory(imageData, fit: BoxFit.cover)
          else if (imageUrl case final imageNetworkUrl?)
            Image.network(imageNetworkUrl, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.12),
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.32),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.brand,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'FEATURED BANNER',
                style: TextStyle(
                  color: AppTheme.dark,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BannerDot(),
                    SizedBox(width: 5),
                    _BannerDot(),
                    SizedBox(width: 5),
                    _BannerDot(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.title.replaceAll('\n', ' '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        slide.description.isEmpty
                            ? slide.subtitle
                            : slide.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppTheme.brand,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    child: Text(
                      slide.ctaLabel.isEmpty ? 'Show Now' : slide.ctaLabel,
                      style: const TextStyle(
                        color: AppTheme.dark,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Uint8List? _decodeImage(String? rawImage) {
    if (rawImage == null || rawImage.trim().isEmpty) {
      return null;
    }
    if (_normalizeImageUrl(rawImage) != null) {
      return null;
    }
    try {
      final normalized = rawImage.contains(',')
          ? rawImage.split(',').last
          : rawImage;
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }

  String? _normalizeImageUrl(String? rawImage) {
    if (rawImage == null || rawImage.trim().isEmpty) {
      return null;
    }
    final normalized = rawImage.trim();
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }
    return null;
  }
}

class _BannerDot extends StatelessWidget {
  const _BannerDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
