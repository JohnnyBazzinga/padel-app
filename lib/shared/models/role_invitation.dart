import '../../core/access/app_roles.dart';

class RoleInvitation {
  final String id;
  final String email;
  final String role;
  final String status;
  final String invitedBy;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String token;
  final String? note;

  RoleInvitation({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.invitedBy,
    this.expiresAt,
    required this.createdAt,
    this.updatedAt,
    required this.token,
    this.note,
  });

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isAccepted => status.toUpperCase() == 'ACCEPTED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get isExpired => status.toUpperCase() == 'EXPIRED';

  String get displayRole => role.isEmpty ? 'PLAYER' : role;

  factory RoleInvitation.fromJson(Map<String, dynamic> json) {
    final inviter = json['invitedBy'];
    String invitedBy = 'Sistema';
    if (inviter is Map<String, dynamic>) {
      invitedBy = inviter['email'] ?? inviter['name'] ?? 'Sistema';
    } else if (inviter is String) {
      invitedBy = inviter;
    } else {
      invitedBy = json['invitedByEmail'] ?? 'Sistema';
    }

    final createdAt = json['createdAt'];
    final updatedAt = json['updatedAt'];

    return RoleInvitation(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? AppRoles.player,
      status: json['status'] ?? 'PENDING',
      invitedBy: invitedBy,
      token: json['token'] ?? '',
      note: json['note'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'])
          : null,
      createdAt: createdAt != null
          ? DateTime.tryParse('$createdAt') ?? DateTime.now()
          : DateTime.now(),
      updatedAt: updatedAt != null ? DateTime.tryParse('$updatedAt') : null,
    );
  }
}
