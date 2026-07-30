// dashboard_screen.dart - Updated with recent meals sync
import 'package:flutter/material.dart';
import 'add_meal_screen.dart';
import 'add_glucose_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'scan_food_screen.dart';
import 'package:motmaen/services/user_service.dart';
import 'package:motmaen/services/database_helper.dart';
import 'package:motmaen/models/glucose_record.dart';
import 'package:motmaen/models/meal_record.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final UserService _userService = UserService();
  String userName = 'User'; // Default name

  // In dashboard_screen.dart - update the initState
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    // Force reload the current user to ensure we have the latest data
    await _userService.loadCurrentUser();
    final user = _userService.currentUser;
    
    if (user != null) {
      setState(() {
        userName = _getFirstName(user.fullName);
      });
    }
  }

  String _getFirstName(String fullName) {
    // Extract first name from full name
    return fullName.split(' ').first;
  }

  final List<Widget> _screens = [
    const DashboardHome(),
    const ReportsScreen(),
    const ScanFoodScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final UserService _userService = UserService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  String _userName = 'User';
  bool _isLoading = true;
  
  // Glucose data
  double? _todayAverage;
  double? _weeklyAverage;
  double? _trend;
  int _todayRecords = 0;
  int _weeklyRecords = 0;
  Map<String, double> _weeklyAverages = {};
  List<GlucoseRecord> _recentGlucose = [];
  
  // Meal data
  List<MealRecord> _recentMeals = [];
  double _todayCalories = 0;
  double _todayCarbs = 0;
  int _todayMealCount = 0;
  // Map<String, int> _todayMealCounts = {};
  Map<String, int> _todayGiCounts = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await _userService.loadCurrentUser();
    final user = _userService.currentUser;
    
    if (user != null) {
      setState(() {
        _userName = _getFirstName(user.fullName);
      });
    }
    
    await _loadGlucoseData();
    await _loadMealData();
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadGlucoseData() async {
    try {
      final userId = await _userService.getCurrentUserId();
      if (userId == null) return;

      // Load glucose stats
      final stats = await _dbHelper.getGlucoseStats(userId);
      setState(() {
        _todayAverage = stats['todayAverage'];
        _weeklyAverage = stats['weeklyAverage'];
        _trend = stats['trend'];
        _todayRecords = stats['todayRecords'];
        _weeklyRecords = stats['weeklyRecords'];
      });

      // Load weekly averages for chart
      final weeklyAverages = await _dbHelper.getWeeklyGlucoseAverages(userId);
      setState(() {
        _weeklyAverages = weeklyAverages;
      });

      // Load recent glucose records
      final recentGlucose = await _dbHelper.getRecentGlucoseRecords(userId, days: 7);
      setState(() {
        _recentGlucose = recentGlucose;
      });
    } catch (e) {
      print('Error loading glucose data: $e');
    }
  }

  Future<void> _loadMealData() async {
    try {
      final userId = await _userService.getCurrentUserId();
      if (userId == null) return;

      // Load recent meals
      final recentMeals = await _dbHelper.getRecentMealRecords(userId, limit: 3);
      setState(() {
        _recentMeals = recentMeals;
      });

      // Load today's nutrition summary
      final nutritionSummary = await _dbHelper.getTodayNutritionSummary(userId);
      setState(() {
        _todayCalories = nutritionSummary['totalCalories'] ?? 0;
        _todayCarbs = nutritionSummary['totalCarbs'] ?? 0;
        _todayMealCount = nutritionSummary['mealCount'] ?? 0;
        _todayGiCounts = nutritionSummary['giCounts'] ?? {};
      });
    } catch (e) {
      print('Error loading meal data: $e');
    }
  }

  String _getFirstName(String fullName) {
    return fullName.split(' ').first;
  }

  void _refreshDashboard() {
    setState(() {
      _isLoading = true;
    });
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading
            ? const Text('Hello...')
            : Text(
                'Hello, $_userName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlucoseProgress(),
            const SizedBox(height: 10),
            _buildNutritionSummary(),
            const SizedBox(height: 15),
            _buildQuickActions(context),
            const SizedBox(height: 10),
            _buildRecentReadings(),
            const SizedBox(height: 10),
            _buildRecentMeals(),
            const SizedBox(height: 10),
            _buildKeyStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlucoseProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Glucose Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Glucose Levels',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _todayAverage != null 
                        ? '${_todayAverage!.toStringAsFixed(0)} mg/dL'
                        : 'No data',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getGlucoseColor(_todayAverage),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_trend != null)
                      Row(
                        children: [
                          Icon(
                            _trend! >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: _trend! >= 0 ? Colors.red : Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last 7 Days ${_trend!.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: _trend! >= 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Add more data to see trends',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.bloodtype, size: 40, color: Colors.red),
                    if (_todayRecords > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _todayRecords.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeeklyChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) {
            final average = _weeklyAverages[day];
            return _buildDayColumn(day, average);
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _weeklyRecords == 0 
            ? 'No glucose data for this week'
            : 'Based on $_weeklyRecords reading${_weeklyRecords == 1 ? '' : 's'} this week',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDayColumn(String day, double? average) {
    const maxHeight = 40.0;
    final height = average != null 
      ? (average / 200).clamp(0.1, 1.0) * maxHeight // Normalize to 200 mg/dL max
      : 0.0;
    
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 20,
          height: maxHeight,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 20,
              height: height,
              decoration: BoxDecoration(
                color: _getGlucoseColor(average),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          average != null ? average.toStringAsFixed(0) : '-',
          style: TextStyle(
            fontSize: 10,
            color: _getGlucoseColor(average),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getGlucoseColor(double? glucose) {
    if (glucose == null) return Colors.grey;
    
    if (glucose < 70) return Colors.orange; // Low
    if (glucose <= 140) return Colors.green; // Normal
    if (glucose <= 180) return Colors.orange; // High
    return Colors.red; // Very High
  }

  Widget _buildNutritionSummary() {
    final user = _userService.currentUser;
    final targetCalories = user?.dailyCaloriesTarget ?? 2000;
    final calorieProgress = _todayCalories / targetCalories;
    
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
            
            // Calorie Progress
            _buildCalorieProgress(calorieProgress, targetCalories),
            const SizedBox(height: 16),
            
            // Nutrition Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutritionStat(
                  'Calories',
                  '${_todayCalories.toInt()} / $targetCalories',
                  Icons.local_fire_department,
                  Colors.red,
                ),
                _buildNutritionStat(
                  'Carbs',
                  '${_todayCarbs.toInt()} g',
                  Icons.grain,
                  Colors.orange,
                ),
                _buildNutritionStat(
                  'Meals',
                  '$_todayMealCount',
                  Icons.restaurant,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // GI Score Distribution
            if (_todayGiCounts.isNotEmpty) _buildGiDistribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieProgress(double progress, int target) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Calorie Intake',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${_todayCalories.toInt()}/$target kcal',
              style: TextStyle(
                color: progress >= 1 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          color: progress >= 1 
              ? Colors.red 
              : progress >= 0.8 
                ? Colors.orange 
                : Colors.green,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          progress >= 1 
            ? 'Over target by ${(_todayCalories - target).toInt()} kcal'
            : '${(target - _todayCalories).toInt()} kcal remaining',
          style: TextStyle(
            fontSize: 12,
            color: progress >= 1 ? Colors.red : Colors.grey,
          ),
        ),
      ],
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
            fontSize: 14,
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

  Widget _buildGiDistribution() {
    final totalMeals = _todayGiCounts.values.fold(0, (sum, count) => sum + count);
    if (totalMeals == 0) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GI Score Distribution',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGiIndicator('Low', _todayGiCounts['Low'] ?? 0, totalMeals, Colors.green),
            const SizedBox(width: 8),
            _buildGiIndicator('Medium', _todayGiCounts['Medium'] ?? 0, totalMeals, Colors.orange),
            const SizedBox(width: 8),
            _buildGiIndicator('High', _todayGiCounts['High'] ?? 0, totalMeals, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildGiIndicator(String type, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0;
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              type,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReadings() {
    if (_recentGlucose.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Column(
            children: [
              const Icon(Icons.bloodtype, size: 50, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No Glucose Readings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your first glucose reading to see your progress',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddGlucoseScreen()),
                  );
                },
                child: const Text('Add First Reading'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30),
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
            Column(
              children: _recentGlucose.take(3).map((record) => _buildReadingItem(record)).toList(),
            ),
            if (_recentGlucose.length > 3)
              TextButton(
                onPressed: () {
                  // Navigate to reports screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportsScreen()),
                  );
                },
                child: const Text('View All Readings'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingItem(GlucoseRecord record) {
    return ListTile(
      leading: Icon(
        Icons.bloodtype,
        color: _getGlucoseColor(record.glucoseLevel),
      ),
      title: Text('${record.glucoseLevel} mg/dL'),
      subtitle: Text('${record.measurementTime} • ${_formatTime(record.dateTime)}'),
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

  Widget _buildRecentMeals() {
    if (_recentMeals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Column(
            children: [
              const Icon(Icons.restaurant, size: 50, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No Meals Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your first meal to track your nutrition',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddMealScreen()),
                  );
                },
                child: const Text('Add First Meal'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Meals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$_todayMealCount today',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: _recentMeals.map((meal) => _buildMealItem(meal)).toList(),
            ),
            if (_todayMealCount > 3)
              TextButton(
                onPressed: () {
                  // Navigate to meal history or reports screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportsScreen()),
                  );
                },
                child: const Text('View All Meals'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(MealRecord meal) {
    return ListTile(
      leading: _getMealTypeIcon(meal.mealType),
      title: Text(meal.mealName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${meal.calories.toInt()} kcal • ${meal.carbohydrates.toInt()}g carbs'),
          Text(
            '${meal.mealType} • ${_getGiScoreText(meal.giScore)}',
            style: TextStyle(
              color: _getGiScoreColor(meal.giScore),
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: Text(
        _formatTime(meal.dateTime),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _getMealTypeIcon(String mealType) {
    final icon = switch (mealType) {
      'Breakfast' => Icons.breakfast_dining,
      'Lunch' => Icons.lunch_dining,
      'Dinner' => Icons.dinner_dining,
      'Snack' => Icons.local_cafe,
      _ => Icons.restaurant,
    };
    
    final color = switch (mealType) {
      'Breakfast' => Colors.orange,
      'Lunch' => Colors.green,
      'Dinner' => Colors.blue,
      'Snack' => Colors.purple,
      _ => Colors.grey,
    };
    
    return Icon(icon, color: color);
  }

  String _getGiScoreText(String giScore) {
    return switch (giScore) {
      'Low' => 'Low GI',
      'Medium' => 'Medium GI',
      'High' => 'High GI',
      _ => giScore,
    };
  }

  Color _getGiScoreColor(String giScore) {
    return switch (giScore) {
      'Low' => Colors.green,
      'Medium' => Colors.orange,
      'High' => Colors.red,
      _ => Colors.grey,
    };
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDate = DateTime(date.year, date.month, date.day);
    
    if (mealDate.isAtSameMomentAs(today)) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Meal',
                Icons.restaurant,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddMealScreen()),
                  ).then((_) {
                    // Refresh data when returning from adding meal
                    _refreshDashboard();
                  });
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _buildActionCard(
                'Add Glucose',
                Icons.bloodtype,
                Colors.red,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddGlucoseScreen()),
                  ).then((_) {
                    // Refresh data when returning from adding glucose
                    _refreshDashboard();
                  });
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _buildActionCard(
                'Scan Food',
                Icons.camera_alt,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanFoodScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyStats() {
    final user = _userService.currentUser;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  'Weekly Glucose',
                  _weeklyAverage != null ? '${_weeklyAverage!.toStringAsFixed(0)} mg/dL' : 'No data',
                  Icons.timeline,
                  _getGlucoseColor(_weeklyAverage),
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  'Today\'s Meals',
                  '$_todayMealCount meal${_todayMealCount == 1 ? '' : 's'}',
                  Icons.restaurant,
                  _todayMealCount > 0 ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(
                  'Calories Today',
                  '${_todayCalories.toInt()} kcal',
                  Icons.local_fire_department,
                  _todayCalories > 0 ? Colors.orange : Colors.grey,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  'Target Range',
                  user != null ? '${user.targetGlucoseMin}-${user.targetGlucoseMax} mg/dL' : '80-120 mg/dL',
                  Icons.flag,
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 14,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showActivityDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Add Activity'),
  //       content: const Text('Activity tracking feature coming soon!'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}