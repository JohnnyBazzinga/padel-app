class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? city;
  final String? country;
  final String skillLevel;
  final String? preferredHand;
  final String? preferredSide;
  final int? yearsPlaying;
  final int matchesPlayed;
  final int matchesWon;
  final double reputationScore;
  final int reputationSignals;
  final String? reputationLabel;
  final int totalPoints;
  final List<String> roles;
  final String? availabilityStatus;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.city,
    this.country,
    required this.skillLevel,
    this.preferredHand,
    this.preferredSide,
    this.yearsPlaying,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
      this.reputationScore = 0,
      this.reputationSignals = 0,
      this.reputationLabel,
      this.totalPoints = 0,
      this.roles = const [],
      this.availabilityStatus,
  });

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  String get initials {
    final f = firstName?.isNotEmpty == true ? firstName![0] : '';
    final l = lastName?.isNotEmpty == true ? lastName![0] : '';
    return '$f$l'.toUpperCase();
  }

  double get winRate {
    if (matchesPlayed == 0) return 0;
    return (matchesWon / matchesPlayed * 100);
  }

  String get reputationBadge {
    if (reputationLabel != null && reputationLabel!.trim().isNotEmpty) {
      return reputationLabel!;
    }
    if (reputationScore >= 90) return 'Top';
    if (reputationScore >= 75) return 'Confiavel';
    if (reputationScore >= 55) return 'Regular';
    return 'Nova Conta';
  }

  String get reputationText => '${reputationBadge} · ${reputationScore.toStringAsFixed(0)}';

  factory User.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final roleList = <String>[];
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    if (rawRoles is List) {
      for (final role in rawRoles) {
        if (role is String) {
          roleList.add(role);
        } else if (role is Map && role['role'] is String) {
          roleList.add(role['role']);
        }
      }
    }

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      phone: json['phone']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      bio: json['bio']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      skillLevel: json['skillLevel']?.toString() ?? 'BEGINNER',
      preferredHand: json['preferredHand']?.toString(),
      preferredSide: json['preferredSide']?.toString(),
      yearsPlaying: parseInt(json['yearsPlaying'], 0),
      matchesPlayed: parseInt(json['matchesPlayed'], 0),
      matchesWon: parseInt(json['matchesWon'], 0),
      reputationScore: _parseReputationScore(json),
      reputationSignals: parseInt(json['reputationSignals'], 0),
      reputationLabel:
          json['reputationLabel']?.toString() ??
          json['reputationTier']?.toString() ??
          json['reputationCategory']?.toString(),
      totalPoints: parseInt(json['totalPoints'], 0),
      availabilityStatus: canonicalAvailabilityStatus(
        json['availabilityStatus'] ??
            json['status'] ??
            json['availability'] ??
            json['state'],
      ),
      roles: roleList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'city': city,
      'country': country,
      'skillLevel': skillLevel,
      'preferredHand': preferredHand,
      'preferredSide': preferredSide,
      'yearsPlaying': yearsPlaying,
      'matchesPlayed': matchesPlayed,
      'matchesWon': matchesWon,
      'reputationScore': reputationScore,
      'reputationSignals': reputationSignals,
      'reputationLabel': reputationLabel,
      'totalPoints': totalPoints,
      'availabilityStatus': availabilityStatus,
      'roles': roles,
    };
  }

  static double _parseReputationScore(Map<String, dynamic> json) {
    final direct = _toDouble(json['reputationScore']);
    if (direct != null) return direct;

    final alias = _toDouble(json['reputation']);
    if (alias != null) return alias;

    final nested = json['reputation'];
    if (nested is Map<String, dynamic>) {
      final nestedScore = _toDouble(nested['score']) ?? _toDouble(nested['value']);
      if (nestedScore != null) return nestedScore;
    }

    final legacy = _toDouble(json['rating']);
    return legacy ?? 0;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? getAvailabilityLabel(String? value) {
    return availabilityStatusLabel(value);
  }

  static String? getCanonicalAvailabilityStatus(String? value) {
    return canonicalAvailabilityStatus(value);
  }
}

String? normalizeAvailabilityStatusValue(String? value) {
  if (value == null) return null;
  final normalized = value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return normalized.isEmpty ? null : normalized;
}

String? canonicalAvailabilityStatus(String? value) {
  final normalized = normalizeAvailabilityStatusValue(value);
  if (normalized == null) return null;

  switch (normalized) {
    case 'a_jogar':
    case 'playing':
    case 'playing_now':
    case 'online':
    case 'activo':
    case 'ativo':
      return 'a_jogar';
    case 'a_procurar_parceiro':
    case 'procurando_parceiro':
    case 'looking':
    case 'need_partner':
    case 'need_1_player':
    case 'need1player':
      return 'a_procurar_parceiro';
    case 'offline':
    case 'ausente':
    case 'away':
      return 'offline';
    case 'ocupado':
    case 'busy':
      return 'busy';
    default:
      return normalized;
  }
}

String? availabilityStatusLabel(String? value) {
  final canonical = canonicalAvailabilityStatus(value);
  if (canonical == null) return null;

  switch (canonical) {
    case 'a_jogar':
      return 'A Jogar';
    case 'a_procurar_parceiro':
      return 'A Procurar Parceiro';
    case 'offline':
      return 'Offline';
    case 'busy':
      return 'Ocupado';
    default:
      return canonical.replaceAll('_', ' ').trim();
  }
}
