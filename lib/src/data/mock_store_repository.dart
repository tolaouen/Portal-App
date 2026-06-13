import '../models/cart_item.dart';
import '../models/customer_order.dart';
import '../models/hero_slide.dart';
import '../models/payment_option.dart';
import '../models/product.dart';
import '../models/store_category.dart';
import 'mock_store_storage.dart';
import 'store_data_storage.dart';
import 'store_repository.dart';

class MockStoreRepository implements StoreRepository {
  MockStoreRepository({StoreDataStorage? storage})
    : _storage = storage ?? MockStoreStorage();

  final StoreDataStorage _storage;

  @override
  List<StoreCategory> getCategories() {
    return _storage.loadCategories();
  }

  @override
  List<Product> getProducts() {
    return _storage.loadProducts();
  }

  @override
  List<CartItem> getInitialCart() {
    return _storage.loadInitialCart();
  }

  @override
  List<CustomerOrder> getOrders() {
    return _storage.loadOrders();
  }

  @override
  List<HeroSlide> getHeroSlides() {
    return _storage.loadHeroSlides();
  }

  @override
  String getShippingAddress() {
    return _storage.loadShippingAddress();
  }

  @override
  PaymentOption getDefaultPaymentOption() {
    return _storage.loadDefaultPaymentOption();
  }
}
