import 'package:flutter_test/flutter_test.dart';
import 'package:green_invest_app/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    group('fromJson', () {
      test('should create User from complete JSON', () {
        // Arrange
        final json = {
          'id': '123',
          'username': 'testuser',
          'email': 'test@example.com',
          'role': 'INVESTISSEUR',
          'keycloakUserId': 'kc-456',
          'dateInscription': '2024-01-15T10:30:00Z',
          'solde': 10000.50,
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, '123');
        expect(user.username, 'testuser');
        expect(user.email, 'test@example.com');
        expect(user.role, 'INVESTISSEUR');
        expect(user.keycloakUserId, 'kc-456');
        expect(user.dateInscription, DateTime.parse('2024-01-15T10:30:00Z'));
        expect(user.solde, 10000.50);
      });

      test('should handle numeric ID conversion to String', () {
        // Arrange
        final json = {
          'id': 42, // Numeric ID
          'username': 'testuser',
          'email': 'test@example.com',
          'role': 'PORTEUR_PROJET',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, '42');
        expect(user.role, 'PORTEUR_PROJET');
      });

      test('should handle null optional fields', () {
        // Arrange
        final json = {
          'id': '1',
          'username': 'admin',
          'email': 'admin@example.com',
          'role': 'ADMIN',
          'keycloakUserId': null,
          'dateInscription': null,
          'solde': null,
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.keycloakUserId, isNull);
        expect(user.dateInscription, isNull);
        expect(user.solde, isNull);
      });

      test('should handle missing optional fields', () {
        // Arrange
        final json = {
          'id': '1',
          'username': 'owner',
          'email': 'owner@example.com',
          'role': 'PORTEUR_PROJET',
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, '1');
        expect(user.username, 'owner');
        expect(user.keycloakUserId, isNull);
        expect(user.dateInscription, isNull);
        expect(user.solde, isNull);
      });

      test('should convert solde to double from int', () {
        // Arrange
        final json = {
          'id': '1',
          'username': 'investor',
          'email': 'investor@example.com',
          'role': 'INVESTISSEUR',
          'solde': 5000, // Integer instead of double
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.solde, 5000.0);
        expect(user.solde, isA<double>());
      });
    });

    group('toJson', () {
      test('should convert User to JSON with all fields', () {
        // Arrange
        final user = User(
          id: '999',
          username: 'jsonuser',
          email: 'json@example.com',
          role: 'INVESTISSEUR',
          keycloakUserId: 'kc-999',
          dateInscription: DateTime.parse('2024-02-20T15:45:00Z'),
          solde: 15000.75,
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], '999');
        expect(json['username'], 'jsonuser');
        expect(json['email'], 'json@example.com');
        expect(json['role'], 'INVESTISSEUR');
        expect(json['keycloakUserId'], 'kc-999');
        expect(json['dateInscription'], '2024-02-20T15:45:00.000Z');
        expect(json['solde'], 15000.75);
      });

      test('should convert User to JSON with null optional fields', () {
        // Arrange
        final user = User(
          id: '888',
          username: 'minimaluser',
          email: 'minimal@example.com',
          role: 'ADMIN',
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], '888');
        expect(json['username'], 'minimaluser');
        expect(json['keycloakUserId'], isNull);
        expect(json['dateInscription'], isNull);
        expect(json['solde'], isNull);
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through fromJson and toJson', () {
        // Arrange
        final originalJson = {
          'id': '777',
          'username': 'roundtrip',
          'email': 'roundtrip@example.com',
          'role': 'INVESTISSEUR',
          'keycloakUserId': 'kc-777',
          'dateInscription': '2024-03-10T08:00:00Z',
          'solde': 20000.0,
        };

        // Act
        final user = User.fromJson(originalJson);
        final resultJson = user.toJson();

        // Assert
        expect(resultJson['id'], originalJson['id']);
        expect(resultJson['username'], originalJson['username']);
        expect(resultJson['email'], originalJson['email']);
        expect(resultJson['role'], originalJson['role']);
        expect(resultJson['keycloakUserId'], originalJson['keycloakUserId']);
        expect(resultJson['solde'], originalJson['solde']);
      });
    });

    group('Edge cases', () {
      test('should handle different role types', () {
        // Test all role types
        final roles = ['INVESTISSEUR', 'PORTEUR_PROJET', 'ADMIN'];
        
        for (final role in roles) {
          final json = {
            'id': '1',
            'username': 'user',
            'email': 'user@example.com',
            'role': role,
          };
          
          final user = User.fromJson(json);
          expect(user.role, role);
        }
      });

      test('should handle zero solde', () {
        // Arrange
        final json = {
          'id': '1',
          'username': 'broke',
          'email': 'broke@example.com',
          'role': 'INVESTISSEUR',
          'solde': 0.0,
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.solde, 0.0);
      });

      test('should handle negative solde', () {
        // Arrange
        final json = {
          'id': '1',
          'username': 'debt',
          'email': 'debt@example.com',
          'role': 'INVESTISSEUR',
          'solde': -500.0,
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.solde, -500.0);
      });
    });
  });
}
