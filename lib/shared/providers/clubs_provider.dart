import 'package:flutter/material.dart';
import '../models/club_model.dart';
import '../../core/api/api_client.dart';
import 'auth_provider.dart';

class ClubsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Club> _clubs = [];
  Club? _selectedClub;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;

  List<Club> get clubs => _clubs;
  Club? get selectedClub => _selectedClub;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _currentPage < _totalPages;

  // Mock data for demo mode
  static final List<Club> _mockClubs = [
    Club(
      id: 'club-1',
      name: 'Padel Lisboa Centro',
      slug: 'padel-lisboa-centro',
      description: 'O melhor clube de padel no coração de Lisboa',
      address: 'Av. da Liberdade, 123',
      city: 'Lisboa',
      hasParking: true,
      hasShowers: true,
      hasLockers: true,
      hasCafeteria: true,
      hasWifi: true,
      isVerified: true,
      courts: [
        Court(id: 'c1', clubId: 'club-1', name: 'Court 1', courtNumber: 1, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2000, isIndoor: true),
        Court(id: 'c2', clubId: 'club-1', name: 'Court 2', courtNumber: 2, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2000, isIndoor: true),
        Court(id: 'c3', clubId: 'club-1', name: 'Court 3', courtNumber: 3, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2500, isIndoor: false),
      ],
    ),
    Club(
      id: 'club-2',
      name: 'Padel Cascais Beach',
      slug: 'padel-cascais-beach',
      description: 'Padel com vista para o mar',
      address: 'Praia de Carcavelos, s/n',
      city: 'Cascais',
      hasParking: true,
      hasShowers: true,
      hasCafeteria: true,
      isVerified: true,
      courts: [
        Court(id: 'c4', clubId: 'club-2', name: 'Beach Court 1', courtNumber: 1, surface: 'ARTIFICIAL_GRASS', pricePerHour: 3000, isIndoor: false),
        Court(id: 'c5', clubId: 'club-2', name: 'Beach Court 2', courtNumber: 2, surface: 'ARTIFICIAL_GRASS', pricePerHour: 3000, isIndoor: false),
      ],
    ),
    Club(
      id: 'club-3',
      name: 'Porto Padel Club',
      slug: 'porto-padel-club',
      description: 'O clube mais popular do Porto',
      address: 'Rua das Flores, 45',
      city: 'Porto',
      hasParking: true,
      hasShowers: true,
      hasLockers: true,
      hasCafeteria: true,
      hasWifi: true,
      isVerified: true,
      courts: [
        Court(id: 'c6', clubId: 'club-3', name: 'Court A', courtNumber: 1, surface: 'ARTIFICIAL_GRASS', pricePerHour: 1800, isIndoor: true),
        Court(id: 'c7', clubId: 'club-3', name: 'Court B', courtNumber: 2, surface: 'ARTIFICIAL_GRASS', pricePerHour: 1800, isIndoor: true),
        Court(id: 'c8', clubId: 'club-3', name: 'Court C', courtNumber: 3, surface: 'ARTIFICIAL_GRASS', pricePerHour: 1800, isIndoor: true),
        Court(id: 'c9', clubId: 'club-3', name: 'Court D', courtNumber: 4, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2200, isIndoor: false),
      ],
    ),
    Club(
      id: 'club-4',
      name: 'Sintra Padel Academy',
      slug: 'sintra-padel-academy',
      description: 'Academia de formação e treino',
      address: 'Estrada de Sintra, 200',
      city: 'Sintra',
      hasParking: true,
      hasShowers: true,
      isVerified: false,
      courts: [
        Court(id: 'c10', clubId: 'club-4', name: 'Training Court', courtNumber: 1, surface: 'ARTIFICIAL_GRASS', pricePerHour: 1500, isIndoor: true),
        Court(id: 'c11', clubId: 'club-4', name: 'Match Court', courtNumber: 2, surface: 'ARTIFICIAL_GRASS', pricePerHour: 1800, isIndoor: true),
      ],
    ),
    Club(
      id: 'club-5',
      name: 'Oeiras Sport Club',
      slug: 'oeiras-sport-club',
      description: 'Complexo desportivo com 6 campos',
      address: 'Av. Marginal, 500',
      city: 'Oeiras',
      hasParking: true,
      hasShowers: true,
      hasLockers: true,
      hasCafeteria: true,
      hasProShop: true,
      hasWifi: true,
      isVerified: true,
      courts: [
        Court(id: 'c12', clubId: 'club-5', name: 'Court 1', courtNumber: 1, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2200, isIndoor: true),
        Court(id: 'c13', clubId: 'club-5', name: 'Court 2', courtNumber: 2, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2200, isIndoor: true),
        Court(id: 'c14', clubId: 'club-5', name: 'Court 3', courtNumber: 3, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2200, isIndoor: true),
        Court(id: 'c15', clubId: 'club-5', name: 'Court 4', courtNumber: 4, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2200, isIndoor: false),
        Court(id: 'c16', clubId: 'club-5', name: 'Court 5', courtNumber: 5, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2500, isIndoor: false),
        Court(id: 'c17', clubId: 'club-5', name: 'Court 6', courtNumber: 6, surface: 'ARTIFICIAL_GRASS', pricePerHour: 2500, isIndoor: false),
      ],
    ),
  ];

  Future<void> fetchClubs({String? city, bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _clubs = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Demo mode: use mock data
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      _clubs = _mockClubs;
      _totalPages = 1;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final params = <String, dynamic>{
        'page': _currentPage,
        'limit': 20,
      };
      if (city != null) params['city'] = city;

      final response = await _api.get('/clubs', queryParameters: params);
      final responseData = response.data['data'];
      final data = responseData['data'] as List;
      final meta = responseData['meta'];

      final newClubs = data.map((c) => Club.fromJson(c)).toList();

      if (refresh) {
        _clubs = newClubs;
      } else {
        _clubs.addAll(newClubs);
      }

      _totalPages = meta['totalPages'];
      _currentPage++;
    } catch (e) {
      _error = 'Erro ao carregar clubes';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchClubById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Demo mode: use mock data
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      _selectedClub = _mockClubs.firstWhere(
        (c) => c.id == id,
        orElse: () => _mockClubs.first,
      );
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await _api.get('/clubs/$id');
      _selectedClub = Club.fromJson(response.data['data']);
    } catch (e) {
      _error = 'Erro ao carregar clube';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Club>> fetchNearbyClubs(double lat, double lng, {double radius = 10}) async {
    try {
      final response = await _api.get('/clubs/nearby', queryParameters: {
        'latitude': lat,
        'longitude': lng,
        'radius': radius,
      });
      return (response.data['data'] as List).map((c) => Club.fromJson(c)).toList();
    } catch (e) {
      return [];
    }
  }

  void clearSelectedClub() {
    _selectedClub = null;
    notifyListeners();
  }
}
