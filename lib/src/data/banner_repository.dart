import '../models/hero_slide.dart';

abstract class BannerRepository {
  Future<List<HeroSlide>> fetchBanners();
}

class BannerException implements Exception {
  const BannerException(this.message);

  final String message;

  @override
  String toString() => message;
}
