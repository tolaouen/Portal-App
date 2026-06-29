import 'package:shared_preferences/shared_preferences.dart';

class CatalogCacheStorage {
  static const _bannersKey = 'catalog_cache_banners';
  static const _categoriesKey = 'catalog_cache_categories';
  static const _productsKey = 'catalog_cache_products';

  Future<String?> readBannersRaw() => _read(_bannersKey);

  Future<void> saveBannersRaw(String raw) => _save(_bannersKey, raw);

  Future<String?> readCategoriesRaw() => _read(_categoriesKey);

  Future<void> saveCategoriesRaw(String raw) => _save(_categoriesKey, raw);

  Future<String?> readProductsRaw() => _read(_productsKey);

  Future<void> saveProductsRaw(String raw) => _save(_productsKey, raw);

  Future<void> clearCatalogCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bannersKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_productsKey);
  }

  Future<String?> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw;
  }

  Future<void> _save(String key, String raw) async {
    if (raw.trim().isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, raw);
  }
}
