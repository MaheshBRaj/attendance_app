import 'package:attendanceapp/widgets.dart/camera_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../services/dependency_injection.dart';
import '../services/face_recognition_service.dart';
import '../utils/app_routes.dart';

class PunchScreen extends StatefulWidget {
  const PunchScreen({super.key});

  @override
  _PunchScreenState createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  bool _showCamera = false;
  String? _capturedImagePath;
  String _currentAction = '';

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  void _loadAttendanceData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      attendanceProvider.loadRecords(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.attendanceLog);
            },
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Consumer2<AuthProvider, AttendanceProvider>(
        builder: (context, authProvider, attendanceProvider, child) {
          if (authProvider.currentUser == null) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildWelcomeCard(authProvider.currentUser!.name),
                SizedBox(height: 20),
                _buildStatusCard(attendanceProvider),
                SizedBox(height: 30),
                if (!_showCamera) ...[
                  _buildActionButtons(attendanceProvider),
                ] else ...[
                  _buildCameraSection(),
                ],
                SizedBox(height: 20),
                _buildViewLogButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(String userName) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.person, size: 50, color: Colors.blue[600]),
            SizedBox(height: 10),
            Text(
              'Welcome, $userName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Ready to mark your attendance?',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AttendanceProvider attendanceProvider) {
    final lastAction = attendanceProvider.lastAction;
    final canPunchIn = lastAction == null || lastAction == 'punch_out';
    final canPunchOut = lastAction == 'punch_in';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Current Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canPunchOut ? Icons.work : Icons.home,
                  size: 30,
                  color: canPunchOut ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 10),
                Text(
                  canPunchOut ? 'Currently Working' : 'Ready to Start',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: canPunchOut ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AttendanceProvider attendanceProvider) {
    final lastAction = attendanceProvider.lastAction;
    final canPunchIn = lastAction == null || lastAction == 'punch_out';
    final canPunchOut = lastAction == 'punch_in';

    return Column(
      children: [
        if (canPunchIn) ...[
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => _startPunchAction('punch_in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'PUNCH IN',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (canPunchOut) ...[
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => _startPunchAction('punch_out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'PUNCH OUT',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCameraSection() {
    return Column(
      children: [
        Text(
          'Capture Your Face for ${_currentAction.toUpperCase().replaceAll('_', ' ')}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: CameraWidget(
            onImageCaptured: (imagePath) {
              setState(() {
                _capturedImagePath = imagePath;
              });
            },
          ),
        ),
        SizedBox(height: 20),
        if (_capturedImagePath != null) ...[
          ElevatedButton(
            onPressed: _processPunch,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _currentAction == 'punch_in' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
            child: Text(
              'Confirm ${_currentAction.toUpperCase().replaceAll('_', ' ')}',
            ),
          ),
          SizedBox(height: 10),
        ],
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showCamera = false;
              _capturedImagePath = null;
              _currentAction = '';
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildViewLogButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.attendanceLog);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.blue[600]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: Colors.blue[600]),
            SizedBox(width: 10),
            Text(
              'VIEW ATTENDANCE LOG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startPunchAction(String action) {
    setState(() {
      _showCamera = true;
      _currentAction = action;
      _capturedImagePath = null;
    });
  }

  Future<void> _processPunch() async {
    if (_capturedImagePath == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    final faceRecognitionService = getIt<FaceRecognitionService>();

    try {
      final capturedFaceEmbedding = await faceRecognitionService
          .extractFaceEmbedding(_capturedImagePath!);

      if (capturedFaceEmbedding == null) {
        _showErrorDialog('Failed to process face image. Please try again.');
        return;
      }

      bool success = false;
      if (_currentAction == 'punch_in') {
        success = await attendanceProvider.punchIn(
          authProvider.currentUser!.id,
          authProvider.currentUser!.faceEmbedding,
          capturedFaceEmbedding,
        );
      } else {
        success = await attendanceProvider.punchOut(
          authProvider.currentUser!.id,
          authProvider.currentUser!.faceEmbedding,
          capturedFaceEmbedding,
        );
      }

      if (success) {
        setState(() {
          _showCamera = false;
          _capturedImagePath = null;
          _currentAction = '';
        });
        _showSuccessDialog(
          '${_currentAction.toUpperCase().replaceAll('_', ' ')} successful!',
        );
      } else {
        _showErrorDialog('Face verification failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Success'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.registration,
                  );
                },
                child: Text('Logout'),
              ),
            ],
          ),
    );
  }
}
