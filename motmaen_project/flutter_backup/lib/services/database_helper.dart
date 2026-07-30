// database_helper.dart - FIXED with proper transaction handling
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/glucose_record.dart';
import '../models/meal_record.dart';
import '../models/emergency_contact.dart';

class DatabaseHelper {
  static Database? _database;
  static const int _databaseVersion = 6; // Increment version to fix emergency_contacts migration

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<void> forceDatabaseReset() async {
    await deleteDatabaseFile();
    _database = null;
    await initDatabase();
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'motmaen.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        targetGlucoseMin REAL NOT NULL,
        targetGlucoseMax REAL NOT NULL,
        dailyCaloriesTarget INTEGER NOT NULL,
        memberSince TEXT NOT NULL,
        phoneNumber TEXT,
        emergencyContact TEXT,
        medicalConditions TEXT,
        medications TEXT,
        profilePhotoPath TEXT,
        allergies TEXT,
        bloodType TEXT,
        insuranceInfo TEXT,
        doctorName TEXT,
        doctorPhone TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE glucose_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        glucoseLevel REAL NOT NULL,
        measurementTime TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE meal_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        mealName TEXT NOT NULL,
        calories REAL NOT NULL,
        carbohydrates REAL NOT NULL,
        giScore TEXT NOT NULL,
        mealType TEXT NOT NULL,
        dateTime TEXT NOT NULL,
        imagePath TEXT,
        predictedFood TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE emergency_contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL,
        phone TEXT NOT NULL,
        isPrimary INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _migrateToVersion(db, version);
    }
  }

  Future<void> _migrateToVersion(Database db, int version) async {
    switch (version) {
      case 2:
        await _migrateToV2(db);
        break;
      case 3:
        await _migrateToV3(db);
        break;
      case 4:
        await _migrateToV4(db);
        break;
      case 5:
        await _migrateToV5(db);
        break;
      case 6:
        await _migrateToV6(db);
        break;
    }
  }

  Future<void> _migrateToV2(Database db) async {
    if (!await _doesColumnExist(db, 'users', 'phoneNumber')) {
      await db.execute('ALTER TABLE users ADD COLUMN phoneNumber TEXT');
    }
    if (!await _doesColumnExist(db, 'users', 'emergencyContact')) {
      await db.execute('ALTER TABLE users ADD COLUMN emergencyContact TEXT');
    }
    if (!await _doesColumnExist(db, 'users', 'medicalConditions')) {
      await db.execute('ALTER TABLE users ADD COLUMN medicalConditions TEXT');
    }
    if (!await _doesColumnExist(db, 'users', 'medications')) {
      await db.execute('ALTER TABLE users ADD COLUMN medications TEXT');
    }
  }

  Future<void> _migrateToV3(Database db) async {
    if (!await _doesColumnExist(db, 'users', 'profilePhotoPath')) {
      await db.execute('ALTER TABLE users ADD COLUMN profilePhotoPath TEXT');
    }
  }

  Future<void> _migrateToV4(Database db) async {
    if (!await _doesColumnExist(db, 'users', 'allergies')) {
      await db.execute('ALTER TABLE users ADD COLUMN allergies TEXT');
    }
    if (!await _doesColumnExist(db, 'users', 'bloodType')) {
      await db.execute('ALTER TABLE users ADD COLUMN bloodType TEXT');
    }
    if (!await _doesColumnExist(db, 'users', 'insuranceInfo')) {
      await db.execute('ALTER TABLE users ADD COLUMN insuranceInfo TEXT');
    }
    if (!await _doesColumnExist(db, 'users', 'doctorName')) {
      await db.execute('ALTER TABLE users ADD COLUMN doctorName TEXT');
    }
    if (!await _doesColumnExist(db, 'users', 'doctorPhone')) {
      await db.execute('ALTER TABLE users ADD COLUMN doctorPhone TEXT');
    }

    if (!await _tableExists(db, 'emergency_contacts')) {
      await db.execute('''
        CREATE TABLE emergency_contacts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          relationship TEXT NOT NULL,
          phone TEXT NOT NULL,
          isPrimary INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> _migrateToV5(Database db) async {
    // Add user_id to glucose_records if it doesn't exist
    if (!await _doesColumnExist(db, 'glucose_records', 'user_id')) {
      await db.execute('ALTER TABLE glucose_records ADD COLUMN user_id INTEGER');
      // Set default user_id for existing records (will be cleaned up later)
      await db.update('glucose_records', {'user_id': 1});
    }

    // Add user_id to meal_records if it doesn't exist
    if (!await _doesColumnExist(db, 'meal_records', 'user_id')) {
      await db.execute('ALTER TABLE meal_records ADD COLUMN user_id INTEGER');
      // Set default user_id for existing records
      await db.update('meal_records', {'user_id': 1});
    }

    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _migrateToV6(Database db) async {
    // FIX: Ensure emergency_contacts table has user_id column and proper structure
    bool hasUserIdColumn = await _doesColumnExist(db, 'emergency_contacts', 'user_id');
    
    if (!hasUserIdColumn) {
      print('🔄 Fixing emergency_contacts table structure...');
      
      // Create a temporary table with the correct structure
      await db.execute('''
        CREATE TABLE emergency_contacts_temp(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          relationship TEXT NOT NULL,
          phone TEXT NOT NULL,
          isPrimary INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      
      // Copy data from old table to new table, setting user_id to 1 for existing records
      try {
        final List<Map<String, dynamic>> oldContacts = await db.query('emergency_contacts');
        
        for (final contact in oldContacts) {
          await db.insert('emergency_contacts_temp', {
            ...contact,
            'user_id': 1, // Set default user_id for existing records
          });
        }
      } catch (e) {
        print('⚠️ No existing emergency contacts to migrate: $e');
      }
      
      // Drop the old table
      await db.execute('DROP TABLE emergency_contacts');
      
      // Rename the temporary table
      await db.execute('ALTER TABLE emergency_contacts_temp RENAME TO emergency_contacts');
      
      print('✅ Successfully fixed emergency_contacts table structure');
    }
    
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    try {
      await db.rawQuery('SELECT 1 FROM $tableName LIMIT 1');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _doesColumnExist(Database db, String tableName, String columnName) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info($tableName)');
      return columns.any((column) => column['name'] == columnName);
    } catch (e) {
      return false;
    }
  }

  // Add this overloaded method that works with both Database and Transaction
  Future<bool> _doesColumnExistForTransaction(dynamic db, String tableName, String columnName) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info($tableName)');
      return columns.any((column) => column['name'] == columnName);
    } catch (e) {
      return false;
    }
  }

  // User operations
  Future<int> insertUser(UserProfile user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserProfile?> getUser(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<UserProfile?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<UserProfile?> getCurrentUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(UserProfile user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<bool> doesEmailExist(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  // Emergency Contact operations
  Future<int> insertEmergencyContact(EmergencyContact contact, int userId) async {
    final db = await database;
    
    // If setting as primary, unset other primary contacts for this user
    if (contact.isPrimary) {
      await db.update(
        'emergency_contacts',
        {'isPrimary': 0},
        where: 'isPrimary = 1 AND user_id = ?',
        whereArgs: [userId],
      );
    }
    
    final map = contact.toMap();
    map['user_id'] = userId;
    
    return await db.insert('emergency_contacts', map);
  }

  Future<List<EmergencyContact>> getEmergencyContacts(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'emergency_contacts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'isPrimary DESC, name ASC',
    );
    return List.generate(maps.length, (i) => EmergencyContact.fromMap(maps[i]));
  }

  Future<EmergencyContact?> getPrimaryEmergencyContact(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'emergency_contacts',
      where: 'isPrimary = 1 AND user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return EmergencyContact.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateEmergencyContact(EmergencyContact contact, int userId) async {
    final db = await database;
    
    // If setting as primary, unset other primary contacts for this user
    if (contact.isPrimary) {
      await db.update(
        'emergency_contacts',
        {'isPrimary': 0},
        where: 'isPrimary = 1 AND user_id = ? AND id != ?',
        whereArgs: [userId, contact.id],
      );
    }
    
    final map = contact.toMap();
    map['user_id'] = userId;
    
    return await db.update(
      'emergency_contacts',
      map,
      where: 'id = ? AND user_id = ?',
      whereArgs: [contact.id, userId],
    );
  }

  Future<int> deleteEmergencyContact(int id, int userId) async {
    final db = await database;
    return await db.delete(
      'emergency_contacts',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  Future<int> setPrimaryContact(int id, int userId) async {
    final db = await database;
    
    // First, unset all primary contacts for this user
    await db.update(
      'emergency_contacts',
      {'isPrimary': 0},
      where: 'isPrimary = 1 AND user_id = ?',
      whereArgs: [userId],
    );
    
    // Then set the new primary contact
    return await db.update(
      'emergency_contacts',
      {'isPrimary': 1},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // Glucose operations
  Future<int> insertGlucoseRecord(GlucoseRecord record, int userId) async {
    final db = await database;
    final map = record.toMap();
    map['user_id'] = userId;
    return await db.insert('glucose_records', map);
  }

  Future<List<GlucoseRecord>> getGlucoseRecords(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'glucose_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'dateTime DESC',
    );
    return List.generate(maps.length, (i) => GlucoseRecord.fromMap(maps[i]));
  }

  Future<List<GlucoseRecord>> getRecentGlucoseRecords(int userId, {int days = 7}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'glucose_records',
      where: 'user_id = ? AND dateTime >= ?',
      whereArgs: [userId, cutoffDate.toIso8601String()],
      orderBy: 'dateTime DESC',
    );
    
    return List.generate(maps.length, (i) => GlucoseRecord.fromMap(maps[i]));
  }

  Future<double?> getAverageGlucose(int userId, {int days = 7}) async {
    final records = await getRecentGlucoseRecords(userId, days: days);
    if (records.isEmpty) return null;
    
    final total = records.fold(0.0, (sum, record) => sum + record.glucoseLevel);
    return total / records.length;
  }

  Future<Map<String, double>> getWeeklyGlucoseAverages(int userId) async {
    final records = await getRecentGlucoseRecords(userId, days: 7);
    final Map<String, List<double>> dailyAverages = {};
    
    for (final record in records) {
      final day = _getDayName(record.dateTime.weekday);
      dailyAverages.putIfAbsent(day, () => []).add(record.glucoseLevel);
    }
    
    final Map<String, double> result = {};
    for (final entry in dailyAverages.entries) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      result[entry.key] = double.parse(average.toStringAsFixed(1));
    }
    
    // Fill missing days with 0
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (final day in days) {
      result.putIfAbsent(day, () => 0.0);
    }
    
    return result;
  }

  Future<List<GlucoseRecord>> getTodayGlucoseRecords(int userId) async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'glucose_records',
      where: 'user_id = ? AND dateTime BETWEEN ? AND ?',
      whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'dateTime DESC',
    );
    
    return List.generate(maps.length, (i) => GlucoseRecord.fromMap(maps[i]));
  }

  Future<Map<String, dynamic>> getGlucoseStats(int userId) async {
    final todayRecords = await getTodayGlucoseRecords(userId);
    final weeklyAverage = await getAverageGlucose(userId, days: 7);
    final lastWeekAverage = await getAverageGlucose(userId, days: 14);
    
    double? todayAverage;
    if (todayRecords.isNotEmpty) {
      final total = todayRecords.fold(0.0, (sum, record) => sum + record.glucoseLevel);
      todayAverage = total / todayRecords.length;
    }
    
    double? trend;
    if (weeklyAverage != null && lastWeekAverage != null && lastWeekAverage > 0) {
      trend = ((weeklyAverage - lastWeekAverage) / lastWeekAverage) * 100;
    }
    
    final weeklyRecords = await getRecentGlucoseRecords(userId, days: 7);
    
    return {
      'todayAverage': todayAverage,
      'weeklyAverage': weeklyAverage,
      'trend': trend,
      'todayRecords': todayRecords.length,
      'weeklyRecords': weeklyRecords.length,
    };
  }

  // Meal operations
  Future<int> insertMealRecord(MealRecord record, int userId) async {
    final db = await database;
    final map = record.toMap();
    map['user_id'] = userId;
    return await db.insert('meal_records', map);
  }

  Future<List<MealRecord>> getMealRecords(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meal_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'dateTime DESC',
    );
    return List.generate(maps.length, (i) => MealRecord.fromMap(maps[i]));
  }

  Future<List<MealRecord>> getRecentMealRecords(int userId, {int limit = 5}) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'meal_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'dateTime DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) => MealRecord.fromMap(maps[i]));
  }

  Future<List<MealRecord>> getTodayMeals(int userId) async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
      'meal_records',
      where: 'user_id = ? AND dateTime BETWEEN ? AND ?',
      whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'dateTime DESC',
    );
    return List.generate(maps.length, (i) => MealRecord.fromMap(maps[i]));
  }

  Future<Map<String, dynamic>> getTodayNutritionSummary(int userId) async {
    final todayMeals = await getTodayMeals(userId);
    
    final totalCalories = todayMeals.fold(0.0, (sum, meal) => sum + meal.calories);
    final totalCarbs = todayMeals.fold(0.0, (sum, meal) => sum + meal.carbohydrates);
    
    final mealCounts = <String, int>{};
    for (final meal in todayMeals) {
      mealCounts[meal.mealType] = (mealCounts[meal.mealType] ?? 0) + 1;
    }
    
    final giCounts = <String, int>{'Low': 0, 'Medium': 0, 'High': 0};
    for (final meal in todayMeals) {
      if (giCounts.containsKey(meal.giScore)) {
        giCounts[meal.giScore] = giCounts[meal.giScore]! + 1;
      }
    }
    
    return {
      'totalCalories': totalCalories,
      'totalCarbs': totalCarbs,
      'mealCount': todayMeals.length,
      'mealCounts': mealCounts,
      'giCounts': giCounts,
      'meals': todayMeals,
    };
  }

  Future<Map<String, double>> getWeeklyCalorieAverages(int userId) async {
    final db = await database;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'meal_records',
      where: 'user_id = ? AND dateTime >= ?',
      whereArgs: [userId, weekAgo.toIso8601String()],
    );
    
    final Map<String, List<double>> dailyCalories = {};
    
    for (final map in maps) {
      final meal = MealRecord.fromMap(map);
      final day = _formatDate(meal.dateTime);
      dailyCalories.putIfAbsent(day, () => []).add(meal.calories);
    }
    
    final Map<String, double> result = {};
    for (final entry in dailyCalories.entries) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      result[entry.key] = double.parse(average.toStringAsFixed(0));
    }
    
    return result;
  }

  // Data management operations - FIXED with proper transaction handling
  Future<void> clearAllData() async {
    final db = await database;
    
    // Delete all data from all tables
    await db.delete('users');
    await db.delete('glucose_records');
    await db.delete('meal_records');
    await db.delete('emergency_contacts');
    
    print('✅ All data cleared successfully');
  }

  Future<void> deleteUserData(int userId) async {
    final db = await database;
    
    try {
      // Use transaction for atomic operations
      await db.transaction((txn) async {
        // Delete user-specific data from all tables
        await txn.delete(
          'glucose_records',
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        
        await txn.delete(
          'meal_records',
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        
        // Check if emergency_contacts table has user_id column before using it
        final hasUserIdColumn = await _doesColumnExistForTransaction(txn, 'emergency_contacts', 'user_id');
        
        if (hasUserIdColumn) {
          await txn.delete(
            'emergency_contacts',
            where: 'user_id = ?',
            whereArgs: [userId],
          );
        } else {
          // If no user_id column exists, delete all emergency contacts (legacy data)
          await txn.delete('emergency_contacts');
        }
        
        await txn.delete(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
        );
      });
      
      print('✅ User $userId data deleted successfully');
    } catch (e) {
      print('❌ Error deleting user data: $e');
      rethrow;
    }
  }

  Future<void> deleteDatabaseFile() async {
    await _database?.close();
    _database = null;
    
    String path = join(await getDatabasesPath(), 'motmaen.db');
    await deleteDatabase(path);
    
    print('✅ Database file deleted successfully');
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.close();
    String path = join(await getDatabasesPath(), 'motmaen.db');
    await deleteDatabase(path);
    _database = null;
    await initDatabase();
  }

  // Helper methods
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  // Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}