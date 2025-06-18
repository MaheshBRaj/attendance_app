import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserProvider(this._userRepository);

  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    return await _userRepository.getUserByPhoneNumber(phoneNumber);
  }
}
