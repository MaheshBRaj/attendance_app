import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceRecognitionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
    ),
  );

  Future<List<double>?> extractFaceEmbedding(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        return _generateFaceEmbedding(face);
      }
      return null;
    } catch (e) {
      debugPrint('Error extracting face embedding: $e');
      return null;
    }
  }

  Future<List<double>?> extractFaceEmbeddingFromBytes(
    Uint8List imageBytes,
  ) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: const Size(640, 480),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 640,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        return _generateFaceEmbedding(face);
      }
      return null;
    } catch (e) {
      debugPrint('Error extracting face embedding from bytes: $e');
      return null;
    }
  }

  bool compareFaces(
    List<double> embedding1,
    List<double> embedding2, {
    double threshold = 0.8,
  }) {
    if (embedding1.length != embedding2.length) return false;
    final similarity = _calculateCosineSimilarity(embedding1, embedding2);
    return similarity >= threshold;
  }

  List<double> _generateFaceEmbedding(Face face) {
    final embedding = List<double>.filled(128, 0.0);

    embedding[0] = face.boundingBox.left;
    embedding[1] = face.boundingBox.top;
    embedding[2] = face.boundingBox.width;
    embedding[3] = face.boundingBox.height;

    final types = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.leftEar,
      FaceLandmarkType.rightEar,
      FaceLandmarkType.leftMouth,
      FaceLandmarkType.rightMouth,
      FaceLandmarkType.bottomMouth,
    ];

    int idx = 4;
    for (var type in types) {
      final lm = face.landmarks[type];
      final x = lm?.position.x ?? 0.0;
      final y = lm?.position.x ?? 0.0;

      if (idx + 1 < embedding.length) {
        embedding[idx++] = x.toDouble();
        embedding[idx++] = y.toDouble();
      }
    }

    final norm = math.sqrt(embedding.fold(0.0, (s, v) => s + v * v));
    if (norm > 0) {
      for (int i = 0; i < embedding.length; i++) {
        embedding[i] /= norm;
      }
    }

    return embedding;
  }

  double _calculateCosineSimilarity(List<double> a, List<double> b) {
    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return (normA == 0 || normB == 0)
        ? 0.0
        : dot / (math.sqrt(normA) * math.sqrt(normB));
  }

  void dispose() {
    _faceDetector.close();
  }
}
