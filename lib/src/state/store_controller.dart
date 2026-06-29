import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/models/auth_exception.dart';
import '../auth/models/auth_user.dart';
import '../auth/models/register_request.dart';
import '../auth/repositories/auth_repository.dart';
import '../data/api_category_repository.dart';
import '../data/api_order_repository.dart';
import '../data/banner_repository.dart';
import '../data/catalog_cache_storage.dart';
import '../data/cart_storage.dart';
import '../data/category_repository.dart';
import '../data/favorite_storage.dart';
import '../data/api_product_repository.dart';
import '../data/order_repository.dart';
import '../data/order_storage.dart';
import '../data/payment_repository.dart';
import '../data/profile_storage.dart';
import '../data/product_repository.dart';
import '../data/settings_storage.dart';
import '../data/shipping_address_storage.dart';
import '../models/cart_item.dart';
import '../models/customer_order.dart';
import '../models/hero_slide.dart';
import '../models/order_item.dart';
import '../models/payment_option.dart';
import '../models/product.dart';
import '../models/store_category.dart';

class StoreController extends ChangeNotifier {
  StoreController({
    required AuthRepository authRepository,
    required BannerRepository bannerRepository,
    required CategoryRepository categoryRepository,
    required ProductRepository productRepository,
    required OrderRepository orderRepository,
    required PaymentRepository paymentRepository,
    CatalogCacheStorage? catalogCacheStorage,
    CartStorage? cartStorage,
    FavoriteStorage? favoriteStorage,
    ProfileStorage? profileStorage,
    SettingsStorage? settingsStorage,
    ShippingAddressStorage? shippingAddressStorage,
    OrderStorage? orderStorage,
  }) : _authRepository = authRepository,
       _bannerRepository = bannerRepository,
       _categoryRepository = categoryRepository,
       _productRepository = productRepository,
       _orderRepository = orderRepository,
       _paymentRepository = paymentRepository,
       _catalogCacheStorage = catalogCacheStorage ?? CatalogCacheStorage(),
       _cartStorage = cartStorage ?? CartStorage(),
       _favoriteStorage = favoriteStorage ?? FavoriteStorage(),
       _profileStorage = profileStorage ?? ProfileStorage(),
       _settingsStorage = settingsStorage ?? SettingsStorage(),
       _shippingAddressStorage =
           shippingAddressStorage ?? ShippingAddressStorage(),
       _orderStorage = orderStorage ?? OrderStorage();

  final AuthRepository _authRepository;
  final BannerRepository _bannerRepository;
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;
  final PaymentRepository _paymentRepository;
  final CatalogCacheStorage _catalogCacheStorage;
  final CartStorage _cartStorage;
  final FavoriteStorage _favoriteStorage;
  final OrderStorage _orderStorage;
  final ProfileStorage _profileStorage;
  final SettingsStorage _settingsStorage;
  final ShippingAddressStorage _shippingAddressStorage;

  List<StoreCategory> _categories = [];
  List<Product> _products = [];
  List<HeroSlide> _heroSlides = [];
  List<CartItem> _cart = [];
  List<CartItem>? _checkoutItems;
  List<CustomerOrder> _orders = [];
  PaymentOption _selectedPayment = PaymentOption.cashOnDelivery;
  String _shippingAddressLabel = 'Home';
  String _shippingAddress =
      'Street 217, Sangkat Boeung Salang\nKhan Tuol Kork, Phnom Penh\nCambodia';

  bool _isReady = false;
  bool _isLoggedIn = false;
  bool _isBusy = false;
  int _selectedTab = 0;
  String _searchQuery = '';
  String? _authErrorMessage;
  String? _bannerErrorMessage;
  String? _categoryErrorMessage;
  String? _productErrorMessage;
  String? _orderErrorMessage;
  AuthUser? _currentUser;
  Set<String> _favoriteIds = <String>{};
  bool _isLoadingBanners = false;
  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;
  bool _isLoadingOrders = false;
  bool _pushNotificationsEnabled = true;
  bool _darkModeEnabled = false;
  String? _profileImageBase64;
  bool _isProcessingCheckout = false;
  final Map<PaymentOption, Map<String, String>> _savedPaymentDetails = {};

  bool get isReady => _isReady;
  bool get isLoggedIn => _isLoggedIn;
  bool get isBusy => _isBusy;
  int get selectedTab => _selectedTab;
  String get shippingAddress => _shippingAddress;
  String get shippingAddressLabel => _shippingAddressLabel;
  PaymentOption get selectedPayment => _selectedPayment;
  String? get authErrorMessage => _authErrorMessage;
  String? get bannerErrorMessage => _bannerErrorMessage;
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
  bool get isLoadingBanners => _isLoadingBanners;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isUsingBuyNowCheckout => _checkoutItems != null;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  String? get profileImageBase64 => _profileImageBase64;
  bool get isProcessingCheckout => _isProcessingCheckout;

  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _cart = await _cartStorage.readCart();
    _orders = await _orderStorage.readOrders();
    _pushNotificationsEnabled = await _settingsStorage
        .readPushNotificationsEnabled();
    _darkModeEnabled = await _settingsStorage.readDarkModeEnabled();
    final savedShippingAddress = await _shippingAddressStorage
        .readShippingAddress();
    if (savedShippingAddress != null) {
      final savedLabel = (savedShippingAddress['label'] ?? '').trim();
      final savedAddress = (savedShippingAddress['address'] ?? '').trim();
      if (savedLabel.isNotEmpty) {
        _shippingAddressLabel = savedLabel;
      }
      if (savedAddress.isNotEmpty) {
        _shippingAddress = savedAddress;
      }
    }
    await _catalogCacheStorage.clearCatalogCache();
    _syncCategoryCounts();
    notifyListeners();
    await _finishInitialize();
    _isReady = true;
    notifyListeners();
  }

  Future<void> _finishInitialize() async {
    await Future.wait([
      loadBanners(notify: false),
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
        await _loadFavorites();
        await _loadProfileOverrides();
      } on AuthException catch (error) {
        final unauthorized =
            error.statusCode == 401 || error.statusCode == 403;
        if (unauthorized) {
          await _authRepository.clearToken();
          _currentUser = null;
          _isLoggedIn = false;
        } else {
          _isLoggedIn = true;
        }
      } catch (_) {
        _isLoggedIn = true;
      }
    }
  }

  Future<void> loadBanners({bool notify = true}) async {
    _isLoadingBanners = true;
    _bannerErrorMessage = null;
    if (notify) {
      notifyListeners();
    }

    try {
      _heroSlides = await _bannerRepository.fetchBanners();
    } on BannerException catch (error) {
      _bannerErrorMessage = error.message;
      _heroSlides = [];
    } catch (_) {
      _bannerErrorMessage = 'Unable to load banners right now.';
      _heroSlides = [];
    }

    _isLoadingBanners = false;
    if (notify) {
      notifyListeners();
    }
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
      _rebuildCategoriesFromProducts();
    } catch (_) {
      _categoryErrorMessage =
          'Unable to load categories right now. Please try again.';
      _categories = [];
      _rebuildCategoriesFromProducts();
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
      _rebuildCategoriesFromProducts();
      _syncCategoryCounts();
    } on ProductException catch (error) {
      _productErrorMessage = error.message;
      _products = [];
      _mergeEmbeddedCategoryProducts();
      _rebuildCategoriesFromProducts();
      _syncCategoryCounts();
    } catch (_) {
      _productErrorMessage =
          'Unable to load products right now. Please try again.';
      _products = [];
      _mergeEmbeddedCategoryProducts();
      _rebuildCategoriesFromProducts();
      _syncCategoryCounts();
    }

    _isLoadingProducts = false;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> refreshCatalogData() async {
    await _catalogCacheStorage.clearCatalogCache();
    await Future.wait([
      loadBanners(notify: false),
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
      final localOrders = await _orderStorage.readOrders();
      final apiOrders = await _orderRepository.fetchOrders();
      final mergedById = <String, CustomerOrder>{
        for (final order in localOrders) order.id: order,
      };
      for (final apiOrder in apiOrders) {
        final localOrder = mergedById[apiOrder.id];
        mergedById[apiOrder.id] = _mergeOrderStatus(
          localOrder: localOrder,
          apiOrder: apiOrder,
        );
      }
      for (final order in _orders) {
        mergedById.putIfAbsent(order.id, () => order);
      }
      _orders = mergedById.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      await _persistOrders();
    } on OrderException catch (error) {
      _orderErrorMessage = error.message;
      _orders = await _orderStorage.readOrders();
    } catch (_) {
      _orderErrorMessage = 'Unable to load orders right now. Please try again.';
      _orders = await _orderStorage.readOrders();
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
      await _loadFavorites();
      await _loadProfileOverrides();
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
      await _loadFavorites();
      await _loadProfileOverrides();
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
    _profileImageBase64 = null;
    _authErrorMessage = null;
    _isLoggedIn = false;
    _favoriteIds = <String>{};
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

  Future<void> setPushNotificationsEnabled(bool value) async {
    _pushNotificationsEnabled = value;
    notifyListeners();
    await _settingsStorage.savePushNotificationsEnabled(value);
  }

  Future<void> setDarkModeEnabled(bool value) async {
    _darkModeEnabled = value;
    notifyListeners();
    await _settingsStorage.saveDarkModeEnabled(value);
  }

  Future<void> saveProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? profileImageBase64,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return;
    }

    _currentUser = user.copyWith(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      updatedAt: DateTime.now(),
    );
    _profileImageBase64 = profileImageBase64;

    await _profileStorage.saveProfileOverrides(user.id, {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': email.trim(),
      'phone': phone?.trim(),
      'profile_image_base64': profileImageBase64,
    });
    notifyListeners();
  }

  Future<void> toggleFavorite(String productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    await _persistFavorites();
    notifyListeners();
  }

  bool get requiresLogin => !_isLoggedIn;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  List<Product> productsByCategory(
    String categoryId, {
    bool applySearch = false,
  }) {
    final scoped = categoryId == 'all'
        ? _products
        : _productsForCategory(categoryId);
    if (!applySearch || _searchQuery.isEmpty) {
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

  List<Product> popularProducts({int? limit}) {
    final productsFromCategories = _categories
        .expand((category) => _productsForCategory(category.id))
        .toList();

    final source = productsFromCategories.isNotEmpty
        ? productsFromCategories
        : _products;

    final uniqueProducts = <String, Product>{
      for (final product in source) product.id: product,
    }.values.toList();

    final popularOnly = uniqueProducts
        .where((product) => product.isPopular)
        .toList();

    final result = popularOnly.isNotEmpty ? popularOnly : uniqueProducts;

    if (limit == null || limit >= result.length) {
      return result;
    }
    return result.take(limit).toList();
  }

  Product productById(String id) {
    return _products.firstWhere(
      (product) => product.id == id,
      orElse: () => throw StateError('Product not found: $id'),
    );
  }

  Product? productByIdOrNull(String id) {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  int quantityFor(String productId) {
    final entry = _cart.where((item) => item.productId == productId);
    if (entry.isEmpty) return 1;
    return entry.first.quantity;
  }

  bool addToCart(String productId, {int quantity = 1}) {
    final product = productByIdOrNull(productId);
    if (product == null) {
      return false;
    }
    final availableStock = product.stock;
    if (availableStock <= 0) {
      return false;
    }

    final updatedCart = List<CartItem>.of(_cart);
    final index = _cart.indexWhere((item) => item.productId == productId);
    if (index == -1) {
      final normalizedQuantity = quantity.clamp(1, availableStock);
      updatedCart.add(
        CartItem(productId: productId, quantity: normalizedQuantity),
      );
    } else {
      final current = updatedCart[index];
      final nextQuantity = (current.quantity + quantity).clamp(1, availableStock);
      updatedCart[index] = current.copyWith(
        quantity: nextQuantity,
      );
    }
    _cart = updatedCart;
    _persistCart();
    notifyListeners();
    return true;
  }

  void updateCartQuantity(String productId, int quantity) {
    final index = _cart.indexWhere((item) => item.productId == productId);
    if (index == -1) return;
    final product = productByIdOrNull(productId);
    if (product == null) {
      removeFromCart(productId);
      return;
    }
    final availableStock = product.stock;
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    if (availableStock <= 0) {
      removeFromCart(productId);
      return;
    }
    final updatedCart = List<CartItem>.of(_cart);
    updatedCart[index] = updatedCart[index].copyWith(
      quantity: quantity.clamp(1, availableStock),
    );
    _cart = updatedCart;
    _persistCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart = _cart.where((item) => item.productId != productId).toList();
    _persistCart();
    notifyListeners();
  }

  bool startBuyNowCheckout(String productId, {int quantity = 1}) {
    final product = productByIdOrNull(productId);
    if (product == null) {
      return false;
    }
    final availableStock = product.stock;
    if (availableStock <= 0) {
      return false;
    }
    _checkoutItems = [
      CartItem(
        productId: productId,
        quantity: quantity.clamp(1, availableStock),
      ),
    ];
    notifyListeners();
    return true;
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
      final product = productByIdOrNull(item.productId);
      if (product == null) {
        return sum;
      }
      return sum + (product.price * item.quantity);
    });
  }

  double get subtotal => _subtotalFor(activeCheckoutItems);

  double get shippingFee => 0;

  double get total => subtotal;

  void setPaymentOption(PaymentOption option) {
    _selectedPayment = option;
    notifyListeners();
  }

  bool requiresPaymentForm([PaymentOption? option]) {
    final target = option ?? _selectedPayment;
    return target != PaymentOption.cashOnDelivery;
  }

  bool hasSavedPaymentDetails([PaymentOption? option]) {
    final target = option ?? _selectedPayment;
    if (!requiresPaymentForm(target)) {
      return true;
    }
    final details = _savedPaymentDetails[target];
    return details != null && details.isNotEmpty;
  }

  Map<String, String>? paymentDetailsFor([PaymentOption? option]) {
    final target = option ?? _selectedPayment;
    final details = _savedPaymentDetails[target];
    if (details == null) {
      return null;
    }
    return Map<String, String>.from(details);
  }

  void savePaymentDetails(
    PaymentOption option,
    Map<String, String> details,
  ) {
    final normalized = <String, String>{};
    for (final entry in details.entries) {
      final value = entry.value.trim();
      if (value.isNotEmpty) {
        normalized[entry.key] = value;
      }
    }
    if (normalized.isEmpty) {
      _savedPaymentDetails.remove(option);
    } else {
      _savedPaymentDetails[option] = normalized;
    }
    notifyListeners();
  }

  String? selectedPaymentDetailsSummary() {
    final details = paymentDetailsFor(_selectedPayment);
    if (details == null || details.isEmpty) {
      return null;
    }
    switch (_selectedPayment) {
      case PaymentOption.cashOnDelivery:
        return null;
      case PaymentOption.abaBank:
        final accountName = details['account_name'];
        final transactionId = details['transaction_id'];
        if (transactionId != null && transactionId.isNotEmpty) {
          return accountName == null || accountName.isEmpty
              ? 'Transaction ID: $transactionId'
              : '$accountName - Transaction ID: $transactionId';
        }
        return accountName;
      case PaymentOption.wing:
        final phoneNumber = details['phone_number'];
        final transactionId = details['transaction_id'];
        if (transactionId != null && transactionId.isNotEmpty) {
          return phoneNumber == null || phoneNumber.isEmpty
              ? 'Transaction ID: $transactionId'
              : '$phoneNumber - Transaction ID: $transactionId';
        }
        return phoneNumber;
      case PaymentOption.card:
        final cardNumber = details['card_number'] ?? '';
        if (cardNumber.length >= 4) {
          return 'Card **** ${cardNumber.substring(cardNumber.length - 4)}';
        }
        return details['account_name'];
    }
  }

  Future<void> setShippingAddress({
    required String label,
    required String address,
  }) async {
    final normalizedLabel = label.trim().isEmpty ? 'Address' : label.trim();
    final normalizedAddress = address.trim();
    if (normalizedAddress.isEmpty) {
      return;
    }

    _shippingAddressLabel = normalizedLabel;
    _shippingAddress = normalizedAddress;
    await _shippingAddressStorage.saveShippingAddress(
      label: _shippingAddressLabel,
      address: _shippingAddress,
    );
    notifyListeners();
  }

  Future<CustomerOrder> placeOrder({String? paymentDetails}) async {
    final checkoutItems = activeCheckoutItems
        .where((item) => productByIdOrNull(item.productId) != null)
        .toList();
    if (checkoutItems.isEmpty) {
      throw const OrderException(
        'Your checkout is empty or contains unavailable products.',
      );
    }
    if (_isProcessingCheckout) {
      throw const OrderException('Checkout is already processing.');
    }
    _isProcessingCheckout = true;
    _orderErrorMessage = null;
    notifyListeners();
    final normalizedPaymentDetails = paymentDetails?.trim();
    final localOrder = CustomerOrder(
      id: '#12${340 + _orders.length}',
      userId: _currentUser?.id ?? 0,
      date: DateTime.now(),
      status: OrderStatus.pending,
      productIds: checkoutItems.map((item) => item.productId).toList(),
      total: total,
      paymentMethod:
          normalizedPaymentDetails == null || normalizedPaymentDetails.isEmpty
          ? _selectedPayment.label
          : '${_selectedPayment.label} - $normalizedPaymentDetails',
      address: _shippingAddress,
    );
    final orderItems = checkoutItems.map((item) {
      final product = productByIdOrNull(item.productId);
      if (product == null) {
        throw const OrderException('Some products are no longer available.');
      }
      return OrderItemPayload(
        productId: int.tryParse(item.productId),
        qty: item.quantity,
        unitPrice: product.price,
        subtotal: product.price * item.quantity,
      );
    }).toList();

    try {
      final persistedOrder = await _orderRepository.createOrder(
        order: localOrder,
        items: orderItems,
      );

      final createdOrderId = int.tryParse(persistedOrder.id);
      if (createdOrderId == null) {
        throw const OrderException('Created order id is invalid.');
      }

      await _paymentRepository.createPayment(
        orderId: createdOrderId,
        amount: persistedOrder.total,
        paymentMethod: _selectedPayment.apiValue,
        paymentStatus: _selectedPayment.backendPaymentStatus,
        paymentDate: DateTime.now().toIso8601String(),
      );

      _orderErrorMessage = null;

      _orders = [
        persistedOrder,
        ..._orders.where((order) => order.id != persistedOrder.id),
      ];
      await _persistOrders();
      if (_checkoutItems == null) {
        _cart = [];
        _persistCart();
      }
      _checkoutItems = null;
      _selectedTab = 3;
      notifyListeners();
      return persistedOrder;
    } on OrderException catch (error) {
      _orderErrorMessage = error.message;
      notifyListeners();
      rethrow;
    } on Exception catch (error) {
      _orderErrorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    } catch (_) {
      _orderErrorMessage = 'Unable to process checkout right now.';
      notifyListeners();
      throw const OrderException('Unable to process checkout right now.');
    } finally {
      _isProcessingCheckout = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index == -1) {
      return;
    }

    final updatedOrders = List<CustomerOrder>.of(_orders);
    updatedOrders[index] = updatedOrders[index].copyWith(status: status);
    updatedOrders.sort((a, b) => b.date.compareTo(a.date));
    _orders = updatedOrders;
    await _persistOrders();
    notifyListeners();
  }

  int cartCount() => _cart.length;

  bool hasProductsForCategory(String categoryId) {
    if (categoryId == 'all') {
      return _products.isNotEmpty;
    }
    return _productsForCategory(categoryId).isNotEmpty;
  }

  Future<void> ensureProductsLoadedForCategory(String categoryId) async {
    if (_productsForCategory(categoryId).isNotEmpty || _isLoadingProducts) {
      return;
    }
    await loadProducts();
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
      final mergedProducts = _productsForCategory(category.id);
      final count = mergedProducts.length;
      return StoreCategory(
        id: category.id,
        name: category.name,
        description: category.description,
        createdAt: category.createdAt,
        itemCount: count,
        icon: category.icon,
        products: mergedProducts,
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

  void _rebuildCategoriesFromProducts() {
    if (_products.isEmpty) {
      return;
    }

    final groupedProducts = <String, List<Product>>{};
    for (final product in _products) {
      final categoryId = product.categoryId.trim();
      if (categoryId.isEmpty || categoryId == 'unknown') {
        continue;
      }
      groupedProducts.putIfAbsent(categoryId, () => <Product>[]).add(product);
    }

    if (groupedProducts.isEmpty) {
      return;
    }

    if (_categories.isEmpty) {
      _categories = groupedProducts.entries
          .map((entry) => StoreCategory.fromProducts(entry.key, entry.value))
          .toList();
      return;
    }

    final existingCategoryIds = _categories
        .map((category) => category.id)
        .toSet();
    final fallbackCategories = groupedProducts.entries
        .where((entry) => !existingCategoryIds.contains(entry.key))
        .map((entry) => StoreCategory.fromProducts(entry.key, entry.value))
        .toList();

    if (fallbackCategories.isNotEmpty) {
      _categories = [..._categories, ...fallbackCategories];
    }
  }

  void _persistCart() {
    if (_cart.isEmpty) {
      unawaited(_cartStorage.clearCart());
      return;
    }
    unawaited(_cartStorage.saveCart(_cart));
  }

  Future<void> _persistOrders() async {
    await _orderStorage.saveOrders(_orders);
  }

  Future<void> _loadFavorites() async {
    final userId = _currentUser?.id;
    if (userId == null || userId == 0) {
      _favoriteIds = <String>{};
      return;
    }
    _favoriteIds = await _favoriteStorage.readFavorites(userId);
  }

  Future<void> _persistFavorites() async {
    final userId = _currentUser?.id;
    if (userId == null || userId == 0) {
      return;
    }
    await _favoriteStorage.saveFavorites(userId, _favoriteIds);
  }

  Future<void> _loadProfileOverrides() async {
    final user = _currentUser;
    if (user == null) {
      _profileImageBase64 = null;
      return;
    }

    final overrides = await _profileStorage.readProfileOverrides(user.id);
    if (overrides == null) {
      _profileImageBase64 = null;
      return;
    }

    _currentUser = user.copyWith(
      firstName: overrides['first_name'] as String? ?? user.firstName,
      lastName: overrides['last_name'] as String? ?? user.lastName,
      email: overrides['email'] as String? ?? user.email,
      phone: overrides['phone'] as String? ?? user.phone,
    );
    _profileImageBase64 = overrides['profile_image_base64'] as String?;
  }

  CustomerOrder _mergeOrderStatus({
    required CustomerOrder? localOrder,
    required CustomerOrder apiOrder,
  }) {
    if (localOrder == null) {
      return apiOrder;
    }

    final hasLocalStatusOverride =
        localOrder.status != OrderStatus.pending &&
        apiOrder.status == OrderStatus.pending;

    if (!hasLocalStatusOverride) {
      return apiOrder.copyWith(
        productIds: apiOrder.productIds.isNotEmpty
            ? apiOrder.productIds
            : localOrder.productIds,
      );
    }

    return apiOrder.copyWith(
      status: localOrder.status,
      productIds: apiOrder.productIds.isNotEmpty
          ? apiOrder.productIds
          : localOrder.productIds,
    );
  }

  List<Product> _productsForCategory(String categoryId) {
    final mergedById = <String, Product>{};

    for (final category in _categories.where(
      (category) => category.id == categoryId,
    )) {
      for (final product in category.products) {
        mergedById[product.id] = product;
      }
    }

    for (final product in _products.where(
      (product) => product.categoryId == categoryId,
    )) {
      mergedById[product.id] = product;
    }

    return mergedById.values.toList();
  }
}
