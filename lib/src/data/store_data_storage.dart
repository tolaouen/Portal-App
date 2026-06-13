import '../models/cart_item.dart';
import '../models/customer_order.dart';
import '../models/hero_slide.dart';
import '../models/payment_option.dart';
import '../models/product.dart';
import '../models/store_category.dart';

abstract class StoreDataStorage {
  List<StoreCategory> loadCategories();
  List<Product> loadProducts();
  List<CartItem> loadInitialCart();
  List<CustomerOrder> loadOrders();
  List<HeroSlide> loadHeroSlides();
  String loadShippingAddress();
  PaymentOption loadDefaultPaymentOption();
}
