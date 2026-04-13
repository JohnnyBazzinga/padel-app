import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/user_model.dart';
import '../../core/api/api_client.dart';
import 'auth_provider.dart';

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

  // Mock data for demo mode
  static List<Match> get _mockMatches {
    final now = DateTime.now();
    return [
      Match(
        id: 'match-1',
        title: 'Jogo casual tarde',
        date: now.add(const Duration(days: 1)),
        startTime: '18:00',
        endTime: '19:30',
        minLevel: 'INTERMEDIATE',
        maxLevel: 'ADVANCED',
        status: 'LOOKING_FOR_PLAYERS',
        playersNeeded: 4,
        location: 'Padel Lisboa Centro',
        city: 'Lisboa',
        players: [
          MatchPlayer(id: 'mp1', matchId: 'match-1', userId: 'u1', team: 1, isOrganizer: true,
            user: User(id: 'u1', email: 'miguel@test.com', firstName: 'Miguel', lastName: 'Santos', skillLevel: 'INTERMEDIATE')),
          MatchPlayer(id: 'mp2', matchId: 'match-1', userId: 'u2', team: 1,
            user: User(id: 'u2', email: 'ana@test.com', firstName: 'Ana', lastName: 'Costa', skillLevel: 'INTERMEDIATE')),
        ],
      ),
      Match(
        id: 'match-2',
        title: 'Treino matinal',
        date: now.add(const Duration(days: 2)),
        startTime: '08:00',
        endTime: '09:30',
        minLevel: 'BEGINNER',
        maxLevel: 'INTERMEDIATE',
        status: 'LOOKING_FOR_PLAYERS',
        playersNeeded: 4,
        location: 'Porto Padel Club',
        city: 'Porto',
        players: [
          MatchPlayer(id: 'mp3', matchId: 'match-2', userId: 'u3', team: 1, isOrganizer: true,
            user: User(id: 'u3', email: 'pedro@test.com', firstName: 'Pedro', lastName: 'Silva', skillLevel: 'BEGINNER')),
        ],
      ),
      Match(
        id: 'match-3',
        title: 'Jogo competitivo',
        date: now.add(const Duration(days: 1)),
        startTime: '20:00',
        endTime: '21:30',
        minLevel: 'ADVANCED',
        maxLevel: 'PROFESSIONAL',
        status: 'LOOKING_FOR_PLAYERS',
        playersNeeded: 4,
        location: 'Oeiras Sport Club',
        city: 'Oeiras',
        players: [
          MatchPlayer(id: 'mp4', matchId: 'match-3', userId: 'u4', team: 1, isOrganizer: true,
            user: User(id: 'u4', email: 'joao@test.com', firstName: 'João', lastName: 'Ferreira', skillLevel: 'ADVANCED')),
          MatchPlayer(id: 'mp5', matchId: 'match-3', userId: 'u5', team: 1,
            user: User(id: 'u5', email: 'maria@test.com', firstName: 'Maria', lastName: 'Oliveira', skillLevel: 'ADVANCED')),
          MatchPlayer(id: 'mp6', matchId: 'match-3', userId: 'u6', team: 2,
            user: User(id: 'u6', email: 'rui@test.com', firstName: 'Rui', lastName: 'Martins', skillLevel: 'PROFESSIONAL')),
        ],
      ),
      Match(
        id: 'match-4',
        title: 'Padel ao fim de semana',
        date: now.add(const Duration(days: 3)),
        startTime: '10:00',
        endTime: '11:30',
        minLevel: 'INTERMEDIATE',
        maxLevel: 'INTERMEDIATE',
        status: 'CONFIRMED',
        playersNeeded: 4,
        location: 'Padel Cascais Beach',
        city: 'Cascais',
        players: [
          MatchPlayer(id: 'mp7', matchId: 'match-4', userId: 'u7', team: 1, isOrganizer: true,
            user: User(id: 'u7', email: 'tiago@test.com', firstName: 'Tiago', lastName: 'Pereira', skillLevel: 'INTERMEDIATE')),
          MatchPlayer(id: 'mp8', matchId: 'match-4', userId: 'u8', team: 1,
            user: User(id: 'u8', email: 'sofia@test.com', firstName: 'Sofia', lastName: 'Rodrigues', skillLevel: 'INTERMEDIATE')),
          MatchPlayer(id: 'mp9', matchId: 'match-4', userId: 'u9', team: 2,
            user: User(id: 'u9', email: 'bruno@test.com', firstName: 'Bruno', lastName: 'Almeida', skillLevel: 'INTERMEDIATE')),
          MatchPlayer(id: 'mp10', matchId: 'match-4', userId: 'u10', team: 2,
            user: User(id: 'u10', email: 'ines@test.com', firstName: 'Inês', lastName: 'Fernandes', skillLevel: 'INTERMEDIATE')),
        ],
      ),
      Match(
        id: 'match-5',
        title: 'Iniciantes bem-vindos!',
        date: now.add(const Duration(days: 4)),
        startTime: '17:00',
        endTime: '18:30',
        minLevel: 'BEGINNER',
        maxLevel: 'BEGINNER',
        status: 'LOOKING_FOR_PLAYERS',
        playersNeeded: 4,
        location: 'Sintra Padel Academy',
        city: 'Sintra',
        players: [
          MatchPlayer(id: 'mp11', matchId: 'match-5', userId: 'u11', team: 1, isOrganizer: true,
            user: User(id: 'u11', email: 'carlos@test.com', firstName: 'Carlos', lastName: 'Gomes', skillLevel: 'BEGINNER')),
          MatchPlayer(id: 'mp12', matchId: 'match-5', userId: 'u12', team: 2,
            user: User(id: 'u12', email: 'lucia@test.com', firstName: 'Lúcia', lastName: 'Sousa', skillLevel: 'BEGINNER')),
        ],
      ),
    ];
  }

  Future<void> fetchMatches({String? city, String? date, String? level}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Demo mode: use mock data
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      _matches = _mockMatches;
      _isLoading = false;
      notifyListeners();
      return;
    }

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

    // Demo mode: use mock data
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      _myMatches = [_mockMatches[0], _mockMatches[3]]; // Sample of matches
      _isLoading = false;
      notifyListeners();
      return;
    }

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

    // Demo mode: use mock data
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      _selectedMatch = _mockMatches.firstWhere(
        (m) => m.id == id,
        orElse: () => _mockMatches.first,
      );
      _isLoading = false;
      notifyListeners();
      return;
    }

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
