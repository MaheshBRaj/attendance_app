import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceRecognitionService {
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
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
        // Simulate face embedding extraction (in real app, use ML model)
        return _generateFaceEmbedding(face);
      }
      return null;
    } catch (e) {
      print('Error extracting face embedding: $e');
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
          size: Size(640, 480),
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
      print('Error extracting face embedding from bytes: $e');
      return null;
    }
  }

  bool compareFaces(
    List<double> embedding1,
    List<double> embedding2, {
    double threshold = 0.8,
  }) {
    if (embedding1.length != embedding2.length) return false;

    double similarity = _calculateCosineSimilarity(embedding1, embedding2);
    return similarity >= threshold;
  }

  List<double> _generateFaceEmbedding(Face face) {
    // In a real app, you would use a trained ML model to generate embeddings
    // For demo purposes, we'll create a simple embedding based on face landmarks
    final landmarks = face.landmarks;
    List<double> embedding = List.filled(128, 0.0);

    // Use face bounding box and landmarks to create a simple embedding
    embedding[0] = face.boundingBox.left.toDouble();
    embedding[1] = face.boundingBox.top.toDouble();
    embedding[2] = face.boundingBox.width.toDouble();
    embedding[3] = face.boundingBox.height.toDouble();

    // Add landmark positions if available
    int index = 4;
    landmarks.forEach((type, landmark) {
      final x = landmark?.position.x.toDouble() ?? 0.0;
      final y = landmark?.position.y.toDouble() ?? 0.0;
      if (index < 126) {
        embedding[index++] = x;
        embedding[index++] = y;
      }
    });

    // Normalize the embedding
    double norm = math.sqrt(embedding.fold(0.0, (sum, val) => sum + val * val));

    if (norm > 0) {
      for (int i = 0; i < embedding.length; i++) {
        embedding[i] /= norm;
      }
    }

    return embedding;
  }

  double _calculateCosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;

    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }

  void dispose() {
    _faceDetector.close();
  }
}
