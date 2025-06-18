import 'package:get_it/get_it.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';
import '../services/face_recognition_service.dart';
import '../services/location_service.dart';
import '../repositories/user_repository.dart';
import '../repositories/attendance_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Services
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<FaceRecognitionService>(
    () => FaceRecognitionService(),
  );
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  // Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<StorageService>()),
  );
  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepository(getIt<StorageService>()),
  );

  // Providers
  getIt.registerFactory<AuthProvider>(
    () =>
        AuthProvider(getIt<UserRepository>(), getIt<FaceRecognitionService>()),
  );
  getIt.registerFactory<AttendanceProvider>(
    () => AttendanceProvider(
      getIt<AttendanceRepository>(),
      getIt<FaceRecognitionService>(),
      getIt<LocationService>(),
    ),
  );
  getIt.registerFactory<UserProvider>(
    () => UserProvider(getIt<UserRepository>()),
  );

  // Initialize services
  await getIt<StorageService>().init();
}
