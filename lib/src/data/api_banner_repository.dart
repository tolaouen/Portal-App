import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/hero_slide.dart';
import 'banner_repository.dart';

class ApiBannerRepository implements BannerRepository {
  ApiBannerRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  @override
  Future<List<HeroSlide>> fetchBanners() async {
    try {
      final response = await _client
          .get(
            _uri(AppConfig.bannerPath),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw BannerException(
          'Unable to load banners. Status ${response.statusCode}.',
        );
      }

      return compute(_parseBanners, response.body);
    } on TimeoutException {
      throw const BannerException(
        'Banner server is taking too long to respond.',
      );
    } on SocketException {
      throw const BannerException(
        'No internet connection or banner server is unreachable.',
      );
    } on http.ClientException {
      throw const BannerException('Unable to reach banner server.');
    } on FormatException {
      throw const BannerException('Invalid banner response.');
    }
  }
}

List<HeroSlide> _parseBanners(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List) {
    throw const BannerException('Invalid banner response.');
  }

  return decoded
      .whereType<Map<String, dynamic>>()
      .map(HeroSlide.fromApiJson)
      .toList();
}
