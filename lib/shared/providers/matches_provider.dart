import 'package:flutter/material.dart';

import '../models/match_model.dart';
import '../models/match_suggestion.dart';
import '../../core/api/api_client.dart';

class MatchesProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Match> _matches = [];
  List<Match> _myMatches = [];
  List<MatchSuggestion> _suggestions = [];
  Match? _selectedMatch;
  final Set<String> _feedbackSubmittedMatchIds = {};

  bool _isLoading = false;
  bool _isSuggesting = false;
  String? _error;
  String? _suggestionError;

  List<Match> get matches => _matches;
  List<Match> get myMatches => _myMatches;
  List<MatchSuggestion> get suggestions => _suggestions;
  Match? get selectedMatch => _selectedMatch;
  bool get isLoading => _isLoading;
  bool get isSuggesting => _isSuggesting;
  String? get error => _error;
  String? get suggestionError => _suggestionError;
  bool hasMatchFeedbackSubmitted(String matchId) => _feedbackSubmittedMatchIds.contains(matchId);

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
      final responseData = _unwrapPayload(response.data);
      final matchList = _extractMatchList(responseData);
      _matches = matchList.map((m) => Match.fromJson(m)).toList();
      for (final item in matchList) {
        _syncFeedbackStateFromMatchData(item);
      }
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
      final responseData = _unwrapPayload(response.data);
      final myMatchList = _extractMatchList(responseData);
      _myMatches = myMatchList.map((m) => Match.fromJson(m)).toList();
      for (final item in myMatchList) {
        _syncFeedbackStateFromMatchData(item);
      }
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
      final responseData = _unwrapPayload(response.data);
      _selectedMatch = _toMatch(responseData);
      _syncFeedbackStateFromMatchData(responseData);
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
      final match = _toMatch(_unwrapPayload(response.data));
      if (match == null) return null;
      _syncFeedbackStateFromMatchData(_normalizeToMap(match));
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

  Future<void> fetchMatchSuggestions({
    String? city,
    String? level,
    String? language,
    bool? indoor,
    int? minPlayersNeeded,
    int? maxPlayersNeeded,
    int? radiusKm,
    String? windowStart,
    String? windowEnd,
    String? limit,
  }) async {
    _isSuggesting = true;
    _suggestionError = null;
    notifyListeners();

    try {
      final response = await _api.post('/match-making/suggest', data: {
        if (city != null) 'city': city,
        if (level != null) 'level': level,
        if (language != null) 'language': language,
        if (indoor != null) 'indoor': indoor,
        if (minPlayersNeeded != null) 'minPlayersNeeded': minPlayersNeeded,
        if (maxPlayersNeeded != null) 'maxPlayersNeeded': maxPlayersNeeded,
        if (radiusKm != null) 'radiusKm': radiusKm,
        if (windowStart != null) 'windowStart': windowStart,
        if (windowEnd != null) 'windowEnd': windowEnd,
      });

      final responseData = _unwrapPayload(response.data);
      _suggestions = _extractSuggestionList(responseData)
          .map((json) => MatchSuggestion.fromJson(json))
          .toList();
      if (limit != null && _suggestions.length > int.parse(limit)) {
        _suggestions = _suggestions.take(int.parse(limit)).toList();
      }
    } catch (e) {
      _suggestionError = 'Erro ao carregar sugestões';
      _suggestions = [];
    }

    _isSuggesting = false;
    notifyListeners();
  }

  Future<Match?> createAutoFill({
    required String suggestionId,
    bool premium = false,
  }) async {
    try {
      final response = await _api.post('/match-making/create-fill', data: {
        'suggestionId': suggestionId,
        'premium': premium,
      });

      final responseData = _unwrapPayload(response.data);
      final matchData = responseData is Map<String, dynamic>
          ? (responseData['match'] ?? responseData)
          : null;
      if (matchData is Map<String, dynamic>) {
        final match = Match.fromJson(matchData);
        if (!_myMatches.any((m) => m.id == match.id)) {
          _myMatches.insert(0, match);
        }
        return match;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createFillFallback({
    required MatchSuggestion suggestion,
    bool premium = false,
  }) async {
    if (suggestion.matchId != null) {
      final directJoin = await joinMatch(suggestion.matchId!);
      return directJoin;
    }

    if (suggestion.match != null && suggestion.match!.id.isNotEmpty) {
      return joinMatch(suggestion.match!.id);
    }

    final created = await createAutoFill(
      suggestionId: suggestion.id,
      premium: premium,
    );
    return created != null;
  }

  Future<bool> recordScore({
    required String matchId,
    required String score,
    String? winnerId,
    int? winnerTeam,
    String? winnerSide,
    String? notes,
  }) async {
    try {
      final response = await _api.post('/matches/$matchId/score', data: {
        'score': score,
        'winnerId': winnerId,
        'winnerTeam': winnerTeam,
        'winnerSide': winnerSide,
        'notes': notes,
      });
      final responseData = _unwrapPayload(response.data);
      if (responseData is Map<String, dynamic>) {
        final updated = _toMatch(responseData);
        if (updated == null) return false;
        _syncFeedbackStateFromMatchData(responseData);
        _updateMatchInLists(updated);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitMatchFeedback({
    required String matchId,
    int punctuality = 3,
    int fairPlay = 3,
    int social = 3,
    String? notes,
  }) async {
    try {
      await _api.post('/matches/$matchId/feedback', data: {
        'punctuality': punctuality,
        'fairPlay': fairPlay,
        'social': social,
        'notes': notes,
      });
      _feedbackSubmittedMatchIds.add(matchId);
      notifyListeners();
      return true;
    } catch (e) {
      // Legacy fallback for API versions with different route
      try {
        await _api.post('/matches/$matchId/feedbacks', data: {
          'punctuality': punctuality,
          'fairPlay': fairPlay,
          'social': social,
          'notes': notes,
        });
        _feedbackSubmittedMatchIds.add(matchId);
        notifyListeners();
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  void _updateMatchInLists(Match updatedMatch) {
    _updateList(_matches, updatedMatch);
    _updateList(_myMatches, updatedMatch);
    if (_selectedMatch?.id == updatedMatch.id) {
      _selectedMatch = updatedMatch;
    }
    notifyListeners();
  }

  void _updateList(List<Match> list, Match updated) {
    final index = list.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    list[index] = updated;
  }

  List<Map<String, dynamic>> _extractMatchList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) return nested.whereType<Map<String, dynamic>>().toList();
    }

    return [];
  }

  List<Map<String, dynamic>> _extractSuggestionList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) return nested.whereType<Map<String, dynamic>>().toList();
      if (nested is Map<String, dynamic> && nested['items'] is List) {
        return nested['items'].whereType<Map<String, dynamic>>().toList();
      }
      if (nested is Map<String, dynamic> && nested['matches'] is List) {
        return nested['matches'].whereType<Map<String, dynamic>>().toList();
      }
    }

    return [];
  }

  Match? _toMatch(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return Match.fromJson(value);
    return null;
  }

  dynamic _unwrapPayload(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested != null) return nested;
    }
    return data;
  }

  void _syncFeedbackStateFromMatchData(dynamic rawData) {
    if (rawData is! Map<String, dynamic>) return;
    final matchId = _normalizeMatchId(rawData['id']);
    if (matchId == null) return;

    final submitted = _extractFeedbackSubmittedFlag(rawData);
    if (submitted == null) return;

    if (submitted) {
      _feedbackSubmittedMatchIds.add(matchId);
    } else {
      _feedbackSubmittedMatchIds.remove(matchId);
    }
  }

  bool? _extractFeedbackSubmittedFlag(Map<String, dynamic> data) {
    for (final key in const [
      'myFeedbackSubmitted',
      'feedbackSubmitted',
      'feedbackGiven',
      'hasFeedback',
      'hasMyFeedback',
      'myFeedbackGiven',
      'feedbackByMe',
    ]) {
      final value = data[key];
      final parsed = _toBool(value);
      if (parsed != null) return parsed;
    }
    return null;
  }

  bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value > 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') return true;
      if (normalized == 'false' || normalized == '0' || normalized == 'no') return false;
    }
    return null;
  }

  String? _normalizeMatchId(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) return value.toString();
    return null;
  }

  Map<String, dynamic>? _normalizeToMap(dynamic value) {
    if (value is Match) {
      return {
        'id': value.id,
        'score': value.score,
      };
    }
    if (value is Map<String, dynamic>) return value;
    return null;
  }
}
