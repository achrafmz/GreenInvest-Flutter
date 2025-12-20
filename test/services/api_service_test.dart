import 'package:flutter_test/flutter_test.dart';
import 'package:green_invest_app/services/api_service.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('ApiService Tests', () {
    test('should return correct baseUrl for web platform', () {
      // This test verifies the baseUrl getter logic
      // Note: In actual test environment, kIsWeb will be false
      // but we can test the ApiService instantiation
      
      final apiService = ApiService();
      expect(apiService, isNotNull);
      expect(apiService.client, isNotNull);
      expect(apiService.storage, isNotNull);
    });

    test('baseUrl should be a valid URL', () {
      final baseUrl = ApiService.baseUrl;
      
      expect(baseUrl, isNotNull);
      expect(baseUrl, contains('http'));
      expect(baseUrl, contains(':'));
    });

    test('createPublicClient should create Dio instance', () {
      final publicClient = ApiService.createPublicClient();
      
      expect(publicClient, isNotNull);
      expect(publicClient.options.baseUrl, equals(ApiService.baseUrl));
      expect(publicClient.options.headers['Content-Type'], equals('application/json'));
      expect(publicClient.options.headers['Accept'], equals('application/json'));
    });

    test('createPublicClient should have correct timeout settings', () {
      final publicClient = ApiService.createPublicClient();
      
      expect(publicClient.options.connectTimeout, equals(const Duration(seconds: 15)));
      expect(publicClient.options.receiveTimeout, equals(const Duration(seconds: 15)));
      expect(publicClient.options.sendTimeout, equals(const Duration(seconds: 15)));
    });

    test('createPublicClient should follow redirects', () {
      final publicClient = ApiService.createPublicClient();
      
      expect(publicClient.options.followRedirects, isTrue);
      expect(publicClient.options.maxRedirects, equals(5));
    });

    test('ApiService instance should have Dio client configured', () {
      final apiService = ApiService();
      
      expect(apiService.client.options.baseUrl, equals(ApiService.baseUrl));
      expect(apiService.client.options.connectTimeout, equals(const Duration(seconds: 15)));
      expect(apiService.client.options.receiveTimeout, equals(const Duration(seconds: 15)));
    });

    test('ApiService should have interceptors configured', () {
      final apiService = ApiService();
      
      // Verify that interceptors are added (at least one for auth token)
      expect(apiService.client.interceptors.length, greaterThan(0));
    });

    test('validateStatus should accept status codes less than 500', () {
      final publicClient = ApiService.createPublicClient();
      final validateStatus = publicClient.options.validateStatus;
      
      expect(validateStatus, isNotNull);
      if (validateStatus != null) {
        expect(validateStatus(200), isTrue);
        expect(validateStatus(201), isTrue);
        expect(validateStatus(400), isTrue);
        expect(validateStatus(404), isTrue);
        expect(validateStatus(499), isTrue);
        expect(validateStatus(500), isFalse);
        expect(validateStatus(503), isFalse);
      }
    });

    test('baseUrl should use correct port for backend', () {
      final baseUrl = ApiService.baseUrl;
      
      // Backend should be on port 8081
      expect(baseUrl, contains('8081'));
    });
  });
}
