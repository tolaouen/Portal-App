import '../models/store_category.dart';

abstract class CategoryRepository {
  Future<List<StoreCategory>> fetchCategories();
}
