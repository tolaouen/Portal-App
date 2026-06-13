import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/customer_order.dart';
import '../models/hero_slide.dart';
import '../models/payment_option.dart';
import '../models/product.dart';
import '../models/store_category.dart';
import 'store_data_storage.dart';

class MockStoreStorage implements StoreDataStorage {
  @override
  List<StoreCategory> loadCategories() {
    return const [
      StoreCategory(
        id: 'electric',
        name: 'Electric Tools',
        itemCount: 32,
        icon: Icons.power,
      ),
      StoreCategory(
        id: 'hand',
        name: 'Hand Tools',
        itemCount: 45,
        icon: Icons.handyman,
      ),
      StoreCategory(
        id: 'concrete',
        name: 'Concrete Tools',
        itemCount: 28,
        icon: Icons.foundation,
      ),
      StoreCategory(
        id: 'safety',
        name: 'Safety Equipment',
        itemCount: 20,
        icon: Icons.health_and_safety,
      ),
      StoreCategory(
        id: 'measure',
        name: 'Measuring Tools',
        itemCount: 18,
        icon: Icons.straighten,
      ),
      StoreCategory(
        id: 'welding',
        name: 'Welding Tools',
        itemCount: 15,
        icon: Icons.bolt,
      ),
      StoreCategory(
        id: 'all',
        name: 'All Tools',
        itemCount: 150,
        icon: Icons.grid_view_rounded,
      ),
    ];
  }

  @override
  List<Product> loadProducts() {
    return [
      Product(
        id: 'dewalt-drill',
        categoryId: 'electric',
        name: 'Dewalt Cordless Drill',
        price: 120,
        rating: 4.5,
        reviews: 120,
        description:
            'High performance cordless drill for professional use with ergonomic grip and strong battery life.',
        icon: Icons.carpenter_rounded,
        color: const Color(0xFFFCC419),
        isFeatured: true,
      ),
      Product(
        id: 'makita-grinder',
        categoryId: 'electric',
        name: 'Makita Grinder',
        price: 85,
        rating: 4.3,
        reviews: 86,
        description:
            'Compact grinder designed for precise cutting and polishing in daily site work.',
        icon: Icons.settings_input_component_rounded,
        color: const Color(0xFF2EC4C7),
        isFeatured: true,
      ),
      Product(
        id: 'bosch-hammer',
        categoryId: 'concrete',
        name: 'Bosch Hammer Drill',
        price: 110,
        rating: 4.6,
        reviews: 73,
        description:
            'Reliable hammer drill built for masonry, concrete and heavy-duty installation jobs.',
        icon: Icons.construction_rounded,
        color: const Color(0xFF247BA0),
      ),
      Product(
        id: 'stanley-jigsaw',
        categoryId: 'electric',
        name: 'Stanley Jigsaw',
        price: 95,
        rating: 4.2,
        reviews: 64,
        description:
            'Smooth cutting jigsaw with adjustable speed for wood and light metal projects.',
        icon: Icons.architecture_rounded,
        color: const Color(0xFFFFC300),
      ),
      Product(
        id: 'black-decker-driver',
        categoryId: 'hand',
        name: 'Black+Decker Driver',
        price: 45,
        rating: 4.1,
        reviews: 48,
        description:
            'Compact electric screwdriver that is perfect for quick household and site fixes.',
        icon: Icons.electrical_services_rounded,
        color: const Color(0xFFFE7F2D),
      ),
      Product(
        id: 'makita-impact',
        categoryId: 'electric',
        name: 'Makita Impact Driver',
        price: 100,
        rating: 4.4,
        reviews: 97,
        description:
            'Balanced impact driver made for repetitive fastening work with reduced fatigue.',
        icon: Icons.build_circle_rounded,
        color: const Color(0xFF1B9AAA),
      ),
      Product(
        id: 'stanley-tape',
        categoryId: 'measure',
        name: 'Stanley Measuring Tape',
        price: 10,
        rating: 4.8,
        reviews: 152,
        description:
            'Durable measuring tape with easy lock and standout for daily site measurements.',
        icon: Icons.straighten_rounded,
        color: const Color(0xFFF4D35E),
      ),
      Product(
        id: 'safety-helmet',
        categoryId: 'safety',
        name: 'Safety Helmet Pro',
        price: 25,
        rating: 4.7,
        reviews: 66,
        description:
            'Lightweight safety helmet with secure fit and ventilation for long work hours.',
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFFFFB703),
      ),
    ];
  }

  @override
  List<CartItem> loadInitialCart() {
    return const [];
  }

  @override
  List<CustomerOrder> loadOrders() {
    return const [];
  }

  @override
  List<HeroSlide> loadHeroSlides() {
    return const [
      HeroSlide(
        id: 'slide-drill',
        title: 'Construction\nTools',
        subtitle: 'High Quality',
        ctaLabel: 'Shop Now',
        productId: 'dewalt-drill',
        icon: Icons.carpenter_rounded,
        gradientColors: [
          Color(0xFFFCC419),
          Color(0xFFFFD65A),
          Color(0xFF161616),
        ],
      ),
      HeroSlide(
        id: 'slide-grinder',
        title: 'Heavy Duty\nGrinding',
        subtitle: 'Pro Performance',
        ctaLabel: 'View Tools',
        productId: 'makita-grinder',
        icon: Icons.settings_input_component_rounded,
        gradientColors: [
          Color(0xFF22C7D7),
          Color(0xFF9BE7EC),
          Color(0xFF16232B),
        ],
      ),
      HeroSlide(
        id: 'slide-impact',
        title: 'Fast Power\nFor Work',
        subtitle: 'Best Deals',
        ctaLabel: 'Buy Today',
        productId: 'makita-impact',
        icon: Icons.build_circle_rounded,
        gradientColors: [
          Color(0xFF163EAE),
          Color(0xFF3565EC),
          Color(0xFF0E1322),
        ],
      ),
    ];
  }

  @override
  String loadShippingAddress() {
    return 'Street 217, Sangkat Boeung Salang\nKhan Tuol Kork, Phnom Penh\nCambodia';
  }

  @override
  PaymentOption loadDefaultPaymentOption() {
    return PaymentOption.cashOnDelivery;
  }
}
