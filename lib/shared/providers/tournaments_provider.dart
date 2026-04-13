import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class Tournament {
  final String id;
  final String clubId;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final String format;
  final int maxTeams;
  final String minLevel;
  final String maxLevel;
  final int entryFee;
  final int? prizePool;
  final String status;
  final String? imageUrl;
  final Map<String, dynamic>? club;
  final int? playerCount;

  Tournament({
    required this.id,
    required this.clubId,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.format,
    required this.maxTeams,
    required this.minLevel,
    required this.maxLevel,
    required this.entryFee,
    this.prizePool,
    required this.status,
    this.imageUrl,
    this.club,
    this.playerCount,
  });

  String get clubName => club?['name'] ?? '';
  String get clubCity => club?['city'] ?? '';
  String get entryFeeFormatted => entryFee > 0 ? '${(entryFee / 100).toStringAsFixed(2)}€' : 'Grátis';
  String get prizePoolFormatted => prizePool != null ? '${(prizePool! / 100).toStringAsFixed(2)}€' : '-';
  bool get isRegistrationOpen => status == 'REGISTRATION_OPEN';
  int get spotsLeft => maxTeams - (playerCount ?? 0);

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      clubId: json['clubId'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      registrationDeadline: DateTime.parse(json['registrationDeadline']),
      format: json['format'] ?? 'SINGLE_ELIMINATION',
      maxTeams: json['maxTeams'] ?? 16,
      minLevel: json['minLevel'] ?? 'BEGINNER',
      maxLevel: json['maxLevel'] ?? 'PROFESSIONAL',
      entryFee: json['entryFee'] ?? 0,
      prizePool: json['prizePool'],
      status: json['status'] ?? 'UPCOMING',
      imageUrl: json['imageUrl'],
      club: json['club'],
      playerCount: json['_count']?['players'],
    );
  }
}

class TournamentsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Tournament> _tournaments = [];
  Tournament? _selectedTournament;
  bool _isLoading = false;
  String? _error;

  List<Tournament> get tournaments => _tournaments;
  Tournament? get selectedTournament => _selectedTournament;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTournaments({String? city, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{};
      if (city != null) params['city'] = city;
      if (status != null) params['status'] = status;

      final response = await _api.get('/tournaments', queryParameters: params);
      final responseData = response.data['data'];
      _tournaments = (responseData['data'] as List)
          .map((t) => Tournament.fromJson(t))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar torneios';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTournamentById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/tournaments/$id');
      _selectedTournament = Tournament.fromJson(response.data['data']);
    } catch (e) {
      _error = 'Erro ao carregar torneio';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(String id, {String? partnerId, String? teamName}) async {
    try {
      await _api.post('/tournaments/$id/register', data: {
        'partnerId': partnerId,
        'teamName': teamName,
      });
      await fetchTournamentById(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unregister(String id) async {
    try {
      await _api.delete('/tournaments/$id/register');
      await fetchTournamentById(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
