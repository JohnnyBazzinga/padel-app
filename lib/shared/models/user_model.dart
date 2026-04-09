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
  final int totalPoints;
  final List<String> roles;

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
    this.totalPoints = 0,
    this.roles = const [],
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      city: json['city'],
      country: json['country'],
      skillLevel: json['skillLevel'] ?? 'BEGINNER',
      preferredHand: json['preferredHand'],
      preferredSide: json['preferredSide'],
      yearsPlaying: json['yearsPlaying'],
      matchesPlayed: json['matchesPlayed'] ?? 0,
      matchesWon: json['matchesWon'] ?? 0,
      totalPoints: json['totalPoints'] ?? 0,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : [],
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
      'totalPoints': totalPoints,
      'roles': roles,
    };
  }
}
