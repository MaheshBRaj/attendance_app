import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../services/face_recognition_service.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  final FaceRecognitionService _faceRecognitionService;

  User? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._userRepository, this._faceRecognitionService);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _userRepository.getCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkUserExists(String phoneNumber) async {
    final user = await _userRepository.getUserByPhoneNumber(phoneNumber);
    return user != null;
  }

  Future<bool> authenticateWithFace(
    String phoneNumber,
    String faceImagePath,
  ) async {
    try {
      final user = await _userRepository.getUserByPhoneNumber(phoneNumber);
      if (user == null) return false;

      final faceEmbedding = await _faceRecognitionService.extractFaceEmbedding(
        faceImagePath,
      );
      if (faceEmbedding == null) return false;

      final isMatch = _faceRecognitionService.compareFaces(
        user.faceEmbedding,
        faceEmbedding,
      );

      if (isMatch) {
        _currentUser = user;
        await _userRepository.setCurrentUser(user);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  Future<bool> registerUser(User user) async {
    try {
      await _userRepository.saveUser(user);
      _currentUser = user;
      await _userRepository.setCurrentUser(user);
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _userRepository.clearCurrentUser();
    notifyListeners();
  }
}
