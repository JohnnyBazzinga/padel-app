import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class Ranking {
  final String id;
  final String oderId;
  final int points;
  final int? position;
  final String? tier;
  final int matchesPlayed;
  final int matchesWon;
  final double winRate;
  final Map<String, dynamic>? user;

  Ranking({
    required this.id,
    required this.oderId,
    required this.points,
    this.position,
    this.tier,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.winRate,
    this.user,
  });

  String get userName {
    if (user == null) return '';
    return '${user!['firstName'] ?? ''} ${user!['lastName'] ?? ''}'.trim();
  }

  String? get userAvatar => user?['avatarUrl'];
  String get userCity => user?['city'] ?? '';
  String get userSkillLevel => user?['skillLevel'] ?? 'BEGINNER';

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      id: json['id'],
      oderId: json['userId'],
      points: json['points'] ?? 0,
      position: json['position'],
      tier: json['tier'],
      matchesPlayed: json['matchesPlayed'] ?? 0,
      matchesWon: json['matchesWon'] ?? 0,
      winRate: (json['winRate'] ?? 0).toDouble(),
      user: json['user'],
    );
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
      _rankings = (response.data['data'] as List)
          .map((r) => Ranking.fromJson(r))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar ranking';
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
}
