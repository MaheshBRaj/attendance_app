import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/dependency_injection.dart';
import '../services/face_recognition_service.dart';
import '../utils/app_routes.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedGender = 'Male';
  DateTime _selectedDate = DateTime.now();
  String? _capturedImagePath;
  bool _isLoading = false;
  bool _phoneVerified = false;
  bool _showUserForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_phoneVerified) ...[
                _buildPhoneVerificationSection(),
              ] else ...[
                _buildUserDetailsSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneVerificationSection() {
    return Column(
      children: [
        Text(
          'Enter Your Phone Number',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 30),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            if (value.length < 10) {
              return 'Phone number must be at least 10 digits';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyPhoneNumber,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          child:
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Verify Phone Number'),
        ),
      ],
    );
  }

  Widget _buildFaceCaptureSection() {
    return Column(
      children: [
        Text(
          'Capture Your Face',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text(
          'Please capture your face for registration',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        SizedBox(height: 30),
        // Container(
        //   height: 300,
        //   child: CameraWidget(
        //     onImageCaptured: (imagePath) {
        //       setState(() {
        //         _capturedImagePath = imagePath;
        //       });
        //     },
        //   ),
        // ),
        SizedBox(height: 20),
        if (_capturedImagePath != null) ...[
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.file(File(_capturedImagePath!), fit: BoxFit.cover),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showUserForm = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text('Continue with Registration'),
          ),
        ],
      ],
    );
  }

  Widget _buildUserDetailsSection() {
    return Column(
      children: [
        Text(
          'Complete Your Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 30),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Please enter your name'
                      : null,
        ),
        SizedBox(height: 15),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Please enter your email';
            if (!value.contains('@')) return 'Please enter a valid email';
            return null;
          },
        ),
        SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
          items:
              ['Male', 'Female', 'Other']
                  .map(
                    (gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)),
                  )
                  .toList(),
          onChanged: (value) => setState(() => _selectedGender = value!),
        ),
        SizedBox(height: 15),
        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isLoading ? null : _registerUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          child:
              _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Complete Registration'),
        ),
      ],
    );
  }

  Future<void> _verifyPhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userExists = await authProvider.checkUserExists(
      _phoneController.text,
    );

    if (userExists) {
      // User exists, go to face authentication
      Navigator.pushReplacementNamed(context, AppRoutes.punch);
    } else {
      // New user, continue with registration
      setState(() {
        _phoneVerified = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate() || _capturedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all fields and capture your face'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final faceRecognitionService = getIt<FaceRecognitionService>();
      final faceEmbedding = await faceRecognitionService.extractFaceEmbedding(
        _capturedImagePath!,
      );

      if (faceEmbedding == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process face image. Please try again.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final user = User(
        id: const Uuid().v4(),
        phoneNumber: _phoneController.text,
        name: _nameController.text,
        email: _emailController.text,
        gender: _selectedGender,
        dateOfBirth: _selectedDate,
        faceImagePath: _capturedImagePath!,
        faceEmbedding: faceEmbedding,
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.registerUser(user);

      if (success) {
        Navigator.pushReplacementNamed(context, AppRoutes.punch);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}
