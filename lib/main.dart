import 'package:attendanceapp/providers/attendance_provider.dart';
import 'package:attendanceapp/providers/auth_provider.dart';
import 'package:attendanceapp/providers/user_provider.dart';
import 'package:attendanceapp/screens/attendance_log_screen.dart';
import 'package:attendanceapp/screens/punch_screen.dart';
import 'package:attendanceapp/screens/registration_screen.dart';
import 'package:attendanceapp/screens/splash_screen.dart';
import 'package:attendanceapp/services/dependency_injection.dart';
import 'package:attendanceapp/utils/app_routes.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize cameras
  cameras = await availableCameras();

  // Setup dependency injection
  await setupDependencyInjection();

  runApp(AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {  
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<AttendanceProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<UserProvider>()),
      ],
      child: MaterialApp(
        title: 'Attendance App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => SplashScreen(),
          AppRoutes.registration: (context) => RegistrationScreen(),
          AppRoutes.punch: (context) => PunchScreen(),
          AppRoutes.attendanceLog: (context) => AttendanceLogScreen(),
        },
      ),
    );
  }
}
