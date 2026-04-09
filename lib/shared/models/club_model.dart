class Club {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String address;
  final String city;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String? coverImageUrl;
  final bool hasParking;
  final bool hasShowers;
  final bool hasLockers;
  final bool hasProShop;
  final bool hasCafeteria;
  final bool hasWifi;
  final bool isVerified;
  final List<Court> courts;
  final double? distance;

  Club({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.address,
    required this.city,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.coverImageUrl,
    this.hasParking = false,
    this.hasShowers = false,
    this.hasLockers = false,
    this.hasProShop = false,
    this.hasCafeteria = false,
    this.hasWifi = false,
    this.isVerified = false,
    this.courts = const [],
    this.distance,
  });

  int get courtCount => courts.length;

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postalCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      logoUrl: json['logoUrl'],
      coverImageUrl: json['coverImageUrl'],
      hasParking: json['hasParking'] ?? false,
      hasShowers: json['hasShowers'] ?? false,
      hasLockers: json['hasLockers'] ?? false,
      hasProShop: json['hasProShop'] ?? false,
      hasCafeteria: json['hasCafeteria'] ?? false,
      hasWifi: json['hasWifi'] ?? false,
      isVerified: json['isVerified'] ?? false,
      courts: json['courts'] != null
          ? (json['courts'] as List).map((c) => Court.fromJson(c)).toList()
          : [],
      distance: json['distance']?.toDouble(),
    );
  }
}

class Court {
  final String id;
  final String clubId;
  final String name;
  final String? description;
  final int courtNumber;
  final String surface;
  final bool isIndoor;
  final bool hasLighting;
  final bool hasCovering;
  final int pricePerHour;
  final int? pricePerHourPeak;
  final String? peakHoursStart;
  final String? peakHoursEnd;
  final bool isActive;
  final bool isUnderMaintenance;

  Court({
    required this.id,
    required this.clubId,
    required this.name,
    this.description,
    required this.courtNumber,
    required this.surface,
    this.isIndoor = false,
    this.hasLighting = true,
    this.hasCovering = false,
    required this.pricePerHour,
    this.pricePerHourPeak,
    this.peakHoursStart,
    this.peakHoursEnd,
    this.isActive = true,
    this.isUnderMaintenance = false,
  });

  String get priceFormatted => '${(pricePerHour / 100).toStringAsFixed(2)}€';
  String get peakPriceFormatted => pricePerHourPeak != null
      ? '${(pricePerHourPeak! / 100).toStringAsFixed(2)}€'
      : priceFormatted;

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'],
      clubId: json['clubId'],
      name: json['name'],
      description: json['description'],
      courtNumber: json['courtNumber'],
      surface: json['surface'] ?? 'ARTIFICIAL_GRASS',
      isIndoor: json['isIndoor'] ?? false,
      hasLighting: json['hasLighting'] ?? true,
      hasCovering: json['hasCovering'] ?? false,
      pricePerHour: json['pricePerHour'] ?? 2000,
      pricePerHourPeak: json['pricePerHourPeak'],
      peakHoursStart: json['peakHoursStart'],
      peakHoursEnd: json['peakHoursEnd'],
      isActive: json['isActive'] ?? true,
      isUnderMaintenance: json['isUnderMaintenance'] ?? false,
    );
  }
}
