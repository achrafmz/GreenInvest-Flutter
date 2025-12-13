import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/investment_model.dart';
import '../services/auth_service.dart';


class InvestmentService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Investment> _myInvestments = [];
  List<Investment> get myInvestments => _myInvestments;

  Future<void> fetchMyInvestments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/investissements/me');

      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        List<dynamic> listData = [];

        if (rawData is Map && rawData.containsKey('data') && rawData['data'] is List) {
          listData = rawData['data'];
        } else if (rawData is List) {
          listData = rawData;
        }

        _myInvestments = listData.map((e) => Investment.fromJson(e)).toList();
      } else {
        _error = 'Erreur récupération investissements: ${response.statusCode}';
      }
    } catch (e) {
      if (e is DioException) {
         _error = e.response?.data?.toString() ?? e.message;
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> invest({
    required String projectId,
    required String investorId,
    required double amount,
  }) async {
    _isLoading = true;
    notifyListeners();
    _error = null;

    try {
      final response = await _apiService.client.post(
        '/investissements',
        queryParameters: {
          'investisseurId': investorId,
          'projetId': projectId,
          'montant': amount,
        },
        // data: { 'montant': amount }, // Removed: trying query param
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _error = 'Erreur lors de l\'investissement: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      if (e is DioException) {
         _error = e.response?.data?.toString() ?? e.message;
      } else {
        _error = e.toString();
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
