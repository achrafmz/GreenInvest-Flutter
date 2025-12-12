import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import 'api_service.dart';

class ProjectService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Project> _projects = [];
  List<Project> _ownerProjects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => _projects;
  List<Project> get ownerProjects => _ownerProjects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProjects({int page = 0, int size = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get(
        '/projets', 
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': 'dateCreation',
          'direction': 'DESC'
        }
      );
      
      if (response.statusCode == 200) {
        _projects = _parseProjects(response.data);
      } else {
        _error = 'Erreur serveur: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur chargement projets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Legacy kept for compatibility if needed, but implementation updated to use new logic if desired or kept as is.
  // Converting fetchPublicProjects to use the new standard method for now? 
  // User might want specific params. Let's alias it.
  Future<void> fetchPublicProjects() => fetchProjects();

  Future<void> fetchOwnerProjects(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get(
        '/porteur/mes-projets',
        queryParameters: {'porteurId': ownerId},
      );
      
      if (response.statusCode == 200) {
        // La réponse est enveloppée dans "data"
        final dynamic rawWrapper = response.data;
        debugPrint('🔍 Raw Owner Projects Response: $rawWrapper'); // DEBUG LOG

        List<dynamic> listData = [];

        if (rawWrapper is Map && rawWrapper.containsKey('data')) {
           final dynamic dataContent = rawWrapper['data'];
           if (dataContent is List) {
             listData = dataContent;
           }
        } else if (rawWrapper is List) {
          listData = rawWrapper;
        }

        _ownerProjects = listData.map((json) {
          debugPrint('Parsing project: $json'); // DEBUG LOG
          return Project.fromJson(json);
        }).toList();
        
        debugPrint('✅ Loaded ${_ownerProjects.length} owner projects');
      } else {
        _error = 'Erreur serveur (Owner): ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur chargement projets owner: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Project> _parseProjects(dynamic rawData) {
    List<dynamic> listData = [];
    if (rawData is List) {
      listData = rawData;
    } else if (rawData is Map) {
      if (rawData.containsKey('content') && rawData['content'] is List) {
        listData = rawData['content'];
      } else if (rawData.containsKey('data') && rawData['data'] is List) {
          listData = rawData['data'];
      }
    }
    return listData.map((json) => Project.fromJson(json)).toList();
  }

  // Ancien getter (optionnel, ou on utilise ownerProjects direct)
  List<Project> getProjectsByOwner(String ownerId) {
    // Si on a chargé spécifiquement les projets du owner, on les retourne directement
    // sans revérifier l'ID (au cas où il y aurait une mismatch ou null)
    if (_ownerProjects.isNotEmpty) {
      return _ownerProjects;
    }
    return _projects.where((p) => p.ownerId == ownerId).toList();
  }
  Future<List<Project>> fetchAdminProjects() async {
    _isLoading = true;
    notifyListeners();
    List<Project> adminProjects = [];

    try {
      // Endpoint probable pour voir tous les projets (admin)
      final response = await _apiService.client.get('/admin/projets');
      
      if (response.statusCode == 200) {
        final dynamic rawWrapper = response.data;
        List<dynamic> listData = [];

        if (rawWrapper is Map && rawWrapper.containsKey('data')) {
           listData = rawWrapper['data'];
        } else if (rawWrapper is List) {
          listData = rawWrapper;
        }

        adminProjects = listData.map((json) => Project.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ /admin/projets failed: $e');
      // Fallback: fetch public and try simple filter? No, public won't have pending.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return adminProjects;
  }

  // Méthode spécifique pour l'admin qui veut voir les projets d'un user
  Future<void> fetchUserProjectsAsAdmin(String userId) async {
    _isLoading = true;
    _error = null; // Reset error
    notifyListeners();
    print('🔍 Fetching projects for user: $userId');
    try {
        final response = await _apiService.client.get('/porteur/mes-projets', queryParameters: {'porteurId': userId});
         
         print('🔍 Response code: ${response.statusCode}');
         
         if (response.statusCode == 200) {
            _ownerProjects = _parseProjects(response.data);
            print('✅ Found ${_ownerProjects.length} projects via specific endpoint');
         } else {
           _error = 'Error ${response.statusCode}: ${response.statusMessage}';
           print('❌ API Error: $_error');
         }
    } catch (e) {
       _error = e.toString();
       print('❌ fetchUserProjectsAsAdmin Error: $e');
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
        await fetchPublicProjects(); 
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
