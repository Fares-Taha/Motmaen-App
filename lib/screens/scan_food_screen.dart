import 'package:flutter/material.dart';
import 'package:motmaen/services/image_picker_service.dart';
import 'package:motmaen/services/tflite_service.dart';
import 'package:motmaen/models/food_prediction.dart';

class ScanFoodScreen extends StatefulWidget {
  const ScanFoodScreen({super.key});

  @override
  State<ScanFoodScreen> createState() => _ScanFoodScreenState();
}

class _ScanFoodScreenState extends State<ScanFoodScreen> {
  final ImagePickerService _imagePicker = ImagePickerService();
  final TFLiteService _tfliteService = TFLiteService();
  
  FoodPrediction? _prediction;
  bool _isLoading = false;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _tfliteService.loadModel();
    setState(() {
      _modelLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Take a photo of your food to get instant GI analysis',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            _buildScanOptions(),
            const SizedBox(height: 10),
            if (_isLoading) _buildProgressIndicator(),
            if (_prediction != null) _buildPredictionResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(
              Icons.camera_alt,
              size: 60,
              color: Color(0xFF28BAA8),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose how to scan your food',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Get instant GI score and nutritional information',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            if (!_modelLoaded)
              const Column(
                children: [
                  LinearProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Loading AI model...'),
                ],
              )
            else ...[
              _buildScanButton(
                'Take Photo',
                Icons.camera_alt,
                _takePhoto,
              ),
              const SizedBox(height: 16),
              _buildScanButton(
                'Choose from Gallery',
                Icons.photo_library,
                _pickFromGallery,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Analyzing Food...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Please wait while we analyze your food',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPredictionResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prediction Result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.restaurant, color: Colors.blue),
              title: Text(
                _prediction!.dishName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Confidence: ${(_prediction!.confidence * 1).toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(height: 16),
            _buildGiInfo(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildGiInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GI Information:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGiIndicator('Low GI', Colors.green),
            const SizedBox(width: 8),
            _buildGiIndicator('Medium GI', Colors.orange),
            const SizedBox(width: 8),
            _buildGiIndicator('High GI', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildGiIndicator(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _prediction = null;
              });
            },
            child: const Text('Scan Again'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to add meal screen with prediction data
            },
            child: const Text('Add to Diary'),
          ),
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    final file = await _imagePicker.takePhotoWithCamera();
    if (file != null) {
      await _analyzeImage(file);
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _imagePicker.pickImageFromGallery();
    if (file != null) {
      await _analyzeImage(file);
    }
  }

  Future<void> _analyzeImage(file) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prediction = await _tfliteService.predictImage(file);
      setState(() {
        _prediction = prediction;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}