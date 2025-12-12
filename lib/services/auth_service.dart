import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Configuration Keycloak
  static String get keycloakUrl {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }
  static const String realm = 'microfinance_realm';
  static const String clientId = 'springboot-client';
  static const String clientSecret = '8ztTsvTOCjWreyXa57eYe5FIGCkUvCCV';

  /// Login via Keycloak
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = {
        'grant_type': 'password',
        'client_id': clientId,
        'client_secret': clientSecret,
        'username': username,
        'password': password,
      };

      // Transformer le map en query string (comme Postman)
      final formBody = data.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await Dio().post(
        '$keycloakUrl/realms/$realm/protocol/openid-connect/token',
        data: formBody,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];

        await _storage.write(key: 'access_token', value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);
        await _fetchCurrentUser();
        notifyListeners();
        return true;
      }

      return false;
    } catch (_) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> retryUserFetch() async {
      await _fetchCurrentUser();
  }

  /// Récupérer les infos de l'utilisateur connecté
  String _debugStatus = 'Init';
  String get debugStatus => _debugStatus;

  Future<void> _fetchCurrentUser() async {
    _debugStatus = 'Starting fetch...';
    try {
      final token = await _storage.read(key: 'access_token');
      
      if (token == null) {
        _debugStatus = 'No token';
        notifyListeners();
        return;
      }

      final parts = token.split('.');
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);

      final userId = json['sub'] ?? '';
      final username = json['preferred_username'] ?? json['sub'] ?? '';
      
      _debugStatus = 'Fetching API...';
      try {
        // TENTATIVE 1: /users/me (Nouvelle méthode standard)
        try {
          final responseMe = await _apiService.client.get('/users/me');
          if (responseMe.statusCode == 200) {
            _currentUser = User.fromJson(responseMe.data);
            _debugStatus = 'Found API (Me)';
            notifyListeners();
            return;
          }
        } catch (e) {
          print('⚠️ GET /users/me failed: $e. Falling back to list search.');
        }

        // TENTATIVE 2: Liste complète (Fallback)
        final response = await _apiService.client.get('/users');

        if (response.statusCode == 200) {
          final rawData = response.data;
          List<dynamic> listCallback = [];

          if (rawData is Map && rawData.containsKey('data') && rawData['data'] is List) {
             listCallback = rawData['data'];
          } else if (rawData is List) {
             listCallback = rawData;
          } else if (rawData is Map && rawData.containsKey('content') && rawData['content'] is List) {
             listCallback = rawData['content'];
          } else {
             _debugStatus = 'Bad data format';
             return;
          }

          final userJson = listCallback.firstWhere(
            (u) => 
              (u['username']?.toString().toLowerCase() ?? '') == username.toLowerCase() ||
              (u['email']?.toString().toLowerCase() ?? '') == username.toLowerCase(),
            orElse: () => null,
          );
          
          if (userJson != null) {
            _currentUser = User.fromJson(userJson);
            _debugStatus = 'Found API: ${_currentUser?.role}';
          } else {
             _debugStatus = 'Not in list';
          }
        }
      } catch (e) {
        // Si la liste échoue (ex: 403), on essaie de récupérer juste NOTRE utilisateur par ID
        print('⚠️ GET /users failed. Trying GET /users/$userId');
        
        if (userId.isNotEmpty) {
           try {
             final responseMe = await _apiService.client.get('/users/$userId');
             if (responseMe.statusCode == 200) {
               _currentUser = User.fromJson(responseMe.data);
               _debugStatus = 'Found API (Direct)';
               notifyListeners();
             }
           } catch (e2) {
             print('⚠️ GET /users/$userId failed too: $e2');
             _debugStatus = 'API Fail: $e';
           }
        }
      }
      
      // ULTIME FALLBACK: Si l'API a échoué complètement, on utilise les infos du token
      if (_currentUser == null) {
         print('⚠️ Using Token Fallback as API failed completely');
         _currentUser = _getUserFromToken(token);
         if (_currentUser != null) {
            _debugStatus = 'Token Fallback (${_currentUser!.role})';
         }
      }

    } catch (e) {
      _debugStatus = 'Gen Except: $e';
    }
    notifyListeners();
  }

  /// Tenter de construire l'utilisateur à partir du Token (Fallback si l'API échoue)
  User? _getUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      
      final userId = json['sub'] ?? 'token_user'; // Utiliser le vrai ID Keycloak (sub)
      final username = json['preferred_username'] ?? json['sub'] ?? '';
      final email = json['email'] ?? '';
      
      // Extraction des rôles Keycloak
      String role = '';
      if (json['realm_access'] != null && json['realm_access']['roles'] != null) {
        final roles = List<String>.from(json['realm_access']['roles']);
        
        // Priorité aux rôles métier
        if (roles.contains('INVESTISSEUR')) {
          role = 'INVESTISSEUR';
        } else if (roles.contains('PORTEUR_PROJET')) {
          role = 'PORTEUR_PROJET';
        } else if (roles.contains('ADMIN')) {
          role = 'ADMIN';
        } else {
          // Chercher n'importe quel rôle pertinent
          role = roles.firstWhere(
            (r) => !['offline_access', 'uma_authorization', 'default-roles-microfinance_realm'].contains(r),
            orElse: () => '',
          );
        }
      }
      
      if (username.isNotEmpty) {
        print('🔑 _getUserFromToken: Extracted $username ($userId), Role: $role');
        return User(
          id: userId,
          username: username,
          email: email,
          role: role,
        );
      }
      return null;
    } catch (e) {
      print('⚠️ _getUserFromToken Error: $e');
      return null;
    }
  }

  /// Décoder le username depuis le JWT
  String _decodeJwtUsername(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      return json['preferred_username'] ?? json['sub'] ?? '';
    } catch (_) {
      return '';
    }
  }



  /// Mettre à jour le profil utilisateur
  Future<bool> updateProfile({
    required String id,
    required String username,
    required String email,
    double? solde,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'username': username,
        'email': email,
      };

      if (solde != null) {
        data['solde'] = solde;
      }

      final response = await _apiService.client.put(
        '/users/me',
        data: data,
      );

      print('📝 Update Profile Response: ${response.statusCode}');
      print('📝 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Rafraîchir l'utilisateur localement
        // Idéalement, l'API renvoie l'objet mis à jour
        _currentUser = User(
          id: id, // On garde l'ID qu'on avait
          username: username,
          email: email,
          role: _currentUser?.role ?? '',
          solde: solde ?? _currentUser?.solde,
          keycloakUserId: _currentUser?.keycloakUserId,
          dateInscription: _currentUser?.dateInscription,
        );
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException && e.response != null) {
         print('❌ Correction error (API): ${e.response?.statusCode} - ${e.response?.data}');
      } else {
         print('❌ Correction error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inscription (signup) - VERSION FINALE CORRIGÉE
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String role, // "INVESTISSEUR" ou "PORTEUR_PROJET"
    double? soldeInitial,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ✅ Construire les données de la requête
      final Map<String, dynamic> data = {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      };

      // ✅ Ajouter soldeInitial UNIQUEMENT pour les investisseurs
      if (role == 'INVESTISSEUR' && soldeInitial != null) {
        data['soldeInitial'] = soldeInitial;
      }

      // ✅ Utiliser le client public (sans authentification)
      final dio = ApiService.createPublicClient();
      
      final response = await dio.post('/auth/signup', data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = response.data['message'] ?? 
                        response.data['data'] ?? 
                        'Inscription réussie';
        
        return {
          'success': true,
          'message': message,
        };
      }
      
      return {
        'success': false,
        'message': 'Erreur inconnue (code ${response.statusCode})',
      };
      
    } on DioException catch (e) {
      String errorMessage = 'Erreur lors de l\'inscription';
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = '⏱️ Délai de connexion dépassé.\nLe serveur met trop de temps à répondre.';
          break;
          
        case DioExceptionType.receiveTimeout:
          errorMessage = '⏱️ Délai de réception dépassé.\nLe serveur ne répond pas assez vite.';
          break;
          
        case DioExceptionType.sendTimeout:
          errorMessage = '⏱️ Délai d\'envoi dépassé.';
          break;
          
        case DioExceptionType.connectionError:
          errorMessage = '🔌 Impossible de contacter le serveur.\n\n'
              '🔍 Vérifications:\n'
              '1. Le backend tourne-t-il sur ${ApiService.baseUrl} ?\n'
              '2. Testez dans le navigateur: ${ApiService.baseUrl}/actuator/health\n'
              '3. Vérifiez les logs du backend Spring Boot';
          break;
          
        case DioExceptionType.badResponse:
          if (e.response != null) {
            if (e.response!.data is Map) {
              errorMessage = e.response!.data['message'] ?? 
                            e.response!.data['error'] ?? 
                            'Erreur ${e.response!.statusCode}';
            } else if (e.response!.data is String) {
              errorMessage = e.response!.data;
            } else {
              errorMessage = 'Erreur ${e.response!.statusCode}: ${e.response!.statusMessage}';
            }
          }
          break;
          
        case DioExceptionType.cancel:
          errorMessage = '❌ Requête annulée';
          break;
          
        default:
          errorMessage = '❌ ${e.message ?? "Erreur réseau inconnue"}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
      
    } catch (e, stackTrace) {
      return {
        'success': false,
        'message': 'Erreur inattendue: ${e.toString()}',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Rafraîchir le token d'accès
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '$keycloakUrl/realms/$realm/protocol/openid-connect/token',
        data: {
          'grant_type': 'refresh_token',
          'client_id': clientId,
          'client_secret': clientSecret,
          'refresh_token': refreshToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        
        await _storage.write(key: 'access_token', value: newAccessToken);
        await _storage.write(key: 'refresh_token', value: newRefreshToken);
        
        return true;
      }
      
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      final token = await _storage.read(key: 'access_token');
      
      // Optionnel: Révoquer le token côté Keycloak
      if (token != null) {
        try {
          await Dio().post(
            '$keycloakUrl/realms/$realm/protocol/openid-connect/logout',
            data: {
              'client_id': clientId,
              'client_secret': clientSecret,
              'refresh_token': await _storage.read(key: 'refresh_token'),
            },
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
            ),
          );
        } catch (_) {}
      }
    } catch (_) {}

    // Supprimer les tokens locaux
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    _currentUser = null;
    notifyListeners();
  }

  /// Vérifier si l'utilisateur est connecté au démarrage
  Future<void> checkAuthStatus() async {
    try {
      final token = await _storage.read(key: 'access_token');
      
      if (token != null) {
        // Vérifier si le token est toujours valide
        if (_isTokenExpired(token)) {
          final refreshed = await refreshToken();
          
          if (!refreshed) {
            await logout();
            return;
          }
        }
        
        // Récupérer les infos utilisateur
        await _fetchCurrentUser();
      }
    } catch (_) {}
  }

  /// Vérifier si le token est expiré
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      
      final exp = json['exp'];
      if (exp == null) return true;
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      // Considérer comme expiré si moins de 5 minutes restantes
      return expiryDate.difference(now).inMinutes < 5;
    } catch (_) {
      return true;
    }
  }
  /// Récupérer tous les utilisateurs (Admin seulement)
  Future<List<User>> fetchAllUsers() async {
    try {
      final response = await _apiService.client.get('/users');

      if (response.statusCode == 200) {
        final rawData = response.data;
        List<dynamic> listData = [];

        if (rawData is Map && rawData.containsKey('data') && rawData['data'] is List) {
          listData = rawData['data'];
        } else if (rawData is List) {
          listData = rawData;
        } else if (rawData is Map && rawData.containsKey('content') && rawData['content'] is List) {
           listData = rawData['content'];
        }

        return listData.map((e) => User.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('❌ fetchAllUsers failed: $e');
      throw e;
    }
  }

  /// Créer un admin via le endpoint dédié
  Future<bool> createAdmin({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = {
        'username': username,
        'email': email,
        'password': password,
        'role': 'ADMIN',
      };

      // Utiliser le client authentifié car c'est une action admin
      final response = await _apiService.client.post('/admin/create', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('❌ createAdmin failed: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}