import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class AttendanceService {
  final AttendanceRepository _repository;

  AttendanceService(this._repository);

  Future<List<AttendanceRecord>> fetchAllLogs() {
    return _repository.getAllRecords();
  }

  Future<List<AttendanceRecord>> fetchUserLogs(String userId) {
    return _repository.getRecordsByUserId(userId);
  }

  Future<AttendanceRecord?> getLastPunch(String userId) {
    return _repository.getLastRecord(userId);
  }

  Future<bool> punch({
    required String userId,
    required String action,
    required double latitude,
    required double longitude,
    required String location,
  }) async {
    try {
      final record = AttendanceRecord(
        id: const Uuid().v4(),
        userId: userId,
        dateTime: DateTime.now(),
        action: action,
        latitude: latitude,
        longitude: longitude,
        location: location,
      );
      await _repository.saveRecord(record);
      return true;
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      return false;
    }
  }
}
