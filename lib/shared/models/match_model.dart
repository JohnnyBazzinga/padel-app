import 'user_model.dart';

class Match {
  final String id;
  final String? title;
  final String? description;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String minLevel;
  final String maxLevel;
  final String status;
  final int playersNeeded;
  final bool isPrivate;
  final String? location;
  final String? city;
  final String? score;
  final String? winnerId;
  final List<MatchPlayer> players;
  final Court? court;
  final Club? club;

  Match({
    required this.id,
    this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.minLevel,
    required this.maxLevel,
    required this.status,
    required this.playersNeeded,
    this.isPrivate = false,
    this.location,
    this.city,
    this.score,
    this.winnerId,
    this.players = const [],
    this.court,
    this.club,
  });

  int get currentPlayers => players.length;
  int get spotsLeft => playersNeeded - currentPlayers;
  bool get isFull => currentPlayers >= playersNeeded;
  bool get isLookingForPlayers => status == 'LOOKING_FOR_PLAYERS';

  String get displayLocation {
    if (court != null && club != null) {
      return '${club!.name} - ${court!.name}';
    }
    return location ?? city ?? 'Local a definir';
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      minLevel: json['minLevel'] ?? 'BEGINNER',
      maxLevel: json['maxLevel'] ?? 'PROFESSIONAL',
      status: json['status'] ?? 'LOOKING_FOR_PLAYERS',
      playersNeeded: json['playersNeeded'] ?? 4,
      isPrivate: json['isPrivate'] ?? false,
      location: json['location'],
      city: json['city'],
      score: json['score'],
      winnerId: json['winnerId'],
      players: json['players'] != null
          ? (json['players'] as List).map((p) => MatchPlayer.fromJson(p)).toList()
          : [],
      court: json['court'] != null ? Court.fromJson(json['court']) : null,
      club: json['court']?['club'] != null ? Club.fromJson(json['court']['club']) : null,
    );
  }
}

class MatchPlayer {
  final String id;
  final String matchId;
  final String userId;
  final int team;
  final String? position;
  final bool isOrganizer;
  final User? user;

  MatchPlayer({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.team,
    this.position,
    this.isOrganizer = false,
    this.user,
  });

  factory MatchPlayer.fromJson(Map<String, dynamic> json) {
    return MatchPlayer(
      id: json['id'],
      matchId: json['matchId'],
      userId: json['userId'],
      team: json['team'] ?? 0,
      position: json['position'],
      isOrganizer: json['isOrganizer'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Court {
  final String id;
  final String name;

  Court({required this.id, required this.name});

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Club {
  final String id;
  final String name;
  final String city;

  Club({required this.id, required this.name, required this.city});

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      name: json['name'],
      city: json['city'] ?? '',
    );
  }
}
