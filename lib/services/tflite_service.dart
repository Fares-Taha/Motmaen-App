import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/food_prediction.dart';

class TFLiteService {
  late Interpreter _interpreter;
  List<String> _classNames = [];

  /// Load the TensorFlow Lite model and labels
  Future<void> loadModel() async {
    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset(
          'assets/models/model_v5_fine_tuned_int8.tflite');

      // Load labels from assets
      final labels = await rootBundle.loadString('assets/models/labels.txt');
      _classNames =
          labels.split('\n').where((name) => name.isNotEmpty).toList();

      // Debug info
      print('✅ Model loaded with ${_classNames.length} classes');
      print('🧠 Input tensor type: ${_interpreter.getInputTensor(0).type}');
      print('🧠 Output tensor type: ${_interpreter.getOutputTensor(0).type}');
    } catch (e) {
      print('❌ Failed to load model: $e');
    }
  }

  /// Predict the class of an image using the loaded model
  Future<FoodPrediction?> predictImage(File imageFile) async {
    try {
      // Decode image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Resize to 224x224 (same as model input)
      final resizedImage = img.copyResize(image, width: 224, height: 224);

      // Prepare input array as uint8 (not float)
      List<List<List<List<int>>>> inputArray = List.generate(
          1,
          (_) => List.generate(224,
              (_) => List.generate(224, (_) => List.generate(3, (_) => 0))));

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);

          // For quantized (uint8) model → use raw RGB values (0–255)
          inputArray[0][y][x][0] = pixel.r.toInt();
          inputArray[0][y][x][1] = pixel.g.toInt();
          inputArray[0][y][x][2] = pixel.b.toInt();
        }
      }

      // Prepare output buffer
      var output =
          List.filled(_classNames.length, 0).reshape([1, _classNames.length]);

      // Run inference
      _interpreter.run(inputArray, output);

      // Convert output to double for confidence comparison
      final outputList = output[0].map((e) => e.toDouble()).toList();

      // Find the class with max confidence
      int maxIndex = 0;
      double maxConfidence = outputList[0];
      for (int i = 1; i < outputList.length; i++) {
        if (outputList[i] > maxConfidence) {
          maxConfidence = outputList[i];
          maxIndex = i;
        }
      }

      // Return prediction result
      return FoodPrediction(
        dishName: _classNames[maxIndex],
        confidence: maxConfidence,
      );
    } catch (e) {
      print('❌ Prediction error: $e');
      return null;
    }
  }

  /// Dispose interpreter
  void dispose() {
    _interpreter.close();
  }
}
