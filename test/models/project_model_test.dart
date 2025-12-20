import 'package:flutter_test/flutter_test.dart';
import 'package:green_invest_app/models/project_model.dart';

void main() {
  group('Project Model Tests', () {
    group('fromJson', () {
      test('should create Project from JSON with French field names', () {
        // Arrange
        final json = {
          'id': 'proj-1',
          'nom': 'Projet Solaire',
          'description': 'Installation de panneaux solaires',
          'montantObjectif': 50000.0,
          'montantInvesti': 15000.0,
          'porteurId': 'owner-123',
          'statut': 'approved',
          'contrepartie': '5% de rendement',
          'pourcentageRendement': 5.0,
          'dureeContrepartie': 36,
          'typeContrepartie': 'financière',
          'dateCreation': '2024-01-15',
          'nombreInvestisseurs': 3,
          'imageUrl': 'https://example.com/solar.jpg',
        };

        // Act
        final project = Project.fromJson(json);

        // Assert
        expect(project.id, 'proj-1');
        expect(project.title, 'Projet Solaire');
        expect(project.description, 'Installation de panneaux solaires');
        expect(project.targetAmount, 50000.0);
        expect(project.currentAmount, 15000.0);
        expect(project.ownerId, 'owner-123');
        expect(project.status, 'approved');
        expect(project.contrepartie, '5% de rendement');
        expect(project.pourcentageRendement, 5.0);
        expect(project.dureeContrepartie, 36);
        expect(project.typeContrepartie, 'financière');
        expect(project.dateCreation, '2024-01-15');
        expect(project.nombreInvestisseurs, 3);
        expect(project.imageUrl, 'https://example.com/solar.jpg');
      });

      test('should create Project from JSON with English field names', () {
        // Arrange
        final json = {
          'id': 'proj-2',
          'title': 'Wind Project',
          'description': 'Wind turbine installation',
          'targetAmount': 100000.0,
          'currentAmount': 0.0,
          'ownerId': 'owner-456',
          'status': 'pending',
        };

        // Act
        final project = Project.fromJson(json);

        // Assert
        expect(project.id, 'proj-2');
        expect(project.title, 'Wind Project');
        expect(project.description, 'Wind turbine installation');
        expect(project.targetAmount, 100000.0);
        expect(project.currentAmount, 0.0);
        expect(project.ownerId, 'owner-456');
        expect(project.status, 'pending');
      });

      test('should create Project from JSON with snake_case field names', () {
        // Arrange
        final json = {
          'id': 'proj-3',
          'name': 'Biomass Project',
          'description': 'Local biomass plant',
          'montant_objectif': 75000.0,
          'montant_investi': 25000.0,
          'porteur_id': 'owner-789',
          'statut': 'approved',
          'pourcentage_rendement': 6.0,
          'duree_contrepartie': 48,
          'type_contrepartie': 'financière',
          'date_creation': '2024-02-01',
          'nombre_investisseurs': 5,
        };

        // Act
        final project = Project.fromJson(json);

        // Assert
        expect(project.title, 'Biomass Project');
        expect(project.targetAmount, 75000.0);
        expect(project.currentAmount, 25000.0);
        expect(project.ownerId, 'owner-789');
        expect(project.pourcentageRendement, 6.0);
        expect(project.dureeContrepartie, 48);
      });

      test('should handle multiple image field name variations', () {
        final imageFieldNames = ['imageUrl', 'image_url', 'image', 'url', 'photo', 'picture'];
        
        for (final fieldName in imageFieldNames) {
          final json = {
            'id': 'proj',
            'nom': 'Test',
            'description': 'Test',
            'montantObjectif': 1000.0,
            'montantInvesti': 0.0,
            'porteurId': '1',
            'statut': 'pending',
            fieldName: 'https://example.com/image.jpg',
          };
          
          final project = Project.fromJson(json);
          expect(project.imageUrl, 'https://example.com/image.jpg', 
            reason: 'Field $fieldName should map to imageUrl');
        }
      });

      test('should use default values for missing fields', () {
        // Arrange
        final Map<String, dynamic> json = {
          // Missing id, will use empty string default
          // Missing amounts, will use 0.0 default
          // Missing status, will use 'pending' default
        };

        // Act
        final project = Project.fromJson(json);

        // Assert
        expect(project.id, '');
        expect(project.title, '');
        expect(project.description, '');
        expect(project.targetAmount, 0.0);
        expect(project.currentAmount, 0.0);
        expect(project.ownerId, '');
        expect(project.status, 'pending');
        expect(project.pourcentageRendement, 0.0);
      });

      test('should convert numeric amounts to double', () {
        // Arrange
        final json = {
          'id': 'proj',
          'nom': 'Test',
          'description': 'Test',
          'montantObjectif': 50000, // Integer
          'montantInvesti': 15000, // Integer
          'porteurId': '1',
          'statut': 'approved',
          'pourcentageRendement': 5, // Integer
        };

        // Act
        final project = Project.fromJson(json);

        // Assert
        expect(project.targetAmount, 50000.0);
        expect(project.targetAmount, isA<double>());
        expect(project.currentAmount, 15000.0);
        expect(project.currentAmount, isA<double>());
        expect(project.pourcentageRendement, 5.0);
        expect(project.pourcentageRendement, isA<double>());
      });

      test('should handle null optional fields', () {
        // Arrange
        final json = {
          'id': 'proj',
          'nom': 'Minimal Project',
          'description': 'Test',
          'montantObjectif': 1000.0,
          'montantInvesti': 0.0,
          'porteurId': '1',
          'statut': 'pending',
          'contrepartie': null,
          'imageUrl': null,
        };

        // Act
        final project = Project.fromJson(json);

        // Assert
        expect(project.contrepartie, isNull);
        expect(project.imageUrl, isNull);
        expect(project.dateCreation, isNull);
      });
    });

    group('toJson', () {
      test('should convert Project to JSON', () {
        // Arrange
        final project = Project(
          id: 'proj-99',
          title: 'Test Project',
          description: 'A test project',
          targetAmount: 30000.0,
          currentAmount: 10000.0,
          ownerId: 'owner-99',
          status: 'approved',
          contrepartie: '4% rendement',
          pourcentageRendement: 4.0,
          dureeContrepartie: 24,
          typeContrepartie: 'financière',
          dateCreation: '2024-03-01',
          nombreInvestisseurs: 2,
          imageUrl: 'https://example.com/test.jpg',
        );

        // Act
        final json = project.toJson();

        // Assert
        expect(json['id'], 'proj-99');
        expect(json['title'], 'Test Project');
        expect(json['description'], 'A test project');
        expect(json['targetAmount'], 30000.0);
        expect(json['currentAmount'], 10000.0);
        expect(json['ownerId'], 'owner-99');
        expect(json['status'], 'approved');
        expect(json['contrepartie'], '4% rendement');
        expect(json['pourcentageRendement'], 4.0);
        expect(json['dureeContrepartie'], 24);
        expect(json['typeContrepartie'], 'financière');
        expect(json['dateCreation'], '2024-03-01');
        expect(json['nombreInvestisseurs'], 2);
        expect(json['imageUrl'], 'https://example.com/test.jpg');
      });

      test('should include null values in JSON', () {
        // Arrange
        final project = Project(
          id: 'proj',
          title: 'Minimal',
          description: 'Test',
          targetAmount: 1000.0,
          currentAmount: 0.0,
          ownerId: '1',
          status: 'pending',
        );

        // Act
        final json = project.toJson();

        // Assert
        expect(json.containsKey('contrepartie'), true);
        expect(json['contrepartie'], isNull);
        expect(json['imageUrl'], isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // Arrange
        final original = Project(
          id: 'proj-1',
          title: 'Original Title',
          description: 'Original Description',
          targetAmount: 50000.0,
          currentAmount: 10000.0,
          ownerId: 'owner-1',
          status: 'pending',
        );

        // Act
        final updated = original.copyWith(
          title: 'Updated Title',
          currentAmount: 20000.0,
          status: 'approved',
        );

        // Assert
        expect(updated.id, 'proj-1'); // Unchanged
        expect(updated.title, 'Updated Title'); // Changed
        expect(updated.description, 'Original Description'); // Unchanged
        expect(updated.currentAmount, 20000.0); // Changed
        expect(updated.status, 'approved'); // Changed
        expect(updated.ownerId, 'owner-1'); // Unchanged
      });

      test('should create exact copy when no fields specified', () {
        // Arrange
        final original = Project(
          id: 'proj-2',
          title: 'Test',
          description: 'Description',
          targetAmount: 30000.0,
          currentAmount: 5000.0,
          ownerId: 'owner-2',
          status: 'approved',
          imageUrl: 'https://example.com/img.jpg',
        );

        // Act
        final copy = original.copyWith();

        // Assert
        expect(copy.id, original.id);
        expect(copy.title, original.title);
        expect(copy.description, original.description);
        expect(copy.targetAmount, original.targetAmount);
        expect(copy.currentAmount, original.currentAmount);
        expect(copy.ownerId, original.ownerId);
        expect(copy.status, original.status);
        expect(copy.imageUrl, original.imageUrl);
      });

      test('should update all fields when specified', () {
        // Arrange
        final original = Project(
          id: 'old-id',
          title: 'Old Title',
          description: 'Old Description',
          targetAmount: 1000.0,
          currentAmount: 0.0,
          ownerId: 'old-owner',
          status: 'pending',
        );

        // Act
        final updated = original.copyWith(
          id: 'new-id',
          title: 'New Title',
          description: 'New Description',
          targetAmount: 2000.0,
          currentAmount: 500.0,
          ownerId: 'new-owner',
          status: 'approved',
          contrepartie: 'New contrepartie',
          pourcentageRendement: 7.0,
          dureeContrepartie: 60,
          typeContrepartie: 'mixte',
          dateCreation: '2024-04-01',
          nombreInvestisseurs: 10,
          imageUrl: 'https://new-image.com/img.jpg',
        );

        // Assert
        expect(updated.id, 'new-id');
        expect(updated.title, 'New Title');
        expect(updated.description, 'New Description');
        expect(updated.targetAmount, 2000.0);
        expect(updated.currentAmount, 500.0);
        expect(updated.ownerId, 'new-owner');
        expect(updated.status, 'approved');
        expect(updated.contrepartie, 'New contrepartie');
        expect(updated.pourcentageRendement, 7.0);
        expect(updated.dureeContrepartie, 60);
        expect(updated.typeContrepartie, 'mixte');
        expect(updated.dateCreation, '2024-04-01');
        expect(updated.nombreInvestisseurs, 10);
        expect(updated.imageUrl, 'https://new-image.com/img.jpg');
      });
    });

    group('Edge cases', () {
      test('should handle different status values', () {
        final statuses = ['pending', 'approved', 'rejected', 'funded'];
        
        for (final status in statuses) {
          final json = {
            'id': 'proj',
            'nom': 'Test',
            'description': 'Test',
            'montantObjectif': 1000.0,
            'montantInvesti': 0.0,
            'porteurId': '1',
            'statut': status,
          };
          
          final project = Project.fromJson(json);
          expect(project.status, status);
        }
      });

      test('should handle zero amounts', () {
        // Arrange
        final json = {
          'id': 'proj',
          'nom': 'Zero Project',
          'description': 'Test',
          'montantObjectif': 0.0,
          'montantInvesti': 0.0,
          'porteurId': '1',
          'statut': 'pending',
        };

        // Act
        final project = Project.fromJson(json);

        // Assert
        expect(project.targetAmount, 0.0);
        expect(project.currentAmount, 0.0);
      });

      test('should handle fully funded project', () {
        // Arrange
        final json = {
          'id': 'proj',
          'nom': 'Funded Project',
          'description': 'Test',
          'montantObjectif': 50000.0,
          'montantInvesti': 50000.0,
          'porteurId': '1',
          'statut': 'funded',
        };

        // Act
        final project = Project.fromJson(json);

        // Assert
        expect(project.currentAmount, project.targetAmount);
        expect(project.status, 'funded');
      });
    });
  });
}
