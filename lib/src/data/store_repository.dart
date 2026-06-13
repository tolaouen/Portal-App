import '../models/cart_item.dart';
import '../models/customer_order.dart';
import '../models/hero_slide.dart';
import '../models/payment_option.dart';
import '../models/product.dart';
import '../models/store_category.dart';

abstract class StoreRepository {
  List<StoreCategory> getCategories();
  List<Product> getProducts();
  List<CartItem> getInitialCart();
  List<CustomerOrder> getOrders();
  List<HeroSlide> getHeroSlides();
  String getShippingAddress();
  PaymentOption getDefaultPaymentOption();
}
