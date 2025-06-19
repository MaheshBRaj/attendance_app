import 'package:attendanceapp/widgets.dart/camera_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../services/dependency_injection.dart';
import '../services/face_recognition_service.dart';
import '../utils/app_routes.dart';

// ...imports stay the same

class PunchScreen extends StatefulWidget {
  const PunchScreen({super.key});
  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  bool _showCamera = false;
  String? _capturedImagePath;
  String _currentAction = '';

  @override
  void initState() {
    super.initState();
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
      appBar: _buildAppBar(),
      body: Consumer2<AuthProvider, AttendanceProvider>(
        builder: (_, auth, attendance, __) {
          final user = auth.currentUser;
          if (user == null)
            return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildWelcomeCard(user.name),
                const SizedBox(height: 20),
                _buildStatusCard(attendance.lastAction),
                const SizedBox(height: 30),
                _showCamera
                    ? _buildCameraSection()
                    : _buildActionButtons(
                      attendance.lastAction,
                      user.id.toString(),
                    ),
                const SizedBox(height: 20),
                _buildViewLogButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Attendance'),
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed:
              () => Navigator.pushNamed(context, AppRoutes.attendanceLog),
        ),
        IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
      ],
    );
  }

  Widget _buildWelcomeCard(String userName) => _buildCard(
    icon: Icons.person,
    title: 'Welcome, $userName',
    subtitle: 'Ready to mark your attendance?',
  );

  Widget _buildStatusCard(String? lastAction) {
    final canPunchOut = lastAction == 'punch_in';
    final statusText = canPunchOut ? 'Currently Working' : 'Ready to Start';
    final statusColor = canPunchOut ? Colors.green : Colors.orange;
    final icon = canPunchOut ? Icons.work : Icons.home;

    return _buildCard(
      icon: icon,
      title: 'Current Status',
      subtitle: statusText,
      subtitleColor: statusColor,
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? subtitleColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue[600]),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: subtitleColor ?? Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(String? lastAction, String userId) {
    final canPunchIn = lastAction == null || lastAction == 'punch_out';
    final canPunchOut = lastAction == 'punch_in';

    return Column(
      children: [
        if (canPunchIn)
          _buildPunchButton('punch_in', Icons.login, Colors.green),
        if (canPunchOut)
          _buildPunchButton('punch_out', Icons.logout, Colors.red),
      ],
    );
  }

  Widget _buildPunchButton(String action, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => _startPunchAction(action),
        icon: Icon(icon, size: 30),
        label: Text(
          _getPunchText(action),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildCameraSection() {
    return Column(
      children: [
        Text(
          'Capture Your Face for ${_getPunchText(_currentAction)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: CameraWidget(
            onImageCaptured: (imagePath) {
              setState(() => _capturedImagePath = imagePath);
            },
          ),
        ),
        const SizedBox(height: 20),
        if (_capturedImagePath != null)
          ElevatedButton(
            onPressed: _processPunch,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _currentAction == 'punch_in' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            ),
            child: Text('Confirm ${_getPunchText(_currentAction)}'),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed:
              () => setState(() {
                _showCamera = false;
                _capturedImagePath = null;
                _currentAction = '';
              }),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildViewLogButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.attendanceLog),
        icon: Icon(Icons.history, color: Colors.blue[600]),
        label: Text(
          'VIEW ATTENDANCE LOG',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[600],
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.blue[600]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);
    final faceService = getIt<FaceRecognitionService>();

    try {
      final capturedEmbedding = await faceService.extractFaceEmbedding(
        _capturedImagePath!,
      );
      if (capturedEmbedding == null) {
        _showDialog('Error', 'Failed to process face image. Please try again.');
        return;
      }

      final isPunchIn = _currentAction == 'punch_in';
      final success =
          isPunchIn
              ? await attendance.punchIn(
                auth.currentUser!.id,
                auth.currentUser!.faceEmbedding,
                capturedEmbedding,
              )
              : await attendance.punchOut(
                auth.currentUser!.id,
                auth.currentUser!.faceEmbedding,
                capturedEmbedding,
              );

      if (success) {
        _showDialog('Success', '${_getPunchText(_currentAction)} successful!');
        setState(() {
          _showCamera = false;
          _capturedImagePath = null;
          _currentAction = '';
        });
      } else {
        _showDialog('Error', 'Face verification failed. Please try again.');
      }
    } catch (_) {
      _showDialog('Error', 'An error occurred. Please try again.');
    }
  }

  void _logout() {
    _showDialog(
      'Logout',
      'Are you sure you want to logout?',
      confirmText: 'Logout',
      onConfirm: () async {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.logout();
        if (mounted)
          Navigator.pushReplacementNamed(context, AppRoutes.registration);
      },
    );
  }

  void _showDialog(
    String title,
    String message, {
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              if (onConfirm != null)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm?.call();
                },
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  String _getPunchText(String action) =>
      action.toUpperCase().replaceAll('_', ' ');
}
