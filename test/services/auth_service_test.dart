import 'package:flutter_test/flutter_test.dart';
import 'package:green_invest_app/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should initialize correctly', () {
      expect(authService, isNotNull);
      expect(authService, isA<AuthService>());
    });

    test('should be a ChangeNotifier', () {
      expect(authService, isA<AuthService>());
      expect(authService.hasListeners, isFalse);
    });

    test('should allow adding and removing listeners', () {
      var listenerCalled = false;
      void listener() {
        listenerCalled = true;
      }

      authService.addListener(listener);
      expect(authService.hasListeners, isTrue);

      authService.removeListener(listener);
      expect(authService.hasListeners, isFalse);
    });

    test('should maintain state across instances independently', () {
      final service1 = AuthService();
      final service2 = AuthService();
      
      expect(service1, isNot(same(service2)));
    });

    test('should be properly instantiated', () {
      final service = AuthService();
      expect(service, isNotNull);
    });
  });

  group('AuthService ChangeNotifier', () {
    test('should notify listeners when notifyListeners is called', () {
      final authService = AuthService();
      var notificationCount = 0;
      
      void listener() {
        notificationCount++;
      }

      authService.addListener(listener);
      authService.notifyListeners();
      
      expect(notificationCount, equals(1));
      
      authService.removeListener(listener);
    });

    test('should support multiple listeners', () {
      final authService = AuthService();
      var listener1Called = false;
      var listener2Called = false;
      
      void listener1() {
        listener1Called = true;
      }
      
      void listener2() {
        listener2Called = true;
      }

      authService.addListener(listener1);
      authService.addListener(listener2);
      
      authService.notifyListeners();
      
      expect(listener1Called, isTrue);
      expect(listener2Called, isTrue);
      
      authService.removeListener(listener1);
      authService.removeListener(listener2);
    });
  });
}
