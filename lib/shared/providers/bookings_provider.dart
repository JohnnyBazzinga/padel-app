import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';

class Booking {
  final String id;
  final String courtId;
  final String userId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int totalPrice;
  final String status;
  final String? notes;
  final Map<String, dynamic>? court;
  final Map<String, dynamic>? user;

  Booking({
    required this.id,
    required this.courtId,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.notes,
    this.court,
    this.user,
  });

  String get priceFormatted => '${(totalPrice / 100).toStringAsFixed(2)}€';
  String get clubName => court?['club']?['name'] ?? '';
  String get courtName => court?['name'] ?? '';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      courtId: json['courtId'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      totalPrice: json['totalPrice'] ?? 0,
      status: json['status'],
      notes: json['notes'],
      court: json['court'],
      user: json['user'],
    );
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool available;
  final int price;
  final bool isPeak;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.available,
    required this.price,
    required this.isPeak,
  });

  String get priceFormatted => '${(price / 100).toStringAsFixed(2)}€';

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'],
      endTime: json['endTime'],
      available: json['available'] ?? false,
      price: json['price'] ?? 0,
      isPeak: json['isPeak'] ?? false,
    );
  }
}

class BookingsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Booking> _myBookings = [];
  List<TimeSlot> _availability = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get myBookings => _myBookings;
  List<TimeSlot> get availability => _availability;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyBookings({bool upcoming = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/bookings/my', queryParameters: {
        'upcoming': upcoming,
      });
      _myBookings = (response.data['data'] as List)
          .map((b) => Booking.fromJson(b))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar reservas';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCourtAvailability(String courtId, String date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/courts/$courtId/availability', queryParameters: {
        'date': date,
      });
      _availability = (response.data['data']['availability'] as List)
          .map((s) => TimeSlot.fromJson(s))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar disponibilidade';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Booking?> createBooking({
    required String courtId,
    required String date,
    required String startTime,
    String? endTime,
    int? durationMins,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/bookings', data: {
        'courtId': courtId,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'durationMins': durationMins ?? 90,
        'notes': notes,
      });
      final booking = Booking.fromJson(response.data['data']);
      _myBookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _error = 'Erro ao criar reserva';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelBooking(String id, {String? reason}) async {
    try {
      await _api.patch('/bookings/$id/cancel', data: {'reason': reason});
      _myBookings.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
