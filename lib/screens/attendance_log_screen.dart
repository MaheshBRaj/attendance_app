import 'package:attendanceapp/repositories/attendance_repository.dart';
import 'package:attendanceapp/services/attendance_service.dart';
import 'package:attendanceapp/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attendance_record.dart';

class AttendanceLogScreen extends StatefulWidget {
  const AttendanceLogScreen({super.key});

  @override
  State<AttendanceLogScreen> createState() => _AttendanceLogScreenState();
}

class _AttendanceLogScreenState extends State<AttendanceLogScreen> {
  final List<AttendanceRecord> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);

    try {
      final records = AttendanceService(AttendanceRepository(StorageService()));
      //  setState(() => _logs = records);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load attendance records')),
      );
    }

    setState(() => _isLoading = false);
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  Color _getActionColor(String action) {
    return action == 'punch_in' ? Colors.green : Colors.red;
  }

  IconData _getActionIcon(String action) {
    return action == 'punch_in' ? Icons.login : Icons.logout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Logs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _logs.isEmpty
              ? const Center(child: Text('No attendance records found.'))
              : ListView.builder(
                itemCount: _logs.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final record = _logs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _getActionIcon(record.action),
                        color: _getActionColor(record.action),
                      ),
                      title: Text(
                        '${record.action.toUpperCase()} - ${_formatDateTime(record.dateTime)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: ${record.userId}'),
                          Text('Location: ${record.location}'),
                          Text(
                            'Lat: ${record.latitude}, Lng: ${record.longitude}',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
