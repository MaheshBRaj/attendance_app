class AttendanceRecord {
  final String id;
  final String userId;
  final DateTime dateTime;
  final String action; // 'punch_in' or 'punch_out'
  final double latitude;
  final double longitude;
  final String location;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.dateTime,
    required this.action,
    required this.latitude,
    required this.longitude,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dateTime': dateTime.toIso8601String(),
      'action': action,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      userId: json['userId'],
      dateTime: DateTime.parse(json['dateTime']),
      action: json['action'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      location: json['location'],
    );
  }
}
