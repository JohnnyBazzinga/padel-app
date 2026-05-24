import 'package:flutter/material.dart';

import '../models/match_model.dart';
import '../../core/api/api_client.dart';

class MatchesProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Match> _matches = [];
  List<Match> _myMatches = [];
  Match? _selectedMatch;
  bool _isLoading = false;
  String? _error;

  List<Match> get matches => _matches;
  List<Match> get myMatches => _myMatches;
  Match? get selectedMatch => _selectedMatch;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMatches({String? city, String? date, String? level}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{};
      if (city != null) params['city'] = city;
      if (date != null) params['date'] = date;
      if (level != null) params['minLevel'] = level;

      final response = await _api.get('/matches', queryParameters: params);
      final responseData = response.data['data'];
      _matches = (responseData['data'] as List)
          .map((m) => Match.fromJson(m))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar jogos';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyMatches({bool upcoming = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/matches/my', queryParameters: {
        'upcoming': upcoming,
      });
      _myMatches = (response.data['data'] as List)
          .map((m) => Match.fromJson(m))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar os teus jogos';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMatchById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/matches/$id');
      _selectedMatch = Match.fromJson(response.data['data']);
    } catch (e) {
      _error = 'Erro ao carregar jogo';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Match?> createMatch({
    required String date,
    required String startTime,
    required String endTime,
    String? title,
    String? description,
    String? courtId,
    String? minLevel,
    String? maxLevel,
    int? playersNeeded,
    bool isPrivate = false,
    String? location,
    String? city,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/matches', data: {
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'title': title,
        'description': description,
        'courtId': courtId,
        'minLevel': minLevel,
        'maxLevel': maxLevel,
        'playersNeeded': playersNeeded ?? 4,
        'isPrivate': isPrivate,
        'location': location,
        'city': city,
      });
      final match = Match.fromJson(response.data['data']);
      _myMatches.insert(0, match);
      _isLoading = false;
      notifyListeners();
      return match;
    } catch (e) {
      _error = 'Erro ao criar jogo';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> joinMatch(String id, {int? team, String? position}) async {
    try {
      await _api.post('/matches/$id/join', data: {
        'team': team,
        'position': position,
      });
      await fetchMatchById(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> leaveMatch(String id) async {
    try {
      await _api.post('/matches/$id/leave');
      await fetchMatchById(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelMatch(String id) async {
    try {
      await _api.delete('/matches/$id');
      _myMatches.removeWhere((m) => m.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
