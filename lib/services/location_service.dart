import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location permission is granted
      if (await Permission.location.request().isGranted) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
      return null;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<String> getLocationString(double latitude, double longitude) async {
    try {
      // In a real app, you would use reverse geocoding
      // For demo purposes, return coordinates
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      return 'Unknown Location';
    }
  }
}
