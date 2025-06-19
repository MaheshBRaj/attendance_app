import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/attendance_record.dart';
import '../repositories/attendance_repository.dart';
import '../services/face_recognition_service.dart';
import '../services/location_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepository _attendanceRepository;
  final FaceRecognitionService _faceRecognitionService;
  final LocationService _locationService;

  List<AttendanceRecord> _records = [];
  bool _isLoading = false;
  String? _lastAction;

  AttendanceProvider(
    this._attendanceRepository,
    this._faceRecognitionService,
    this._locationService,
  );

  List<AttendanceRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get lastAction => _lastAction;

  Future<void> loadRecords(String userId) async {
    _isLoading = true;
    notifyListeners();

    _records = await _attendanceRepository.getRecordsByUserId(userId);
    _records.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final lastRecord = await _attendanceRepository.getLastRecord(userId);
    _lastAction = lastRecord?.action;

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> punchIn(
    String userId,
    List<double> userFaceEmbedding,
    List<double> capturedFaceEmbedding,
  ) async {
    try {
      // Verify face match
      if (!_faceRecognitionService.compareFaces(
        userFaceEmbedding,
        capturedFaceEmbedding,
      )) {
        return false;
      }

      // Get location
      final position = await _locationService.getCurrentLocation();
      if (position == null) return false;

      final locationString = await _locationService.getLocationString(
        position.latitude,
        position.longitude,
      );

      // Create record

      //initial commit
      final record = AttendanceRecord(
        id: const Uuid().v4(),
        userId: userId,
        dateTime: DateTime.now(),
        action: 'punch_in',
        latitude: position.latitude,
        longitude: position.longitude,
        location: locationString,
      );

      await _attendanceRepository.saveRecord(record);
      _records.insert(0, record);
      _lastAction = 'punch_in';
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Punch in error: $e');
      return false;
    }
  }

  Future<bool> punchOut(
    String userId,
    List<double> userFaceEmbedding,
    List<double> capturedFaceEmbedding,
  ) async {
    try {
      // Verify face match
      if (!_faceRecognitionService.compareFaces(
        userFaceEmbedding,
        capturedFaceEmbedding,
      )) {
        return false;
      }

      // Get location
      final position = await _locationService.getCurrentLocation();
      if (position == null) return false;

      final locationString = await _locationService.getLocationString(
        position.latitude,
        position.longitude,
      );

      // Create record
      final record = AttendanceRecord(
        id: const Uuid().v4(),
        userId: userId,
        dateTime: DateTime.now(),
        action: 'punch_out',
        latitude: position.latitude,
        longitude: position.longitude,
        location: locationString,
      );

      await _attendanceRepository.saveRecord(record);
      _records.insert(0, record);
      _lastAction = 'punch_out';
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Punch out error: $e');
      return false;
    }
  }
}
