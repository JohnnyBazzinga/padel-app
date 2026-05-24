class AppRoles {
  static const String player = 'PLAYER';
  static const String organizer = 'ORGANIZER';
  static const String clubOwner = 'CLUB_OWNER';
  static const String clubManager = 'CLUB_MANAGER';
  static const String admin = 'ADMIN';
  static const String platformAdmin = 'PLATFORM_ADMIN';

  static final Set<String> allAdminRoles = {
    admin,
    platformAdmin,
  };

  static final Set<String> allOrganizerRoles = {
    organizer,
    clubOwner,
    clubManager,
    ...allAdminRoles,
  };

  static String normalize(String role) => role.trim().toUpperCase();

  static Set<String> normalizeRoles(List<String> roles) {
    return roles.map((r) => normalize(r)).toSet();
  }

  static bool hasRole(List<String> roles, String role) {
    final normalized = normalizeRoles(roles);
    return normalized.contains(normalize(role));
  }

  static bool isAdmin(List<String> roles) {
    return normalizeRoles(roles).any(allAdminRoles.contains);
  }

  static bool isOrganizer(List<String> roles) {
    return normalizeRoles(roles).any(allOrganizerRoles.contains);
  }

  static bool canCreateTournaments(List<String> roles) {
    return isOrganizer(roles);
  }

  static bool canInviteOrganizer(List<String> roles) {
    return isAdmin(roles);
  }

  static bool canCreateMatches(List<String> roles) {
    return isOrganizer(roles);
  }

  static bool isPlatformAdministrator(List<String> roles) {
    return normalizeRoles(roles).contains(platformAdmin);
  }

  static bool canAccessAdminArea(List<String> roles) {
    return isAdmin(roles);
  }

  static bool canManageAll(List<String> roles) {
    return isAdmin(roles);
  }
}
