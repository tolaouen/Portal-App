import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/models/auth_exception.dart';
import '../auth/models/auth_user.dart';
import '../auth/models/register_request.dart';
import '../auth/repositories/auth_repository.dart';
import '../data/api_category_repository.dart';
import '../data/api_order_repository.dart';
import '../data/cart_storage.dart';
import '../data/category_repository.dart';
import '../data/api_product_repository.dart';
import '../data/order_repository.dart';
import '../data/product_repository.dart';
import '../data/store_repository.dart';
import '../models/cart_item.dart';
import '../models/customer_order.dart';
import '../models/hero_slide.dart';
import '../models/payment_option.dart';
import '../models/product.dart';
import '../models/store_category.dart';

class StoreController extends ChangeNotifier {
  StoreController({
    required StoreRepository repository,
    required AuthRepository authRepository,
    required CategoryRepository categoryRepository,
    required ProductRepository productRepository,
    required OrderRepository orderRepository,
    CartStorage? cartStorage,
  }) : _authRepository = authRepository,
       _categoryRepository = categoryRepository,
       _productRepository = productRepository,
       _orderRepository = orderRepository,
       _cartStorage = cartStorage ?? CartStorage() {
    _fallbackProducts = repository.getProducts();
    _products = List<Product>.of(_fallbackProducts);
    _heroSlides = repository.getHeroSlides();
    _cart = List<CartItem>.of(repository.getInitialCart());
    _orders = List<CustomerOrder>.of(repository.getOrders());
    _selectedPayment = repository.getDefaultPaymentOption();
    _shippingAddress = repository.getShippingAddress();
  }

  final AuthRepository _authRepository;
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;
  final CartStorage _cartStorage;
  late final List<Product> _fallbackProducts;

  List<StoreCategory> _categories = [];
  List<Product> _products = [];
  late final List<HeroSlide> _heroSlides;
  late List<CartItem> _cart;
  List<CartItem>? _checkoutItems;
  late List<CustomerOrder> _orders;
  late PaymentOption _selectedPayment;
  late String _shippingAddress;

  bool _isReady = false;
  bool _isLoggedIn = false;
  bool _isBusy = false;
  int _selectedTab = 0;
  String _searchQuery = '';
  String? _authErrorMessage;
  String? _categoryErrorMessage;
  String? _productErrorMessage;
  String? _orderErrorMessage;
  AuthUser? _currentUser;
  final Set<String> _favoriteIds = {'dewalt-drill', 'makita-grinder'};
  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;
  bool _isLoadingOrders = false;

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  bool get isBusy => _isBusy;
  int get selectedTab => _selectedTab;
  String get shippingAddress => _shippingAddress;
  PaymentOption get selectedPayment => _selectedPayment;
  String? get authErrorMessage => _authErrorMessage;
  String? get categoryErrorMessage => _categoryErrorMessage;
  String? get productErrorMessage => _productErrorMessage;
  String? get orderErrorMessage => _orderErrorMessage;
  AuthUser? get currentUser => _currentUser;
  List<StoreCategory> get categories => List.unmodifiable(_categories);
  List<Product> get products => List.unmodifiable(_products);
  List<HeroSlide> get heroSlides => List.unmodifiable(_heroSlides);
  List<CustomerOrder> get orders => List.unmodifiable(_orders);
  List<CartItem> get cart => List.unmodifiable(_cart);
  List<CartItem> get activeCheckoutItems =>
      List.unmodifiable(_checkoutItems ?? _cart);
  String get searchQuery => _searchQuery;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isUsingBuyNowCheckout => _checkoutItems != null;

  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _cart = await _cartStorage.readCart();
    await Future.wait([
      loadCategories(notify: false),
      loadProducts(notify: false),
      loadOrders(notify: false),
    ]);
    _syncCategoryCounts();
    final token = await _authRepository.readToken();
    if (token != null && token.accessToken.isNotEmpty) {
      try {
        _currentUser = await _authRepository.getMe(token.accessToken);
        _isLoggedIn = true;
      } catch (_) {
        await _authRepository.clearToken();
        _currentUser = null;
        _isLoggedIn = false;
      }
    }
    _isReady = true;
    notifyListeners();
  }

  Future<void> loadCategories({bool notify = true}) async {
    _isLoadingCategories = true;
    _categoryErrorMessage = null;
    if (notify) {
      notifyListeners();
    }

    try {
      _categories = await _categoryRepository.fetchCategories();
      _mergeEmbeddedCategoryProducts();
      _syncCategoryCounts();
    } on CategoryException catch (error) {
      _categoryErrorMessage = error.message;
      _categories = [];
    } catch (_) {
      _categoryErrorMessage =
          'Unable to load categories right now. Please try again.';
      _categories = [];
    }

    _isLoadingCategories = false;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> loadProducts({bool notify = true}) async {
    _isLoadingProducts = true;
    _productErrorMessage = null;
    if (notify) {
      notifyListeners();
    }

    try {
      _products = await _productRepository.fetchProducts();
      _mergeEmbeddedCategoryProducts();
      _syncCategoryCounts();
    } on ProductException catch (error) {
      _productErrorMessage = error.message;
      _products = [];
    } catch (_) {
      _productErrorMessage =
          'Unable to load products right now. Please try again.';
      _products = [];
    }

    _isLoadingProducts = false;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> refreshCatalogData() async {
    await Future.wait([
      loadCategories(notify: false),
      loadProducts(notify: false),
    ]);
    _syncCategoryCounts();
    notifyListeners();
  }

  Future<void> loadOrders({bool notify = true}) async {
    _isLoadingOrders = true;
    _orderErrorMessage = null;
    if (notify) {
      notifyListeners();
    }

    try {
      final apiOrders = await _orderRepository.fetchOrders();
      final mergedById = <String, CustomerOrder>{
        for (final order in apiOrders) order.id: order,
      };
      for (final order in _orders) {
        mergedById.putIfAbsent(order.id, () => order);
      }
      _orders = mergedById.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } on OrderException catch (error) {
      _orderErrorMessage = error.message;
    } catch (_) {
      _orderErrorMessage = 'Unable to load orders right now. Please try again.';
    }

    _isLoadingOrders = false;
    if (notify) {
      notifyListeners();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isBusy = true;
    _authErrorMessage = null;
    notifyListeners();
    try {
      final token = await _authRepository.login(
        username: username,
        password: password,
      );
      debugPrint('Login token: ${token.accessToken}');
      await _authRepository.saveToken(token);
      _currentUser = await _authRepository.getMe(token.accessToken);
      _isLoggedIn = true;
    } on AuthException catch (error) {
      _authErrorMessage = error.message;
      _isLoggedIn = false;
    } catch (_) {
      _authErrorMessage = 'Unable to login right now. Please try again.';
      _isLoggedIn = false;
    }
    _isBusy = false;
    notifyListeners();
    return _isLoggedIn;
  }

  Future<bool> register(RegisterRequest request) async {
    _isBusy = true;
    _authErrorMessage = null;
    notifyListeners();
    try {
      final token = await _authRepository.register(request);
      await _authRepository.saveToken(token);
      _currentUser = await _authRepository.getMe(token.accessToken);
      _isLoggedIn = true;
    } on AuthException catch (error) {
      _authErrorMessage = error.message;
      _isLoggedIn = false;
    } catch (_) {
      _authErrorMessage = 'Unable to register right now. Please try again.';
      _isLoggedIn = false;
    }
    _isBusy = false;
    notifyListeners();
    return _isLoggedIn;
  }

  Future<void> logout() async {
    await _authRepository.clearToken();
    _currentUser = null;
    _authErrorMessage = null;
    _isLoggedIn = false;
    _selectedTab = 0;
    notifyListeners();
  }

  void setSelectedTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value.trim().toLowerCase();
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  List<Product> productsByCategory(String categoryId) {
    final embeddedProducts = _categories
        .where((category) => category.id == categoryId)
        .expand((category) => category.products)
        .toList();
    final scoped = categoryId == 'all'
        ? _products
        : embeddedProducts.isNotEmpty
        ? embeddedProducts
        : _products
              .where((product) => product.categoryId == categoryId)
              .toList();
    if (_searchQuery.isEmpty) {
      return scoped;
    }
    return scoped
        .where((product) => product.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  List<Product> featuredProducts() {
    final featured = _products.where((product) => product.isFeatured).toList();
    if (featured.isNotEmpty) {
      return featured;
    }
    return _products.take(4).toList();
  }

  Product productById(String id) {
    return _products.firstWhere(
      (product) => product.id == id,
      orElse: () => _fallbackProducts.firstWhere(
        (product) => product.id == id,
        orElse: () =>
            _products.isNotEmpty ? _products.first : _fallbackProducts.first,
      ),
    );
  }

  int quantityFor(String productId) {
    final entry = _cart.where((item) => item.productId == productId);
    if (entry.isEmpty) return 1;
    return entry.first.quantity;
  }

  void addToCart(String productId, {int quantity = 1}) {
    final updatedCart = List<CartItem>.of(_cart);
    final index = _cart.indexWhere((item) => item.productId == productId);
    if (index == -1) {
      updatedCart.add(CartItem(productId: productId, quantity: quantity));
    } else {
      final current = updatedCart[index];
      updatedCart[index] = current.copyWith(
        quantity: current.quantity + quantity,
      );
    }
    _cart = updatedCart;
    _persistCart();
    notifyListeners();
  }

  void updateCartQuantity(String productId, int quantity) {
    final index = _cart.indexWhere((item) => item.productId == productId);
    if (index == -1) return;
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final updatedCart = List<CartItem>.of(_cart);
    updatedCart[index] = updatedCart[index].copyWith(quantity: quantity);
    _cart = updatedCart;
    _persistCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart = _cart.where((item) => item.productId != productId).toList();
    _persistCart();
    notifyListeners();
  }

  void startBuyNowCheckout(String productId, {int quantity = 1}) {
    _checkoutItems = [CartItem(productId: productId, quantity: quantity)];
    notifyListeners();
  }

  void clearBuyNowCheckout() {
    if (_checkoutItems == null) {
      return;
    }
    _checkoutItems = null;
    notifyListeners();
  }

  double _subtotalFor(List<CartItem> items) {
    return items.fold<double>(0, (sum, item) {
      return sum + (productById(item.productId).price * item.quantity);
    });
  }

  double get subtotal => _subtotalFor(activeCheckoutItems);

  double get shippingFee => activeCheckoutItems.isEmpty ? 0 : 10;

  double get total => subtotal + shippingFee;

  void setPaymentOption(PaymentOption option) {
    _selectedPayment = option;
    notifyListeners();
  }

  Future<void> placeOrder() async {
    final checkoutItems = activeCheckoutItems;
    if (checkoutItems.isEmpty) return;
    final order = CustomerOrder(
      id: '#12${340 + _orders.length}',
      userId: _currentUser?.id ?? 0,
      date: DateTime.now(),
      status: OrderStatus.pending,
      productIds: checkoutItems.map((item) => item.productId).toList(),
      total: total,
      paymentMethod: _selectedPayment.label,
      address: _shippingAddress,
    );
    _orders = [order, ..._orders];
    if (_checkoutItems == null) {
      _cart = [];
      _persistCart();
    }
    _checkoutItems = null;
    _selectedTab = 3;
    notifyListeners();
  }

  int cartCount() => _cart.fold<int>(0, (sum, item) => sum + item.quantity);

  bool hasProductsForCategory(String categoryId) {
    if (categoryId == 'all') {
      return _products.isNotEmpty;
    }
    final embeddedMatch = _categories.any(
      (category) => category.id == categoryId && category.products.isNotEmpty,
    );
    if (embeddedMatch) {
      return true;
    }
    return _products.any((product) => product.categoryId == categoryId);
  }

  List<Product> get wishlistProducts {
    return _products
        .where((product) => _favoriteIds.contains(product.id))
        .toList();
  }

  void _syncCategoryCounts() {
    if (_categories.isEmpty) {
      return;
    }

    _categories = _categories.map((category) {
      final count = category.products.isNotEmpty
          ? category.products.length
          : _products
                .where((product) => product.categoryId == category.id)
                .length;
      return StoreCategory(
        id: category.id,
        name: category.name,
        itemCount: count,
        icon: category.icon,
        products: category.products,
      );
    }).toList();
  }

  void _mergeEmbeddedCategoryProducts() {
    if (_categories.isEmpty) {
      return;
    }

    final mergedById = <String, Product>{
      for (final product in _products) product.id: product,
    };

    for (final category in _categories) {
      for (final product in category.products) {
        mergedById[product.id] = product;
      }
    }

    _products = mergedById.values.toList();
  }

  void _persistCart() {
    if (_cart.isEmpty) {
      unawaited(_cartStorage.clearCart());
      return;
    }
    unawaited(_cartStorage.saveCart(_cart));
  }
}
