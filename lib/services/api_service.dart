// import 'dart:io'; // Removed for web compatibility
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // ✅ URL de base STATIQUE selon la plateforme
  static String get baseUrl {
    if (kIsWeb) {
      // ✅ Flutter Web : Tester d'abord avec 127.0.0.1, puis localhost
      // Note: Parfois les navigateurs préfèrent 127.0.0.1
      return 'http://127.0.0.1:8081';
      // Alternative : 'http://localhost:8081' si 127.0.0.1 ne marche pas
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // ✅ Android Emulator : 10.0.2.2 = localhost de la machine hôte
      return 'http://10.0.2.2:8081';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // ✅ iOS Simulator : localhost fonctionne directement
      return 'http://localhost:8081';
    } else {
      // ✅ Par défaut (macOS, Windows, Linux)
      return 'http://localhost:8081';
    }
  }

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // ✅ Suivre les redirections
      followRedirects: true,
      maxRedirects: 5,
      // ✅ Valider le status code
      validateStatus: (status) => status != null && status < 500,
    ));

    // ✅ Intercepteur pour ajouter le token automatiquement
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      
      onResponse: (response, handler) {
        return handler.next(response);
      },
      
      onError: (DioException error, handler) async {
        return handler.next(error);
      },
    ));
  }

  Dio get client => _dio;
  
  // ✅ Méthode utilitaire pour tester la connexion
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get(
        '/actuator/health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
  
  // ✅ Créer une instance Dio sans authentification (pour signup, login)
  static Dio createPublicClient() {
    return Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => status != null && status < 500,
    ));
  }
}