import 'match_model.dart';

class MatchSuggestion {
  final String id;
  final String? title;
  final String? description;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final String? city;
  final String? location;
  final int playersNeeded;
  final int currentPlayers;
  final String? minLevel;
  final String? maxLevel;
  final String? language;
  final bool indoor;
  final double? confidence;
  final double? distanceKm;
  final String? matchId;
  final Match? match;

  MatchSuggestion({
    required this.id,
    this.title,
    this.description,
    this.date,
    this.startTime,
    this.endTime,
    this.city,
    this.location,
    this.playersNeeded = 4,
    this.currentPlayers = 0,
    this.minLevel,
    this.maxLevel,
    this.language,
    this.indoor = false,
    this.confidence,
    this.distanceKm,
    this.matchId,
    this.match,
  });

  int get spotsLeft => playersNeeded - currentPlayers;
  String get displayLocation => location ?? city ?? '';

  factory MatchSuggestion.fromJson(Map<String, dynamic> json) {
    final matchPayload = json['match'];
    final nested =
        matchPayload is Map<String, dynamic> ? Match.fromJson(matchPayload) : null;

    return MatchSuggestion(
      id: json['id']?.toString() ??
          matchPayload?['id']?.toString() ??
          (nested?.id ?? ''),
      title: _toString(json['title']) ?? _toString(matchPayload?['title']),
      description: _toString(json['description']) ?? _toString(matchPayload?['description']),
      date: _parseDate(json['date']) ?? _parseDate(matchPayload?['date']),
      startTime: _toString(json['startTime']) ?? _toString(matchPayload?['startTime']),
      endTime: _toString(json['endTime']) ?? _toString(matchPayload?['endTime']),
      city: _toString(json['city']) ?? _toString(matchPayload?['city']),
      location: _toString(json['location']) ?? _toString(matchPayload?['location']),
      playersNeeded: _toInt(json['playersNeeded']) ?? nested?.playersNeeded ?? 4,
      currentPlayers: _toInt(json['currentPlayers']) ?? nested?.currentPlayers ?? 0,
      minLevel: _toString(json['minLevel']) ?? _toString(matchPayload?['minLevel']) ?? nested?.minLevel,
      maxLevel: _toString(json['maxLevel']) ?? _toString(matchPayload?['maxLevel']) ?? nested?.maxLevel,
      language: _toString(json['language']) ?? _toString(matchPayload?['language']),
      indoor: _toBool(json['indoor']) ?? _toBool(matchPayload?['indoor']) ?? false,
      confidence: _toDouble(json['confidence']),
      distanceKm: _toDouble(json['distanceKm']),
      matchId: _toString(json['matchId']) ?? _toString(matchPayload?['id']),
      match: nested,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'city': city,
      'location': location,
      'playersNeeded': playersNeeded,
      'currentPlayers': currentPlayers,
      'minLevel': minLevel,
      'maxLevel': maxLevel,
      'language': language,
      'indoor': indoor,
      'confidence': confidence,
      'distanceKm': distanceKm,
      'matchId': matchId,
    };
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lowered = value.toLowerCase();
      if (lowered == 'true' || lowered == '1' || lowered == 'yes') return true;
      if (lowered == 'false' || lowered == '0' || lowered == 'no') return false;
    }
    return null;
  }

  static String? _toString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
