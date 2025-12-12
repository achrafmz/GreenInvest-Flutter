import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import 'api_service.dart';

class ProjectService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Appel API réel
      // final response = await _apiService.client.get('/projects');
      // _projects = (response.data as List).map((p) => Project.fromJson(p)).toList();

      // Simulation
      await Future.delayed(const Duration(seconds: 1));
      _projects = [
        Project(
          id: '1',
          title: 'Ferme Solaire Souss',
          description: 'Installation de panneaux solaires pour une coopérative agricole.',
          targetAmount: 150000,
          currentAmount: 45000,
          ownerId: 'owner_1',
          status: 'approved',
        ),
        Project(
          id: '2',
          title: 'Recyclage Plastique Rabat',
          description: 'Unité de transformation des déchets plastiques en mobilier urbain.',
          targetAmount: 80000,
          currentAmount: 12000,
          ownerId: 'owner_2',
          status: 'pending',
        ),
      ];
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur chargement projets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> createProject({
    required String nom,
    required String description,
    required double montantObjectif,
    required String contrepartie,
    required double pourcentageRendement,
    required int dureeContrepartie,
    required String typeContrepartie,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = {
        "nom": nom,
        "description": description,
        "montantObjectif": montantObjectif,
        "contrepartie": contrepartie,
        "pourcentageRendement": pourcentageRendement,
        "dureeContrepartie": dureeContrepartie,
        "typeContrepartie": typeContrepartie,
      };

      print('🚀 Creating project with data: $data');

      final response = await _apiService.client.post('/projets', data: data);

      print('✅ Create Project Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh list if needed (optional)
        // await fetchProjects(); 
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Create Project Error: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
