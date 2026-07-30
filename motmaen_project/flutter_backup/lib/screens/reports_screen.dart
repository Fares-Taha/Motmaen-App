import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:motmaen/services/database_helper.dart';
import 'package:motmaen/models/glucose_record.dart';
import 'package:motmaen/models/meal_record.dart';
import 'package:motmaen/services/user_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<GlucoseRecord> _glucoseRecords = [];
  List<MealRecord> _mealRecords = [];
  bool _isLoading = true;
  String _selectedPeriod = 'Weekly';
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = await _userService.getCurrentUserId();
      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final glucoseRecords = await DatabaseHelper().getGlucoseRecords(userId);
      final mealRecords = await DatabaseHelper().getMealRecords(userId);
      
      setState(() {
        _glucoseRecords = glucoseRecords;
        _mealRecords = mealRecords;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 10),
                  _buildGlucoseChart(),
                  const SizedBox(height: 10),
                  _buildNutritionSummary(),
                  const SizedBox(height: 10),
                  _buildRecentReadings(),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPeriodButton('Daily', _selectedPeriod == 'Daily'),
        _buildPeriodButton('Weekly', _selectedPeriod == 'Weekly'),
        _buildPeriodButton('Monthly', _selectedPeriod == 'Monthly'),
      ],
    );
  }

  Widget _buildPeriodButton(String period, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedPeriod = period;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
            foregroundColor: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            elevation: isSelected ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            side: isSelected 
                ? null 
                : BorderSide(
                    color: theme.dividerTheme.color ?? const Color(0xFFE0E0E0),
                    width: 1,
                  ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            period,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlucoseChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Glucose Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _glucoseRecords.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.show_chart, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No glucose data available'),
                        ],
                      ),
                    )
                  : SfCartesianChart(
                      primaryXAxis: DateTimeAxis(),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'mg/dL'),
                      ),
                      series: <LineSeries<GlucoseData, DateTime>>[
                        LineSeries<GlucoseData, DateTime>(
                          dataSource: _glucoseRecords
                              .map((record) => GlucoseData(record.dateTime, record.glucoseLevel))
                              .toList(),
                          xValueMapper: (GlucoseData data, _) => data.date,
                          yValueMapper: (GlucoseData data, _) => data.level,
                          color: Color(0xFF28BAA8),
                          markerSettings: const MarkerSettings(isVisible: true),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSummary() {
    final todayMeals = _mealRecords.where((meal) => 
        meal.dateTime.day == DateTime.now().day).toList();
    
    final totalCalories = todayMeals.fold(0.0, (sum, meal) => sum + meal.calories);
    final totalCarbs = todayMeals.fold(0.0, (sum, meal) => sum + meal.carbohydrates);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Nutrition",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutritionStat('Calories', '${totalCalories.toInt()} kcal', Icons.local_fire_department, Colors.red),
                _buildNutritionStat('Carbs', '${totalCarbs.toInt()} g', Icons.grain, Colors.orange),
                _buildNutritionStat('Meals', '${todayMeals.length}', Icons.restaurant, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionStat(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReadings() {
    final recentGlucose = _glucoseRecords.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Readings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (recentGlucose.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.bloodtype, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No recent readings'),
                    SizedBox(height: 8),
                  ],
                ),
              )
            else
              Column(
                children: recentGlucose.map((record) => _buildReadingItem(record)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingItem(GlucoseRecord record) {
    return ListTile(
      leading: const Icon(Icons.bloodtype, color: Colors.red),
      title: Text('${record.glucoseLevel} mg/dL'),
      subtitle: Text('${record.measurementTime} • ${_formatDate(record.dateTime)}'),
      trailing: _getGlucoseStatusIcon(record.glucoseLevel),
    );
  }

  Widget _getGlucoseStatusIcon(double level) {
    if (level < 70) {
      return const Icon(Icons.warning, color: Colors.orange);
    } else if (level > 180) {
      return const Icon(Icons.warning, color: Colors.red);
    } else {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class GlucoseData {
  final DateTime date;
  final double level;

  GlucoseData(this.date, this.level);
}