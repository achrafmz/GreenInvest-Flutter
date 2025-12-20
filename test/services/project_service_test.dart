import 'package:flutter_test/flutter_test.dart';
import 'package:green_invest_app/services/project_service.dart';

void main() {
  group('ProjectService Tests', () {
    late ProjectService projectService;

    setUp(() {
      projectService = ProjectService();
    });

    test('should initialize with default values', () {
      expect(projectService.isLoading, isFalse);
      expect(projectService.error, isNull);
      expect(projectService.projects, isEmpty);
    });

    test('isLoading should be false initially', () {
      expect(projectService.isLoading, isFalse);
    });

    test('error should be null initially', () {
      expect(projectService.error, isNull);
    });

    test('projects list should be empty initially', () {
      expect(projectService.projects, isEmpty);
      expect(projectService.projects, isA<List>());
    });

    test('should be a ChangeNotifier', () {
      expect(projectService, isA<ProjectService>());
      expect(projectService.hasListeners, isFalse);
    });

    test('should allow adding and removing listeners', () {
      var listenerCalled = false;
      void listener() {
        listenerCalled = true;
      }

      projectService.addListener(listener);
      expect(projectService.hasListeners, isTrue);

      projectService.removeListener(listener);
      expect(projectService.hasListeners, isFalse);
    });

    test('should notify listeners when notifyListeners is called', () {
      var notificationCount = 0;
      void listener() {
        notificationCount++;
      }

      projectService.addListener(listener);
      
      // Manually trigger notification (in real scenario, this happens in service methods)
      projectService.notifyListeners();
      
      expect(notificationCount, equals(1));

      projectService.removeListener(listener);
    });
  });

  group('ProjectService State Management', () {
    test('should maintain independent state across instances', () {
      final service1 = ProjectService();
      final service2 = ProjectService();
      
      expect(service1, isNot(same(service2)));
      expect(service1.projects, isNot(same(service2.projects)));
    });

    test('should have correct initial state values', () {
      final service = ProjectService();
      
      expect(service.isLoading, isFalse);
      expect(service.error, isNull);
      expect(service.projects.length, equals(0));
    });
  });
}
