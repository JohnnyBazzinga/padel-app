import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import 'auth_provider.dart';

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

  // Mock data for demo mode
  static final List<Ranking> _mockRankings = [
    Ranking(id: 'r1', oderId: 'u1', points: 2850, position: 1, tier: 'DIAMOND', matchesPlayed: 156, matchesWon: 112, winRate: 71.8,
      user: {'firstName': 'Ricardo', 'lastName': 'Mendes', 'city': 'Lisboa', 'skillLevel': 'PROFESSIONAL'}),
    Ranking(id: 'r2', oderId: 'u2', points: 2640, position: 2, tier: 'DIAMOND', matchesPlayed: 142, matchesWon: 98, winRate: 69.0,
      user: {'firstName': 'André', 'lastName': 'Sousa', 'city': 'Porto', 'skillLevel': 'PROFESSIONAL'}),
    Ranking(id: 'r3', oderId: 'u3', points: 2380, position: 3, tier: 'PLATINUM', matchesPlayed: 128, matchesWon: 85, winRate: 66.4,
      user: {'firstName': 'Miguel', 'lastName': 'Costa', 'city': 'Lisboa', 'skillLevel': 'ADVANCED'}),
    Ranking(id: 'r4', oderId: 'u4', points: 2120, position: 4, tier: 'PLATINUM', matchesPlayed: 98, matchesWon: 62, winRate: 63.3,
      user: {'firstName': 'Tiago', 'lastName': 'Ferreira', 'city': 'Cascais', 'skillLevel': 'ADVANCED'}),
    Ranking(id: 'r5', oderId: 'u5', points: 1890, position: 5, tier: 'GOLD', matchesPlayed: 87, matchesWon: 54, winRate: 62.1,
      user: {'firstName': 'Pedro', 'lastName': 'Santos', 'city': 'Porto', 'skillLevel': 'ADVANCED'}),
    Ranking(id: 'r6', oderId: 'u6', points: 1650, position: 6, tier: 'GOLD', matchesPlayed: 76, matchesWon: 45, winRate: 59.2,
      user: {'firstName': 'João', 'lastName': 'Almeida', 'city': 'Oeiras', 'skillLevel': 'INTERMEDIATE'}),
    Ranking(id: 'r7', oderId: 'demo-user-001', points: 1250, position: 7, tier: 'SILVER', matchesPlayed: 42, matchesWon: 28, winRate: 66.7,
      user: {'firstName': 'João', 'lastName': 'Demo', 'city': 'Lisboa', 'skillLevel': 'INTERMEDIATE'}),
    Ranking(id: 'r8', oderId: 'u8', points: 1180, position: 8, tier: 'SILVER', matchesPlayed: 65, matchesWon: 38, winRate: 58.5,
      user: {'firstName': 'Rui', 'lastName': 'Oliveira', 'city': 'Sintra', 'skillLevel': 'INTERMEDIATE'}),
    Ranking(id: 'r9', oderId: 'u9', points: 920, position: 9, tier: 'BRONZE', matchesPlayed: 48, matchesWon: 26, winRate: 54.2,
      user: {'firstName': 'Carlos', 'lastName': 'Martins', 'city': 'Lisboa', 'skillLevel': 'INTERMEDIATE'}),
    Ranking(id: 'r10', oderId: 'u10', points: 750, position: 10, tier: 'BRONZE', matchesPlayed: 34, matchesWon: 18, winRate: 52.9,
      user: {'firstName': 'Bruno', 'lastName': 'Silva', 'city': 'Porto', 'skillLevel': 'BEGINNER'}),
  ];

  Future<void> fetchRankings({String? category, String? period}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Demo mode: use mock data
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      _rankings = _mockRankings;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final params = <String, dynamic>{
        'limit': 50,
      };
      if (category != null) params['category'] = category;
      if (period != null) params['period'] = period;

      final response = await _api.get('/rankings', queryParameters: params);
      final responseData = response.data['data'];
      _rankings = (responseData['data'] as List)
          .map((r) => Ranking.fromJson(r))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar ranking';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyRanking() async {
    // Demo mode: use mock data
    if (kDemoMode) {
      _myRanking = _mockRankings.firstWhere((r) => r.oderId == 'demo-user-001');
      notifyListeners();
      return;
    }

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
