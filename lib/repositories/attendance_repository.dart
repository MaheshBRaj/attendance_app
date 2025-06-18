import 'dart:convert';
import '../models/attendance_record.dart';
import '../services/storage_service.dart';

class AttendanceRepository {
  final StorageService _storageService;
  static const String _attendanceKey = 'attendance_records';

  AttendanceRepository(this._storageService);

  Future<List<AttendanceRecord>> getAllRecords() async {
    final recordsJson = _storageService.getList(_attendanceKey) ?? [];
    return recordsJson
        .map((json) => AttendanceRecord.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<List<AttendanceRecord>> getRecordsByUserId(String userId) async {
    final allRecords = await getAllRecords();
    return allRecords.where((record) => record.userId == userId).toList();
  }

  Future<void> saveRecord(AttendanceRecord record) async {
    final records = await getAllRecords();
    records.add(record);
    final recordsJson =
        records.map((record) => jsonEncode(record.toJson())).toList();
    await _storageService.setList(_attendanceKey, recordsJson);
  }

  Future<AttendanceRecord?> getLastRecord(String userId) async {
    final userRecords = await getRecordsByUserId(userId);
    if (userRecords.isEmpty) return null;
    userRecords.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return userRecords.first;
  }
}
