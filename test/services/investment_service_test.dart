import 'package:flutter_test/flutter_test.dart';
import 'package:green_invest_app/services/investment_service.dart';

void main() {
  group('InvestmentService Tests', () {
    late InvestmentService investmentService;

    setUp(() {
      investmentService = InvestmentService();
    });

    test('should initialize with default values', () {
      expect(investmentService.isLoading, isFalse);
      expect(investmentService.error, isNull);
      expect(investmentService.myInvestments, isEmpty);
    });

    test('isLoading should be false initially', () {
      expect(investmentService.isLoading, isFalse);
    });

    test('error should be null initially', () {
      expect(investmentService.error, isNull);
    });

    test('myInvestments should be empty initially', () {
      expect(investmentService.myInvestments, isEmpty);
      expect(investmentService.myInvestments, isA<List>());
    });

    test('should be a ChangeNotifier', () {
      expect(investmentService, isA<InvestmentService>());
      // InvestmentService extends ChangeNotifier
      expect(investmentService.hasListeners, isFalse);
    });

    test('should allow adding listeners', () {
      var listenerCalled = false;
      void listener() {
        listenerCalled = true;
      }

      investmentService.addListener(listener);
      expect(investmentService.hasListeners, isTrue);

      investmentService.removeListener(listener);
      expect(investmentService.hasListeners, isFalse);
    });
  });

  group('InvestmentService State Management', () {
    test('should start with correct initial state', () {
      final service = InvestmentService();
      
      expect(service.isLoading, equals(false));
      expect(service.error, isNull);
      expect(service.myInvestments.length, equals(0));
    });

    test('should be able to create multiple instances', () {
      final service1 = InvestmentService();
      final service2 = InvestmentService();
      
      expect(service1, isNot(same(service2)));
      expect(service1.myInvestments, isNot(same(service2.myInvestments)));
    });
  });
}
