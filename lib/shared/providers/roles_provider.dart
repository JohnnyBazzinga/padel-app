import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/access/app_roles.dart';
import '../../core/api/api_client.dart';
import '../models/role_invitation.dart';

class RolesProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  int? _lastErrorStatus;

  List<RoleInvitation> _pendingInvitations = [];
  List<RoleInvitation> _myInvitations = [];
  RoleInvitation? _tokenInvitation;
  bool _isLoading = false;
  String? _error;
  int? get lastErrorStatus => _lastErrorStatus;

  List<RoleInvitation> get pendingInvitations => _pendingInvitations;
  List<RoleInvitation> get myInvitations => _myInvitations;
  RoleInvitation? get tokenInvitation => _tokenInvitation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTokenInvitation => _tokenInvitation != null;

  List<RoleInvitation> _parseInvitationList(dynamic payload) {
    final data = payload is List
        ? payload
        : (payload is Map && payload['data'] is List
            ? payload['data']
            : <dynamic>[]);
    return data
        .whereType<Map<String, dynamic>>()
        .map(RoleInvitation.fromJson)
        .toList();
  }

  dynamic _extractPayload(Response<dynamic>? response) {
    if (response == null) return null;
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
      return data['data'];
    }
    return data;
  }

  String? _resolveErrorMessage(Object error, String fallback) {
    if (error is DioException) {
      _lastErrorStatus = error.response?.statusCode;
      final responseData = error.response?.data;
      if (responseData is Map && responseData['message'] is String) {
        return responseData['message'];
      }
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) return 'Sessão inválida, faz login novamente';
      if (statusCode == 403) return 'Não tens permissão para esta ação';
      if (statusCode == 404) return 'Recurso não encontrado';
      if (statusCode == 409) return 'Este convite já foi processado';
      if (statusCode == 410) return 'Convite expirado';
      if (statusCode == 429)
        return 'Muitas tentativas, tenta novamente mais tarde';
    }
    return fallback;
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<void> fetchPendingInvitations() async {
    _lastErrorStatus = null;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/roles/invitations/pending');
      _pendingInvitations = _parseInvitationList(_extractPayload(response));
    } catch (e) {
      _error = _resolveErrorMessage(e, 'Erro ao carregar convites');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyInvitations() async {
    _lastErrorStatus = null;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/roles/invitations/me');
      _myInvitations = _parseInvitationList(_extractPayload(response));
    } catch (e) {
      _error = _resolveErrorMessage(
        e,
        'Erro ao carregar convites do utilizador',
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshMyAndPendingInvitations() async {
    try {
      await Future.wait([fetchPendingInvitations(), fetchMyInvitations()]);
    } catch (_) {
      // ignore
    }
  }

  Future<bool> inviteOrganizer(String email, {String? note}) async {
    _lastErrorStatus = null;
    _error = null;
    return inviteByRole(
      email: email,
      role: AppRoles.clubOwner,
      note: note,
    );
  }

  Future<bool> inviteByRole({
    required String email,
    required String role,
    String? note,
  }) async {
    _lastErrorStatus = null;
    _error = null;
    try {
      await _api.post('/roles/invitations', data: {
        'email': email,
        'role': _normalizeInvitableRole(role),
        if (note != null && note.isNotEmpty) 'note': note,
      });
      await fetchPendingInvitations();
      return true;
    } catch (e) {
      _error = _resolveErrorMessage(e, 'Nao foi possivel enviar convite');
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptInvitation(String invitationId) async {
    _lastErrorStatus = null;
    _error = null;
    try {
      await _api.post('/roles/invitations/$invitationId/accept');
      await fetchMyInvitations();
      return true;
    } catch (e) {
      _error = _resolveErrorMessage(e, 'Nao foi possivel aceitar este convite');
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectInvitation(String invitationId) async {
    _lastErrorStatus = null;
    _error = null;
    try {
      await _api.post('/roles/invitations/$invitationId/reject');
      await fetchMyInvitations();
      return true;
    } catch (e) {
      _error =
          _resolveErrorMessage(e, 'Nao foi possivel rejeitar este convite');
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelInvitation(String invitationId) async {
    _lastErrorStatus = null;
    _error = null;
    try {
      await _api.post('/roles/invitations/$invitationId/cancel');
      await fetchPendingInvitations();
      return true;
    } catch (e) {
      _error =
          _resolveErrorMessage(e, 'Nao foi possivel cancelar este convite');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchInvitationByToken(String token) async {
    _lastErrorStatus = null;
    _isLoading = true;
    _error = null;
    _tokenInvitation = null;
    notifyListeners();

    try {
      final response = await _api.get('/roles/invitations/token/$token');
      final payload = _extractPayload(response);
      final invitationPayload = payload is Map<String, dynamic>
          ? payload['invitation'] ?? payload
          : null;
      _tokenInvitation = invitationPayload is Map<String, dynamic>
          ? RoleInvitation.fromJson(invitationPayload)
          : null;
    } catch (e) {
      _tokenInvitation = null;
      _error = _resolveErrorMessage(e, 'Convite inválido ou expirado');
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearTokenInvitation() {
    _tokenInvitation = null;
    notifyListeners();
  }

  Future<bool> acceptInvitationByToken(String token) async {
    return _actOnInvitationByToken(
      token: token,
      endpoint: 'accept',
      message: 'aceitar',
    );
  }

  Future<bool> rejectInvitationByToken(String token) async {
    return _actOnInvitationByToken(
      token: token,
      endpoint: 'reject',
      message: 'rejeitar',
    );
  }

  Future<bool> _actOnInvitationByToken({
    required String token,
    required String endpoint,
    required String message,
  }) async {
    _lastErrorStatus = null;
    _error = null;
    try {
      await _api.post('/roles/invitations/token/$token/$endpoint');
      _tokenInvitation = null;
      await refreshMyAndPendingInvitations();
      return true;
    } catch (e) {
      _error = _resolveErrorMessage(
        e,
        'Nao foi possivel $message este convite',
      );
      notifyListeners();
      return false;
    }
  }

  String _normalizeInvitableRole(String role) {
    final normalized = AppRoles.normalize(role);
    if (normalized == AppRoles.organizer) {
      return AppRoles.clubOwner;
    }
    if (normalized == AppRoles.player || normalized == AppRoles.admin) {
      return normalized;
    }
    return normalized;
  }
}
