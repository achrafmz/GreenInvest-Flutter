import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
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


  // Pour la page publique (HomeScreen) - Endpoint public sans auth
  Future<void> fetchPublicProjects({int page = 0, int size = 10}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    debugPrint('🔍 Fetching PUBLIC projects from /public/projets with page=$page, size=$size');
    final response = await _apiService.client.get(
      '/public/projets', 
      queryParameters: {
        'page': page,
        'size': size,
        'sortBy': 'dateCreation',
        'direction': 'DESC'
      }
    );
    
    debugPrint('📥 /public/projets response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      _projects = _parseProjects(response.data);
      debugPrint('✅ Loaded ${_projects.length} public projects');
      
      if (_projects.isNotEmpty) {
        debugPrint('🔍 Parsed Project [0] imageUrl: ${_projects[0].imageUrl}');
      }
    } else {
      _error = 'Erreur serveur: ${response.statusCode}';
      debugPrint('❌ Server error: ${response.statusCode}');
    }
  } catch (e) {
    _error = e.toString();
    debugPrint('❌ Erreur chargement projets publics: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Pour l'admin (PendingProjectsScreen) - Endpoint avec auth
  Future<void> fetchProjects({int page = 0, int size = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔍 Fetching ALL projects from /projets with page=$page, size=$size (ADMIN)');
      final response = await _apiService.client.get(
        '/projets', 
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': 'dateCreation',
          'direction': 'DESC'
        }
      );
      
      debugPrint('📥 /projets response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _projects = _parseProjects(response.data);
        debugPrint('✅ Loaded ${_projects.length} projects (all statuses)');
      } else if (response.statusCode == 401) {
        _error = 'Non autorisé. Veuillez vous reconnecter.';
        debugPrint('❌ 401 Unauthorized - Token invalide ou expiré');
      } else {
        _error = 'Erreur serveur: ${response.statusCode}';
        debugPrint('❌ Server error: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Erreur chargement projets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
        final dynamic rawWrapper = response.data;
        debugPrint('🔍 Raw Owner Projects Response: $rawWrapper');

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
          return Project.fromJson(json);
        }).toList();
        
        debugPrint('✅ Loaded ${_ownerProjects.length} owner projects');
        if (listData.isNotEmpty) {
           final first = listData[0];
           if (first is Map) {
             debugPrint('🔑 Owner Projects Keys: ${first.keys.toList()}');
           }
        }
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

  List<Project> getProjectsByOwner(String ownerId) {
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return adminProjects;
  }

  Future<void> fetchUserProjectsAsAdmin(String userId) async {
    _isLoading = true;
    _error = null;
    _ownerProjects = [];
    notifyListeners();
    print('🔍 Fetching projects for user: $userId');
    try {
        // Attempt 1: /porteur/mes-projets
        try {
          final response = await _apiService.client.get('/porteur/mes-projets', queryParameters: {'porteurId': userId});
          if (response.statusCode == 200) {
              _ownerProjects = _parseProjects(response.data);
              print('✅ Found ${_ownerProjects.length} projects via /porteur/mes-projets');
              return;
          }
        } catch (e) {
          print('⚠️ /porteur/mes-projets failed: $e');
        }

        // Attempt 2: /projets with filter
        try {
           final response = await _apiService.client.get('/projets', queryParameters: {'porteurId': userId});
           if (response.statusCode == 200) {
              final projects = _parseProjects(response.data);
              _ownerProjects = projects.where((p) => p.ownerId == userId).toList();
              print('✅ Found ${_ownerProjects.length} projects via /projets');
              return;
           }
        } catch (e) {
           print('⚠️ /projets?porteurId failed: $e');
        }

        // Attempt 3: /admin/projets
        try {
           final response = await _apiService.client.get('/admin/projets', queryParameters: {'porteurId': userId});
           if (response.statusCode == 200) {
              _ownerProjects = _parseProjects(response.data);
              return;
           }
        } catch (e) {
           print('⚠️ /admin/projets failed: $e');
        }
        
        _error = "Impossible de récupérer les projets (403/500) après 3 tentatives.";

    } catch (e) {
       _error = e.toString();
       print('❌ fetchUserProjectsAsAdmin Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createProject({
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
        // Le backend retourne un wrapper {success: true, data: {...}}
        dynamic projectData = response.data;
        if (projectData is Map && projectData.containsKey('data')) {
           projectData = projectData['data'];
        }
        
        final createdProject = Project.fromJson(projectData);
        print('✅ Project Created ID: ${createdProject.id}');
        
        await fetchPublicProjects(); 
        return createdProject.id;
      }
      return null;
    } catch (e) {
      print('❌ Create Project Error: $e');
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadProjectImage(String projectId, XFile imageFile) async {
    _isLoading = true;
    notifyListeners();
    print('🚀 Uploading image for project: $projectId (via http)');

    try {
      final token = await _apiService.storage.read(key: 'access_token');
      final uri = Uri.parse('${ApiService.baseUrl}/projets/$projectId/image');
      
      final request = http.MultipartRequest('POST', uri);
      
      // Headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      // Note: MultipartRequest sets Content-Type automatically with boundary

      // File
      final bytes = await imageFile.readAsBytes();
      final mimeStr = lookupMimeType(imageFile.name) ?? 'image/jpeg';
      final mimeType = MediaType.parse(mimeStr);

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: imageFile.name,
        contentType: mimeType,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('✅ Upload Image Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Parse the response to get the updated project data with image
        try {
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse is Map && jsonResponse['success'] == true && jsonResponse['data'] != null) {
            final updatedProjectData = jsonResponse['data'];
            final String? newImageUrl = updatedProjectData['imageUrl']; // The logs showed this key exists
            
            if (newImageUrl != null) {
              print('✅ Found new image URL in response: $newImageUrl');
              
              // Update _projects list
              final indexFn = _projects.indexWhere((p) => p.id == projectId);
              if (indexFn != -1) {
                _projects[indexFn] = _projects[indexFn].copyWith(imageUrl: newImageUrl);
              }

              // Update _ownerProjects list
              final indexOwner = _ownerProjects.indexWhere((p) => p.id == projectId);
              if (indexOwner != -1) {
                _ownerProjects[indexOwner] = _ownerProjects[indexOwner].copyWith(imageUrl: newImageUrl);
              } else {
                // If not in list, add it!
                print('➕ Adding new project to local owner list');
                 _ownerProjects.insert(0, Project.fromJson(updatedProjectData));
              }
              
              notifyListeners();
            }

            // Extract ownerId to refresh correctly
            final String? ownerId = updatedProjectData['ownerId'] ?? updatedProjectData['porteurId'];
            if (ownerId != null) {
               // Refresh owner list from server to be sure
               await fetchOwnerProjects(ownerId);
            }
          }
        } catch (e) {
          print('⚠️ Error parsing upload response for local update: $e');
        }

        // We still fetch public to keep in sync
        await fetchPublicProjects();
        return true;
        return true;
      } else {
        print('❌ Upload failed code: ${response.statusCode}');
        print('❌ Server Response: ${response.body}');
        _error = 'Erreur upload image: ${response.statusCode} - ${response.body}';
        return false;
      }
    } catch (e) {
       print('❌ Upload Image Error: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProjectStatus(String projectId, String newStatus) async {
    _isLoading = true;
    notifyListeners();
    print('🔄 Update Status: $projectId -> $newStatus');
    
    try {
      // Endpoint corrigé : /projets/{id}/statut?statut={status}
      final response = await _apiService.client.put(
        '/projets/$projectId/statut',
        queryParameters: {'statut': newStatus},
      );

      print('🔄 Update Status Response: ${response.statusCode}');
      print('📄 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update local state if successful
        final index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          // Re-fetch everything to be safe
          await fetchProjects();
          // Force refresh
          notifyListeners(); 
        }
        // Also update owner projects if present
        if (_ownerProjects.isNotEmpty) {
           await fetchUserProjectsAsAdmin(_ownerProjects.first.ownerId);
        }
        
        return true;
      }
      _error = 'Status Update Failed: ${response.statusCode} - ${response.data}';
      return false;
    } catch (e) {
      if (e is DioException) {
         print('❌ Update Status DioError: ${e.response?.statusCode} - ${e.response?.data}');
         _error = 'DioError: ${e.response?.statusCode}';
      } else {
         print('❌ Update Status Error: $e');
         _error = e.toString();
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
