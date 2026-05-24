import 'package:flutter/material.dart';

import '../models/club_model.dart';
import '../../core/api/api_client.dart';

class ClubsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Club> _clubs = [];
  Club? _selectedClub;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;

  List<Club> get clubs => _clubs;
  Club? get selectedClub => _selectedClub;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _currentPage < _totalPages;

  Future<void> fetchClubs({String? city, bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _clubs = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{
        'page': _currentPage,
        'limit': 20,
      };
      if (city != null) params['city'] = city;

      final response = await _api.get('/clubs', queryParameters: params);
      final responseData = response.data['data'];
      final data = responseData['data'] as List;
      final meta = responseData['meta'];

      final newClubs = data.map((c) => Club.fromJson(c)).toList();

      if (refresh) {
        _clubs = newClubs;
      } else {
        _clubs.addAll(newClubs);
      }

      _totalPages = meta['totalPages'];
      _currentPage++;
    } catch (e) {
      _error = 'Erro ao carregar clubes';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchClubById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/clubs/$id');
      _selectedClub = Club.fromJson(response.data['data']);
    } catch (e) {
      _error = 'Erro ao carregar clube';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Club>> fetchNearbyClubs(double lat, double lng, {double radius = 10}) async {
    try {
      final response = await _api.get('/clubs/nearby', queryParameters: {
        'latitude': lat,
        'longitude': lng,
        'radius': radius,
      });
      return (response.data['data'] as List).map((c) => Club.fromJson(c)).toList();
    } catch (e) {
      return [];
    }
  }

  void clearSelectedClub() {
    _selectedClub = null;
    notifyListeners();
  }
}
