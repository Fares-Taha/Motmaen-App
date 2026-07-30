class MealRecord {
  int? id;
  String mealName;
  double calories;
  double carbohydrates;
  String giScore; // Low, Medium, High
  String mealType; // Breakfast, Lunch, Dinner, Snack
  DateTime dateTime;
  String? imagePath;
  String? predictedFood;

  MealRecord({
    this.id,
    required this.mealName,
    required this.calories,
    required this.carbohydrates,
    required this.giScore,
    required this.mealType,
    required this.dateTime,
    this.imagePath,
    this.predictedFood,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mealName': mealName,
      'calories': calories,
      'carbohydrates': carbohydrates,
      'giScore': giScore,
      'mealType': mealType,
      'dateTime': dateTime.toIso8601String(),
      'imagePath': imagePath,
      'predictedFood': predictedFood,
    };
  }

  factory MealRecord.fromMap(Map<String, dynamic> map) {
    return MealRecord(
      id: map['id'],
      mealName: map['mealName'],
      calories: map['calories'],
      carbohydrates: map['carbohydrates'],
      giScore: map['giScore'],
      mealType: map['mealType'],
      dateTime: DateTime.parse(map['dateTime']),
      imagePath: map['imagePath'],
      predictedFood: map['predictedFood'],
    );
  }
}