import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';

class Ranking {
  final String id;
  final String userId;
  final int points;
  final int? position;
  final String? tier;
  final int matchesPlayed;
  final int matchesWon;
  final double winRate;
  final String? reputationLabel;
  final double reputationScore;
  final int reputationSignals;
  final Map<String, dynamic>? user;

  Ranking({
    required this.id,
    required this.userId,
    required this.points,
    this.position,
    this.tier,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.winRate,
    this.reputationLabel,
    this.reputationScore = 0,
    this.reputationSignals = 0,
    this.user,
  });

  String get userName {
    if (user == null) return '';
    return '${user!['firstName'] ?? ''} ${user!['lastName'] ?? ''}'.trim();
  }

  String get userBadge {
    if (reputationLabel != null && reputationLabel!.isNotEmpty) return reputationLabel!;
    if (reputationScore >= 90) return 'Top';
    if (reputationScore >= 75) return 'Confiavel';
    if (reputationScore >= 55) return 'Regular';
    return 'Nova Conta';
  }

  String? get userAvatar => user?['avatarUrl'];
  String get userCity => user?['city'] ?? '';
  String get userSkillLevel => user?['skillLevel'] ?? 'BEGINNER';

  factory Ranking.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] : null;

    return Ranking(
      id: json['id'],
      userId: json['userId'] ?? json['id'],
      points: json['points'] ?? 0,
      position: json['position'],
      tier: json['tier'],
      matchesPlayed: json['matchesPlayed'] ?? 0,
      matchesWon: json['matchesWon'] ?? 0,
      winRate: (json['winRate'] ?? 0).toDouble(),
      reputationLabel: _extractReputationLabel(json: json, user: user),
      reputationScore:
          _extractReputationScore(json: json, user: user) ?? 0,
      reputationSignals: _extractReputationSignals(json: json, user: user) ?? 0,
      user: json['user'],
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static String? _extractReputationLabel({
    required Map<String, dynamic> json,
    required Map<String, dynamic>? user,
  }) {
    final candidates = <dynamic>[
      json['reputationLabel'],
      json['reputationTier'],
      json['reputationCategory'],
      user?['reputationLabel'],
      user?['reputationTier'],
      user?['reputationCategory'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString();
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  static double? _extractReputationScore({
    required Map<String, dynamic> json,
    required Map<String, dynamic>? user,
  }) {
    final candidates = <dynamic>[
      json['reputationScore'],
      json['reputation'],
      user?['reputationScore'],
      user?['reputation'],
      json['reputationData'],
      user?['reputationData'],
    ];

    for (final candidate in candidates) {
      final score = _parseReputationNumeric(candidate);
      if (score != null) return score;
    }
    return null;
  }

  static int? _extractReputationSignals({
    required Map<String, dynamic> json,
    required Map<String, dynamic>? user,
  }) {
    final candidates = <dynamic>[
      json['reputationSignals'],
      user?['reputationSignals'],
      json['reputation'],
      user?['reputation'],
      json['reputationData'],
      user?['reputationData'],
    ];

    for (final candidate in candidates) {
      final signals = _parseReputationSignals(candidate);
      if (signals != null) return signals;
    }
    return null;
  }

  static double? _parseReputationNumeric(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is Map<String, dynamic>) {
      return _toDouble(value['score']) ??
          _toDouble(value['value']) ??
          _toDouble(value['rating']) ??
          _toDouble(value['scoreValue']);
    }
    return null;
  }

  static int? _parseReputationSignals(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is Map<String, dynamic>) {
      return _toInt(value['signals']) ??
          _toInt(value['votes']) ??
          _toInt(value['count']) ??
          _toInt(value['total']);
    }
    return null;
  }
}

class RankingsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Ranking> _rankings = [];
  Ranking? _myRanking;
  bool _isLoading = false;
  String? _error;

  List<Ranking> get rankings => _rankings;
  Ranking? get myRanking => _myRanking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRankings({String? category, String? period}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{
        'limit': 50,
      };
      if (category != null) params['category'] = category;
      if (period != null) params['period'] = period;

      final response = await _api.get('/rankings', queryParameters: params);
      final responseData = response.data['data'];
      _rankings = _extractList(responseData).map((r) => Ranking.fromJson(r)).toList();
    } catch (e) {
      _error = 'Erro ao carregar ranking';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchEloRankings({String? city}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/rankings/elo', queryParameters: {
        if (city != null) 'city': city,
        'limit': 50,
      });
      final responseData = response.data['data'];
      _rankings = _extractList(responseData).map((r) => Ranking.fromJson(r)).toList();
    } catch (e) {
      _error = 'Erro ao carregar ranking elo';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyRanking() async {
    try {
      final response = await _api.get('/rankings/me');
      if (response.data['data'] != null) {
        _myRanking = Ranking.fromJson(response.data['data']);
        notifyListeners();
      }
    } catch (e) {
      // Ignore
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    if (data is Map<String, dynamic> && data['data'] is List) {
      return data['data'].whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }
}
