import 'dart:convert';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class UserRepository {
  final StorageService _storageService;
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  UserRepository(this._storageService);

  Future<List<User>> getAllUsers() async {
    final usersJson = _storageService.getList(_usersKey) ?? [];
    return usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
  }

  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user.phoneNumber == phoneNumber);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUser(User user) async {
    final users = await getAllUsers();
    users.add(user);
    final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
    await _storageService.setList(_usersKey, usersJson);
  }

  Future<void> setCurrentUser(User user) async {
    await _storageService.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  Future<User?> getCurrentUser() async {
    final userJson = _storageService.getString(_currentUserKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> clearCurrentUser() async {
    await _storageService.setString(_currentUserKey, '');
  }
}
